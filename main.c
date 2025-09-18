#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <stdatomic.h>
#include <stdbool.h>
#include <assert.h>

#define BLOCK_SIZE (1024 * 4)
// #define BLOCK_SIZE 2
#define THREAD_NUMBER 1

#define SIGN_CHANCE 25
#define MAX_VALUE 10000

#define ITERATION 30

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

    // printf("Thread is running.\n");
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
                    sched_yield();
                }
            }
            data->descriptors[block_idx].prefix = aggregate + prefix;
            atomic_store_explicit(&data->descriptors[block_idx].flag, 2, memory_order_release);
            scan_seq(&data->input[start], &data->output[start], len, prefix);
        }
    }

    pthread_exit(NULL);
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

int main(int argc, char *argv[])
{
    assert(argc == 2);

    int size = 67108864; // 2^16
    sscanf(argv[1], "%d", &size);
    srand(time(NULL));
    pthread_t threads[THREAD_NUMBER];

    int *input = (int *)malloc(size * sizeof(int));
    input = generateData(size);

    double total = 0.0;
    for (int i = 0; i < ITERATION; i++)
    {

        // number of blocks
        int block_number = (size + BLOCK_SIZE - 1) / BLOCK_SIZE;

        Descriptor *descriptor = (Descriptor *)malloc(block_number * sizeof(Descriptor));

        Data *data = (Data *)malloc(sizeof(Data));
        atomic_init(&data->work_index, 0);
        int *output = (int *)malloc(size * sizeof(int));
        data->input = input;
        data->output = output;
        data->size = size;
        data->block_count = block_number;
        data->descriptors = descriptor;
        for (int i = 0; i < block_number; ++i)
        {
            atomic_init(&descriptor[i].flag, 0);
            descriptor[i].aggregate = 0;
            descriptor[i].prefix = 0;
        }

        struct timespec start_parallel, end_paralell;
        clock_gettime(CLOCK_MONOTONIC, &start_parallel);

        for (int i = 0; i < THREAD_NUMBER; i++)
        {
            if (pthread_create(&threads[i], NULL, scan_worker, (void *)data) != 0)
            {
                printf("Error creating thread %d\n", i);
                return 1;
            }
        }

        for (int i = 0; i < THREAD_NUMBER; i++)
        {
            pthread_join(threads[i], NULL);
        }

        clock_gettime(CLOCK_MONOTONIC, &end_paralell);
        free(descriptor);
        free(output);
        free(data);

        double elapsed = (end_paralell.tv_sec - start_parallel.tv_sec) * 1e6 + (end_paralell.tv_nsec - start_parallel.tv_nsec) / 1e3;
        total += elapsed;
        // printf("%f\n", elapsed);
    }
    double avg_parallel = total / ITERATION;
    total = 0.0;
    for (int i = 0; i < ITERATION; i++)
    {
        int *output_seq = (int *)malloc(size * sizeof(int));

        struct timespec start_seq, end_seq;
        clock_gettime(CLOCK_MONOTONIC, &start_seq);
        scan_seq(input, output_seq, size, 0);
        clock_gettime(CLOCK_MONOTONIC, &end_seq);
        double elapsed = (end_seq.tv_sec - start_seq.tv_sec) * 1e6 + (end_seq.tv_nsec - start_seq.tv_nsec) / 1e3;
        total += elapsed;
        free(output_seq);
        // printf("%f\n", elapsed);
    }
    double avg_seq = total / ITERATION;
    printf("%f %f\n", avg_parallel, avg_seq);
    return 0;
}

// bool test = true;
// for (int i = 0; i < size; i++)
// {
//     if (output_seq[i] != data->output[i])
//     {
//         test = false;
//         break;
//     }
// }
// if (test)
// {
//     printf("pass\n");
// }
// else
// {
//     printf("failed\n");
// }
