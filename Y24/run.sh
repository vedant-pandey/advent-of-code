#!/bin/sh

CXX="$(brew --prefix llvm)/bin/clang++"
CXX_FLAGS="-Winline -Wall -Werror -std=c++20 -O3"
CC="$(brew --prefix llvm)/bin/clang"
CC_FLAGS="-Winline -Wall -Werror -std=c2x -O3"
PREV_DAY=$(cat .lastRun)

# Function to clean up build artifacts
clean() {
    rm -f output assembly.s
}

# Function to run the program
run() {

    if [ -z $DAY ]; then
        DAY=$PREV_DAY
    fi

    if [ $DAY -gt 6 ]; then
        $CC $CC_FLAGS "./day${DAY}.c" -o output
    else
        $CXX $CXX_FLAGS "./day${DAY}.cpp" -o output
    fi


    # Compile

    # Check if compilation was successful
    if [ $? -ne 0 ]; then
        echo "Compilation failed!"
        exit 1
    fi

    # Run with RUN=1
    ./output

    # Clean up
    clean

    # Save last run day
    echo "$DAY" > .lastRun
}

# Function to generate assembly
assembly() {
    if [ -z $DAY ]; then
        DAY=$PREV_DAY
    fi

    if [ $DAY -gt 6 ]; then
        # $CC $CC_FLAGS -S "./day${DAY}.c" -o assembly.s
        # Generate cleaner assembly for analysis
        clang -S -O3 -march=native \
            -fno-asynchronous-unwind-tables \
            -fno-verbose-asm \
            "./day${DAY}.c" -o assembly.s
    else
        $CXX $CXX_FLAGS -S "./day${DAY}.cpp" -o assembly.s
    fi

    # Check if compilation was successful
    if [ $? -ne 0 ]; then
        echo "Assembly generation failed!"
        exit 1
    fi

    echo "Assembly generated in assembly.s"
    echo "$DAY" > .lastRun
}

# Main script logic
if [ $# -eq 0 ]; then
    echo "Usage: $0 {run|test|assembly|clean}"
    echo "  run      - Compile and run with RUN=1"
    echo "  test     - Compile and run with RUN=0"
    echo "  assembly - Generate assembly code"
    echo "  clean    - Remove build artifacts"
    exit 1
fi

# Process command
case "$1" in
    run)
        run
        ;;
    test)
        test
        ;;
    assembly)
        assembly
        ;;
    clean)
        clean
        echo "Cleaned build artifacts"
        ;;
    *)
        echo "Invalid command: $1"
        echo "Usage: $0 {run|test|assembly|clean}"
        exit 1
        ;;
esac
