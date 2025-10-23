#include "utils/utils.h"
#include <iostream>
#include <queue>
#include <utility>

// 140*140
global_var char const* FILE_NAME = "/Volumes/RAM_Disk_10GB/day12";
// area - count of blocks
// perimeter - count of other blocks/boundary touching

global_var i64 const DIRECTIONS[4][2]
    = { { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } };

__attribute((always_inline)) u32* getIters() {
    char* iter1Char = getenv("ITER1");
    char* iter2Char = getenv("ITER2");
    u32* iters = (u32*)malloc(sizeof(u32) * 2);
    // char* iterChar = getenv("ITERS1");
    iters[0] = iter1Char == nullptr ? 1 : std::stoi(iter1Char);
    iters[1] = iter2Char == nullptr ? 1 : std::stoi(iter2Char);
    return iters;
}

__attribute((always_inline)) inline i64 isValid(i16 i, i16 j) {
    return i >= 0 && i < 140 && j >= 0 && j < 140;
}

__attribute((always_inline)) inline u64 countCorners(
    u8 grid[140][140], i32 i, i32 j, u8 ch) {
    u64 corners = 0;

    auto matches
        = [&](i32 r, i32 c) -> bool { return isValid(r, c) && grid[r][c] == ch; };

    i8 configs[4][6] = {
        { -1, 0, 0, -1, -1, -1 }, // Top-left
        { -1, 0, 0, 1, -1, 1 },   // Top-right
        { 1, 0, 0, -1, 1, -1 },   // Bottom-left
        { 1, 0, 0, 1, 1, 1 }      // Bottom-right
    };

    for (auto& cfg : configs) {
        bool side1 = matches(i + cfg[0], j + cfg[1]);
        bool side2 = matches(i + cfg[2], j + cfg[3]);
        bool diag = matches(i + cfg[4], j + cfg[5]);

        // Outer corner: both sides are outside
        if (!side1 && !side2) {
            corners++;
        }
        // Inner corner: both sides inside, but diagonal is outside
        else if (side1 && side2 && !diag) {
            corners++;
        }
    }

    return corners;
}

u64 part1(u8 grid[140][140]) {
    i64 visited[140][140] = { { 0 } };
    std::queue<std::pair<i64, i64>> bfsQ;
    u64 area, peri;
    u64 soln = 0;

    for (i64 i = 0; i < 140; i++) {
        for (i64 j = 0; j < 140; j++) {
            if (visited[i][j])
                continue;

            area = peri = 0;
            i64 ch = grid[i][j];
            bfsQ.push({ i, j });
            visited[i][j] = 1;

            while (!bfsQ.empty()) {
                auto [curI, curJ] = bfsQ.front();
                bfsQ.pop();
                area++;
                for (i64 d = 0; d < 4; d++) {
                    i64 nextI = curI + DIRECTIONS[d][0];
                    i64 nextJ = curJ + DIRECTIONS[d][1];

                    if (isValid(nextI, nextJ) && grid[nextI][nextJ] == ch) {
                        if (visited[nextI][nextJ])
                            continue;
                        visited[nextI][nextJ] = 1;
                        bfsQ.push({ nextI, nextJ });
                    } else {
                        peri++;
                    }
                }
            }
            soln += area * peri;
        }
    }

    return soln;
}

u64 part2(u8 grid[140][140]) {
    u8 visited[140][140] = { { 0 } };
    std::queue<std::pair<i64, i64>> bfsQ;
    u64 area, peri;
    u64 soln = 0;

    for (u8 i = 0; i < 140; i++) {
        for (u8 j = 0; j < 140; j++) {
            if (visited[i][j])
                continue;

            area = peri = 0;
            u8 ch = grid[i][j];
            bfsQ.push({ i, j });
            visited[i][j] = 1;

            while (!bfsQ.empty()) {
                auto [curI, curJ] = bfsQ.front();
                bfsQ.pop();
                area++;
                peri += countCorners(grid, curI, curJ, ch);
                for (i64 d = 0; d < 4; d++) {
                    i32 nextI = curI + DIRECTIONS[d][0];
                    i32 nextJ = curJ + DIRECTIONS[d][1];

                    if (isValid(nextI, nextJ) && grid[nextI][nextJ] == ch) {
                        if (visited[nextI][nextJ])
                            continue;
                        visited[nextI][nextJ] = 1;
                        bfsQ.push({ nextI, nextJ });
                    }
                }
            }
            soln += area * peri;
        }
    }

    return soln;
}

void solve(u8 grid[140][140], u32 iters[2]) {
    u64 s1 = 0, s2;

    // PART 1 START

    {
        Timer t("Part 1", iters[0]);
        for (u32 i = 0; i < iters[0]; i++) {
            s1 = part1(grid);
        }
    }

    // PART 1 END

    // PART 2 START

    {
        Timer t("Part 2", iters[1]);
        for (u32 i = 0; i < iters[1]; i++) {
            s2 = part2(grid);
        }
    }

    // PART 2 END
    std::cout << "\nSolutions\n";
    std::cout << "\tPart 1 - " << s1 << '\n';
    std::cout << "\tPart 2 - " << s2 << '\n';
}

int main() {
    std::string line(140, 0);
    u8 grid[140][140] = { { 0 } };
    std::ifstream inputFile(FILE_NAME);
    {
        Timer t("File Reading");
        if (!inputFile.is_open()) {
            std::cerr << "Unable to open file" << '\n';
            return EXIT_FAILURE;
        }

        for (i64 i = 0; i < 140; i++) {
            std::getline(inputFile, line);
            for (i64 j = 0; j < 140; j++) {
                grid[i][j] = line[j];
            }
        }
        inputFile.close();
    }

    auto iters = getIters();
    solve(grid, iters);

    return EXIT_SUCCESS;
}
