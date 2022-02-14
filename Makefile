# Build Target
TARGET=runz80

# GCC toolchain programs.
CPP = ${LIBZ80_GCC}g++

LIBS += libz80cpu/libz80cpu.a 
LIBS += libs19/libs19.a 

# C compilation directives
CFLAGS +=  -I libz80cpu/inc -I libs19
CFLAGS += -c
CFLAGS += -Wall
CFLAGS += ${LIBZ80_CFLAGS}

# Header file directories.
INCLUDE += -I inc

# Z/80 CPU Source Files
CPP_SRC  += src/run80.cpp
CPP_SRC  += src/run80io.cpp
CPP_SRC  += src/run80mem.cpp
CPP_SRC  += src/load80.cpp
CPP_SRC  += src/main.cpp

# Object files to build.
OBJS += $(CPP_SRC:.cpp=.o)

# Default rule to build the whole project.
.PHONY: all
all: $(TARGET)

# Rule to compile C files.
%.o: %.cpp
	$(CPP) $(CFLAGS) $(INCLUDE) $< -o $@

# Rule to create an ELF file from the compiled object files.
$(TARGET): $(OBJS)
	$(CPP) -o $@  $^ $(LIBS)


# Rule to clear out generated build files.
.PHONY: clean
clean:
	rm -f $(OBJS) $(TARGET)

