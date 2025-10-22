#include "c_utils.h"

char* FILE_NAME = "/Volumes/RAM_Disk_10GB/day7";

__attribute((always_inline)) inline u64 concatenate(u64 left, u64 right) {
    if (right == 0)
        return left * 10;

    u64 temp = right;
    u64 mul = 1;
    while (temp > 0) {
        mul *= 10;
        temp /= 10;
    }
    return left * mul + right;
}

__attribute((always_inline)) inline u8 isValid(Vector* vec, u64 val) {
    u32 ops = vec->size - 1;
    u32 combs = 1 << ops;
    u8 found = 0;

    for (u32 mask = 0; mask < combs; mask++) {
        u64 expr = vec->data[0];
        u8 valid = 1;

        for (u32 i = 0; i < ops; i++) {
            expr = (((mask >> i) & 1) * (expr * vec->data[i + 1]))
                 + ((1 - ((mask >> i) & 1)) * (expr + vec->data[i + 1]));
            valid &= (expr <= val);
        }

        found |= (valid & (expr == val));
    }

    return found;
}

__attribute((always_inline)) inline u8 isValid2(Vector* vec, u64 val) {
    u32 ops = vec->size - 1;
    u32 combs = 1;
    u8 found = 0;

    for (u32 i = 0; i < ops; i++) {
        combs *= 3;
    }

    for (u32 mask = 0; mask < combs; mask++) {
        u64 expr = vec->data[0];
        u8 valid = 1;
        u32 tempMask = mask;

        for (u32 i = 0; i < ops; i++) {
            u8 op = tempMask % 3;
            tempMask /= 3;
            u64 next = vec->data[i + 1];

            switch (op) {
            case 0:
                expr += next;
                break;
            case 1:
                expr *= next;
                break;
            case 2:
                expr = concatenate(expr, next);
                break;
            }

            valid &= (expr <= val);
        }

        found |= (valid & (expr == val));
    }

    return found;
}

__attribute((always_inline)) inline void solve(String* line, u64* soln) {
    u64 val = 0;
    u32 i = 0;
    for (i = 0; i < line->size; i++) {
        if (line->data[i] == ':') {
            i += 2;
            break;
        }
        val = (val * 10) + line->data[i] - '0';
    }
    u32 num = 0;
    Vector* vec = initArray();
    for (; i < line->size; i++) {
        if (line->data[i] == ' ') {
            addElem(vec, num);
            num = 0;
        } else {
            num = (num * 10) + line->data[i] - '0';
        }
    }
    addElem(vec, num);
    if (isValid(vec, val)) {
        *soln += val;
    }
}

__attribute((always_inline)) inline void solve2(String* line, u64* soln) {
    u64 val = 0;
    u32 i = 0;
    for (i = 0; i < line->size; i++) {
        if (line->data[i] == ':') {
            i += 2;
            break;
        }
        val = (val * 10) + line->data[i] - '0';
    }
    u32 num = 0;
    Vector* vec = initArray();
    for (; i < line->size; i++) {
        if (line->data[i] == ' ') {
            addElem(vec, num);
            num = 0;
        } else {
            num = (num * 10) + line->data[i] - '0';
        }
    }
    addElem(vec, num);
    if (isValid2(vec, val)) {
        *soln += val;
    }
}

__attribute((always_inline)) inline void part1(FILE* fptr) {
    String* line = initString();
    u64 soln = 0;
    while (readline(fptr, line)) {
        solve(line, &soln);
    }
    printf("%lld", soln);
}

__attribute((always_inline)) inline void part2(FILE* fptr) {
    String* line = initString();
    u64 soln = 0;
    while (readline(fptr, line)) {
        solve2(line, &soln);
    }
    printf("%lld", soln);
}

int main() {
    FILE* fptr;
    struct timespec start, end;
    fptr = fopen(FILE_NAME, "r");
    if (fptr == NULL) {
        printf("Error while opening file");
        return 1;
    }
    printf("Part 1 - ");
    clock_gettime(CLOCK_MONOTONIC, &start);
    part1(fptr);
    clock_gettime(CLOCK_MONOTONIC, &end);
    long elapsed_ns = (end.tv_sec - start.tv_sec) * 1000000000L + (end.tv_nsec - start.tv_nsec);

    printf("\nTIME - %ld ns ", elapsed_ns);
    printf("\n");
    fseek(fptr, 0, SEEK_SET);
    printf("Part 2 - ");
    clock_gettime(CLOCK_MONOTONIC, &start);
    part2(fptr);
    clock_gettime(CLOCK_MONOTONIC, &end);
    elapsed_ns = (end.tv_sec - start.tv_sec) * 1000000000L + (end.tv_nsec - start.tv_nsec);
    printf("\nTIME - %ld ns ", elapsed_ns);
    printf("\n");
    return 0;
}
