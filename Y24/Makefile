CXX = $(shell brew --prefix llvm)/bin/clang++
CFLAGS = -Wall -Werror -std=c++20 -O3

.PHONY: all run clean assembly

run:
	@read -p "Which day: " DAY; \
	$(CXX) $(CFLAGS) ./day$$DAY.cpp -o output; \
	RUN=1 ./output; \
	$(MAKE) clean; \
	echo "$DAY" > .lastRun

test:
	@read -p "Which day: " DAY; \
	$(CXX) $(CFLAGS) ./day$$DAY.cpp -o output; \
	RUN=0 ./output; \
	$(MAKE) clean; \
	echo "$$DAY" > .lastRun

assembly:
	@read -p "Which day: " DAY; \
	$(CXX) $(CFLAGS) -S ./day$$DAY.cpp -o assembly.s; \

clean:
	rm -f output assembly.s

