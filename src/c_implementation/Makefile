# make: main.c
#   gcc -o pngtest -std=c99 -lpng main.c


CC = gcc
CFLAGS = -O1 -Wall -m32
LIBS = -std=c99 -lpng

all: pngtest

pngtest: main.c pnglib.c
	$(CC) $(CFLAGS) $(LIBS) -o pngtest main.c pnglib.c

run:
	./pngtest red1.png red2.png red2_out.png
	open red1.png
	open red2_out.png

clean:
	rm -f *.o pngtest
