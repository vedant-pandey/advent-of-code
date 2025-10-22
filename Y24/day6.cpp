#include "utils/utils.h"
#include <cstring>

using namespace std;

// 130 * 130
global_var char const* FILE_NAME = "/Volumes/RAM_Disk_10GB/day6";
global_var i8 const DIRECTIONS[4][2]
    = { { -1, 0 }, { 0, 1 }, { 1, 0 }, { 0, -1 } };
global_var char grid[130][130] = { { 0 } };

__attribute((always_inline)) u64 solve(i64 gRow, i64 gCol) {
    u64 count = 1;
    i8 DIRECTIONS[4][2] = { { -1, 0 }, { 0, 1 }, { 1, 0 }, { 0, -1 } };
    u8 curDir = 0;
    u8 visited[130][130];
    memset(visited, 0, sizeof(visited));
    visited[gRow][gCol] = 1;

    while (true) {
        i64 nxtGRow = gRow + DIRECTIONS[curDir][0];
        i64 nxtGCol = gCol + DIRECTIONS[curDir][1];
        u8 nxtIsValid = (static_cast<u64>(nxtGRow) < 130)
                      & (static_cast<u64>(nxtGCol) < 130);
        if (!nxtIsValid)
            break;

        if (grid[nxtGRow][nxtGCol] == '#') {
            curDir = (curDir + 1) % 4;
            continue;
        }
        gRow = nxtGRow;
        gCol = nxtGCol;

        if (!visited[gRow][gCol]) {
            visited[gRow][gCol] = 1;
            count++;
        }
    }
    return count;
}

__attribute((always_inline)) inline u8 createsLoop(
    i64 startRow, i64 startCol, i64 obstacleRow, i64 obstacleCol) {

    char originalChar = grid[obstacleRow][obstacleCol];
    grid[obstacleRow][obstacleCol] = '#';

    u8 visited[130][130][4];
    memset(visited, 0, sizeof(visited));

    i64 gRow = startRow;
    i64 gCol = startCol;
    u8 curDir = 0;

    while (true) {
        if (visited[gRow][gCol][curDir]) {
            grid[obstacleRow][obstacleCol] = originalChar;
            return 1;
        }
        visited[gRow][gCol][curDir] = 1;

        i64 nxtGRow = gRow + DIRECTIONS[curDir][0];
        i64 nxtGCol = gCol + DIRECTIONS[curDir][1];

        u8 nxtIsValid = (static_cast<u64>(nxtGRow) < 130)
                      & (static_cast<u64>(nxtGCol) < 130);
        if (!nxtIsValid) {
            grid[obstacleRow][obstacleCol] = originalChar;
            return 0;
        }

        if (grid[nxtGRow][nxtGCol] == '#') {
            curDir = (curDir + 1) % 4;
        } else {
            gRow = nxtGRow;
            gCol = nxtGCol;
        }
    }
}

__attribute((always_inline)) inline u64 solve2(i64 startRow, i64 startCol) {
    u64 count = 0;

    u8 pathVisited[130][130];
    memset(pathVisited, 0, sizeof(pathVisited));

    i64 gRow = startRow;
    i64 gCol = startCol;
    u8 curDir = 0;
    pathVisited[gRow][gCol] = 1;

    while (true) {
        i64 nxtGRow = gRow + DIRECTIONS[curDir][0];
        i64 nxtGCol = gCol + DIRECTIONS[curDir][1];
        u8 nxtIsValid = (static_cast<u64>(nxtGRow) < 130)
                      & (static_cast<u64>(nxtGCol) < 130);
        if (!nxtIsValid)
            break;

        if (grid[nxtGRow][nxtGCol] == '#') {
            curDir = (curDir + 1) % 4;
            continue;
        }

        gRow = nxtGRow;
        gCol = nxtGCol;

        if (!pathVisited[gRow][gCol] && !(gRow == startRow && gCol == startCol)
            && grid[gRow][gCol] != '#') {

            if (createsLoop(startRow, startCol, gRow, gCol)) {
                count++;
            }
        }
        pathVisited[gRow][gCol] = 1;
    }

    return count;
}

__attribute((always_inline)) void part1() {
    ifstream inputFile(FILE_NAME);
    if (!inputFile.is_open()) {
        cerr << "Unable to open file" << endl;
        exit(EXIT_FAILURE);
    }

    string line;
    memset(grid, 0, sizeof(grid));
    int gRow = 0, gCol = 0;
    for (int i = 0; i < 130; i++) {
        getline(inputFile, line);
        for (int j = 0; j < 130; j++) {
            grid[i][j] = line[j];
            if (line[j] == '^') {
                gRow = i;
                gCol = j;
            }
        }
    }
    inputFile.close();

    u64 soln = solve(gRow, gCol);
    cout << soln << endl;
}

__attribute((always_inline)) void part2() {
    ifstream inputFile(FILE_NAME);
    if (!inputFile.is_open()) {
        cerr << "Unable to open file" << endl;
    }

    string line;
    memset(grid, 0, sizeof(grid));
    int gRow = 0, gCol = 0;
    for (int i = 0; i < 130; i++) {
        getline(inputFile, line);
        for (int j = 0; j < 130; j++) {
            grid[i][j] = line[j];
            if (line[j] == '^') {
                gRow = i;
                gCol = j;
            }
        }
    }
    inputFile.close();
    u64 const soln = solve2(gRow, gCol);

    cout << soln << endl;
}

int main() {
    cout << "Part 1 - ";
    part1();
    cout << "Part 2 - ";
    part2();
    return EXIT_SUCCESS;
}
