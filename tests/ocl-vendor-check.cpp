#ifdef HAVE_CL_CL_H
#  include <CL/cl.h>
#elif defined(HAVE_OPENCL_CL_H)
#  include <OpenCL/cl.h>
#endif

#include <iostream>

int main( ) 
    {
    cl_uint platforms_available = 0;
    cl_int res = clGetPlatformIDs( 0, 0, &platforms_available);
    switch( res )
	{
	case CL_SUCCESS :
	    std::cout << res << " platform(s) available" << std::endl; 
	    return 0;
	    // break;
	default:
	    std::cout << "Error code: " << res <<  std::endl;
	}
    return 1;
    }
