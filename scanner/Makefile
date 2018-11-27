.PHONY: default clean

CC=gcc
CFLAGS=-I. -Wall
DEPS = token.h
OBJ = main.o lex.yy.o

default: a.out clean

lex.yy.c: *.l
	lex $<

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c $<

a.out: $(OBJ)
	$(CC) $^ -o $@ 

clean:
	rm *.o lex.yy.c
