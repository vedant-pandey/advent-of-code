#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "utils.h"

using namespace std;

static char const* FILE_NAME = "/Volumes/RAM_Disk_10GB/day5.txt";

__attribute((always_inline)) inline void addEdge(
    unordered_map<u64, unordered_set<u64>>& edges, string const& line) {

    auto delim = line.find('|');
    auto f = stoi(line.substr(0, delim));
    auto s = stoi(line.substr(delim + 1));
    edges[f].insert(s);
}

__attribute((always_inline)) inline u64 validateSeq(
    unordered_map<u64, unordered_set<u64>>& edges, string const& line) {
    vector<u64> seq;
    u64 num = 0;
    for (int i = 0; i < line.size(); i++) {
        if (line[i] == ',') {
            seq.push_back(num);
            num = 0;
        } else {
            num = (num * 10) + (line[i] - '0');
        }
    }
    seq.push_back(num);
    unordered_set<u64> seen;

    for (auto const& num : seq) {
        for (auto const& val : edges[num]) {
            if (seen.contains(val)) {
                return 0;
            }
        }
        seen.insert(num);
    }

    return seq[seq.size() / 2];
}

__attribute((always_inline)) inline u64 validateSeq2(
    unordered_map<u64, unordered_set<u64>>& edges, string const& line) {
    vector<u64> seq;
    u64 num = 0;
    for (int i = 0; i < line.size(); i++) {
        if (line[i] == ',') {
            seq.push_back(num);
            num = 0;
        } else {
            num = (num * 10) + (line[i] - '0');
        }
    }

    seq.push_back(num);

    unordered_set<u64> seen;
    u8 isValid = 1;

    for (auto const& num : seq) {
        if (isValid) {
            for (auto const& val : edges[num]) {
                if (seen.contains(val)) {
                    isValid = 0;
                }
            }
        }
        seen.insert(num);
    }

    if (!isValid) {
        // fix seq
        sort(seq.begin(), seq.end(), [&edges](u64 a, u64 b) {
            if (edges.count(a) && edges[a].count(b)) {
                return true;
            }

            if (edges.count(b) && edges[b].count(a)) {
                return false;
            }

            return false;
        });
        return seq[seq.size() / 2];
    }

    return 0;
}

__attribute((always_inline)) void part1() {
    ifstream inputFile(FILE_NAME);
    if (!inputFile.is_open()) {
        cerr << "Unable to open file" << endl;
        exit(EXIT_FAILURE);
    }

    string line;
    u64 soln = 0;
    u8 s1 = 1;
    unordered_map<u64, unordered_set<u64>> edges;
    while (getline(inputFile, line)) {
        if (line.empty()) {
            s1 = 0;
            continue;
        }

        if (s1) {
            addEdge(edges, line);
        } else {
            soln += validateSeq(edges, line);
        }
    }

    inputFile.close();

    cout << soln << endl;
}

__attribute((always_inline)) void part2() {
    ifstream inputFile(FILE_NAME);
    if (!inputFile.is_open()) {
        cerr << "Unable to open file" << endl;
    }

    string line;
    u64 soln = 0;
    u8 s1 = 1;
    unordered_map<u64, unordered_set<u64>> edges;
    while (getline(inputFile, line)) {
        if (line.empty()) {
            s1 = 0;
            continue;
        }

        if (s1) {
            addEdge(edges, line);
        } else {
            soln += validateSeq2(edges, line);
        }
    }
    inputFile.close();

    cout << soln << endl;
}

int main() {
    cout << "Part 1 - ";
    part1();
    cout << "Part 2 - ";
    part2();
    return EXIT_SUCCESS;
}
