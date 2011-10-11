#serial 1
m4_define([TN_OPENCL_CONST_V10], [1.0])
m4_define([TN_OPENCL_CONST_V11], [1.1])
m4_define([TN_OPENCL_CONST_NVIDIA], [nv])
m4_define([TN_OPENCL_CONST_INTEL], [intel])


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
  

AC_DEFUN([TN_OPENCL_CHECK_HEADERS_V11],
  [
  TN_OPENCL_CHECK_APPLE_PP_FLAG()

  AS_IF([test -d $1],
    [opencl_cl_flags="-I$1"],
    [opencl_cl_flags=])
  
  opencl_save_CPPFLAGS=$CPPFLAGS
  CPPFLAGS="$CPPFLAGS $opencl_cl_flags"
  AS_IF([test "$tn_opencl_cv_apple_pp_flag" == "no"],
    [
    AC_CHECK_HEADERS([CL/opencl.h CL/cl.h])
    AS_IF(
      [test "$ac_cv_header_cl_opencl_h" == "yes" -a \
            "$ac_cv_header_cl_cl_h" == "yes"],
      [opencl_headers_located="yes"],
      [opencl_headers_located=])
    ],
    [
    AC_CHECK_HEADERS([OpenCL/opencl.h OpenCL/cl.h])
    AS_IF(
      [test "$ac_cv_header_opencl_opencl_h" == "yes" -a \
            "$ac_cv_header_opencl_cl_h" == "yes"],
      [opencl_headers_located="yes"],
      [opencl_headers_located=])
    ])
  CPPFLAGS=$opencl_save_CPPFLAGS  
  ])


AC_DEFUN([TN_OPENCL_CHECK_LIBS_V11],
  [
  AC_REQUIRE([TN_OPENCL_CHECK_HEADERS_V11])
  AS_IF([test "$opencl_headers_located" == "yes" -a \
              "$1" != ""],
    [
    opencl_cl_libs=
    opencl_cl_libs_path=
    opencl_libraries_located=

    AS_IF([test -d $2],
      [opencl_cl_libs_path="-L$2"])
  
    opencl_save_CPPFLAGS=$CPPFLAGS
    CPPFLAGS="$CPPFLAGS $opencl_cl_flags $opencl_cl_libs_path"

    opencl_save_LIBS=$LIBS
    LIBS="-l$1 $opencl_save_LIBS"

    AC_LANG_PUSH([C])
    AC_LINK_IFELSE([__TN_OPENCL_PROG_CHECK_CL_V11],
      [
      opencl_cl_libs=$1
      opencl_libraries_located="yes"
      break
      ])
    AC_LANG_POP([C])
    ])
    
  CPPFLAGS=$opencl_save_CPPFLAGS
  LIBS=$opencl_save_LIBS
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
  AS_IF([test -z $3 -o -d $3], [], 
    [AC_MSG_ERROR([Invalid OpenCL include directory provided.])] )

  AS_IF([test -z $4 -o -d $4], [], 
    [AC_MSG_ERROR([Invalid OpenCL library directory provided.])] )

  AS_CASE(["$2"],
    [TN_OPENCL_CONST_NVIDIA], 
      [TN_OPENCL_CHECK_NVIDIA([$1], [$3], [$4])],
    [TN_OPENCL_CONST_INTEL], 
      [AC_MSG_ERROR([Not implemented yet.])],
    [AC_MSG_ERROR([Invalid OpenCL vendor name provided.])])
  ])


m4_define([TN_OPENCL_CHECK_NVIDIA],
  [
  AS_CASE([$1],
    [TN_OPENCL_CONST_V10], 
      [TN_OPENCL_CHECK_NVIDIA_V10([$2], [$3])],
    [TN_OPENCL_CONST_V11], 
      [TN_OPENCL_CHECK_NVIDIA_V11([$2], [$3])],
    [AC_MSG_ERROR([Unsupported OpenCL version provided.])])
  ])

m4_define([TN_OPENCL_CHECK_NVIDIA_V10], 
    [
    AC_MSG_ERROR([Not implemented yet.])
    ])

m4_define([TN_OPENCL_CHECK_NVIDIA_V11], 
    [
    dnl Checks for headers. 
    TN_OPENCL_CHECK_HEADERS_V11([$1])

    AS_IF(
      [test "$opencl_headers_located" == "yes"],
      [TN_OPENCL_CHECK_LIBS_NVIDIA_V11([$2])])

    AS_IF(
      [test "$opencl_headers_located" == "yes" -a \
            "$opencl_libraries_located" == "yes"],
      [
      AC_SUBST([CL_FLAGS], [$opencl_cl_flags])
      AC_SUBST([CL_LIBS], [$opencl_cl_libs])
      ])
    ])

dnl m4_define([AC_OPENCL_HEADERS_V11], 
dnl     [
dnl     AC_CACHE_VAL([opencl_m4_cv_headers_v11],
dnl       [
dnl       opencl_m4_cv_headers_v11=""
dnl       AC_LANG_PUSH([C])
dnl       AC_RUN_IFELSE([AC_OPENCL_CHECK_PROG_APPLE_FLAG],
dnl 	[opencl_m4_cv_headers_v11="OpenCL/opencl.h OpenCL/cl.h"],
dnl 	[opencl_m4_cv_headers_v11="CL/opencl.h CL/cl.h"])
dnl       AC_LANG_POP([C])
dnl       ])
dnl     ])
dnl 
dnl AC_DEFUN([AC_OPENCL_HEADERS], 
dnl     [AC_REQUIRE(AC_OPENCL_HEADERS_V11)
dnl     $opencl_m4_cv_headers_v11])
dnl 
dnl m4_define([AC_OPENCL_CHECK_PROG_APPLE_FLAG],
dnl     [
dnl     AC_LANG_PROGRAM(
dnl       [[#ifdef __APPLE__
dnl         #  define __EXIT_CODE 0
dnl 	#else
dnl 	#  define __EXIT_CODE 1
dnl 	#endif]], 
dnl       [[return __EXIT_CODE;]])
dnl     ])
dnl 
dnl m4_define([AC_OPENCL_VENDOR_NVIDIA], [nv])
dnl m4_define([AC_OPENCL_VENDOR_INTEL], [intel])
dnl m4_define([AC_OPENCL_VENDOR_ANY], [any])
dnl 
dnl 
dnl m4_define([AC_OPENCL_NVIDIA_CHECK], 
dnl   [
dnl   AC_REQUIRE([__AC_OPENCL_CHECK_HEADERS])
dnl   AC_LANG_PUSH([C])
dnl   AC_RUN_IFELSE([AC_OPENCL_CHECK_PROG_APPLE_FLAG],
dnl     [echo "Apple"],
dnl     [echo "Not Apple"])
dnl   AC_LANG_POP([C])
dnl 
dnl   m4_define([AX_CHECK_CL_PROGRAM],
dnl     [AC_LANG_PROGRAM([[
dnl       # ifdef HAVE_CL_CL_H
dnl       #   include <CL/cl.h>
dnl       # else
dnl       #   error no cl.h
dnl       # endif]],
dnl       [[clFinish(0)]])])
dnl 
dnl   AC_CACHE_CHECK([for OpenCL library], 
dnl     [ax_cv_check_cl_libcl],
dnl     [
dnl     ax_cv_check_cl_libcl=no
dnl     AS_CASE([$host_cpu],
dnl       [x86_64], [ax_check_cl_libdir=lib64],
dnl       [ax_check_cl_libdir=lib])
dnl 
dnl     ax_save_CPPFLAGS=$CPPFLAGS
dnl     CPPFLAGS="$CL_CPPFLAGS $CPPFLAGS"
dnl     ax_save_LIBS=$LIBS
dnl     LIBS=""
dnl     ax_check_libs="-lOpenCL -lCL"
dnl 
dnl     AC_LANG_PUSH([C])
dnl 
dnl     for ax_lib in $ax_check_libs; do
dnl       LIBS="$ax_lib $ax_save_LIBS"
dnl       AC_LINK_IFELSE([AX_CHECK_CL_PROGRAM],
dnl         [ax_cv_check_cl_libcl=$ax_lib; break],
dnl 	[echo "Error to ling against the $ax_lib library"])o
dnl     done	
dnl 
dnl     AC_LANG_POP([C])
dnl     ])
dnl   
dnl     LIBS=$ax_save_LIBS
dnl     CPPFLAGS=$ax_save_CPPFLAGS
dnl 
dnl     AS_IF([test "X$ax_cv_check_cl_libcl" = Xno],
dnl       [no_cl=yes; CL_CPPFLAGS=""; CL_LIBS=""],
dnl       [CL_LIBS="$ax_cv_check_cl_libcl"])
dnl 
dnl     AC_SUBST([CL_CPPFLAGS])
dnl     AC_SUBST([CL_LIBS])
dnl 
dnl   ])
dnl 
dnl   m4_define([AC_OPENCL_INTEL_CHECK], 
dnl   [
dnl   echo "Checks for Int v $1"
dnl   __AC_OPENCL_CHECK_HEADERS
dnl   AC_MSG_ERROR("Doesn't support for Intel")
dnl   ])
dnl 
dnl AC_DEFUN([__AC_OPENCL_CHECK_HEADERS],
dnl   [
dnl   AC_LANG_PUSH([C])
dnl   AS_IF([test -d $with_opencl_inc],
dnl     [CL_CPPFLAGS="-I$with_opencl_inc"])
dnl 
dnl   ac_opencl_save_CPPFLAGS=$CPPFLAGS
dnl   CPPFLAGS="$CL_CPPFLAGS $CPPFLAGS"
dnl   AC_CHECK_HEADERS([AC_OPENCL_HEADERS])
dnl   CPPFLAGS=$ac_opencl_save_CPPFLAGS
dnl   AC_LANG_POP([C])
dnl   ])
dnl 
dnl 
dnl dnl --=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--= 
dnl m4_define([AC_WITH_OPENCL_HELP_STRING],
dnl   [points to the need to check system for installed OpenCL \
dnl   framework and its libraries. The @<:@ARG@:>@ argument \
dnl   specifies a vendor for whos OpenCL implementation system \
dnl   will be checked and it may have one of predefined values: \
dnl   AC_OPENCL_VENDOR_NVIDIA - for Nvidia[,] \
dnl   AC_OPENCL_VENDOR_INTEL - for Intel. dnl
dnl   dnl  AC_OPENCL_VENDOR_ANY - for any. 
dnl   ])
dnl 
dnl dnl --=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--= 
dnl m4_define([AC_WITH_OPENCL_INC_HELP_STRING],
dnl   [path to directory[,] where OpenCL header files are located.])
dnl 
dnl 
dnl dnl --=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--= 
dnl m4_define([AC_WITH_OPENCL_LIB_HELP_STRING],
dnl   [path to directory[,] where OpenCL library files are located.])
dnl 
dnl dnl --=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--= 
dnl m4_define([AC_OPENCL_WITH_PARAM_CONSISTENCY_CHECK],
dnl   [
dnl   dnl Checks for OpenCL version requested
dnl   AS_IF(
dnl     [test "$1" != "1.1"],
dnl     [AC_MSG_ERROR([Invalid OpenCL version provided.])])
dnl 
dnl   dnl Checks for OpenCL vendor
dnl   AS_IF(
dnl     [test "$2" = "AC_OPENCL_VENDOR_NVIDIA" -o \
dnl           "$2" = "AC_OPENCL_VENDOR_INTEL" -o \
dnl           "$2" = "AC_OPENCL_VENDOR_ANY"],
dnl     [AS_IF(
dnl       [test -d "$3" -o \
dnl             -z "$3" && \
dnl        test -d "$4" -o \
dnl             -z "$4"],
dnl       [opencl_requested=1],
dnl       [AC_MSG_ERROR([Invalid options provided.])])],
dnl     [opencl_requested=0])
dnl   ])  
dnl 
dnl 
dnl AC_DEFUN([AC_OPENCL_CHECK],
dnl   [
dnl   AC_ARG_WITH([opencl],
dnl     [AC_HELP_STRING(
dnl       [--with-opencl@<:@=ARG@:>@],
dnl       AC_WITH_OPENCL_HELP_STRING)])
dnl 
dnl   AC_ARG_WITH([opencl-inc],
dnl     [AC_HELP_STRING(
dnl       [--with-opencl-inc@<:@=PATH@:>@],
dnl       AC_WITH_OPENCL_INC_HELP_STRING)])
dnl 
dnl   AC_ARG_WITH([opencl-lib],
dnl     [AC_HELP_STRING(
dnl       [--with-opencl-lib@<:@=PATH@:>@],
dnl       AC_WITH_OPENCL_LIB_HELP_STRING)])
dnl 
dnl   AC_OPENCL_WITH_PARAM_CONSISTENCY_CHECK(
dnl     [$1], [$with_opencl], [$with_opencl_inc], [$with_opencl_lib])
dnl 
dnl   AS_IF(
dnl     [test "$opencl_requested" = "1" -a \
dnl           "$with_opencl" = "AC_OPENCL_VENDOR_NVIDIA"],
dnl       [AC_OPENCL_NVIDIA_CHECK],
dnl     [test "$opencl_requested" = "1" -a \
dnl           "$with_opencl" = "AC_OPENCL_VENDOR_INTEL"],
dnl       [AC_OPENCL_INTEL_CHECK],
dnl     [echo cancel])
dnl   ])
