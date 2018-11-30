.PHONY: default clean

SDIR =../scanner
CC=gcc
CFLAGS=-I. -Wall
DEPS = token.h
OBJ = parser.o scanner.o

default: a.out clean

a.out: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c $<

scanner.c: $(SDIR)/*.l parser.c
	flex -o $@ $<

parser.c: *.y
	bison --defines=$(DEPS) -o $@ $<

clean:
	rm *.o *.c
