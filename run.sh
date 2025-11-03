#!/usr/bin/env bash

clang -o main.out main.c scan.c scan_old_futhark.c -O2
echo "Program compiled"

sizes="1000
5000
10000
50000
100000
200000
300000
400000
500000
600000
700000
800000
900000
1000000
2000000
3000000
4000000
5000000
6000000
7000000
8000000
9000000
10000000
20000000
30000000
40000000
50000000"



outfile="results.csv"
echo "size,parallel_time_microseconds,sequential_time_microseconds,roofline_parallel_time_microseconds,roofline_sequential_time_microseconds,fut_chained_scan_time_microseconds,old_fut_scan_time_microseconds" > "$outfile"

for s in $sizes; do
    read -r parallel_time sequential_time roofline_parallel_time roofline_sequential_time fut_chained_scan old_fut_scan < <(./main.out "$s")
    echo "$s,$parallel_time,$sequential_time,$roofline_parallel_time,$roofline_sequential_time,$fut_chained_scan,$old_fut_scan" | tee -a "$outfile"
done

echo "Results saved to $outfile"
