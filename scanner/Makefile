.PHONY: all clean

CC=gcc
CFLAGS=-I. -Wall

all: a.out

a.out: lex.yy.c
	$(CC) $(CFLAGS) -o $@ $<

lex.yy.c: *.l
	lex $<

clean:
	rm -f lex.yy.c a.out

