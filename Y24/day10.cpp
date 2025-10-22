#include "utils.h"
#include <cstring>

// 45*45
global_var char const* FILE_NAME = "/Volumes/RAM_Disk_10GB/day10";

static i8 const DIRECTIONS[4][2] = { { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } };

__attribute((always_inline)) inline u8 isValid(u8 i, u8 j) {
    return (i >= 0 && i < 45 && j >= 0 && j < 45);
}

__attribute((always_inline)) inline u64 calc(
    u8 grid[45][45], u8 visited[45][45], u8 i, u8 j) {
    if (grid[i][j] == 9)
        return 1;
    u64 soln = 0;
    for (u8 k = 0; k < 4; k++) {
        u8 newI = i + DIRECTIONS[k][0], newJ = j + DIRECTIONS[k][1];
        if (isValid(newI, newJ) && !visited[newI][newJ]
            && (grid[newI][newJ] - grid[i][j]) == 1) {
            visited[newI][newJ] = 1;
            soln += calc(grid, visited, newI, newJ);
        }
    }
    return soln;
}

__attribute((always_inline)) inline u64 calc2(u8 grid[45][45], u8 i, u8 j) {
    if (grid[i][j] == 9)
        return 1;
    u64 soln = 0;
    for (u8 k = 0; k < 4; k++) {
        u8 newI = i + DIRECTIONS[k][0], newJ = j + DIRECTIONS[k][1];
        if (isValid(newI, newJ) && (grid[newI][newJ] - grid[i][j]) == 1) {
            soln += calc2(grid, newI, newJ);
        }
    }
    return soln;
}

void solve(u8 grid[45][45]) {
    u64 soln = 0;
    u8 visited[45][45] = { { 0 } };
    auto st = std::chrono::high_resolution_clock::now();
    for (u8 i = 0; i < 45; i++) {
        for (u8 j = 0; j < 45; j++) {
            if (!grid[i][j]) {
                // start calc
                memset(visited, 0, sizeof(visited));
                visited[i][j] = 1;
                soln += calc(grid, visited, i, j);
            }
        }
    }
    auto en = std::chrono::high_resolution_clock::now();
    std::cout << "Part 1 - " << soln << " | ";
    std::cout << "Time - " << (en - st) << '\n';
    soln = 0;
    st = std::chrono::high_resolution_clock::now();
    for (u8 i = 0; i < 45; i++) {
        for (u8 j = 0; j < 45; j++) {
            if (!grid[i][j]) {
                // start calc
                soln += calc2(grid, i, j);
            }
        }
    }
    en = std::chrono::high_resolution_clock::now();
    std::cout << "Part 2 - " << soln << " | ";
    std::cout << "Time - " << (en - st) << '\n';
}

int main() {
    std::ifstream inputFile(FILE_NAME);
    if (!inputFile.is_open()) {
        std::cerr << "Unable to open file" << '\n';
        return EXIT_FAILURE;
    }
    std::string line(45, 0);
    u8 grid[45][45] = { { 0 } };
    for (u32 i = 0; i < 45; i++) {
        std::getline(inputFile, line);
        for (u32 j = 0; j < 45; j++) {
            grid[i][j] = line[j] - '0';
        }
    }

    solve(grid);

    return EXIT_SUCCESS;
}
