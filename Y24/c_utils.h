#include <_time.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

typedef int8_t i8;
typedef int16_t i16;
typedef int32_t i32;
typedef int64_t i64;

typedef void* any;

#define INITIAL_CAPACITY 20

////////////
// String //
////////////

typedef struct {
    u32 size;
    u32 cap;
    u8* data;
} String;

__attribute((always_inline, noreturn)) static inline void errorf(
    char const* __restrict format, ...) {
    va_list args;
    va_start(args, format);

    vfprintf(stderr, format, args);

    va_end(args);
    exit(1);
}

__attribute((always_inline)) inline String* initStringWithCapacity(
    u32 capacity) {
    if (capacity == 0) {
        errorf("Invalid capacity\n");
    }
    String* ret = (String*)malloc(sizeof(String));
    if (ret == NULL) {
        errorf("Unable to create string with size %d\n", capacity);
    }
    ret->cap = capacity;
    ret->size = 0;
    ret->data = (u8*)malloc(capacity * sizeof(u8));

    return ret;
}

__attribute((always_inline)) inline String* initString() {
    return initStringWithCapacity(INITIAL_CAPACITY);
}

__attribute((always_inline)) inline void increaseCapacity(String* str) {
    str->data = (u8*)realloc(str->data, str->cap * 2 * sizeof(u8));
    if (str->data == NULL) {
        errorf("Could not allocate\n");
    }

    str->cap *= 2;
}

__attribute((always_inline)) inline void addChar(String* str, u8 const ch) {
    if (str->size == str->cap) {
        increaseCapacity(str);
    }
    str->data[str->size] = ch;
    ++str->size;
}

__attribute((always_inline)) inline void clearString(String* str) {
    memset(str->data, 0, str->size * sizeof(u8));
    str->size = 0;
}

__attribute((always_inline)) inline void printString(String* str) {
    for (u32 i = 0; i < str->size; i++) {
        printf("%c", (char)str->data[i]);
    }
}

__attribute((always_inline)) inline void freeString(String* str) {
    free(str->data);
    free(str);
}

__attribute((always_inline)) inline u8 readline(FILE* fptr, String* line) {
    i8 ch;

    clearString(line);
    while (1) {
        ch = fgetc(fptr);
        if (ch == '\n') {
            break;
        }
        if (ch == EOF) {
            return 0;
        }
        addChar(line, ch);
    }

    return 1;
}

////////////
// VECTOR //
////////////

typedef struct {
    u32 size;
    u32 cap;
    u32* data;
} Vector;

__attribute((always_inline)) inline Vector* initArrayWithCapacity(
    int capacity) {
    if (capacity == 0) {
        errorf("Invalid capacity\n");
    }

    Vector* ret = (Vector*)malloc(sizeof(Vector));
    if (ret == NULL) {
        errorf("Unable to create array of size %d\n", capacity);
    }

    ret->cap = capacity;
    ret->size = 0;
    ret->data = (u32*)malloc(capacity * sizeof(u32));

    return ret;
}
__attribute((always_inline)) inline Vector* initArray() {
    return initArrayWithCapacity(INITIAL_CAPACITY);
}

__attribute((always_inline)) inline void incCapacity(Vector* arr) {
    arr->data = (u32*)realloc(arr->data, arr->cap * 2 * sizeof(u32));
    if (arr->data == NULL) {
        errorf("Could not allocate\n");
    }

    arr->cap *= 2;
}

__attribute((always_inline)) inline void addElem(Vector* vec, u32 const val) {
    if (vec->size == vec->cap) {
        incCapacity(vec);
    }
    vec->data[vec->size] = val;
    ++vec->size;
}

__attribute((always_inline)) inline void clearArr(Vector* arr) {
    memset(arr->data, 0, arr->size * sizeof(u32));
    arr->size = 0;
}

__attribute((always_inline)) inline void printArr(Vector* arr) {
    for (u32 i = 0; i < arr->size; i++) {
        printf("%d ", arr->data[i]);
    }
}
