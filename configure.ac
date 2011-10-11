#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

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

AC_PREREQ([2.65])
AC_INIT([opencl.m4], [0.1], [ldm.thread@gmail.com])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([-Werror -Wall foreign])


# Checks for programs.
AC_PROG_CXX

# Checks for libraries.
AC_ARG_WITH([opencl],
  [AC_HELP_STRING(
    [--with-opencl@<:@=ARG@:>@],
    AC_WITH_OPENCL_HELP_STRING)])

AC_ARG_WITH([opencl-inc],
  [AC_HELP_STRING(
    [--with-opencl-inc@<:@=PATH@:>@],
    AC_WITH_OPENCL_INC_HELP_STRING)])

AC_ARG_WITH([opencl-lib],
  [AC_HELP_STRING(
    [--with-opencl-lib@<:@=PATH@:>@],
    AC_WITH_OPENCL_LIB_HELP_STRING)])

dnl AC_OPENCL_CHECK([1.1], [], [])

TN_OPENCL_CHECK([1.1],
  [$with_opencl],
  [$with_opencl_inc],
  [$with_opencl_lib])

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_CONFIG_FILES([Makefile
  tests/Makefile])
AC_OUTPUT
