.PHONY: default clean

CC = gcc
CFLAGS = -I. -Wall
DEPS = token.h ast.h symbol.h
OBJ = parser.o scanner.o ast.o symbol.o

default: semantic clean

semantic: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^ -lm

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c $<

scanner.c: *.l parser.c
	flex -o $@ $<

parser.c: *.y
	bison --defines=token.h -o $@ $<

clean:
	rm *.o parser.c scanner.c
