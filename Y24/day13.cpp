#include "utils/utils.h"
#include <vector>

global_var char const* FILE_NAME = "/Volumes/RAM_Disk_10GB/day13";

global_var auto const MAX_ATTEMPT = 100;
global_var auto const COST_A = 3;
global_var auto const COST_B = 1;

typedef struct PrizeInstance {
    i64 aX = 0;
    i64 aY = 0;
    i64 bX = 0;
    i64 bY = 0;
    i64 pX = 0;
    i64 pY = 0;
} PrizeEntry;

__attribute((always_inline)) u32* getIters() {
    char* iter1Char = getenv("ITER1");
    char* iter2Char = getenv("ITER2");
    u32* iters = (u32*)malloc(sizeof(u32) * 2);
    // char* iterChar = getenv("ITERS1");
    iters[0] = iter1Char == nullptr ? 1 : std::stoi(iter1Char);
    iters[1] = iter2Char == nullptr ? 1 : std::stoi(iter2Char);
    return iters;
}

__attribute((always_inline)) inline u64 calcTokens(PrizeEntry const& e, u8 checkLimit = 1) {
    // From equation 1: aX·f + bX·s = pX
    // Solve for f: f = (pX - bX·s) / aX
    
    // Substitute into equation 2: aY·f + bY·s = pY
    // aY·(pX - bX·s)/aX + bY·s = pY
    // Multiply by aX: aY·(pX - bX·s) + aX·bY·s = pY·aX
    // aY·pX - aY·bX·s + aX·bY·s = pY·aX
    // s·(aX·bY - aY·bX) = pY·aX - aY·pX
    // s = (pY·aX - aY·pX) / (aX·bY - aY·bX)
    
    i64 denominator = (i64)e.aX * e.bY - (i64)e.aY * e.bX;
    
    if (denominator == 0) return 0;
    
    i64 numerator_s = (i64)e.pY * e.aX - (i64)e.aY * e.pX;
    if (numerator_s % denominator != 0) return 0;
    
    i64 s = numerator_s / denominator;
    if (checkLimit && (s < 0 || s > MAX_ATTEMPT)) return 0;
    
    // Now solve for f: f = (pX - bX·s) / aX
    i64 numerator_f = (i64)e.pX - (i64)e.bX * s;
    if (numerator_f % e.aX != 0) return 0;
    
    i64 f = numerator_f / e.aX;
    if (checkLimit && (f < 0 || f > MAX_ATTEMPT)) return 0;
    
    // Verify
    if ((e.aX * f + e.bX * s == e.pX) && (e.aY * f + e.bY * s == e.pY)) {
        return f * COST_A + s * COST_B;
    }
    
    return 0;
}


u64 part1(std::vector<PrizeEntry>& entryList) {
    u64 soln = 0;
    for (auto const& entry : entryList) {
        soln += calcTokens(entry);
    }
    return soln;
}

u64 part2(std::vector<PrizeEntry>& entryList) {
    u64 soln = 0;
    for (auto entry : entryList) {
        entry.pX += 10000000000000;
        entry.pY += 10000000000000;
        soln += calcTokens(entry, 0);
    }
    return soln;
}

void solve(std::vector<PrizeEntry>& entryList, u32 iters[2]) {
    u64 s1 = 0, s2;

    // PART 1 START

    {
        Timer t("Part 1", iters[0]);
        for (u32 i = 0; i < iters[0]; i++) {
            s1 = part1(entryList);
        }
    }

    // PART 1 END

    // PART 2 START

    {
        Timer t("Part 2", iters[1]);
        for (u32 i = 0; i < iters[1]; i++) {
            s2 = part2(entryList);
        }
    }

    // PART 2 END
    std::cout << "\nSolutions\n";
    std::cout << "\tPart 1 - " << s1 << '\n';
    std::cout << "\tPart 2 - " << s2 << '\n';
}

int main() {
    std::string line(32, 0);
    std::ifstream inputFile(FILE_NAME);
    std::vector<PrizeEntry> entryList;
    {
        Timer t("File Reading");
        if (!inputFile.is_open()) {
            std::cerr << "Unable to open file" << '\n';
            return EXIT_FAILURE;
        }

        while (std::getline(inputFile, line)) {
            PrizeEntry entry;
            // first line Button A
            entry.aX = (line[12] - '0') * 10 + line[13] - '0';
            entry.aY = (line[18] - '0') * 10 + line[19] - '0';

            // second line Button B
            std::getline(inputFile, line);
            entry.bX = (line[12] - '0') * 10 + line[13] - '0';
            entry.bY = (line[18] - '0') * 10 + line[19] - '0';

            // third line Prize
            std::getline(inputFile, line);
            auto it = line.begin() + 9;
            for (; *it != ','; it++) {
                entry.pX = entry.pX * 10 + (*it - '0');
            }
            for (it = it + 4; it != line.end(); it++) {
                entry.pY = entry.pY * 10 + (*it - '0');
            }

            // fourth line empty
            std::getline(inputFile, line);

            entryList.push_back(entry);
        }
        inputFile.close();
    }

    auto iters = getIters();
    solve(entryList, iters);

    return EXIT_SUCCESS;
}
