#include "utils/linkedList.h"
#include "utils/utils.h"
#include <unordered_map>

// 28591 78 0 3159881 4254 524155 598 1
global_var u64 const INPUT[8] = { 28591, 78, 0, 3159881, 4254, 524155, 598, 1 };

__attribute((always_inline)) inline u8 countDigits(u64 num) {
    if (num == 0)
        return 1;
    u8 cnt = 0;
    while (num) {
        num /= 10;
        cnt++;
    }
    return cnt;
}

__attribute((always_inline)) inline void expandDict(
    std::unordered_map<u64, u64>& valueToCount) {
    std::unordered_map<u64, u64> next;
    for (auto& [key, val] : valueToCount) {
        if (key == 0) {
            next[1] += val;
        } else {
            u8 digs = countDigits(key);
            if (!(digs & 1)) {
                u64 tenPow = pow(10, digs / 2);
                auto l = ((key) / tenPow), r = ((key) % tenPow);
                next[l] += val;
                next[r] += val;
            } else {
                next[2024 * key] += val;
            }
        }
    }
    valueToCount = std::move(next);
}

__attribute((always_inline)) inline u64 getCountAfterNIterations(u64 count) {
    std::unordered_map<u64, u64> valueToCount;

    for (u64 i = 0; i < 8; ++i) {
        valueToCount[INPUT[i]] = 1;
    }

    for (u64 i = 0; i < count; i++) {
        expandDict(valueToCount);
    }
    u64 soln = 0;
    for (auto const& pair : valueToCount) {
        soln += pair.second;
    }
    return soln;
}

u64 part1() {
    auto soln = getCountAfterNIterations(25);
    return soln;
}

u64 part2() {
    auto soln = getCountAfterNIterations(75);
    return soln;
}

static void solve() {
    u64 soln = 0;
    auto st = std::chrono::high_resolution_clock::now();
    soln = part1();
    auto en = std::chrono::high_resolution_clock::now();
    std::cout << "Part 1 - " << soln << " | ";
    std::cout << "Time - " << (en - st) << '\n';
    soln = 0;
    st = std::chrono::high_resolution_clock::now();
    soln = part2();
    en = std::chrono::high_resolution_clock::now();
    std::cout << "Part 2 - " << soln << " | ";
    std::cout << "Time - " << (en - st) << '\n';
}

int main() {
    solve();

    return EXIT_SUCCESS;
}
