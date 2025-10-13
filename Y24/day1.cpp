#include "utils.h"

void part1() {
    std::ifstream inputFile("/Volumes/RAM_Disk_10GB/day1.txt");
    if (!inputFile.is_open()) {
        std::cerr << "Unable to open file" << std::endl;
    }

    std::priority_queue<int, std::vector<int>, std::greater<int>> left, right;

    std::string line;
    u32 num = 0;
    u32 j = 0;
    while (std::getline(inputFile, line)) {
        num = 0;
        j = 0;
        for (; j < line.size(); j++) {
            if (line[j] == ' ') {
                break;
            }
            num *= 10;
            num += line[j] - '0';
        }

        while (j < line.size() && line[j] == ' ') {
            j++;
        }

        left.push(num);
        num = 0;

        for (; j < line.size(); j++) {
            num *= 10;
            num += line[j] - '0';
        }
        right.push(num);
    }
    inputFile.close();

    u64 soln = 0;
    while (!left.empty()) {
        soln += std::abs(left.top() - right.top());
        left.pop();
        right.pop();
    }

    std::cout << soln << std::endl;
}

void part2() {
    std::ifstream inputFile("/Volumes/RAM_Disk_10GB/day1.txt");
    if (!inputFile.is_open()) {
        std::cerr << "Unable to open file" << std::endl;
    }

    std::unordered_map<int, int> rightCount, leftCount;

    std::string line;
    u32 num = 0;
    u32 j = 0;
    while (std::getline(inputFile, line)) {
        num = 0;
        j = 0;
        for (; j < line.size(); j++) {
            if (line[j] == ' ') {
                break;
            }
            num *= 10;
            num += line[j] - '0';
        }

        while (j < line.size() && line[j] == ' ') {
            j++;
        }

        leftCount[num]++;
        num = 0;

        for (; j < line.size(); j++) {
            num *= 10;
            num += line[j] - '0';
        }
        rightCount[num]++;
    }
    inputFile.close();

    u64 soln = 0;
    for (auto &pair: leftCount) {
        soln += pair.first * pair.second * rightCount[pair.first];
    }

    std::cout << soln << std::endl;
}

int main() { 

    std::cout << "Part 1 - ";
    part1();
    std::cout << "Part 2 - ";
    part2();
    return 0;
}
