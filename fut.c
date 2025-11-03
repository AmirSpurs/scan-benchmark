// #include <pthread.h>
// #include <stdio.h>
// #include <stdlib.h>
// #include <time.h>
// #include <unistd.h>
// #include <stdatomic.h>
// #include <stdbool.h>
// #include <assert.h>
// #include <string.h>

// #define BLOCK_SIZE (1024 * 16)
// #define THREAD_NUMBER 11

// #define SIGN_CHANCE 25
// #define MAX_VALUE 10000

// #define ITERATION 50

// typedef struct
// {
//     atomic_int flag;
//     int aggregate;
//     int prefix;
// } Descriptor;

// typedef struct
// {
//     int *input;
//     int *output;
//     int size;
//     int block_count;
//     atomic_int work_index;
//     Descriptor *descriptors;
// } Data;

// int reduce_seq(int *data, int len)
// {

//     int acc = 0;
//     for (int i = 0; i < len; i++)
//     {
//         acc += data[i];
//     }
//     return acc;
// }

// int scan_seq(int *data, int *scanned, int size, int prefix)
// {
//     int acc = prefix;
//     for (int i = 0; i < size; i++)
//     {
//         acc = data[i] + acc;
//         scanned[i] = acc;
//     }
//     return acc;
// }

// int *generateData(int size)
// {
//     int *ptr = (int *)malloc(size * sizeof(int));
//     for (int i = 0; i < size; i++)
//     {
//         int value = 1 + (rand() % MAX_VALUE);
//         int pos = rand() % 100;
//         if (pos < SIGN_CHANCE)
//             value = value * -1;
//         ptr[i] = value;
//     }
//     return ptr;
// }

// bool verify(int *output_paralell, int *output_seq, int size)
// {
//     for (int i = 0; i < size; i++)
//     {
//         if (output_seq[i] != output_paralell[i])
//             return false;
//     }
//     return true;
// }

// int main(int argc, char *argv[])
// {
//     assert(argc == 2);

//     int size ;
//     sscanf(argv[1], "%d", &size);
//     srand(time(NULL));

//     int *input = (int *)malloc(size * sizeof(int));
//     input = generateData(size);

//     double total_parallel = 0.0;
//     double total_seq = 0.0;
//     double total_roofline = 0.0;
//     double total_roofline_seq = 0.0;

//     int *output_paralell = (int *)malloc(size * sizeof(int));
//     int *output_seq = (int *)malloc(size * sizeof(int));
//     int *output_roofline = (int *)malloc(size * sizeof(int));
//     int *output_roofline_seq = (int *)malloc(size * sizeof(int));

//     // pre touch
//     for (int i = 0; i < size; i++)
//     {
//         output_paralell[i] = 0;
//         output_seq[i] = 0;
//         output_roofline[i] = 0;
//         output_roofline_seq[i] = 0;
//     }

//     for (int j = 0; j < ITERATION; j++)
//     {

//         struct timespec start_seq, end_seq;
//         clock_gettime(CLOCK_MONOTONIC, &start_seq);
//         scan_seq(input, output_seq, size, 0);
//         clock_gettime(CLOCK_MONOTONIC, &end_seq);
//         total_seq += (end_seq.tv_sec - start_seq.tv_sec) * 1e6 + (end_seq.tv_nsec - start_seq.tv_nsec) / 1e3;

//         // validation for chained scan
//         assert(verify(output_paralell, output_seq, size));
//     }
//     double avg_seq = total_seq / ITERATION;
//     double avg_parallel = total_parallel / ITERATION;
//     double avg_roofline = total_roofline / ITERATION;
//     double avg_roofline_seq = total_roofline_seq / ITERATION;

//     printf("%f %f %f %f\n", avg_parallel, avg_seq, avg_roofline, avg_roofline_seq);

//     free(output_paralell);
//     free(output_seq);
//     free(output_roofline);
//     free(output_roofline_seq);

//     return 0;
// }

// ----------------------------

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
#define THREAD_NUMBER 11

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

// int *generateData(int size)
// {
//     int *ptr = (int *)malloc(size * sizeof(int));

//     for (int i = 0; i < size; i++)
//     {
//         int value = 1 + (rand() % MAX_VALUE);
//         int pos = rand() % 100;
//         if (pos < SIGN_CHANCE)
//             value = value * -1;
//         ptr[i] = value;
//     }
//     return ptr;
// }

// int main(int argc, char *argv[])
// {
//     int size = 1000 ;
//     int *input = (int *)malloc(size * sizeof(int));

//     int *output_fut = (int *)malloc(size * sizeof(int));
//     int *output_paralell = (int *)malloc(size * sizeof(int));
//     int *output_seq = (int *)malloc(size * sizeof(int));
//     int *output_roofline = (int *)malloc(size * sizeof(int));
//     int *output_roofline_seq = (int *)malloc(size * sizeof(int));

//     for (int i = 0; i < size; i++)
//     {
//         output_paralell[i] = 0;
//         output_seq[i] = 0;
//         output_roofline[i] = 0;
//         output_roofline_seq[i] = 0;
//     }
// }

#include <stdio.h>

#include "scan.h"

int main()
{
    int x[] = {0, 1000, 1, 1};
    int y[] = {0, 0, 0, 0};

    struct futhark_context_config *cfg = futhark_context_config_new();
    struct futhark_context *ctx = futhark_context_new(cfg);

    struct futhark_i32_1d *x_arr = futhark_new_i32_1d(ctx, x, 4);

    struct futhark_i32_1d *y_arr = futhark_new_i32_1d(ctx, y, 4);

    futhark_entry_main(ctx, &y_arr, x_arr);
    futhark_context_sync(ctx);

    printf("Result: \n");
    futhark_values_i32_1d(ctx, y_arr, y);

    for (int i = 0; i < 4; i++)
    {
        printf("%d ", y[i]);
    }
    printf("\n");

    futhark_free_i32_1d(ctx, x_arr);
    futhark_free_i32_1d(ctx, y_arr);

    futhark_context_free(ctx);
    futhark_context_config_free(cfg);
}