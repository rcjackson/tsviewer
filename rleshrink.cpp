/* RLE compression for CIP images */

#include "mex.h"
#include "matrix.h"

void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
   short * RawData;
   short * ReturnData;
   unsigned char c;
   int i, j, compressed_pos, RLHBpos, endsize;
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
        mexErrMsgTxt("Array must be of uint8's!\n");
        return;
    }
   
   RawData = (short *)mxGetData(prhs[0]);
   endsize = mxGetNumberOfElements(prhs[0]);
   ReturnData = (short *)mxCalloc(endsize, 1);
   
   i=0;
   compressed_pos=1;                // Position in compressed file
   RLHBpos=0;                      // Position of RLHB
   j=-1;
   while(i<endsize)
   {
       c=RawData[i];
       if(c==0)
       {
           if(i!=0 && j!=-1)
           {
                ReturnData[RLHBpos] = j;            
                RLHBpos=compressed_pos;
           }
           j=0;
           
           while(c==0 && i!=endsize && j!=31)
           {
               //mexPrintf("Compressing byte %d:\n", i);
               c=RawData[i];
               if(c==0)
               {
                  i++;
                  j++;
               }
//               if(j==31 || i==endsize) break;
           }
           ReturnData[RLHBpos]=127 + j;
           if(i!=endsize)
           {
               compressed_pos=RLHBpos+2;
               RLHBpos++;
           }
           else
               compressed_pos=RLHBpos+1;
           j=-1;
       }
       else if(c == 255)
       {
           if(i!=0 && j!=-1)
           {
               ReturnData[RLHBpos] = j;
               RLHBpos=compressed_pos;
           }
            j=0;
           //compressed_pos++;
           while(c==255 && j!=31 && i!=endsize)
           {
              // mexPrintf("Compressing byte %d:\n", i);
               c=RawData[i];
               if(c==255)
               {
                  j++;
                  i++;
               }
//               if(j==31 || i==endsize) break;
           }
           ReturnData[RLHBpos]=63 + j;
           if(i!=endsize)
           {
               compressed_pos=RLHBpos+2;
               RLHBpos++;
           }
           else
               compressed_pos=RLHBpos+1;
           j=-1;
       }
       else
       {
         //  mexPrintf("Compressing byte %d:\n", i);
           ReturnData[compressed_pos] = c;
           compressed_pos++;
           j++;
           if(j==31)
           {
               ReturnData[RLHBpos]=j;
               j=-1;
               RLHBpos=compressed_pos;
               compressed_pos++;
           }
           i++;
       }
   }
   //ReturnData[RLHBpos]=j;
   dims[0]=1;
   dims[1]=compressed_pos;
   plhs[0]=mxCreateNumericArray(2, dims, mxINT16_CLASS, mxREAL);
   mxFree(mxGetData(plhs[0]));
   mxSetData(plhs[0], (void *)ReturnData);
}
