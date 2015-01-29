/*==========================================================
 * mexcpp.cpp - example in MATLAB External Interfaces
 *
 * Illustrates how to use some C++ language features in a MEX-file.
 * It makes use of member functions, constructors, destructors, and the
 * iostream.
 *
 * The routine simply defines a class, constructs a simple object,
 * and displays the initial values of the internal variables.  It
 * then sets the data members of the object based on the input given
 * to the MEX-file and displays the changed values.
 *
 * This file uses the extension .cpp.  Other common C++ extensions such
 * as .C, .cc, and .cxx are also supported.
 *
 * The calling syntax is:
 *
 *		mexcpp( num1, num2 )
 *
 * Limitations:
 * On Windows, this example uses mexPrintf instead cout.  Iostreams
 * (such as cout) are not supported with MATLAB with all C++ compilers.
 *
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2013 The MathWorks, Inc.
 *
 *========================================================*/

#include <math.h>
#include "mex.h"
#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <stdexcept>

using namespace std;

void _main();

int levels;
int imageHeight;
int imageWidth;
double* image;
double* m_COM;
mxArray* m_OUT;
void UpdatePixel ( int x1 , int y1 , int x2 , int y2 )
{
   // cout<< "Pixel Update";
    // Make sure the neighbour pixel exists ( can be e . g . negative ) :
    if ( x2 < 0 || x2 >= ( int ) imageWidth || y2 < 0|| y2 >= ( int ) imageHeight )
        return ;

    int pixel , neighbour ;
    pixel = image[y1 + x1 * imageHeight];
    neighbour = image[y2 + x2 * imageHeight];
    int ind = pixel + neighbour * levels;
    if (ind >= (levels * levels))
            return;
    m_COM [ ind ] ++ ;

}


static void calcglcm(int levels, int dirx, int diry){

    for ( int y = 0; y < imageHeight ; y ++ )
        for ( int x = 0; x < imageWidth ; x ++ ) {
            UpdatePixel ( x , y , x + dirx , y + diry) ;
    }

    return;
}
void mexFunction(
		 int          nlhs,
		 mxArray      *plhs[],
		 int          nrhs,
		 const mxArray *prhs[]
		 )
{
    int dirx,diry;

    image = mxGetPr(prhs[0]);
    
    imageHeight = mxGetM(prhs[0]);
    imageWidth = mxGetN(prhs[0]);
    
    levels =  mxGetScalar(prhs[1]);
    dirx =  mxGetScalar(prhs[2]);
    diry =  mxGetScalar(prhs[3]);
    //cout << dirx << endl;
    m_OUT = plhs[0] = mxCreateDoubleMatrix(levels,levels,mxREAL);
    m_COM = mxGetPr(m_OUT);
    calcglcm( levels,  dirx, diry);
  
    
  return;
}
