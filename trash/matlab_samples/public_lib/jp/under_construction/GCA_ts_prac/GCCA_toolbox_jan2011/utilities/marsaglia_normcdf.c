/*
 * phi.c - compute Phi for standard normal distribution
 *
 * Implemented by Misha Koshelev.
 * mk144210 at bcm dot edu
 * 
 * This is a MEX-file for MATLAB.
 */ 
#include "math.h"
#include "mex.h"

#ifndef mwSize
#define mwSize int
#endif 

/*
 * Based on:
 * Marsaglia, George "Evaluating the Normal Distribution",
 * Journal of Statistical Software 11, 4 (July 2004).
 * http://www.jstatsoft.org/
 */
void phi(double *xarray, double *y, mwSize m, mwSize n)
{
  mwSize row,col,count=0;
  long double s,t,b,q,i;
  double x;
  
  for (row=0; row<n; row++) {
    for (col=0; col<m; col++) {
      x = *(xarray+count);
      if (x < -8)
	*(y+count) = 0;
      else if (x > 8)
	*(y+count) = 1;
      else {
	s=x; t=0; b=x; q=x*x; i=1;
	while(s!=t) s=(t=s)+(b*=q/(i+=2));
	*(y+count) = .5+s*exp(-.5*q-.91893853320467274178L);
	count++;
      }
    }
  }
}

/* the gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  double *x,*y;
  mwSize mrows,ncols;
  
  /*  check for proper number of arguments */
  /* NOTE: You do not need an else statement when using mexErrMsgTxt
     within an if statement, because it will never get to the else
     statement if mexErrMsgTxt is executed. (mexErrMsgTxt breaks you out of
     the MEX-file) */
  if(nrhs!=1) 
    mexErrMsgTxt("One input required.");
  if(nlhs!=1) 
    mexErrMsgTxt("One output required.");
  
  /*  create a pointer to the input matrix x */
  x = mxGetPr(prhs[0]);
  
  /*  get the dimensions of the matrix input x */
  mrows = mxGetM(prhs[0]);
  ncols = mxGetN(prhs[0]);
  
  /*  set the output pointer to the output matrix */
  plhs[0] = mxCreateDoubleMatrix(mrows,ncols, mxREAL);
  
  /*  create a C pointer to a copy of the output matrix */
  y = mxGetPr(plhs[0]);
  
  /*  call the C subroutine */
  phi(x,y,mrows,ncols);  
}
