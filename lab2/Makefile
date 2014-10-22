CC = gcc
OBJECTS = main.o config.o server.o http.o
FILES = main.c config.c server.c http.c

all : $(OBJECTS)
	$(CC) -lc $^ -o main

$(OBJECTS) : $(FILES)
	$(CC) -std=c99 -Wall -c $^

clean:
	rm -f *.~
	rm -f *.o
	rm -f main
