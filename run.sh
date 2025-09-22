#!/usr/bin/env bash

clang -o main.out main.c -O2
echo "Program compiled"

sizes="1000 5000 10000 50000 100000 500000 1000000 5000000 10000000 50000000 100000000"

outfile="results.csv"
echo "size,parallel_time_microseconds,sequential_time_microseconds" > "$outfile"

for s in $sizes; do
    read -r parallel_time sequential_time < <(./main.out "$s")
    echo "$s,$parallel_time,$sequential_time" | tee -a "$outfile"
done

echo "Results saved to $outfile"
