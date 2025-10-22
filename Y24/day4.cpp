#include <cstdlib>
#include <iostream>
#include <ostream>
#include <string>

#include "utils/utils.h"

// 140 * 140 characters
static char const* FILE_NAME = "/Volumes/RAM_Disk_10GB/day4";

__attribute((always_inline)) inline u64 solve(char grid[140][140]) {
    u64 soln = 0;
    for (int i = 0; i < 140; i++) {
        for (int j = 0; j < 140; j++) {
            if (grid[i][j] == 'X') {
                // check left
                if (j > 2 && grid[i][j - 1] == 'M' && grid[i][j - 2] == 'A'
                    && grid[i][j - 3] == 'S')
                    soln++;

                // check left-up
                if (i > 2 && j > 2 && grid[i - 1][j - 1] == 'M'
                    && grid[i - 2][j - 2] == 'A' && grid[i - 3][j - 3] == 'S')
                    soln++;

                // check up
                if (i > 2 && grid[i - 1][j] == 'M' && grid[i - 2][j] == 'A'
                    && grid[i - 3][j] == 'S')
                    soln++;

                // check right-up
                if (i > 2 && j < 137 && grid[i - 1][j + 1] == 'M'
                    && grid[i - 2][j + 2] == 'A' && grid[i - 3][j + 3] == 'S')
                    soln++;

                // check right
                if (j < 137 && grid[i][j + 1] == 'M' && grid[i][j + 2] == 'A'
                    && grid[i][j + 3] == 'S')
                    soln++;

                // check right-down
                if (i < 137 && j < 137 && grid[i + 1][j + 1] == 'M'
                    && grid[i + 2][j + 2] == 'A' && grid[i + 3][j + 3] == 'S')
                    soln++;

                // check down
                if (i < 137 && grid[i + 1][j] == 'M' && grid[i + 2][j] == 'A'
                    && grid[i + 3][j] == 'S')
                    soln++;

                // check left-down
                if (i < 137 && j > 2 && grid[i + 1][j - 1] == 'M'
                    && grid[i + 2][j - 2] == 'A' && grid[i + 3][j - 3] == 'S')
                    soln++;
            }
        }
    }
    return soln;
}

__attribute((always_inline)) inline u64 solve2(char grid[140][140]) {
    u64 soln = 0;
    for (int i = 0; i < 140; i++) {
        for (int j = 0; j < 140; j++) {
            if (grid[i][j] == 'A') {
                // (top left M & bottom right S) OR (top left S & bottom right
                // M)
                if (!(i > 0 && j > 0 && i < 139 && j < 139
                        && grid[i - 1][j - 1] == 'M'
                        && grid[i + 1][j + 1] == 'S')
                    && !(i > 0 && j > 0 && i < 139 && j < 139
                         && grid[i - 1][j - 1] == 'S'
                         && grid[i + 1][j + 1] == 'M'))
                    continue;
                // (bottom left M & top right S) OR (bottom left S & top right
                // M)
                if (!(i > 0 && j > 0 && i < 139 && j < 139
                        && grid[i + 1][j - 1] == 'M'
                        && grid[i - 1][j + 1] == 'S')
                    && !(i > 0 && j > 0 && i < 139 && j < 139
                         && grid[i + 1][j - 1] == 'S'
                         && grid[i - 1][j + 1] == 'M'))
                    continue;
                soln += 1;
            }
        }
    }
    return soln;
}

void part1() {
    std::ifstream inputFile(FILE_NAME);
    if (!inputFile.is_open()) {
        std::cerr << "Unable to open file" << std::endl;
        exit(EXIT_FAILURE);
    }
    char grid[140][140];

    std::string line;
    u64 soln = 0;
    for (int i = 0; i < 140; i++) {
        std::getline(inputFile, line);
        for (int j = 0; j < line.size(); j++) {
            grid[i][j] = line[j];
        }
    }
    soln = solve(grid);
    inputFile.close();

    std::cout << soln << std::endl;
}

void part2() {
    std::ifstream inputFile(FILE_NAME);
    if (!inputFile.is_open()) {
        std::cerr << "Unable to open file" << std::endl;
    }

    std::string line;
    char grid[140][140];
    u64 soln = 0;
    for (int i = 0; i < 140; i++) {
        std::getline(inputFile, line);
        for (int j = 0; j < line.size(); j++) {
            grid[i][j] = line[j];
        }
    }
    soln = solve2(grid);
    inputFile.close();

    std::cout << soln << std::endl;
}

int main() {
    std::cout << "Part 1 - ";
    part1();
    std::cout << "Part 2 - ";
    part2();
    return EXIT_SUCCESS;
}
