#serial 1
m4_define([TN_OPENCL_CONST_V10], [1.0])
m4_define([TN_OPENCL_CONST_V11], [1.1])
m4_define([TN_OPENCL_CONST_NVIDIA], [nv])
m4_define([TN_OPENCL_CONST_INTEL], [intel])





dnl --=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--= 
m4_define([AC_WITH_OPENCL_HELP_STRING],
  [points to the need to check system for installed OpenCL \
  framework and its libraries. The @<:@ARG@:>@ argument \
  specifies a vendor for whos OpenCL implementation system \
  will be checked and it may have one of predefined values: \
  nv - for Nvidia[,] \
  intel - for Intel. dnl
  ])

dnl --=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--= 
m4_define([AC_WITH_OPENCL_INC_HELP_STRING],
  [path to directory[,] where OpenCL header files are located.])


dnl --=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--= 
m4_define([AC_WITH_OPENCL_LIB_HELP_STRING],
  [path to directory[,] where OpenCL library files are located.])




m4_define([__TN_OPENCL_PROG_CHECK_APPLE_PP_FLAG],
  [
  AC_LANG_PROGRAM(
    [[
    #ifdef __APPLE__
    #  define __EXIT_CODE 0
    #else
    #  define __EXIT_CODE 1
    #endif
    ]], 
    [[return __EXIT_CODE;]])
  ])

m4_define([__TN_OPENCL_PROG_CHECK_CL_V11],
  [
  AC_LANG_PROGRAM(
    [[
    #ifdef HAVE_CL_CL_H
    #  include <CL/cl.h>
    #elif defined( HAVE_OPENCL_CL_H ) 
    #  include <OpenCL/cl.h>
    #else
    #   error no cl.h
    #endif
    ]],
    [[clFinish(0)]])])


AC_DEFUN([TN_OPENCL_CHECK_APPLE_PP_FLAG],
  [
  AC_REQUIRE([AC_PROG_CC])
  AC_CACHE_VAL([tn_opencl_cv_apple_pp_flag], 
    [
    AC_LANG_PUSH([C])
    AC_RUN_IFELSE(
      [__TN_OPENCL_PROG_CHECK_APPLE_PP_FLAG],
      [tn_opencl_cv_apple_pp_flag=yes],
      [tn_opencl_cv_apple_pp_flag=no])
    AC_LANG_POP([C])
    ])
  ])
  

m4_define([TN_OPENCL_CHECK_HEADERS],
  [
  m4_ifnblank([$1], 
  [AC_CHECK_HEADERS([$1], 
    [
    opencl_headers_located=yes
    $0(m4_shift($@))
    ],
    [opencl_headers_located=no])])
  ])


m4_define([TN_OPENCL_CHECK_HEADERS_DEFUN],
[
  m4_define(m4_toupper([TN_OPENCL_CHECK_HEADERS_$2_V$1]),
  [
  TN_OPENCL_CHECK_APPLE_PP_FLAG()
  AS_IF([test -d $with_opencl_inc],
    [opencl_cl_flags="-I$with_opencl_inc"],
    [opencl_cl_flags=])
  
  opencl_save_CPPFLAGS=$CPPFLAGS
  CPPFLAGS="$CPPFLAGS $opencl_cl_flags"
  AS_IF([test "$tn_opencl_cv_apple_pp_flag" == "no"],
    [
    TN_OPENCL_CHECK_HEADERS(m4_map_args_sep(
      [CL/], [], [,], m4_shift2($@)))
    ],
    [
    TN_OPENCL_CHECK_HEADERS(m4_map_args_sep(
      [OpenCL/], [], [,], m4_shift2($@)))
    ])
  CPPFLAGS=$opencl_save_CPPFLAGS  
  ])
])

m4_define([TN_OPENCL_CHECK_HEADERS_DO],
  [m4_indir(m4_toupper([TN_OPENCL_CHECK_HEADERS_$2_V$1]))])



m4_define([TN_OPENCL_LIB_LIST_DEFUN],
  [m4_define(m4_toupper([TN_OPENCL_LIB_LIST_$3_$2_V$1]),
    [m4_shift3($@)])])


m4_define([TN_OPENCL_LIB_LIST],
  [m4_indir(m4_toupper([TN_OPENCL_LIB_LIST_$3_$2_V$1]))])



m4_define([TN_OPENCL_CHECK_LIBS_DEFUN],
  [
  m4_define(m4_toupper([TN_OPENCL_CHECK_LIBS_$2_V$1]),
    [
    AS_IF([test "$opencl_headers_located" == "yes"],
      [
      opencl_cl_libs=
      opencl_cl_libs_path=
      opencl_libraries_located=
      AS_IF([test  -d "$with_opencl_lib"],
        [opencl_cl_libs_path="-L$with_opencl_lib"])
    
      opencl_save_CPPFLAGS=$CPPFLAGS
      CPPFLAGS="$CPPFLAGS $opencl_cl_flags $opencl_cl_libs_path"
  
      opencl_save_LIBS=$LIBS

      AC_LANG_PUSH([C])

      m4_foreach([libs], TN_OPENCL_LIB_LIST([$1], [$2], [LINUX]),
        [
	AS_IF([test "$opencl_libraries_located" != "yes"],
	  [
          cl_libs="m4_combine([ ], [[]], [-l], libs)"
          LIBS="$cl_libs $opencl_save_LIBS"
    
          AC_LINK_IFELSE([__TN_OPENCL_PROG_CHECK_CL_V11],
            [
            opencl_cl_libs=$cl_libs
            opencl_libraries_located=yes
            ])
	  ])
	])

      AC_LANG_POP([C])
  
      CPPFLAGS=$opencl_save_CPPFLAGS
      LIBS=$opencl_save_LIBS
      ])
      
    ])
  ])

m4_define([TN_OPENCL_CHECK_LIBS_DO],
  [
  m4_indir(m4_toupper([TN_OPENCL_CHECK_LIBS_$2_V$1]))
  ])


## MACRO
## ------------
## AC_OPENCL_CHECK([<ver>], [<vnd>], [<inc>], [<lib>])
##
##   Checks the system for installed OpenCL framework and its
## libraries. 
##
## [<ver>] specifies a version of OpenCL implementation
##   - 1.1   for OpenCL 1.1 
##
## [<vnd>] specifies an OpenCL implementation of
## particular manufactorer and may have one of following values:
##   - nv    for NVidia
##   - intel for Intel
##   - any   for any of mentioned above implementation 
##
## [<inc>] include directory
##
## [<lib>] library directory
###################################################################### 
AC_DEFUN([TN_OPENCL_CHECK], 
  [
  AC_ARG_WITH([opencl],
    [AC_HELP_STRING(
      [--with-opencl@<:@=ARG@:>@],
      AC_WITH_OPENCL_HELP_STRING)],
  [],
  [with_opencl=no])
  
  AC_ARG_WITH([opencl-inc],
    [AC_HELP_STRING(
      [--with-opencl-inc@<:@=PATH@:>@],
      AC_WITH_OPENCL_INC_HELP_STRING)])
  
  AC_ARG_WITH([opencl-lib],
    [AC_HELP_STRING(
      [--with-opencl-lib@<:@=PATH@:>@],
      AC_WITH_OPENCL_LIB_HELP_STRING)])


  AS_IF([test "$with_opencl" != "no"],
    [
    AS_IF([test -z "$with_opencl_inc" -o -d "$with_opencl_inc"], [], 
      [AC_MSG_ERROR([Invalid OpenCL include directory provided.])] )
  
    AS_IF([test -z "$with_opencl_lib" -o -d "$with_opencl_lib"], [], 
      [AC_MSG_ERROR([Invalid OpenCL library directory provided.])] )
  
    AS_CASE(["$with_opencl"],
      [TN_OPENCL_CONST_NVIDIA], 
        [TN_OPENCL_CHECK_NVIDIA([$1])],
      [TN_OPENCL_CONST_INTEL], 
        [TN_OPENCL_CHECK_INTEL([$1])],
      [AC_MSG_ERROR([Invalid OpenCL vendor name provided.])])
    ])
  ])


m4_define([TN_OPENCL_CHECK_NVIDIA],
  [
  AS_CASE([$1],
    [TN_OPENCL_CONST_V10], 
      [TN_OPENCL_CHECK_NVIDIA_V10],
    [TN_OPENCL_CONST_V11], 
      [TN_OPENCL_CHECK_NVIDIA_V11],
    [AC_MSG_ERROR([Unsupported OpenCL version provided.])])
  ])

m4_define([TN_OPENCL_CHECK_NVIDIA_V10], 
    [
    AC_MSG_ERROR([Not implemented yet.])
    ])


m4_define([TN_OPENCL_CHECK_NVIDIA_V11], 
    [
    dnl Checks for headers. 
    TN_OPENCL_CHECK_HEADERS_DO([11], [LINUX])

    AS_IF(
      [test "$opencl_headers_located" == "yes"],
        [TN_OPENCL_CHECK_LIBS_DO([11], [NVIDIA])])

    AS_IF(
      [test "$opencl_headers_located" == "yes" -a \
            "$opencl_libraries_located" == "yes"],
        [
        AC_SUBST([CL_FLAGS], 
	  ["$opencl_cl_flags $opencl_cl_libs_path"])
        AC_SUBST([CL_LIBS], 
	  ["$opencl_cl_libs"])
        ],
      [AC_MSG_ERROR([Unable to find OpenCL framework])])
    ])

m4_define([TN_OPENCL_CHECK_INTEL],
  [
  AS_CASE([$1],
    [TN_OPENCL_CONST_V10], 
      [TN_OPENCL_CHECK_INTEL_V10],
    [TN_OPENCL_CONST_V11], 
      [TN_OPENCL_CHECK_INTEL_V11],
    [AC_MSG_ERROR([Unsupported OpenCL version provided.])])
  ])

m4_define([TN_OPENCL_CHECK_INTEL_V10], 
    [
    AC_MSG_ERROR([Not implemented yet.])
    ])


m4_define([TN_OPENCL_CHECK_INTEL_V11], 
    [
    dnl Checks for headers. 
    TN_OPENCL_CHECK_HEADERS_DO([11], [LINUX])

    AS_IF(
      [test "$opencl_headers_located" == "yes"],
        [TN_OPENCL_CHECK_LIBS_DO([11], [INTEL])])

    AS_IF(
      [test "$opencl_headers_located" == "yes" -a \
            "$opencl_libraries_located" == "yes"],
        [
        AC_SUBST([CL_FLAGS], 
	  ["$opencl_cl_flags $opencl_cl_libs_path"])
        AC_SUBST([CL_LIBS], 
	  ["$opencl_cl_libs"])
        ],
      [AC_MSG_ERROR([Unable to find OpenCL framework])])
    ])


TN_OPENCL_CHECK_HEADERS_DEFUN([11], [LINUX], 
  [opencl.h], 
  [cl.h])

TN_OPENCL_LIB_LIST_DEFUN([11], [NVIDIA], [LINUX], 
  [[OpenCL], [CL]])

TN_OPENCL_CHECK_LIBS_DEFUN([11], [NVIDIA])


TN_OPENCL_LIB_LIST_DEFUN([11], [INTEL], [LINUX],
dnl  [[intelocl, cl_logger, clang_compiler, cpu_device, OclCpuBackEnd, task_executor, tbb, tbbmalloc, tbbmalloc_proxy]])
  [[OpenCL]])

TN_OPENCL_CHECK_LIBS_DEFUN([11], [INTEL])
