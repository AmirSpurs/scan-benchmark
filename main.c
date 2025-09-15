
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <assert.h>

#define SIGN_CHANCE 25
#define MAX_VALUE 10000
#define ITERATION 5

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

int *scan(int *data, int size)
{
    int acc = 0;
    int *scanned = (int *)malloc(size * sizeof(int));
    for (int i = 0; i < size; i++)
    {
        acc = data[i] + acc;
        scanned[i] = acc;
    }
    return scanned;
}

int main(int argc, char *argv[])
{

    assert(argc == 2);
    int size;
    sscanf(argv[1], "%d", &size);
    srand((unsigned int)time(NULL));
    double total = 0.0;

    for (int i = 0; i < ITERATION; i++)
    {

        int *data = generateData(size);
        struct timespec start, end;
        clock_gettime(CLOCK_MONOTONIC, &start);
        int *res = scan(data, size);
        clock_gettime(CLOCK_MONOTONIC, &end);

        double elapsed = (end.tv_sec - start.tv_sec) * 1e6 + (end.tv_nsec - start.tv_nsec) / 1e3;
        total += elapsed;
        free(data);
        free(res);
    }
    double avg = total / ITERATION;
    printf("%f\n", avg);
}