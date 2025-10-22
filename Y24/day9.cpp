#include "utils.h"
#include <algorithm>
#include <tuple>
#include <vector>

// 19999 chars
// even - used
// odd - free
global_var char const* FILE_NAME = "~/RAM_DISK/day9";

__attribute((always_inline)) inline i32* initArray(
    std::string const& line, u32 size) {
    i32* vec = new i32[size];
    std::fill(vec, vec + size, -1);

    u32 ind = 0;
    u32 id = 0;

    for (u32 i = 0; i < line.size(); ++i) {
        u8 count = line[i] - '0';
        if (i & 1) {
            ind += count;
        } else {
            for (u8 off = 0; off < count; off++) {
                vec[ind++] = id;
            }
            id++;
        }
    }

    return vec;
}

__attribute((always_inline)) inline u64 checksum(i32* vec, u32 size) {
    u64 soln = 0;
    for (u32 i = 0; i < size; i++) {
        if (vec[i] != -1) {
            soln += i * vec[i];
        }
    }

    return soln;
}

__attribute((always_inline)) inline void cleanArr(i32* vec) {
    delete[] vec;
    vec = nullptr;
}

void solve2(i32* vec, u32 size) {
    std::vector<std::tuple<u32, u32, u32>> files; // {id, st, size}
    for (u32 i = 0; i < size;) {
        if (vec[i] != -1) {
            u32 id = vec[i];
            u32 st = i;
            u32 fileSize = 0;
            while (i < size && vec[i] == id) {
                fileSize++;
                i++;
            }
            files.push_back({ id, st, fileSize });
        } else {
            i++;
        }
    }

    std::sort(files.begin(), files.end(),
        [](auto& a, auto& b) { return std::get<0>(a) > std::get<0>(b); });

    for (auto& [id, st, fileSize] : files) {
        u32 bestPos = size;
        u32 consecutive = 0;
        u32 freeSt = 0;

        for (u32 i = 0; i < st; i++) {
            if (vec[i] == -1) {
                freeSt = (consecutive == 0) * i;
                consecutive++;
                if (consecutive >= fileSize) {
                    bestPos = freeSt;
                    break;
                }
            } else {
                consecutive = 0;
            }
        }

        if (bestPos < st) {
            for (u32 i = st; i < st + fileSize; i++) {
                vec[i] = -1;
            }

            for (u32 i = bestPos; i < bestPos + fileSize; i++) {
                vec[i] = id;
            }
        }
    }

    auto soln = checksum(vec, size);
    cleanArr(vec);
    std::cout << "Part 2 - " << soln << '\n';
}

void solve(i32* vec, u32 size) {
    u32 l = 0, r = size - 1;
    while (l < r) {
        while (vec[l] != -1)
            l++;
        while (vec[r] == -1)
            r--;
        if (l >= r)
            break;
        std::swap(vec[l++], vec[r--]);
    }

    auto soln = checksum(vec, size);
    cleanArr(vec);
    std::cout << "Part 1 - " << soln << '\n';
}

void root(std::string line) {
    auto st = std::chrono::high_resolution_clock::now();
    u32 size = 0;
    for (auto const& ch : line) {
        size += ch - '0';
    }
    auto en = std::chrono::high_resolution_clock::now();
    std::cout << "Calc size - " << (en - st) << '\n';
    st = std::chrono::high_resolution_clock::now();
    auto* vec = initArray(line, size);
    solve(vec, size);
    en = std::chrono::high_resolution_clock::now();
    std::cout << "Time - " << (en - st) << '\n';
    st = std::chrono::high_resolution_clock::now();
    solve2(vec, size);
    en = std::chrono::high_resolution_clock::now();
    std::cout << "Time - " << (en - st) << '\n';
}

int main() {
    std::ifstream inputFile(FILE_NAME);
    if (!inputFile.is_open()) {
        std::cerr << "Unable to open file" << '\n';
        return EXIT_FAILURE;
    }
    std::string line;
    std::getline(inputFile, line);
    root(line);
    return EXIT_SUCCESS;
}
