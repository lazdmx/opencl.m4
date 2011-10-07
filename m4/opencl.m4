#serial 1

m4_define(
  [OPENCL_11_HEADERS], 
  [[CL/opencl.h], 
   [CL/cl_platform.h], 
   [CL/cl.h], 
   [CL/cl_ext.h], 
   [CL/cl_d3d10.h], 
   [CL/cl_gl.h], 
   [CL/cl_gl_ext.h], 
   [CL/cl.hpp]])

m4_define([AC_OPENCL_VENDOR_NVIDIA], [nv])
m4_define([AC_OPENCL_VENDOR_INTEL], [intel])
m4_define([AC_OPENCL_VENDOR_ANY], [any])

m4_define([AC_OPENCL_NVIDIA_CHECK], [echo "Checks for NV v $1"])
m4_define([AC_OPENCL_INTEL_CHECK], [echo "Checks for Int v $1"])

dnl --=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--= 
m4_define([AX_WITH_OPENCL_HELP_STRING],
  [points to the need to check system for installed OpenCL \
  framework and its libraries. The @<:@ARG@:>@ argument \
  specifies a vendor for whos OpenCL implementation system \
  will be checked and it may have one of predefined values: \
  AC_OPENCL_VENDOR_NVIDIA - for Nvidia[,] \
  AC_OPENCL_VENDOR_INTEL - for Intel and \
  AC_OPENCL_VENDOR_ANY - for any. If the @<:@ARG@:>@ argument \
  is not set[,] system will be checked for any available OpenCL \
  implementation.])

dnl --=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--= 
m4_define([AC_WITH_OPENCL_INC_HELP_STRING],
  [path to directory[,] where OpenCL header files are located.])


dnl --=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--= 
m4_define([AC_WITH_OPENCL_LIB_HELP_STRING],
  [path to directory[,] where OpenCL library files are located.])

m4_define([AC_OPENCL_WITH_PARAM_CONSISTENCY_CHECK],
  [
  dnl Checks for OpenCL version requested
  AS_IF(
    [test "$1" = "1.1"],
      [opencl_req_ver=11],
    [AC_MSG_ERROR([Invalid OpenCL version provided.])])

  dnl Checks for OpenCL vendor
  AS_IF(
    [test "$2" = "AC_OPENCL_VENDOR_NVIDIA" -o \
          "$2" = "AC_OPENCL_VENDOR_INTEL" -o \
          "$2" = "AC_OPENCL_VENDOR_ANY"],
    [AS_IF(
      [test -d "$3" -o \
            -z "$3" && \
       test -d "$4" -o \
            -z "$4"],
      [opencl_requested=1],
      [AC_MSG_ERROR([Inconsistent parameters.])])]
    [opencl_requested=0])])  


AC_DEFUN([AC_OPENCL_CHECK],
  [
  AC_ARG_WITH([opencl],
    [AC_HELP_STRING(
      [--with-opencl@<:@=ARG@:>@],
      AX_WITH_OPENCL_HELP_STRING)])

  AC_ARG_WITH([opencl-inc],
    [AC_HELP_STRING(
      [--with-opencl-inc@<:@=PATH@:>@],
      AC_WITH_OPENCL_INC_HELP_STRING)])

  AC_ARG_WITH([opencl-lib],
    [AC_HELP_STRING(
      [--with-opencl-lib@<:@=PATH@:>@],
      AC_WITH_OPENCL_LIB_HELP_STRING)])

  AC_OPENCL_WITH_PARAM_CONSISTENCY_CHECK(
    [$1], [$with_opencl], [$with_opencl_inc], [$with_opencl_lib])

  AS_IF(
    [test "$opencl_requested" = "1" -a \
          "$with_opencl" = "AC_OPENCL_VENDOR_NVIDIA"],
      [AC_OPENCL_NVIDIA_CHECK($opencl_req_ver)],
    [test "$opencl_requested" = "1" -a \
          "$with_opencl" = "AC_OPENCL_VENDOR_INTEL"],
      [AC_OPENCL_INTEL_CHECK($opencl_req_ver)]i,
    [echo cancel])
  ])
