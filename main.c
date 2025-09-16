
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

void scan(int *data, int *scanned, int size)
{
    int acc = 0;
    for (int i = 0; i < size; i++)
    {
        acc = data[i] + acc;
        scanned[i] = acc;
    }
    return ;
}

int main(int argc, char *argv[])
{

    assert(argc == 2);
    int size;
    sscanf(argv[1], "%d", &size);
    srand(time(NULL));
    double total = 0.0;
    int *data = generateData(size);

    for (int i = 0; i < ITERATION; i++)
    {
        int *scanned = (int *)malloc(size * sizeof(int));
        
        struct timespec start, end;
        clock_gettime(CLOCK_MONOTONIC, &start);
        scan(data, scanned , size);
        clock_gettime(CLOCK_MONOTONIC, &end);

        double elapsed = (end.tv_sec - start.tv_sec) * 1e6 + (end.tv_nsec - start.tv_nsec) / 1e3;
        total += elapsed;
        free(scanned);
    }
    free(data);
    double avg = total / ITERATION;
    printf("%f\n", avg);
}