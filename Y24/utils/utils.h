#ifndef UTILS_H

#    include <chrono>
#    include <cstdlib>
#    include <cstring>
#    include <fstream>
#    include <iostream>
#    include <ostream>
#    include <stdint.h>
#    include <string>

#    define global_var static
#    define local_persist static

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

typedef int8_t i8;
typedef int16_t i16;
typedef int32_t i32;
typedef int64_t i64;

class Timer {
    std::chrono::high_resolution_clock::time_point st;
    std::string label;
    u32 iters = 1;

public:
    Timer(std::string const& label)
        : st(std::chrono::high_resolution_clock::now())
        , label(label) { }
    Timer(std::string const& label, u32 iters)
        : st(std::chrono::high_resolution_clock::now())
        , label(label)
        , iters(iters) { }
    ~Timer() {
        auto en = std::chrono::high_resolution_clock::now();
        auto duration
            = (std::chrono::duration_cast<std::chrono::microseconds>(en - st))
                  .count()
            / 1000.0;

        std::cout << label << "\n\tTime for " << iters << " - " << duration
                  << "ms\n\tAvg per iter - " << duration / iters << "ms\n";
    }
};

#    define UTILS_H
#endif
