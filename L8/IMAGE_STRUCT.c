#include <stdio.h>
#include <stdlib.h>
#include <math.h>

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
void dimgalloc(dimg *img, int col, int row){

  img->col = col;
  img->row = row;

  img->data = (double *)calloc(col*row, sizeof(double));
}

void dimgread(dimg *img, char *FNAME){

  FILE *fp;

  if((fp = fopen(FNAME, "rb")) == NULL){
    fprintf(stderr, "File Open Faliure: %s\n", FNAME);
    exit(EXIT_FAILURE);
  }

  fread(img->data, sizeof(double), img->col*img->row, fp);
  
  fclose(fp);
}

void dimgwrite(dimg *img, char *FNAME){

  FILE *fp;

  if((fp = fopen(FNAME, "wb")) == NULL){
    fprintf(stderr, "File Open Faliure: %s\n", FNAME);
    exit(EXIT_FAILURE);
  }

  fwrite(img->data, sizeof(double), img->col*img->row, fp);

  fclose(fp);
}

void delput(dimg *img, double el, int col, int row){

  img->data[col + img->col*row] = el;
}

double delget(dimg *img, int col, int row){

  return img->data[col + img->col*row];
}

/******************************************/
/* unsinged char image handling functions */
/******************************************/
void ucimgalloc(ucimg *img, int col, int row){

  img->col = col;
  img->row = row;

  img->data = (unsigned char *)calloc(col*row, sizeof(unsigned char));
}

void ucimgread(ucimg *img, char *FNAME){

  FILE *fp;

  if((fp = fopen(FNAME, "rb")) == NULL){
    fprintf(stderr, "File Open Faliure: %s\n", FNAME);
    exit(EXIT_FAILURE);
  }

  fread(img->data, sizeof(unsigned char), img->col*img->row, fp);
  
  fclose(fp);
}

void ucimgwrite(ucimg *img, char *FNAME){

  FILE *fp;

  if((fp = fopen(FNAME, "wb")) == NULL){
    fprintf(stderr, "File Open Faliure: %s\n", FNAME);
    exit(EXIT_FAILURE);
  }

  fwrite(img->data, sizeof(unsigned char), img->col*img->row, fp);
  
  fclose(fp);
}

void ucelput(ucimg *img, unsigned char el, int col, int row){

  img->data[col + img->col*row] = el;
}

unsigned char ucelget(ucimg *img, int col, int row){

  return img->data[col + img->col*row];
}

/************************************/
/* integer image handling functions */
/************************************/
void iimgalloc(iimg *img, int col, int row){

  img->col = col;
  img->row = row;

  img->data = (int *)calloc(col*row, sizeof(int));
}

void iimgread(iimg *img, char *FNAME){

  FILE *fp;

  if((fp = fopen(FNAME, "rb")) == NULL){
    fprintf(stderr, "File Open Faliure: %s\n", FNAME);
    exit(EXIT_FAILURE);
  }

  fread(img->data, sizeof(int), img->col*img->row, fp);
  
  fclose(fp);
}

void iimgwrite(iimg *img, char *FNAME){

  FILE *fp;

  if((fp = fopen(FNAME, "wb")) == NULL){
    fprintf(stderr, "File Open Faliure: %s\n", FNAME);
    exit(EXIT_FAILURE);
  }

  fwrite(img->data, sizeof(int), img->col*img->row, fp);
  
  fclose(fp);
}
