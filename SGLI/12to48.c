#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    register int l,k,j,i;
    FILE *f;
    static unsigned short D[1200];

    if(argc!=2)
    {
        fprintf(stderr,"Usage: 12to48 12file\n");
	exit(1);
    }
    if((f=fopen(argv[1],"r"))==NULL)
    {
        fprintf(stderr,"Cannot find file %s\n",argv[1]);
	exit(1);
    }

    for(i=0;i<1200;i++)
    {
        fread(D,sizeof(unsigned short),1200,f);
        for(l=0;l<4;l++)
	{
	    for(j=0;j<1200;j++)
	    {
	        for(k=0;k<4;k++)
		{
		    fwrite(&D[j],sizeof(unsigned short),1,stdout);
		}
	    }
	}
    }
    fclose(f);
}
