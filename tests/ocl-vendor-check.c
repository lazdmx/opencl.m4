#ifdef HAVE_CL_CL_H
#  include <CL/cl.h>
#elif defined(HAVE_OPENCL_CL_H)
#  include <OpenCL/cl.h>
#endif

int main( ) 
    {
    cl_uint platforms_available = 0;
    cl_int res = clGetPlatformIDs( 0, 0, &platforms_available);
    if ( CL_SUCCESS  == res ) 
	return 0;
    return 1;
    }
