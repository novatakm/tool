/* #include <stdio.h> */
/* #include <stdlib.h> */
/* #include <math.h> */
#ifndef _IMAGE_STRUCT_H_
#define _IMAGE_STRUCT_H_

typedef struct {
  int col;
  int row;
  double *data;
}dimg;

typedef struct {
  int col;
  int row;
  unsigned char *data;
}ucimg;

typedef struct {
  int col;
  int row;
  int *data;
}iimg;

/***********************************/
/* double image handling functions */
/***********************************/
void dimgalloc(dimg *img, int col, int row);
void dimgread(dimg *img, char *FNAME);
void dimgwrite(dimg *img, char *FNAME);
void delput(dimg *img, double el, int col, int row);
double delget(dimg *img, int col, int row);

/******************************************/
/* unsinged char image handling functions */
/******************************************/
void ucimgalloc(ucimg *img, int col, int row);
void ucimgread(ucimg *img, char *FNAME);
void ucimgwrite(ucimg *img, char *FNAME);
void ucelput(ucimg *img, unsigned char el, int col, int row);
unsigned char ucelget(ucimg *img, int col, int row);

/************************************/
/* integer image handling functions */
/************************************/
void iimgalloc(iimg *img, int col, int row);
void iimgread(iimg *img, char *FNAME);
void iimgwrite(iimg *img, char *FNAME);

#endif //_IMAGE_STRUCT_H_
