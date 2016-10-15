# make: main.c
#   gcc -o pngtest -std=c99 -lpng main.c


CC = gcc
CFLAGS = -O1 -Wall -m32
LIBS = -std=c99 -lpng

all: pngtest

pngtest: main.c pnglib.c
	$(CC) $(CFLAGS) $(LIBS) -o pngtest main.c pnglib.c

run:
	./pngtest carnegie.png carnegie2.png
	open carnegie.png
	open carnegie2.png

clean:
	rm -f *.o pngtest
