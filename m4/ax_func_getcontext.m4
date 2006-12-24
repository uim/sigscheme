##### 
#
# SYNOPSIS
#
#   AX_FUNC_GETCONTEXT
#
# DESCRIPTION
#
#   Checks whether getcontext(3) is available.
#
#   This macro uses compile-time detection and so is cross-compile
#   ready.
#
# LAST MODIFICATION
#
#   2006-12-25
#
# COPYLEFT
#
#   Copyright (c) 2006 YAMAMOTO Kengo <yamaken AT bp.iij4u.or.jp>
#
#   Copying and distribution of this file, with or without
#   modification, are permitted in any medium without royalty provided
#   the copyright notice and this notice are preserved.

AC_DEFUN([AX_FUNC_GETCONTEXT], [
  AC_CACHE_CHECK([for getcontext],
                 [ax_cv_func_getcontext],
                 [AC_LINK_IFELSE(
                    AC_LANG_PROGRAM([[@%:@include <ucontext.h>]],
                                    [[ucontext_t ctx;
                                      return getcontext(&ctx);]]),
                    [ax_cv_func_getcontext=yes],
                    [ax_cv_func_getcontext=no])])
  if test "x$ax_cv_func_getcontext" = xyes; then
    AC_DEFINE([HAVE_GETCONTEXT], [1],
              [Define to 1 if you have the `getcontext' function.])
  fi
])
