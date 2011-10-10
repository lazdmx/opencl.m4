#serial 1

m4_define([AC_OPENCL_VENDOR_NVIDIA], [nv])
m4_define([AC_OPENCL_VENDOR_INTEL], [intel])
m4_define([AC_OPENCL_VENDOR_ANY], [any])


m4_define([AC_OPENCL_NVIDIA_CHECK], 
  [
  AC_REQUIRE([__AC_OPENCL_CHECK_HEADERS])

  m4_define([AX_CHECK_CL_PROGRAM],
    [AC_LANG_PROGRAM([[
      # ifdef HAVE_CL_CL_H
      #   include <CL/cl.h>
      # else
      #   error no cl.h
      # endif]],
      [[clFinish(0)]])])

  AC_CACHE_CHECK([for OpenCL library], 
    [ax_cv_check_cl_libcl],
    [
    ax_cv_check_cl_libcl=no
    AS_CASE([$host_cpu],
      [x86_64], [ax_check_cl_libdir=lib64],
      [ax_check_cl_libdir=lib])

    ax_save_CPPFLAGS=$CPPFLAGS
    CPPFLAGS="$CL_CPPFLAGS $CPPFLAGS"
    ax_save_LIBS=$LIBS
    LIBS=""
    ax_check_libs="-lOpenCL -lCL"

    AC_LANG_PUSH([C])

    for ax_lib in $ax_check_libs; do
      LIBS="$ax_lib $ax_save_LIBS"
      AC_LINK_IFELSE([AX_CHECK_CL_PROGRAM],
        [ax_cv_check_cl_libcl=$ax_lib; break],
	[echo "Error to ling against the $ax_lib library"])o
    done	

    AC_LANG_POP([C])
    ])
  
    LIBS=$ax_save_LIBS
    CPPFLAGS=$ax_save_CPPFLAGS

    AS_IF([test "X$ax_cv_check_cl_libcl" = Xno],
      [no_cl=yes; CL_CPPFLAGS=""; CL_LIBS=""],
      [CL_LIBS="$ax_cv_check_cl_libcl"])

    AC_SUBST([CL_CPPFLAGS])
    AC_SUBST([CL_LIBS])

  ])

  m4_define([AC_OPENCL_INTEL_CHECK], 
  [
  echo "Checks for Int v $1"
  __AC_OPENCL_CHECK_HEADERS
  AC_MSG_ERROR("Doesn't support for Intel")
  ])

AC_DEFUN([__AC_OPENCL_CHECK_HEADERS],
  [
  AC_LANG_PUSH([C])
  AS_IF([test -d $with_opencl_inc],
    [CL_CPPFLAGS="-I$with_opencl_inc"])

  ac_opencl_save_CPPFLAGS=$CPPFLAGS
  CPPFLAGS="$CL_CPPFLAGS $CPPFLAGS"
  AC_CHECK_HEADERS([CL/cl.h CL/opencl.h])
  CPPFLAGS=$ac_opencl_save_CPPFLAGS
  AC_LANG_POP([C])
  ])


dnl --=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--= 
m4_define([AX_WITH_OPENCL_HELP_STRING],
  [points to the need to check system for installed OpenCL \
  framework and its libraries. The @<:@ARG@:>@ argument \
  specifies a vendor for whos OpenCL implementation system \
  will be checked and it may have one of predefined values: \
  AC_OPENCL_VENDOR_NVIDIA - for Nvidia. \
dnl  AC_OPENCL_VENDOR_INTEL - for Intel and \
dnl  AC_OPENCL_VENDOR_ANY - for any. 
  If the @<:@ARG@:>@ argument is not set[,] system will be \
  checked for any available OpenCL implementation.])

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
    [test "$1" != "1.1"],
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
      [AC_MSG_ERROR([Invalid options provided.])])],
    [opencl_requested=0])
  ])  


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
      [AC_OPENCL_NVIDIA_CHECK],
    [test "$opencl_requested" = "1" -a \
          "$with_opencl" = "AC_OPENCL_VENDOR_INTEL"],
      [AC_OPENCL_INTEL_CHECK],
    [echo cancel])
  ])
