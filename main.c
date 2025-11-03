#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <stdatomic.h>
#include <stdbool.h>
#include <assert.h>
#include <string.h>
#include "scan.h"
#include "scan_old_futhark.h"

#define BLOCK_SIZE (1024 * 16)
#define THREAD_NUMBER 11

#define SIGN_CHANCE 25
#define MAX_VALUE 10000

#define ITERATION 500

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
                // else {
                //     sched_yield();
                // }
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

    int size;
    sscanf(argv[1], "%d", &size);
    srand(time(NULL));

    int *input = (int *)malloc(size * sizeof(int));
    input = generateData(size);

    double total_parallel = 0.0;
    double total_seq = 0.0;
    double total_roofline = 0.0;
    double total_roofline_seq = 0.0;
    double total_fut_chained_scan = 0.0;
    double total_old_fut_scan = 0.0;

    int *output_paralell = (int *)malloc(size * sizeof(int));
    int *output_seq = (int *)malloc(size * sizeof(int));
    int *output_roofline = (int *)malloc(size * sizeof(int));
    int *output_roofline_seq = (int *)malloc(size * sizeof(int));
    int *output_fut_chained_scan = (int *)malloc(size * sizeof(int));
    int *output_old_fut_scan = (int *)malloc(size * sizeof(int));

    // pre touch
    for (int i = 0; i < size; i++)
    {
        output_paralell[i] = 0;
        output_seq[i] = 0;
        output_roofline[i] = 0;
        output_roofline_seq[i] = 0;
        output_fut_chained_scan[i] = 0;
        output_old_fut_scan[i] = 0;
    }

    struct futhark_context_config *cfg = futhark_context_config_new();

    struct futhark_context *ctx = futhark_context_new(cfg);

    struct futhark_old_context_config *old_cfg = futhark_old_context_config_new();

    struct futhark_old_context *old_ctx = futhark_old_context_new(old_cfg);

    for (int j = 0; j < ITERATION; j++)
    {

        double tmp = run_threads(scan_worker, input, output_paralell, size);
        if (j > 0)
            total_parallel += tmp;

        struct timespec start_seq, end_seq;
        clock_gettime(CLOCK_MONOTONIC, &start_seq);
        scan_seq(input, output_seq, size, 0);
        clock_gettime(CLOCK_MONOTONIC, &end_seq);

        if (j > 0)
            total_seq += (end_seq.tv_sec - start_seq.tv_sec) * 1e6 + (end_seq.tv_nsec - start_seq.tv_nsec) / 1e3;

        // validation for chained scan
        assert(verify(output_paralell, output_seq, size));

        struct futhark_i32_1d *input_fut_chained_scan_fut = futhark_new_i32_1d(ctx, input, size);

        struct futhark_i32_1d *output_fut_chained_scan_fut;

        struct timespec start_fut_chained_scan, end_fut_chained_scan;

        clock_gettime(CLOCK_MONOTONIC, &start_fut_chained_scan);
        futhark_entry_main(ctx, &output_fut_chained_scan_fut, input_fut_chained_scan_fut);
        futhark_context_sync(ctx);
        clock_gettime(CLOCK_MONOTONIC, &end_fut_chained_scan);


        if (j > 0)
            total_fut_chained_scan += (end_fut_chained_scan.tv_sec - start_fut_chained_scan.tv_sec) * 1e6 + (end_fut_chained_scan.tv_nsec - start_fut_chained_scan.tv_nsec) / 1e3;


        futhark_values_i32_1d(ctx, output_fut_chained_scan_fut, output_fut_chained_scan);
        assert(verify(output_fut_chained_scan, output_seq, size));

        futhark_free_i32_1d(ctx, input_fut_chained_scan_fut);
        futhark_free_i32_1d(ctx, output_fut_chained_scan_fut);

        struct futhark_old_i32_1d *input_old_fut_scan_fut = futhark_old_new_i32_1d(old_ctx, input, size);

        struct futhark_old_i32_1d *output_old_fut_scan_fut;

        struct timespec start_old_fut_scan, end_old_fut_scan;

        clock_gettime(CLOCK_MONOTONIC, &start_old_fut_scan);
        futhark_old_entry_main_old_scan(old_ctx, &output_old_fut_scan_fut, input_old_fut_scan_fut);
        futhark_old_context_sync(old_ctx);
        clock_gettime(CLOCK_MONOTONIC, &end_old_fut_scan);


        if (j > 0)
            total_old_fut_scan += (end_old_fut_scan.tv_sec - start_old_fut_scan.tv_sec) * 1e6 + (end_old_fut_scan.tv_nsec - start_old_fut_scan.tv_nsec) / 1e3;

        // printf("Futhark chained scan done\n");
        // printf("%f\n", (end_fut_chained_scan.tv_sec - start_fut_chained_scan.tv_sec) * 1e6 + (end_fut_chained_scan.tv_nsec - start_fut_chained_scan.tv_nsec) / 1e3);

        futhark_old_values_i32_1d(old_ctx, output_old_fut_scan_fut, output_old_fut_scan);
        assert(verify(output_old_fut_scan, output_seq, size));

        futhark_old_free_i32_1d(old_ctx, input_old_fut_scan_fut);
        futhark_old_free_i32_1d(old_ctx, output_old_fut_scan_fut);

        total_roofline += run_threads(roofline_worker, input, output_roofline, size);

        struct timespec start_roofline_seq, end_roofline_seq;
        clock_gettime(CLOCK_MONOTONIC, &start_roofline_seq);
        memcpy(output_roofline_seq, input, size * sizeof(int));
        clock_gettime(CLOCK_MONOTONIC, &end_roofline_seq);
        total_roofline_seq += (end_roofline_seq.tv_sec - start_roofline_seq.tv_sec) * 1e6 + (end_roofline_seq.tv_nsec - start_roofline_seq.tv_nsec) / 1e3;
        assert(verify(output_roofline_seq, output_roofline, size));
    }
    double avg_seq = total_seq / (ITERATION - 1);
    double avg_parallel = total_parallel / (ITERATION - 1);
    double avg_roofline = total_roofline / (ITERATION - 1);
    double avg_roofline_seq = total_roofline_seq / (ITERATION - 1);
    double avg_fut_chained_scan = total_fut_chained_scan / (ITERATION - 1);
    double avg_old_fut_scan = total_old_fut_scan / (ITERATION - 1);

    printf("%f %f %f %f %f %f\n", avg_parallel, avg_seq, avg_roofline, avg_roofline_seq, avg_fut_chained_scan, avg_old_fut_scan);

    free(output_paralell);
    free(output_seq);
    free(output_roofline);
    free(output_roofline_seq);
    free(output_fut_chained_scan);
    free(output_old_fut_scan);
    free(input);

    futhark_context_free(ctx);
    futhark_context_config_free(cfg);

    futhark_old_context_free(old_ctx);
    futhark_old_context_config_free(old_cfg);

    return 0;
}
