#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <ostream>
#include <string>

#include "utils.h"

char const* FILE_NAME = "/Volumes/RAM_Disk_10GB/day2.txt";

__attribute((always_inline)) inline u8 isSafe(std::string line) {
    i32 num = 0;
    i32 prev = 0;
    u32 i = 0;
    i8 order = -1; // -1 uninit | 0 - increasing | 1 - decreasing

    for (; i < line.size(); i++) {
        if (line[i] == ' ') {
            i++;
            break;
        }
        prev *= 10;
        prev += line[i] - '0';
    }

    for (; i < line.size(); i++) {
        if (line[i] == ' ') {
            i32 val = num - prev;
            if (std::abs(val) < 1 || std::abs(val) > 3) {
                return 0;
            }
            if (order == -1) {
                order = num - prev < 0 ? 1 : 0;
                prev = num;
                num = 0;
            } else {
                if (order == 0 && num - prev < 0) {
                    return 0;
                }
                if (order == 1 && num - prev > 0) {
                    return 0;
                }
                prev = num;
                num = 0;
            }
            continue;
        }
        num *= 10;
        num += line[i] - '0';
    }
    i32 val = num - prev;
    if (std::abs(val) < 1 || std::abs(val) > 3) {
        return 0;
    }
    if (order == 0 && num - prev < 0) {
        return 0;
    }
    if (order == 1 && num - prev > 0) {
        return 0;
    }
    prev = num;
    num = 0;

    return 1;
}
__attribute((always_inline)) inline u8 isSafe2(std::string line) {
    i32 num = 0;
    i32 prev = 0;
    u32 i = 0;
    i8 order = -1; // -1 uninit | 0 - increasing | 1 - decreasing
    u8 removed = 0;

    for (; i < line.size(); i++) {
        if (line[i] == ' ') {
            i++;
            break;
        }
        prev *= 10;
        prev += line[i] - '0';
    }

    for (; i < line.size(); i++) {
        if (line[i] == ' ') {
            i32 val = num - prev;
            if (std::abs(val) < 1 || std::abs(val) > 3) {
                if (removed > 0)
                    return 0;
                removed++;
            }
            if (order == -1) {
                order = num - prev < 0 ? 1 : 0;
                prev = num;
                num = 0;
            } else {
                if (order == 0 && num - prev < 0) {
                    if (removed > 0)
                        return 0;
                    removed++;
                }
                if (order == 1 && num - prev > 0) {
                    if (removed > 0)
                        return 0;
                    removed++;
                }
                prev = num;
                num = 0;
            }
            continue;
        }
        num *= 10;
        num += line[i] - '0';
    }
    i32 val = num - prev;
    if (std::abs(val) < 1 || std::abs(val) > 3) {
        if (removed > 0)
            return 0;
        removed++;
    }
    if (order == 0 && num - prev < 0) {
        if (removed > 0)
            return 0;
        removed++;
    }
    if (order == 1 && num - prev > 0) {
        if (removed > 0)
            return 0;
        removed++;
    }
    prev = num;
    num = 0;

    return 1;
}

void part1() {
    std::ifstream inputFile(FILE_NAME);
    if (!inputFile.is_open()) {
        std::cerr << "Unable to open file" << std::endl;
        exit(EXIT_FAILURE);
    }

    std::string line;
    u64 soln = 0;
    while (std::getline(inputFile, line)) {
        soln += isSafe(line);
    }
    inputFile.close();

    std::cout << soln << std::endl;
}

void part2() {
    std::ifstream inputFile(FILE_NAME);
    if (!inputFile.is_open()) {
        std::cerr << "Unable to open file" << std::endl;
    }

    std::string line;
    u64 soln = 0;
    while (std::getline(inputFile, line)) {
        soln += isSafe2(line);
    }
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
