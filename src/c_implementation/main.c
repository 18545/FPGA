
#include <stdbool.h>
#include "pnglib.h"
#include <png.h>

#define PNG_DEBUG 3
#define X_MIN 50
#define X_MAX 250
#define Y_MIN 50
#define Y_MAX 250


extern int width, height;

void blue(png_bytep * row_pointers)
{
  int x, y;
  for (y=0; y<height; y++) {
          png_byte* row = row_pointers[y];
          for (x=0; x<width; x++) {
                  png_byte* ptr = &(row[x*4]);
                  printf("Pixel at position [ %d - %d ] has RGBA values: %d - %d - %d - %d\n",
                         x, y, ptr[0], ptr[1], ptr[2], ptr[3]);

                  /* set red value to 0 and green value to the blue one */
                  ptr[0] = 0;
                  ptr[1] = ptr[2];
          }
  }
}

bool in_box(int x, int y) {
  return ((x == X_MIN || x == X_MAX) && y >= Y_MIN && y <= Y_MAX) || \
          ((y == Y_MIN || y == Y_MAX) && x >= X_MIN && x <= X_MAX);
}

void box(png_bytep * row_pointers)
{
  int x, y;

  for (y=0; y<height; y++) {
          png_byte* row = row_pointers[y];
          for (x=0; x<width; x++) {
                  png_byte* ptr = &(row[x*4]);
                  printf("Pixel at position [ %d - %d ] has RGBA values: %d - %d - %d - %d\n",
                         x, y, ptr[0], ptr[1], ptr[2], ptr[3]);

                  /* set red value to 0 and green value to the blue one */
                  if (in_box(x, y)) {
                    // printf("Setting value to 0\n");
                    ptr[0] = 0;
                    ptr[1] = 0;
                    ptr[2] = 0;
                    ptr[3] = 0;
                  }

          }
  }
}
//
// void sobel_filtering( )
//      /* Spatial filtering of image data */
//      /* Sobel filter (horizontal differentiation */
//      /* Input: image1[y][x] ---- Outout: image2[y][x] */
// {
//   /* Definition of Sobel filter in horizontal direction */
//   int weight[3][3] = {{ -1,  0,  1 },
//           { -2,  0,  2 },
//           { -1,  0,  1 }};
//   double pixel_value;
//   double min, max;
//   int x, y, i, j;  /* Loop variable */
//
//   /* Maximum values calculation after filtering*/
//   printf("Now, filtering of input image is performed\n\n");
//   min = DBL_MAX;
//   max = -DBL_MAX;
//   for (y = 1; y < y_size1 - 1; y++) {
//     for (x = 1; x < x_size1 - 1; x++) {
//       pixel_value = 0.0;
//       for (j = -1; j <= 1; j++) {
//       for (i = -1; i <= 1; i++) {
//         pixel_value += weight[j + 1][i + 1] * image1[y + j][x + i];
//       }
//       }
//       if (pixel_value < min) min = pixel_value;
//       if (pixel_value > max) max = pixel_value;
//     }
//   }
//   if ((int)(max - min) == 0) {
//     printf("Nothing exists!!!\n\n");
//     exit(1);
//   }
//
//   /* Initialization of image2[y][x] */
//   x_size2 = x_size1;
//   y_size2 = y_size1;
//   for (y = 0; y < y_size2; y++) {
//     for (x = 0; x < x_size2; x++) {
//       image2[y][x] = 0;
//     }
//   }
//   /* Generation of image2 after linear transformtion */
//   for (y = 1; y < y_size1 - 1; y++) {
//     for (x = 1; x < x_size1 - 1; x++) {
//       pixel_value = 0.0;
//       for (j = -1; j <= 1; j++) {
//       for (i = -1; i <= 1; i++) {
//         pixel_value += weight[j + 1][i + 1] * image1[y + j][x + i];
//       }
//       }
//       pixel_value = MAX_BRIGHTNESS * (pixel_value - min) / (max - min);
//       image2[y][x] = (unsigned char)pixel_value;
//     }
//   }
// }

int main(int argc, char **argv)
{
  if (argc != 3)
    abort_("Usage: program_name <file_in> <file_out>");

  // READ IN PNG FILE
  png_bytep *row_pointers = read_png_file(argv[1]);

  // ADD MORE EFFECTS HERE
  blue(row_pointers);
  box(row_pointers);

  // WRITE OUT EDITED PNG FILE
  write_png_file(row_pointers, argv[2]);
  return 0;
}
