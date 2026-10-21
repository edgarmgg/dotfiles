SRCS     := $(wildcard *.cc)
TARGETS  := $(SRCS:.cc=)
CXX      := g++
CXXFLAGS := -std=c++17 -Wall -Wextra -pedantic -g -MMD -MP

all: $(TARGETS)

%: %.cc
	$(CXX) $(CXXFLAGS) -o $@ $<

clean:
	rm -f $(TARGETS) $(TARGETS:=.d)

-include $(TARGETS:=.d)

.PHONY: all clean
