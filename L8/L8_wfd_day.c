#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "IMAGE_STRUCT.h"

#define MAX(a, b) ((a) > (b) ? (a) : (b))

#define UNAMBF_1   3
#define UNAMBF_2   2
#define POTENTIALF 1
#define WTR 1

dimg pr[7];
ucimg det;
int row, col;

void unambiguous_fire_1(){
  int i;

  for(i=0; i<col*row; i++){
    if(pr[6].data[i]/pr[4].data[i] > 2.5 &&
       pr[6].data[i]-pr[4].data[i] > 0.3 &&
       pr[6].data[i] > 0.5){
      det.data[i] = UNAMBF_1;
    }
  }
}

void unambiguous_fire_2(){
  int i;

  for(i=0; i<col*row; i++){
    if(det.data[i] != UNAMBF_1){
      if(pr[5].data[i] > 0.8 &&
	 pr[0].data[i] < 0.2 &&
	 (pr[4].data[i] > 0.4 || pr[6].data[i] < 0.1)){
	det.data[i] = UNAMBF_2;
      }
    }
  }
}

void potential_fire_3(){
  int i, j;
  ucimg wtr;

  ucimgalloc(&wtr, col, row);
  
  // candidates screening and
  // water body capturing
  for(i=0; i<col*row; i++){
    if(det.data[i] != UNAMBF_1 && det.data[i] != UNAMBF_2){
      // candidate fire screening
      if(pr[6].data[i]/pr[4].data[i] > 1.8 &&
	 pr[6].data[i]-pr[4].data[i] > 0.17){
	det.data[i] = POTENTIALF;
      }
      // water body capturing
      if(pr[3].data[i] > pr[4].data[i] &&
	 pr[4].data[i] > pr[5].data[i] &&
	 pr[5].data[i] > pr[6].data[i] &&
	 pr[0].data[i]-pr[6].data[i] < 0.2
	 &&
	 (pr[2].data[i] > pr[1].data[i]
	  ||
	  (pr[0].data[i] > pr[1].data[i] &&
	   pr[1].data[i] > pr[2].data[i] &&
	   pr[2].data[i] > pr[3].data[i]))
	 ){
	wtr.data[i] = WTR;	
      }
    }
  }
  // for debugging
  // ucimgwrite(&wtr, "wtr.raw");
  
  // potential fire-affected pixel detection
  for(i=0; i<row; i++){
    for(j=0; j<col; j++){
      // run the process over the candidate pixels
      if(ucelget(&det, j, i) == POTENTIALF){
	// background stats. calculation
	double R75, mn_R75 = 0, sd_R75;
	double r7, mn_r7 = 0, sd_r7;
	double R76;
	int n = 0;
	// background mean calc.
	for(int c_i=i-30; c_i<i+30; c_i++){
	  for(int c_j=j-30; c_j<j+30; c_j++){
	    if(0 <= c_i && c_i < row &&
	       0 <= c_j && c_j < col &&
	       ucelget(&det, c_j, c_i) != 255 &&
	       ucelget(&det, c_j, c_i) != 127 &&
	       ucelget(&wtr, c_j, c_i) != 255){
	      R75 = delget(&pr[6], c_j, c_i)/delget(&pr[4], c_j, c_i);
	      r7 = delget(&pr[6], c_j, c_i);
	      mn_R75 += R75;
	      mn_r7 += r7;
	      n++;
	    }
	  }
	}
	mn_R75 = mn_R75/n;
	mn_r7 = mn_r7/n;

	// background s.d. calc.
	for(int c_i=i-30; c_i<i+30; c_i++){
	  for(int c_j=j-30; c_j<j+30; c_j++){
	    if(0 <= c_i && c_i < row &&
	       0 <= c_j && c_j < col &&
	       ucelget(&det, c_j, c_i) != 255 &&
	       ucelget(&det, c_j, c_i) != 127 &&
	       ucelget(&wtr, c_j, c_i) != 255){
	      R75 = delget(&pr[6], c_j, c_i)/delget(&pr[4], c_j, c_i);
	      r7 = delget(&pr[6], c_j, c_i);
	      sd_R75 += (R75 - mn_R75)*(R75 - mn_R75);
	      sd_r7 += (r7 - mn_r7)*(r7 - mn_r7);
	    }
	  }
	}
	sd_R75 = sd_R75/(n-1);
	sd_r7 = sd_r7/(n-1);
	
	// contextual tests in order to be classified as P.F.
	R75 = delget(&pr[6], j, i)/delget(&pr[4], j, i);
	r7 = delget(&pr[6], j, i);
	R76 = delget(&pr[6], j, i)/delget(&pr[5], j, i);
	if(R75 > mn_R75 + MAX(3*sd_R75, 0.8) &&
	   r7 > mn_r7 + MAX(3*sd_r7, 0.08) &&
	   R76 > 1.6){
	  ucelput(&det, POTENTIALF, j, i);
	}else{
	  ucelput(&det, 0, j, i);
	}
      }
      
    }
  }
  
  free(wtr.data);
}

int main(int argc, char *argv[]){

  FILE *fp_prm;
  char PR[7][512];
  char DET[512];
  
  if(argc != 2){
    fprintf(stderr, "Usage: %s param_file\n", argv[0]);
    fprintf(stderr, "param_file format\n");
    fprintf(stderr, "COLS ROWS\n");
    fprintf(stderr, "PR1_IMG\n");
    fprintf(stderr, "PR2_IMG\n");
    fprintf(stderr, "PR3_IMG\n");
    fprintf(stderr, "PR4_IMG\n");
    fprintf(stderr, "PR5_IMG\n");
    fprintf(stderr, "PR6_IMG\n");
    fprintf(stderr, "PR7_IMG\n");
    fprintf(stderr, "L8DETMAP_IMG\n");
    exit(EXIT_FAILURE);
  }

  if((fp_prm=fopen(argv[1], "r")) == NULL){
    fprintf(stderr, "Cannot open file %s\n", argv[1]);
    exit(EXIT_FAILURE);
  }

  fscanf(fp_prm, "%d %d", &col, &row);
  for(int i=0; i<7; i++){
    fscanf(fp_prm, "%s", PR[i]);
  }
  fscanf(fp_prm, "%s", DET);
  fclose(fp_prm);

  // allocate image structs and read-in
  for(int i=0; i<7; i++){
    dimgalloc(&pr[i], col, row);
    dimgread(&pr[i], PR[i]);
  }
  ucimgalloc(&det, col, row);

  // L8 fire detection
  unambiguous_fire_1();
  unambiguous_fire_2();
  potential_fire_3();
  //write-out detection map image
  ucimgwrite(&det, DET);
}
