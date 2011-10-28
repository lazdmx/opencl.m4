#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.


AC_PREREQ([2.65])
AC_INIT([opencl.m4], [0.1], [ldm.thread@gmail.com])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([-Werror -Wall foreign])


# Checks for programs.
AC_PROG_CXX

# Checks for libraries.

dnl AC_OPENCL_CHECK([1.1], [], [])

TN_OPENCL_CHECK([1.1])

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_CONFIG_FILES([Makefile
  tests/Makefile])
AC_OUTPUT
