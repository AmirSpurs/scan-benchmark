#!/usr/bin/env bash

# Load compiler paths from .env if it exists
# need to set FUTHARK_CHAINED and FUTHARK_OLD 

if [ -f .env ]; then
    source .env
fi

outfile="fut_bench_result.csv"
RUNS=500

PROG="fut_bench_scan.fut"

cat > "$PROG" <<'EOF'
entry main (arr: []i32): []i32 =
  scan (+) 0 arr

-- ==
-- random input { [1000]i32 } auto output
-- random input { [5000]i32 } auto output
-- random input { [10000]i32 } auto output
-- random input { [50000]i32 } auto output
-- random input { [100000]i32 } auto output
-- random input { [200000]i32 } auto output
-- random input { [300000]i32 } auto output
-- random input { [400000]i32 } auto output
-- random input { [500000]i32 } auto output
-- random input { [600000]i32 } auto output
-- random input { [700000]i32 } auto output
-- random input { [800000]i32 } auto output
-- random input { [900000]i32 } auto output
-- random input { [1000000]i32 } auto output
-- random input { [2000000]i32 } auto output
-- random input { [3000000]i32 } auto output
-- random input { [4000000]i32 } auto output
-- random input { [5000000]i32 } auto output
-- random input { [6000000]i32 } auto output
-- random input { [7000000]i32 } auto output
-- random input { [8000000]i32 } auto output
-- random input { [9000000]i32 } auto output
-- random input { [10000000]i32 } auto output
-- random input { [20000000]i32 } auto output
-- random input { [30000000]i32 } auto output
-- random input { [40000000]i32 } auto output
-- random input { [50000000]i32 } auto output
EOF

echo "Using the following Futhark compilers:"

echo "FUTHARK_CHAINED: $FUTHARK_CHAINED"
echo "FUTHARK_OLD: $FUTHARK_OLD"

echo "=== Chained Scan ==="
chained_out=$("$FUTHARK_CHAINED" bench "$PROG" --backend=multicore --runs="$RUNS" | tee /dev/tty)

echo "=== Old Scan ==="
old_out=$("$FUTHARK_OLD" bench "$PROG" --backend=multicore --runs="$RUNS" | tee /dev/tty)

{
  echo "size,fut_chained_scan,old_fut_scan"
  paste -d, \
    <(echo "$chained_out" | awk '/i32:/{print $1}') \
    <(echo "$chained_out" | awk '/i32:/{print $2}') \
    <(echo "$old_out"     | awk '/i32:/{print $2}')
} > "$outfile"
