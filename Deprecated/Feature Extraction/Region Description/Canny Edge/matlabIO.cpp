/* MatlabIO.cpp
 *
 * Notes:
 *		A collection of functions to help get variables 
 *		in and out of Matlab as well as insure variables 
 *		are setup properly before use.
 *
 * Author:
 *		Anthony Gabrielson 
 */

#include "matlabIO.h"

/*
 *  getDblRetInt:  Gets double from a Matlab argument.
 *
 *  Inputs: 
 *      const mxArray **prhs: Right hand side argument with data
 *
 *  Returns:
 *      (int) the data
 */
int getDblRetInt( const mxArray **prhs )
{ 
    double      *pr; 
    int         number_of_dimensions, total_elements, data;  
    const int   *ldims;
    
     if (mxIsNumeric(*prhs) == 0) 
		mexErrMsgTxt("Not numbers...\n");
    
    total_elements = mxGetNumberOfElements(*prhs);
    number_of_dimensions = mxGetNumberOfDimensions(*prhs);
    ldims = mxGetDimensions(*prhs);
    
	//mexPrintf("%d,%d\n",number_of_dimensions,total_elements);

    if( number_of_dimensions != 2 || total_elements != 1)
		mexErrMsgTxt("getDbl: Inproper input...\n");
   
    //Get the double
	pr = (double *)mxGetData(*prhs);
    data = (int) *pr;
    
    return data;
}

/*
 *  getDblRetDbl:  Gets double from a Matlab argument.
 *
 *  Inputs: 
 *      const mxArray **prhs: Right hand side argument with data
 *
 *  Returns:
 *      (double) the data
 */
double getDblRetDbl( const mxArray **prhs )
{ 
    double      *pr; 
    int         number_of_dimensions, total_elements;  
    const int   *ldims;
    
     if (mxIsNumeric(*prhs) == 0) 
		mexErrMsgTxt("Not numbers...\n");
    
    total_elements = mxGetNumberOfElements(*prhs);
    number_of_dimensions = mxGetNumberOfDimensions(*prhs);
    ldims = mxGetDimensions(*prhs);
    
	//mexPrintf("%d,%d\n",number_of_dimensions,total_elements);

    if( number_of_dimensions != 2 || total_elements != 1)
		mexErrMsgTxt("getDbl: Inproper input...\n");

    //Get the double
	pr = (double *)mxGetData(*prhs);

    return *pr;
}

/*
 *  getStr:  Gets a string from a Matlab argument.
 *
 *  Inputs: 
 *      mxArray **prhs: Right hand side argument to get string
 *      (char **) String coming from matlab.
 */
void getStr( const mxArray **prhs, char **str )
{ 
    int	index = 0, tot_elem = 0; 
    
    if ( mxIsNumeric(*prhs) == 0 ) {  //User specifing numbers
		tot_elem = mxGetNumberOfElements(*prhs)+1;
        //Allocate memory using dynamic memory allocation routine mxCalloc 
        *str = (char *)mxCalloc( (tot_elem) ,sizeof(char));       
        mxGetString(*prhs, *str, tot_elem);
	} else {
		mexErrMsgTxt("getStr: Inproper input...\n");
	}   

	return;
}

/*
 *  sendStr:  Sends a string back to Matlab.
 *
 *  Inputs: 
 *      mxArray **plhs: Left hand side argument to send string
 *      (char **) String going to matlab.
 *		or
 *		(char *) String coming from matlab.
 */
void sendStr( mxArray **plhs, char **str )
{ 
	*plhs = mxCreateString(*str);
       
	return;
}

void sendStr( mxArray **plhs, char *str )
{ 
	*plhs = mxCreateString(str);
       
	return;
}

/*
 *  sendBool:  Sends a bool back to a Matlab argument. (True/False)
 *
 *  Inputs: 
 *      mxArray **plhs: Left hand side argument to get BW image
 *      bool: true/false to go back to Matlab.
 */
void sendBool(mxArray **plhs, bool result)
{
    bool *start_of_pr;   
	const int dims[]={1,1};

    //Create a dims[0] by dims[1] array of logical bits. 
    *plhs = mxCreateNumericArray(BOOL_NDIMS,dims,mxLOGICAL_CLASS,mxREAL); 
                                  
    //Populate the the created array.
    start_of_pr = (bool *) mxGetData(*plhs);
	*start_of_pr = result;
	
    return;
}
