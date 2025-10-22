#!/bin/sh

CXX="$(brew --prefix llvm)/bin/clang++"
CXX_FLAGS="-Winline -Wall -Werror -std=c++23 -O3"
CC="$(brew --prefix llvm)/bin/clang"
CC="zig cc"
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

    if [ $DAY -eq 7 ]; then
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

    echo "\nExit code - $?"

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

    if [ $DAY -eq 7 ]; then
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

visualize() {
    # Colors for output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color

    echo -e "${YELLOW}Building Array Visualizer...${NC}"

    # Compiler settings
    CXX="clang++"
    CXXFLAGS="-std=c++17 -Wall -Wextra -O2"
    OUTPUT="array_visualizer"
    SOURCE="main.cpp"

    # SDL3 flags (using pkg-config)
    SDL_CFLAGS=$(pkg-config --cflags sdl3 2>/dev/null)
    SDL_LIBS=$(pkg-config --libs sdl3 2>/dev/null)

    # If SDL3 not found, try SDL2
    if [ -z "$SDL_LIBS" ]; then
        echo -e "${YELLOW}SDL3 not found, trying SDL2...${NC}"
        SDL_CFLAGS=$(pkg-config --cflags sdl2)
        SDL_LIBS=$(pkg-config --libs sdl2)

        # You'll need to adjust the includes in your code from SDL3/SDL.h to SDL2/SDL.h
        echo -e "${YELLOW}Using SDL2 instead of SDL3${NC}"
    fi

    # If still no SDL found
    if [ -z "$SDL_LIBS" ]; then
        echo -e "${RED}Error: SDL not found. Please install SDL2 or SDL3${NC}"
        echo "Try: brew install sdl2"
        exit 1
    fi

    # Compile command
    COMPILE_CMD="$CXX $CXXFLAGS $SDL_CFLAGS $SOURCE -o $OUTPUT $SDL_LIBS"

    # Show the compile command
    echo -e "${GREEN}Compile command:${NC}"
    echo "$COMPILE_CMD"
    echo ""

    # Compile
    if $COMPILE_CMD; then
        echo -e "${GREEN}✓ Build successful!${NC}"
        echo -e "${GREEN}Run with: ./$OUTPUT${NC}"
    else
        echo -e "${RED}✗ Build failed!${NC}"
        exit 1
    fi
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
    visualize)
        echo "Starting visualization..."
        visualize
        ;;
    *)
        echo "Invalid command: $1"
        echo "Usage: $0 {run|test|assembly|clean}"
        exit 1
        ;;
esac
