#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <stdatomic.h>
#include <stdbool.h>
#include <assert.h>
#include <string.h>

#define BLOCK_SIZE (1024 * 16)
#define THREAD_NUMBER 8

#define SIGN_CHANCE 25
#define MAX_VALUE 10000

#define ITERATION 50

typedef struct
{
    atomic_int flag;
    int aggregate;
    int prefix;
} Descriptor;

typedef struct
{
    int *input;
    int *output;
    int size;
    int block_count;
    atomic_int work_index;
    Descriptor *descriptors;
} Data;

int reduce_seq(int *data, int len)
{

    int acc = 0;
    for (int i = 0; i < len; i++)
    {
        acc += data[i];
    }
    return acc;
}

int scan_seq(int *data, int *scanned, int size, int prefix)
{
    int acc = prefix;
    for (int i = 0; i < size; i++)
    {
        acc = data[i] + acc;
        scanned[i] = acc;
    }
    return acc;
}

void *scan_worker(void *arg)
{
    Data *data = (Data *)arg;

    bool seq = true;
    while (1)
    {
        int block_idx = atomic_fetch_add_explicit(&data->work_index, 1, memory_order_relaxed);

        if (block_idx >= data->block_count)
        {
            pthread_exit(NULL);
        }
        int start = block_idx * BLOCK_SIZE;
        int len = BLOCK_SIZE;
        int prefix;
        if (data->size - start < len)
            len = data->size - start;
        if (seq)
        {
            if (block_idx == 0)
            {
                prefix = 0;
            }
            else
            {
                int prev_flag = atomic_load_explicit(&data->descriptors[block_idx - 1].flag, memory_order_acquire);
                if (prev_flag == 2)
                    prefix = data->descriptors[block_idx - 1].prefix;
                else
                    seq = false;
            }
        }

        if (seq)
        {
            int result_prefix = scan_seq(&data->input[start], &data->output[start], len, prefix);
            data->descriptors[block_idx].prefix = result_prefix;
            atomic_store_explicit(&data->descriptors[block_idx].flag, 2, memory_order_release);
        }
        else
        {
            int aggregate = reduce_seq(&data->input[start], len);
            data->descriptors[block_idx].aggregate = aggregate;
            atomic_store_explicit(&data->descriptors[block_idx].flag, 1, memory_order_release);
            int prefix = 0;
            int lb = block_idx - 1;
            while (1)
            {
                int flag = atomic_load_explicit(&data->descriptors[lb].flag, memory_order_acquire);
                if (flag == 2)
                {
                    prefix = prefix + data->descriptors[lb].prefix;
                    break;
                }
                else if (flag == 1)
                {
                    prefix = prefix + data->descriptors[lb].aggregate;
                    lb = lb - 1;
                }
                else
                {
                    // sched_yield();
                }
            }
            data->descriptors[block_idx].prefix = aggregate + prefix;
            atomic_store_explicit(&data->descriptors[block_idx].flag, 2, memory_order_release);
            scan_seq(&data->input[start], &data->output[start], len, prefix);
        }
    }

    pthread_exit(NULL);
}

void *roofline_worker(void *arg)
{
    Data *data = (Data *)arg;

    while (1)
    {
        int block_idx = atomic_fetch_add_explicit(&data->work_index, 1, memory_order_relaxed);
        if (block_idx >= data->block_count)
            pthread_exit(NULL);

        int start = block_idx * BLOCK_SIZE;
        int len = BLOCK_SIZE;
        if (data->size - start < len)
            len = data->size - start;
        memcpy(&data->output[start], &data->input[start], len * sizeof(int));
    }

    pthread_exit(NULL);
}

double run_threads(void *(*worker)(void *), int *input, int *output, int size)
{
    pthread_t threads[THREAD_NUMBER];

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    int block_number = (size + BLOCK_SIZE - 1) / BLOCK_SIZE;

    Data *data = (Data *)malloc(sizeof(Data));
    data->input = input;
    data->output = output;
    data->size = size;
    data->block_count = block_number;
    atomic_init(&data->work_index, 0);

    Descriptor *descriptor = (Descriptor *)malloc(block_number * sizeof(Descriptor));

    for (int i = 0; i < block_number; i++)
    {
        atomic_init(&descriptor[i].flag, 0);
        descriptor[i].aggregate = 0;
        descriptor[i].prefix = 0;
    }
    data->descriptors = descriptor;

    for (int i = 0; i < THREAD_NUMBER; i++)
    {
        if (pthread_create(&threads[i], NULL, worker, (void *)data) != 0)
        {
            printf("Error creating thread %d\n", i);
            exit(1);
        }
    }

    for (int i = 0; i < THREAD_NUMBER; i++)
        pthread_join(threads[i], NULL);



    free(descriptor);
    free(data);

    clock_gettime(CLOCK_MONOTONIC, &end);


    return (end.tv_sec - start.tv_sec) * 1e6 + (end.tv_nsec - start.tv_nsec) / 1e3;
}

int *generateData(int size)
{
    int *ptr = (int *)malloc(size * sizeof(int));
    for (int i = 0; i < size; i++)
    {
        int value = 1 + (rand() % MAX_VALUE);
        int pos = rand() % 100;
        if (pos < SIGN_CHANCE)
            value = value * -1;
        ptr[i] = value;
    }
    return ptr;
}

bool verify(int *output_paralell, int *output_seq, int size)
{
    for (int i = 0; i < size; i++)
    {
        if (output_seq[i] != output_paralell[i])
            return false;
    }
    return true;
}

int main(int argc, char *argv[])
{
    assert(argc == 2);

    int size ;
    sscanf(argv[1], "%d", &size);
    srand(time(NULL));

    int *input = (int *)malloc(size * sizeof(int));
    input = generateData(size);

    double total_parallel = 0.0;
    double total_seq = 0.0;
    double total_roofline = 0.0;
    double total_roofline_seq = 0.0;

    int *output_paralell = (int *)malloc(size * sizeof(int));
    int *output_seq = (int *)malloc(size * sizeof(int));
    int *output_roofline = (int *)malloc(size * sizeof(int));
    int *output_roofline_seq = (int *)malloc(size * sizeof(int));

    // pre touch
    for (int i = 0; i < size; i++)
    {
        output_paralell[i] = 0;
        output_seq[i] = 0;
        output_roofline[i] = 0;
        output_roofline_seq[i] = 0;
    }

    for (int j = 0; j < ITERATION; j++)
    {

        total_parallel += run_threads(scan_worker, input, output_paralell, size);

        struct timespec start_seq, end_seq;
        clock_gettime(CLOCK_MONOTONIC, &start_seq);
        scan_seq(input, output_seq, size, 0);
        clock_gettime(CLOCK_MONOTONIC, &end_seq);
        total_seq += (end_seq.tv_sec - start_seq.tv_sec) * 1e6 + (end_seq.tv_nsec - start_seq.tv_nsec) / 1e3;

        // validation for chained scan
        assert(verify(output_paralell, output_seq, size));

        total_roofline += run_threads(roofline_worker, input, output_roofline, size);

        struct timespec start_roofline_seq, end_roofline_seq;
        clock_gettime(CLOCK_MONOTONIC, &start_roofline_seq);
        memcpy(output_roofline_seq, input, size * sizeof(int));
        clock_gettime(CLOCK_MONOTONIC, &end_roofline_seq);
        total_roofline_seq += (end_roofline_seq.tv_sec - start_roofline_seq.tv_sec) * 1e6 + (end_roofline_seq.tv_nsec - start_roofline_seq.tv_nsec) / 1e3;
        assert(verify(output_roofline_seq, output_roofline, size));
    }
    double avg_seq = total_seq / ITERATION;
    double avg_parallel = total_parallel / ITERATION;
    double avg_roofline = total_roofline / ITERATION;
    double avg_roofline_seq = total_roofline_seq / ITERATION;

    printf("%f %f %f %f\n", avg_parallel, avg_seq, avg_roofline, avg_roofline_seq);

    free(output_paralell);
    free(output_seq);
    free(output_roofline);
    free(output_roofline_seq);

    return 0;
}
