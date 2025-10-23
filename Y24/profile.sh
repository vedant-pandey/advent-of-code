#!/bin/bash

PROGRAM="./output"
OUTPUT_DIR="profiling_results"
mkdir -p $OUTPUT_DIR

echo "Starting comprehensive profiling..."

# 1. Basic timing
echo "=== Basic Timing ===" | tee $OUTPUT_DIR/timing.txt
/usr/bin/time -l $PROGRAM 2>&1 | tee -a $OUTPUT_DIR/timing.txt

# 2. CPU profiling
echo "=== CPU Profiling ==="
xcrun xctrace record --template "Time Profiler" \
    --launch $PROGRAM \
    --output $OUTPUT_DIR/cpu_profile.trace \
    --time-limit 30s

# 3. Memory profiling
echo "=== Memory Profiling ==="
export MallocStackLogging=1
leaks --atExit -- $PROGRAM > $OUTPUT_DIR/leaks.txt 2>&1

# 4. System trace
echo "=== System Trace ==="
xcrun xctrace record --template "System Trace" \
    --launch $PROGRAM \
    --output $OUTPUT_DIR/system.trace \
    --time-limit 30s

echo "Profiling complete! Results in $OUTPUT_DIR"
