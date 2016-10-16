#include <png.h>

void abort_(const char * s, ...);
png_bytep * read_png_file(char* file_name);
void write_png_file(png_bytep * row_pointers, char* file_name);
