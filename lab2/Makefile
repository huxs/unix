CC = gcc
OBJECTS = main.o config.o
FILES = main.c config.c

all : $(OBJECTS)
	$(CC) -lc $^ -o main

$(OBJECTS) : $(FILES)
	$(CC) -std=c99 -c $^

clean:
	rm -f *.~
	rm -f *.o
	rm -f main
