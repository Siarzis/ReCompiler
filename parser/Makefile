.PHONY: default clean

CC=gcc
CFLAGS=-I. -Wall

default: a.out clean

parser.c: *.y
	bison -o $@ $<

a.out: parser.c
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm *.o parser.c
