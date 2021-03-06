# /*****************************************************************************
#  ________          ___ ________  ________          ________  ________  ___  ___     
# |\_____  \        /  /|\   __  \|\   __  \        |\   ____\|\   __  \|\  \|\  \    
#  \|___/  /|      /  //\ \  \|\  \ \  \|\  \       \ \  \___|\ \  \|\  \ \  \\\  \   
#      /  / /     /  //  \ \   __  \ \  \\\  \       \ \  \    \ \   ____\ \  \\\  \  
#     /  /_/__   /  //    \ \  \|\  \ \  \\\  \       \ \  \____\ \  \___|\ \  \\\  \ 
#    |\________\/_ //      \ \_______\ \_______\       \ \_______\ \__\    \ \_______\
#     \|_______|__|/        \|_______|\|_______|        \|_______|\|__|     \|_______|
                                                                                    
# MIT License

# Copyright (c) 2022 Mike Sharkey

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# ******************************************************************************/
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
	(cd libs19 && make)
	(cd libz80cpu && make)
	(cd test && make)
	$(CPP) -o $@  $^ $(LIBS)


# Rule to clear out generated build files.
.PHONY: clean
clean:
	rm -f $(OBJS) $(TARGET)
	(cd libs19 && make clean)
	(cd libz80cpu && make clean)
	(cd test && make clean)

