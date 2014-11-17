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
double Max;
double Min;
double* image;
double* m_COM;
mxArray* m_OUT;

static void maxmin(){

    double maxValue = 0;
    double minValue = 257;
    double currentValue = 0;
    
    for ( int y = 0; y < imageHeight ; y ++ )
        for ( int x = 0; x < imageWidth ; x ++ ) {
            currentValue = image[y + x * imageHeight];
            if (maxValue < currentValue){
                maxValue = currentValue;
            }else if (minValue > currentValue){
                minValue = currentValue;
            }
            
    }
    Min = minValue;
    Max = maxValue;

    return;
}
void mexFunction(
		 int          nlhs,
		 mxArray      *plhs[],
		 int          nrhs,
		 const mxArray *prhs[]
		 )
{

    image = mxGetPr(prhs[0]);
    
    imageHeight = mxGetM(prhs[0]);
    imageWidth = mxGetN(prhs[0]);

    maxmin();
    m_OUT = plhs[0] = mxCreateDoubleScalar(Min);
    m_OUT = plhs[1] = mxCreateDoubleScalar(Max);
    m_COM = mxGetPr(m_OUT);
    
  return;
}
