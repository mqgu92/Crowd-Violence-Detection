#pragma once

/* MatlabIO.h
 * Notes: See matlabIO.cpp
 */

#include "mex.h"

#define BOOL_NDIMS	1
#define MAXSTR		256

extern int getDblRetInt( const mxArray **prhs );
extern double getDblRetDbl( const mxArray **prhs );
extern void getStr( const mxArray **prhs, char **str );
extern void sendStr( mxArray **plhs, char **str );
extern void sendStr( mxArray **plhs, char *str );
extern void sendBool(mxArray **plhs, bool result);


