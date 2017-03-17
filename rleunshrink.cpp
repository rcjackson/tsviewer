/* RLE Unshrinker */

#include "mex.h"
#include "matrix.h"

void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
   short * RawData;
   short * ReturnData;
   unsigned char c;
   int i, j, uncompressed_pos, RLHBpos, endsize, compsize;
   int dims[2];
   if(nrhs != 1)
    {
        mexErrMsgTxt("One must specify a block of data to compress!\n");
        return;
    }
    
    if(nlhs != 1)
    {
        mexErrMsgTxt("No or too many output arguments!\n");
        return;
    }
    
    if(!mxIsInt16(prhs[0]))
    {
        mexErrMsgTxt("Array must be of short's!\n");
        return;
    }
   
   RawData = (short *)mxGetData(prhs[0]);
   endsize = mxGetNumberOfElements(prhs[0])*32;
   compsize=endsize/32;
   ReturnData = (short *)mxCalloc(endsize, 1);
   uncompressed_pos=0;
   i=0;
   while(i<compsize)
   {
       c=RawData[i];
       if((c & 128)!=0)    // Zero flag is set
       {
           if((c&32)==0) // Check for dummy flag
           {
               for(j=0;j<=(c&31);j++)
               {
                   ReturnData[uncompressed_pos]=0;
                   uncompressed_pos++;
               }
           }
           i++;
       }
       else if ((c & 64)!=0) // Ones flag is set
       {
           if((c&32)==0) // Check for dummy flag
           {
               for(j=0;j<=(c&31);j++)
               {
                   ReturnData[uncompressed_pos]=255;
                   uncompressed_pos++;
               }
           }
           i++;
       }
       else              // Both are zero
       {
           if((c&32)==0)
           {
               i++;
               for(j=0;j<=c;j++)
               {
                   ReturnData[uncompressed_pos]=RawData[i];
                   i++;
                   uncompressed_pos++;
               }
           }
		   else
		   {
			   i++;
		   }
       }
   }
   dims[0]=1;
   dims[1]=uncompressed_pos;
   plhs[0]=mxCreateNumericArray(2, dims, mxINT16_CLASS, mxREAL);
   mxFree(mxGetData(plhs[0]));
   mxSetData(plhs[0], (void *)ReturnData);
}

           
           
        