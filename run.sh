#!/usr/bin/env bash

clang -o main.out main.c scan.c -O2
echo "Program compiled"

sizes="600000"

outfile="results.csv"
echo "size,parallel_time_microseconds,sequential_time_microseconds,roofline_parallel_time_microseconds,roofline_sequential_time_microseconds" > "$outfile"

for s in $sizes; do
    read -r parallel_time sequential_time roofline_parallel_time roofline_sequential_time fut_chained_scan < <(./main.out "$s")
    echo "$s,$parallel_time,$sequential_time,$roofline_parallel_time,$roofline_sequential_time,$fut_chained_scan" | tee -a "$outfile"
done

echo "Results saved to $outfile"
