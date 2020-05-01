#include <stdio.h>
#include <stdlib.h>

int main(int argc, char  *argv[])
{
  register int j,i;
  FILE *f;
  FILE *fo;
  static double *D;
  int LRECL;
  int LLRECL;
  
  if(argc!=4)
    {
      fprintf(stderr,"Usage: 48to12 48file LRECL OUTPUT\n");
      exit(1);
    }
  if((f=fopen(argv[1],"r"))==NULL)
    {
      fprintf(stderr,"Cannot find file %s\n",argv[1]);
      exit(1);
    }
  LRECL=atoi(argv[2]);
  if((fo=fopen(argv[3],"w"))==NULL)
    {
      fprintf(stderr,"Cannot create file %s\n",argv[3]);
      exit(1);
    }
  if((D=(double*)malloc(sizeof(double)*LRECL))==NULL)
    {
      fprintf(stderr,"Cannot allocate memory for D\n");
      exit(1);
    }
  
  for(i=0;i<1200;i++)
    {
      //read-in 48file 
      fread(D,sizeof(double),LRECL,f); if(feof(f)) break;
      fread(D,sizeof(double),LRECL,f); if(feof(f)) break;
      fread(D,sizeof(double),LRECL,f); if(feof(f)) break;
      fread(D,sizeof(double),LRECL,f); if(feof(f)) break;
      LLRECL=0;
      for(j=0;j<LRECL;j+=4)
	{
	  // get pixel value @RIGHT-UPPER
	  fwrite(&D[j+3],sizeof(double),1,fo);
	  // increase the num. of the output samples
	  LLRECL++;
	}
    }
  fclose(f);
  fclose(fo);
  printf("%d\n",LLRECL);
}

