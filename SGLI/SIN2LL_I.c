#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/* Sinusoidal to LAT/LNG (ushort ) */

int main(int argc ,char *argv[])
{
  int LRECL,NL; /* SINUSOIDAL IMAGE */
  int LLRECL,LNL; /* LAT/LNG IMAGE */
  int H,V;
  
  double ULAT,LLAT,RLNG,LLNG,DD;
  int XXXNUL;
  char fn[512];
  FILE *f;
  
  int *SINIMG;
  int *LLIMG;
  
  
  register int j,i;
  double ATX;
  int SATX;
  double DT,LAT,LNG,CLAT;
  
  if(argc!=2)
    {
      fprintf(stderr,"Usage: SIN2LL_I paramfile\n");
      fprintf(stderr,"parameter file\n");
      fprintf(stderr,"    LRECL NL\n");
      fprintf(stderr,"    LLRECL LNL\n");
      fprintf(stderr,"    H V\n");
      fprintf(stderr,"    ULAT LLAT RLNG LLNG DD NULL\n");
      fprintf(stderr,"    SINIMG_FILE\n");
      exit(1);
    }
  
  if((f=fopen(argv[1],"r"))==NULL)
    {
      fprintf(stderr,"Cannot find file %s\n",argv[1]);
      exit(1);
    }
  
  fscanf(f,"%d %d",&LRECL,&NL);
  fscanf(f,"%d %d",&LLRECL,&LNL);
  fscanf(f,"%d %d",&H,&V);
  fscanf(f,"%lf %lf %lf %lf %lf %d",&ULAT,&LLAT,&RLNG,&LLNG,&DD,&XXXNUL);
  fscanf(f,"%s",fn);
  fclose(f);
  
  if((f=fopen(fn,"r"))==NULL)
    {
      fprintf(stderr,"Cannot find file %s\n",fn);
      exit(1);
    }
  
  if((LLIMG=(int*)malloc(sizeof(int)*LLRECL))==NULL)
    {
      fprintf(stderr,"Cannot allocate momory for LLIMG");
      exit(1);
    }
  if((SINIMG=(int*)malloc(sizeof(int)*LRECL))==NULL)
    {
      fprintf(stderr,"Cannot allocate momory for SINIMG");
      exit(1);
    }
  
  DT=10.0/(double)NL;
  for(i=0;i<NL;i++)
    {
      fread(SINIMG,sizeof(int),LRECL,f);
      // latitude @ position "i" on the LLIMG
      LAT=ULAT - (double)i * DD;
      CLAT=cos(M_PI*LAT/180.0);
      for(j=0;j<LLRECL;j++)
	{
	  // longitude @ position "j" on the LLIMG
	  LNG=LLNG + (double)j*DD;
	  // position "ATX" on the SINIMG
	  // corresponding to (LAT,LNG) on the LLIMG
	  ATX=LNG*CLAT/DT - (double)(H-18)*(double)LRECL;

	  // "ATX" is out of the SINIMG area
	  if((ATX<0)||(ATX>=LRECL))
	    {
	      LLIMG[j]=-500;
	      continue;
	    }
	  // "ATX" is in the SINIMG area
	  SATX=(int)(-0.5+ATX);
	  // data @ "SATX" on the SINIMG is NULL
	  if(SINIMG[SATX]==XXXNUL)
	    LLIMG[j]=-500;
	  else
	    LLIMG[j]=SINIMG[SATX];
	}
      fwrite(LLIMG,sizeof(int),LLRECL,stdout);
    }
  fclose(f);
}
