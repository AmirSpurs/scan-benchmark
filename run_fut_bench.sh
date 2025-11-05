#!/usr/bin/env bash

FUTHARK_CHAINED=${1:-"/Users/amir/Desktop/specialCourse/futhark/dist-newstyle/build/aarch64-osx/ghc-9.6.7/futhark-0.26.0/x/futhark/build/futhark/futhark"}
FUTHARK_OLD=${2:-"/Users/amir/Desktop/old_futhark/futhark/dist-newstyle/build/aarch64-osx/ghc-9.6.7/futhark-0.26.0/x/futhark/build/futhark/futhark"}
RUNS=${RUNS:-500}

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

echo "FUTHARK_CHAINED: $FUTHARK_CHAINED"
echo "FUTHARK_OLD: $FUTHARK_OLD"

echo "=== Chained Scan ==="
"$FUTHARK_CHAINED" bench "$PROG" --backend=multicore --runs="$RUNS"

echo
echo "=== Old Scan ==="
"$FUTHARK_OLD" bench "$PROG" --backend=multicore --runs="$RUNS" 