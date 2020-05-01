#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/* Sinusoidal to LAT/LNG with Gain offset corr (ushort 14bit mask) */

int main(int argc ,char *argv[])
{
    int LRECL,NL; /* SINUSOIDAL IMAGE */
    int LLRECL,LNL; /* LAT/LNG IMAGE */
    int H,V;

    double ULAT,LLAT,RLNG,LLNG,DD;
    int XXXNUL;
    char fn[512];
    FILE *f;

    unsigned short *SINIMG;
    double *LLIMG;

    double G,O;

    register int j,i;
    double ATX;
    int SATX;
    double DT,LAT,LNG,CLAT;

    if(argc!=2)
    {
        fprintf(stderr,"Usage: SIN2LL_MUSGO paramfile\n");
	fprintf(stderr,"parameter file\n");
	fprintf(stderr,"    LRECL NL\n");
	fprintf(stderr,"    LLRECL LNL\n");
	fprintf(stderr,"    H V\n");
	fprintf(stderr,"    ULAT LLAT RLNGLLNG DD NULL\n");
	fprintf(stderr,"    SINIMG_FILE\n");
	fprintf(stderr,"    GAIN OFFSET\n");
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
    fscanf(f,"%lf %lf",&G,&O);
    fclose(f);

    if((f=fopen(fn,"r"))==NULL)
    {
        fprintf(stderr,"Cannot find file %s\n",fn);
        exit(1);
    }

    if((LLIMG=(double*)malloc(sizeof(double)*LLRECL))==NULL)
    {
        fprintf(stderr,"Cannot allocate momory for LLIMG");
	exit(1);
    }
    if((SINIMG=(unsigned short*)malloc(sizeof(unsigned short)*LRECL))==NULL)
    {
        fprintf(stderr,"Cannot allocate momory for SINIMG");
	exit(1);
    }

    DT=10.0/(double)NL;
    for(i=0;i<NL;i++)
    {
        fread(SINIMG,sizeof(unsigned short),LRECL,f);
	LAT=ULAT - (double)i * DD;
        CLAT=cos(M_PI*LAT/180.0);
	for(j=0;j<LLRECL;j++)
	{
	    LNG=LLNG + (double)j*DD;
	    ATX=LNG*CLAT/DT - (double)(H-18)*(double)LRECL;
	    if((ATX<0)||(ATX>=LRECL))
	    {
	        LLIMG[j]=-500;
	        continue;
	    }
	    //SATX=(int)(0.5+ATX);
	    SATX=(int)(-0.5+ATX);
	    if(SINIMG[SATX]==XXXNUL)
	        LLIMG[j]=-500;
	    else
	        LLIMG[j]=G*(double)(SINIMG[SATX] & 16383)+O;
	}
	fwrite(LLIMG,sizeof(double),LLRECL,stdout);
    }
    fclose(f);
}
	    
