#include <cstdlib>
#include <iostream>
#include <ostream>
#include <string>

#include "utils.h"

static char const* FILE_NAME = "/Volumes/RAM_Disk_10GB/day3.txt";

__attribute((always_inline)) inline u64 solve(std::string const line) {
    u64 f = 0, s = 0, sum = 0;
    for (int i = 3; i < line.size(); i++) {
        // mul(\d\d\d,\d\d\d)
        if (line[i] == '(' && line[i - 1] == 'l' && line[i - 2] == 'u'
            && line[i - 3] == 'm') {
            i++;
            while (line[i] >= '0' && line[i] <= '9') {
                f *= 10;
                f += line[i] - '0';
                i++;
            }
            if (line[i] != ',') {
                f = s = 0;
                continue;
            }
            i++;
            while (line[i] >= '0' && line[i] <= '9') {
                s *= 10;
                s += line[i] - '0';
                i++;
            }
            if (line[i] != ')') {
                f = s = 0;
                continue;
            }
            sum += f * s;
            f = s = 0;
        }
    }

    return sum;
}

__attribute((always_inline)) inline u64 solve2(std::string const line, u8& doInst) {
    u64 f = 0, s = 0, sum = 0;
    for (int i = 3; i < line.size(); i++) {
        if (doInst == 1
            && (
                // mul(\d\d\d,\d\d\d)
                line[i - 3] == 'm' && line[i - 2] == 'u' && line[i - 1] == 'l'
                && line[i] == '(')) {
            i++;
            while (line[i] >= '0' && line[i] <= '9') {
                f *= 10;
                f += line[i] - '0';
                i++;
            }
            if (line[i] != ',') {
                f = s = 0;
                continue;
            }
            i++;
            while (line[i] >= '0' && line[i] <= '9') {
                s *= 10;
                s += line[i] - '0';
                i++;
            }
            if (line[i] != ')') {
                f = s = 0;
                continue;
            }
            sum += f * s;
            f = s = 0;
        } else if (line[i - 3] == 'd' && line[i - 2] == 'o'
                   && line[i - 1] == '(' && line[i] == ')') {
            // do()
            doInst = 1;
        } else if (i >= 6
                   && (line[i - 6] == 'd' && line[i - 5] == 'o'
                       && line[i - 4] == 'n' && line[i - 3] == '\''
                       && line[i - 2] == 't' && line[i - 1] == '('
                       && line[i] == ')')) {
            // don't()
            doInst = 0;
        }
    }

    return sum;
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
        soln += solve(line);
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
    u8 doInst = 1;
    while (std::getline(inputFile, line)) {
        soln += solve2(line, doInst);
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
