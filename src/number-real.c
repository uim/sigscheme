/*===========================================================================
 *  Filename : number-real.c
 *  About    : Procedures for inexact real numbers
 *
 *  Copyright (c) 2026 SigScheme Project https://github.com/uim/sigscheme
 *
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *  3. Neither the name of authors nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS
 *  IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *  PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
 *  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 *  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 *  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 *  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 *  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 *  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
===========================================================================*/

#include <config.h>

#include <math.h>

#include <sigscheme/sigscheme.h>
#include "sigschemeinternal.h"

/*=======================================
  File Local Macro Definitions
=======================================*/

/*=======================================
  File Local Type Definitions
=======================================*/

/*=======================================
  Variable Definitions
=======================================*/

/*=======================================
  File Local Function Declarations
=======================================*/
static double simplest_rational(double lo, double hi);

/*=======================================
  Function Definitions
=======================================*/
/*===========================================================================
  R7RS : 6.2 Numbers : 6.2.6 Numerical operations
===========================================================================*/
/* Returns the simplest rational number in [LO, HI] where 0 < LO <= HI. It's
 * the smallest integer in the range if exists. Otherwise, it's FL + 1 / R
 * where FL is floor(LO) and R is the simplest rational number in
 * [1 / (HI - FL), 1 / (LO - FL)]. */
static double
simplest_rational(double lo, double hi)
{
    double fl;

    fl = floor(lo);
    if (fl == lo)
        return fl;
    if (fl < floor(hi))
        return fl + 1.0;
    return fl + 1.0 / simplest_rational(1.0 / (hi - fl), 1.0 / (lo - fl));
}

SCM_EXPORT ScmObj
scm_p_rationalize(ScmObj x, ScmObj y)
{
    double dx, dy, lo, hi, r;
    scm_int_t n;
    DECLARE_FUNCTION("rationalize", procedure_fixed_2);

    dx = scm_real_value(SCM_MANGLE(name), x);
    dy = scm_real_value(SCM_MANGLE(name), y);
    lo = dx - fabs(dy);
    hi = dx + fabs(dy);
    if (isnan(lo) || isnan(hi))
        r = NAN;
    else if (lo <= 0.0 && 0.0 <= hi)
        r = 0.0;
    else if (hi < 0.0)
        r = -simplest_rational(-hi, -lo);
    else
        r = simplest_rational(lo, hi);

    if (REALP(x) || REALP(y))
        return MAKE_REAL(r);
    /* Rationals aren't supported. */
    if (!scm_real2int(r, &n))
        ERR_OBJ("exact integer can't represent the result for", LIST_2(x, y));
    return MAKE_INT(n);
}

/* Returns an exact integer for an exact perfect square. */
SCM_EXPORT ScmObj
scm_p_sqrt(ScmObj z)
{
    double d;
    scm_int_t n, root;
    DECLARE_FUNCTION("sqrt", procedure_fixed_1);

    d = scm_real_value(SCM_MANGLE(name), z);
    if (d < 0.0)
        ERR_OBJ(ERRMSG_COMPLEX_NOT_SUPPORTED, z);
    if (INTP(z)) {
        n = SCM_INT_VALUE(z);
        /* sqrt() may be rounded for large N. */
        root = (scm_int_t)sqrt(d);
        while (root * root > n)
            root--;
        while ((root + 1) * (root + 1) <= n)
            root++;
        if (root * root == n)
            return MAKE_INT(root);
    }

    return MAKE_REAL(sqrt(d));
}

SCM_EXPORT ScmObj
scm_p_exp(ScmObj z)
{
    DECLARE_FUNCTION("exp", procedure_fixed_1);

    return MAKE_REAL(exp(scm_real_value(SCM_MANGLE(name), z)));
}

/* (log z1 z2) is the logarithm of Z1 to the base Z2. */
SCM_EXPORT ScmObj
scm_p_log(ScmObj z1, ScmObj args)
{
    ScmObj z2;
    double d1, d2;
    DECLARE_FUNCTION("log", procedure_variadic_1);

    d1 = scm_real_value(SCM_MANGLE(name), z1);
    if (d1 < 0.0)
        ERR_OBJ(ERRMSG_COMPLEX_NOT_SUPPORTED, z1);
    if (NULLP(args))
        return MAKE_REAL(log(d1));

    z2 = POP(args);
    ASSERT_NO_MORE_ARG(args);
    d2 = scm_real_value(SCM_MANGLE(name), z2);
    if (d2 < 0.0)
        ERR_OBJ(ERRMSG_COMPLEX_NOT_SUPPORTED, z2);
    return MAKE_REAL(log(d1) / log(d2));
}

SCM_EXPORT ScmObj
scm_p_sin(ScmObj z)
{
    DECLARE_FUNCTION("sin", procedure_fixed_1);

    return MAKE_REAL(sin(scm_real_value(SCM_MANGLE(name), z)));
}

SCM_EXPORT ScmObj
scm_p_cos(ScmObj z)
{
    DECLARE_FUNCTION("cos", procedure_fixed_1);

    return MAKE_REAL(cos(scm_real_value(SCM_MANGLE(name), z)));
}

SCM_EXPORT ScmObj
scm_p_tan(ScmObj z)
{
    DECLARE_FUNCTION("tan", procedure_fixed_1);

    return MAKE_REAL(tan(scm_real_value(SCM_MANGLE(name), z)));
}

SCM_EXPORT ScmObj
scm_p_asin(ScmObj z)
{
    double d;
    DECLARE_FUNCTION("asin", procedure_fixed_1);

    d = scm_real_value(SCM_MANGLE(name), z);
    if (fabs(d) > 1.0)
        ERR_OBJ(ERRMSG_COMPLEX_NOT_SUPPORTED, z);
    return MAKE_REAL(asin(d));
}

SCM_EXPORT ScmObj
scm_p_acos(ScmObj z)
{
    double d;
    DECLARE_FUNCTION("acos", procedure_fixed_1);

    d = scm_real_value(SCM_MANGLE(name), z);
    if (fabs(d) > 1.0)
        ERR_OBJ(ERRMSG_COMPLEX_NOT_SUPPORTED, z);
    return MAKE_REAL(acos(d));
}

/* (atan y x) is the angle of the point (x, y). */
SCM_EXPORT ScmObj
scm_p_atan(ScmObj y, ScmObj args)
{
    ScmObj x;
    DECLARE_FUNCTION("atan", procedure_variadic_1);

    if (NULLP(args))
        return MAKE_REAL(atan(scm_real_value(SCM_MANGLE(name), y)));

    x = POP(args);
    ASSERT_NO_MORE_ARG(args);
    return MAKE_REAL(atan2(scm_real_value(SCM_MANGLE(name), y),
                           scm_real_value(SCM_MANGLE(name), x)));
}
