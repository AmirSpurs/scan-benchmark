#!/usr/bin/env bash

# Load compiler paths from .env if it exists
# need to set FUTHARK_CHAINED and FUTHARK_OLD 

# Usage: ./run_fut_bench.sh [path_to_futhark_benchmark] 

if [ -f .env ]; then
    source .env
fi

outfile="fut_bench_result.csv"
RUNS=2
PROG="${1:-fut_bench_scan.fut}"


echo "Using the following Futhark compilers:"

echo "FUTHARK_CHAINED: $FUTHARK_CHAINED"
echo "FUTHARK_OLD: $FUTHARK_OLD"

echo "=== Old Scan ==="
old_out=$("$FUTHARK_OLD" bench "$PROG" --backend=multicore  --pass-option=--num-threads=8 | tee /dev/tty)

echo "=== Chained Scan ==="
chained_out=$("$FUTHARK_CHAINED" bench "$PROG" --backend=multicore  --pass-option=--num-threads=8  | tee /dev/tty)

{
  echo "benchmark,size,fut_chained_scan,old_fut_scan"
  paste -d, \
    <(echo "$chained_out" | awk '
      /\.fut:/{
        b=$0
        sub(/:$/,"",b)        
        sub(/.*:/,"",b)
        sub(/ .*/,"",b)
      }
      /:.*μs/{
        split($0,a,":")
        print b "," a[1]
      }') \
    <(echo "$chained_out" | awk '/:.*μs/{split($0,a,":");t=a[2];sub(/μs.*/,"",t);sub(/^[[:space:]]+/,"",t);print t}') \
    <(echo "$old_out"     | awk '/:.*μs/{split($0,a,":");t=a[2];sub(/μs.*/,"",t);sub(/^[[:space:]]+/,"",t);print t}')
} > "$outfile"
