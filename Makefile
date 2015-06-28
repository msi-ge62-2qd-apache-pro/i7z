#
# Makefile for i7z, GPL v2, License in COPYING
#

GIT_VERSION := $(shell git log --max-count 1 --pretty=format:"%H ( %cd )%n")
GIT_AUTHOR := $(shell git log --max-count 1 --pretty=format:"%cn%n ( %ce )%n")
GIT_MESSAGE := $(shell git log --max-count 1 --pretty=format:"%s%n" | sed -e 's/['\''"]//g')

#makefile updated from patch by anestling

#explicitly disable two scheduling flags as they cause segfaults, two more seem to crash the GUI version so putting them
#here 
CFLAGS_FOR_AVOIDING_SEG_FAULT = -fno-schedule-insns2  -fno-schedule-insns -fno-inline-small-functions -fno-caller-saves
CFLAGS ?= -O3
CFLAGS += -DVERSION='"$(GIT_VERSION)"' -DAUTHOR='"$(GIT_AUTHOR)"' -DMESSAGE='"${GIT_MESSAGE}"' 
CFLAGS += $(CFLAGS_FOR_AVOIDING_SEG_FAULT) -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -DBUILD_MAIN -Wimplicit-function-declaration

LBITS := $(shell getconf LONG_BIT)
ifeq ($(LBITS),64)
   CFLAGS += -Dx64_BIT
else
   CFLAGS += -Dx86
endif

CC       ?= gcc

LIBS  += -lncurses -lpthread -lrt -lm
INCLUDEFLAGS = 

BIN	= i7z
# PERFMON-BIN = perfmon-i7z #future version to include performance monitor, either standalone or integrated
SRC	= i7z.c helper_functions.c i7z_Single_Socket.c i7z_Dual_Socket.c
OBJ	= $(SRC:.c=.o)

prefix ?= /usr
sbindir = $(prefix)/sbin/
docdir = $(prefix)/share/doc/$(BIN)/
mandir ?= $(prefix)/share/man/

all: clean test_exist

bin: $(OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BIN) $(OBJ) $(LIBS)

static-bin: $(OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BIN) $(OBJ) -static-libgcc -DNCURSES_STATIC -static -lpthread -lncurses -lrt -lm -ltinfo

# perfmon-bin: $(OBJ)
# 	$(CC) $(CFLAGS) $(LDFLAGS) -o $(PERFMON-BIN) perfmon-i7z.c helper_functions.c $(LIBS)

test_exist: bin
	@test -f i7z && echo 'Succeeded, now run sudo ./i7z' || echo 'Compilation failed'

clean:
	rm -f *.o $(BIN)

distclean: clean
	rm -f *~ \#*

install:  $(BIN)
	install -D -m 0644 doc/i7z.man $(DESTDIR)$(mandir)man1/i7z.1
	install -D -m 755 $(BIN) $(DESTDIR)$(sbindir)$(BIN)
	install -d $(DESTDIR)$(docdir)
	install -m 0644 README.txt put_cores_offline.sh put_cores_online.sh $(DESTDIR)$(docdir)
