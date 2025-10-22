#include "utils/utils.h"
#include <unordered_set>

using namespace std;

global_var char const* FILE_NAME = "/Volumes/RAM_Disk_10GB/day8";
global_var u8 grid[50][50];

__attribute((always_inline)) inline u8 isValid(int i, int j) {
    return i >= 0 && i < 50 && j >= 0 && j < 50;
}

struct PairHash {
    template<class T1, class T2>
    size_t operator()(pair<T1, T2> const& p) const {
        auto h1 = hash<T1> {}(p.first);
        auto h2 = hash<T2> {}(p.second);

        return h1 ^ (h2 << 1);
    }
};

__attribute((always_inline)) inline void part1(
    unordered_set<pair<u8, u8>, PairHash>& antinodes, i32 f1, i32 s1, i32 f2,
    i32 s2) {
    i32 df = f2 - f1;
    i32 ds = s2 - s1;
    if (isValid(f2 + df, s2 + ds)) {
        antinodes.insert(pair(f2 + df, s2 + ds));
    }
    if (isValid(f1 - df, s1 - ds)) {
        antinodes.insert(pair(f1 - df, s1 - ds));
    }
}

__attribute((always_inline)) inline void part2(
    unordered_set<pair<u8, u8>, PairHash>& antinodes, i32 f1, i32 s1, i32 f2,
    i32 s2) {
    antinodes.insert(pair(f1, s1));
    antinodes.insert(pair(f2, s2));

    i32 df = f2 - f1;
    i32 ds = s2 - s1;
    i32 tempDf = df;
    i32 tempDs = ds;
    while (isValid(f1 - tempDf, s1 - tempDs)) {
        antinodes.insert(pair(f1 - tempDf, s1 - tempDs));
        tempDf += df;
        tempDs += ds;
    }
    tempDf = df;
    tempDs = ds;
    while (isValid(f2 + tempDf, s2 + tempDs)) {
        antinodes.insert(pair(f2 + tempDf, s2 + tempDs));
        tempDf += df;
        tempDs += ds;
    }
}

int main() {
    ifstream inputFile(FILE_NAME);
    if (!inputFile.is_open()) {
        cerr << "Unable to open file" << '\n';
        exit(EXIT_FAILURE);
    }

    string line;
    for (u32 i = 0; i < 50; ++i) {
        getline(inputFile, line);
        for (u32 j = 0; j < 50; ++j) {
            grid[i][j] = line[j];
        }
    }
    inputFile.close();

    unordered_map<u8, vector<pair<u8, u8>>> pointMap;
    unordered_set<pair<u8, u8>, PairHash> antinodes;
    for (int i = 0; i < 50; i++) {
        for (int j = 0; j < 50; j++) {
            if (grid[i][j] == '.')
                continue;
            pointMap[grid[i][j]].push_back(pair(i, j));
        }
    }

    for (auto const& p : pointMap) {
        for (int i = 0; i < p.second.size(); i++) {
            for (int j = i + 1; j < p.second.size(); j++) {
                i32 f1 = p.second[i].first;
                i32 s1 = p.second[i].second;
                i32 f2 = p.second[j].first;
                i32 s2 = p.second[j].second;
                part1(antinodes, f1, s1, f2, s2);
            }
        }
    }

    cout << "Part 1 - " << antinodes.size() << '\n';

    for (auto const& p : pointMap) {
        for (int i = 0; i < p.second.size(); i++) {
            for (int j = i + 1; j < p.second.size(); j++) {
                i32 f1 = p.second[i].first;
                i32 s1 = p.second[i].second;
                i32 f2 = p.second[j].first;
                i32 s2 = p.second[j].second;
                part2(antinodes, f1, s1, f2, s2);
            }
        }
    }

    cout << "Part 2 - " << antinodes.size() << '\n';
    return EXIT_SUCCESS;
}
