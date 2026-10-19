/*===========================================================================
 *  Filename : number.c
 *  About    : R5RS numbers
 *
 *  Copyright (C) 2005      Kazuki Ohta <mover AT hct.zaq.ne.jp>
 *  Copyright (C) 2005-2006 Jun Inoue <jun.lambda AT gmail.com>
 *  Copyright (C) 2005-2006 YAMAMOTO Kengo <yamaken AT bp.iij4u.or.jp>
 *  Copyright (c) 2007-2026 SigScheme Project https://github.com/uim/sigscheme
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

#if SCM_USE_REAL
#include <math.h>
#endif

#include <sigscheme/sigscheme.h>
#include "sigschemeinternal.h"

/*=======================================
  File Local Macro Definitions
=======================================*/
#define ERRMSG_REQ_1_ARG       "at least 1 argument required"
#define ERRMSG_NEGATIVE_EXP    "negative exponent"

/*=======================================
  File Local Type Definitions
=======================================*/

/*=======================================
  Variable Definitions
=======================================*/

/*=======================================
  File Local Function Declarations
=======================================*/
static scm_int_t gcd(const char *func_name, scm_int_t x, scm_int_t y);

/*=======================================
  Function Definitions
=======================================*/
/* The following functions signal an error instead of overflowing. They
 * don't compute out of range values because overflow of signed integers is
 * undefined behavior. */

SCM_EXPORT scm_int_t
scm_int_multiply(const char *func_name, scm_int_t n1, scm_int_t n2)
{
    if (n1 > 0
        ? (n2 > 0 ? n1 > SCM_INT_MAX / n2 : n2 < SCM_INT_MIN / n1)
        : (n2 > 0 ? n1 < SCM_INT_MIN / n2 : n2 < 0 && n1 < SCM_INT_MAX / n2))
        scm_error(func_name, ERRMSG_FIXNUM_OVERFLOW);

    return n1 * n2;
}

/* Returns the quotient truncated toward zero. */
SCM_EXPORT scm_int_t
scm_int_quotient(const char *func_name, scm_int_t n1, scm_int_t n2)
{
    if (n2 == 0)
        scm_error(func_name, ERRMSG_DIV_BY_ZERO);
    if (n1 == SCM_INT_MIN && n2 == -1)
        scm_error(func_name, ERRMSG_FIXNUM_OVERFLOW);

    return n1 / n2;
}

/* Returns the remainder that has the same sign as N1. */
SCM_EXPORT scm_int_t
scm_int_remainder(const char *func_name, scm_int_t n1, scm_int_t n2)
{
    if (n2 == 0)
        scm_error(func_name, ERRMSG_DIV_BY_ZERO);
    /* SCM_INT_MIN % -1 may overflow. */
    if (n2 == -1)
        return 0;

    return n1 % n2;
}

/* Returns the remainder that has the same sign as N2. */
SCM_EXPORT scm_int_t
scm_int_modulo(const char *func_name, scm_int_t n1, scm_int_t n2)
{
    scm_int_t rem;

    rem = scm_int_remainder(func_name, n1, n2);
    if (rem && ((rem < 0) != (n2 < 0)))
        rem += n2;

    return rem;
}

/*===========================================================================
  R5RS : 6.2 Numbers : 6.2.5 Numerical Operations
===========================================================================*/
/* Note: SigScheme supports only the integer part of the numerical tower. */

SCM_EXPORT ScmObj
scm_p_add(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    scm_int_t result, l, r;
    DECLARE_FUNCTION("+", reduction_operator);

    result = l = 0;
    switch (*state) {
    case SCM_REDUCE_PARTWAY:
    case SCM_REDUCE_LAST:
        ENSURE_INT(left);
        l = SCM_INT_VALUE(left);
        /* Fall through. */
    case SCM_REDUCE_1:
        ENSURE_INT(right);
        r = SCM_INT_VALUE(right);
        if (r > 0 ? l > SCM_INT_MAX - r : l < SCM_INT_MIN - r)
            ERR(ERRMSG_FIXNUM_OVERFLOW);
        result = l + r;
        /* Fall through. */
    case SCM_REDUCE_0:
        break;
    default:
        SCM_NOTREACHED;
    }

    return MAKE_INT(result);
}

SCM_EXPORT ScmObj
scm_p_multiply(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    scm_int_t result;
    DECLARE_FUNCTION("*", reduction_operator);

    result = 1;
    switch (*state) {
    case SCM_REDUCE_PARTWAY:
    case SCM_REDUCE_LAST:
        ENSURE_INT(left);
        result = SCM_INT_VALUE(left);
        /* Fall through. */
    case SCM_REDUCE_1:
        ENSURE_INT(right);
        result = scm_int_multiply(SCM_MANGLE(name), result,
                                  SCM_INT_VALUE(right));
        /* Fall through. */
    case SCM_REDUCE_0:
        break;
    default:
        SCM_NOTREACHED;
    }

    return MAKE_INT(result);
}

SCM_EXPORT ScmObj
scm_p_subtract(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    scm_int_t result, l, r;
    DECLARE_FUNCTION("-", reduction_operator);

    result = l = 0;
    switch (*state) {
    case SCM_REDUCE_PARTWAY:
    case SCM_REDUCE_LAST:
        ENSURE_INT(left);
        l = SCM_INT_VALUE(left);
        /* Fall through. */
    case SCM_REDUCE_1:
        ENSURE_INT(right);
        r = SCM_INT_VALUE(right);
        if (r < 0 ? l > SCM_INT_MAX + r : l < SCM_INT_MIN + r)
            ERR(ERRMSG_FIXNUM_OVERFLOW);
        result = l - r;
        break;

    case SCM_REDUCE_0:
        ERR(ERRMSG_REQ_1_ARG);
    default:
        SCM_NOTREACHED;
    }
    return MAKE_INT(result);
}

SCM_EXPORT ScmObj
scm_p_divide(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    scm_int_t result, val;
    DECLARE_FUNCTION("/", reduction_operator);

    result = 1;
    switch (*state) {
    case SCM_REDUCE_PARTWAY:
    case SCM_REDUCE_LAST:
        ENSURE_INT(left);
        result = SCM_INT_VALUE(left);
        /* Fall through. */
    case SCM_REDUCE_1:
        ENSURE_INT(right);
        val = SCM_INT_VALUE(right);
        result = scm_int_quotient(SCM_MANGLE(name), result, val);
        break;

    case SCM_REDUCE_0:
        ERR(ERRMSG_REQ_1_ARG);
    default:
        SCM_NOTREACHED;
    }
    return MAKE_INT(result);
}

SCM_EXPORT ScmObj
scm_p_numberp(ScmObj obj)
{
    DECLARE_FUNCTION("number?", procedure_fixed_1);

    return MAKE_BOOL(NUMBERP(obj));
}

SCM_EXPORT ScmObj
scm_p_integerp(ScmObj obj)
{
    DECLARE_FUNCTION("integer?", procedure_fixed_1);

#if SCM_USE_REAL
    /* 2.0 is an integer. */
    if (REALP(obj))
        return MAKE_BOOL(scm_real_integerp(SCM_REAL_VALUE(obj)));
#endif
    return MAKE_BOOL(INTP(obj));
}

/* SigScheme supports only exact integers and inexact reals. So all numbers
 * are reals. */
SCM_EXPORT ScmObj
scm_p_complexp(ScmObj obj)
{
    DECLARE_FUNCTION("complex?", procedure_fixed_1);

    return MAKE_BOOL(NUMBERP(obj));
}

SCM_EXPORT ScmObj
scm_p_realp(ScmObj obj)
{
    DECLARE_FUNCTION("real?", procedure_fixed_1);

    return MAKE_BOOL(NUMBERP(obj));
}

/* All finite reals are rationals. */
SCM_EXPORT ScmObj
scm_p_rationalp(ScmObj obj)
{
    DECLARE_FUNCTION("rational?", procedure_fixed_1);

#if SCM_USE_REAL
    if (REALP(obj))
        return MAKE_BOOL(isfinite(SCM_REAL_VALUE(obj)));
#endif
    return MAKE_BOOL(INTP(obj));
}

SCM_EXPORT ScmObj
scm_p_exactp(ScmObj z)
{
    DECLARE_FUNCTION("exact?", procedure_fixed_1);

    ENSURE_NUMBER(z);

    return MAKE_BOOL(INTP(z));
}

SCM_EXPORT ScmObj
scm_p_inexactp(ScmObj z)
{
    DECLARE_FUNCTION("inexact?", procedure_fixed_1);

    ENSURE_NUMBER(z);

    return MAKE_BOOL(!INTP(z));
}

#if SCM_USE_REAL
/* Returns true if D is an integer. All doubles whose absolute value is 2^52
 * or more are integers. */
SCM_EXPORT scm_bool
scm_real_integerp(double d)
{
    if (!isfinite(d))
        return scm_false;
    if (d <= -4503599627370496.0 || 4503599627370496.0 <= d)
        return scm_true;
    return d == (double)(int64_t)d;
}
#endif

#define COMPARATOR_BODY(op)                                                  \
    switch (*state) {                                                        \
    case SCM_REDUCE_0:                                                       \
    case SCM_REDUCE_1:                                                       \
        ERR("at least 2 arguments required");                                \
    case SCM_REDUCE_PARTWAY:                                                 \
    case SCM_REDUCE_LAST:                                                    \
        ENSURE_INT(left);                                                    \
        ENSURE_INT(right);                                                   \
        if (SCM_INT_VALUE(left) op SCM_INT_VALUE(right))                     \
            return (*state == SCM_REDUCE_LAST) ? SCM_TRUE : right;           \
        *state = SCM_REDUCE_STOP;                                            \
        break;                                                               \
                                                                             \
    default:                                                                 \
        SCM_NOTREACHED;                                                      \
    }                                                                        \
    return SCM_FALSE

SCM_EXPORT ScmObj
scm_p_equal(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    DECLARE_FUNCTION("=", reduction_operator);

    COMPARATOR_BODY(==);
}

SCM_EXPORT ScmObj
scm_p_less(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    DECLARE_FUNCTION("<", reduction_operator);

    COMPARATOR_BODY(<);
}

SCM_EXPORT ScmObj
scm_p_less_equal(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    DECLARE_FUNCTION("<=", reduction_operator);

    COMPARATOR_BODY(<=);
}

SCM_EXPORT ScmObj
scm_p_greater(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    DECLARE_FUNCTION(">", reduction_operator);

    COMPARATOR_BODY(>);
}

SCM_EXPORT ScmObj
scm_p_greater_equal(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    DECLARE_FUNCTION(">=", reduction_operator);

    COMPARATOR_BODY(>=);
}

#undef COMPARATOR_BODY

SCM_EXPORT ScmObj
scm_p_zerop(ScmObj n)
{
    DECLARE_FUNCTION("zero?", procedure_fixed_1);

    ENSURE_INT(n);

    return MAKE_BOOL(SCM_INT_VALUE(n) == 0);
}

SCM_EXPORT ScmObj
scm_p_positivep(ScmObj n)
{
    DECLARE_FUNCTION("positive?", procedure_fixed_1);

    ENSURE_INT(n);

    return MAKE_BOOL(SCM_INT_VALUE(n) > 0);
}

SCM_EXPORT ScmObj
scm_p_negativep(ScmObj n)
{
    DECLARE_FUNCTION("negative?", procedure_fixed_1);

    ENSURE_INT(n);

    return MAKE_BOOL(SCM_INT_VALUE(n) < 0);
}

SCM_EXPORT ScmObj
scm_p_oddp(ScmObj n)
{
    DECLARE_FUNCTION("odd?", procedure_fixed_1);

    ENSURE_INT(n);

    return MAKE_BOOL(SCM_INT_VALUE(n) & 0x1);
}

SCM_EXPORT ScmObj
scm_p_evenp(ScmObj n)
{
    DECLARE_FUNCTION("even?", procedure_fixed_1);

    ENSURE_INT(n);

    return MAKE_BOOL(!(SCM_INT_VALUE(n) & 0x1));
}

SCM_EXPORT ScmObj
scm_p_max(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    DECLARE_FUNCTION("max", reduction_operator);

    if (*state == SCM_REDUCE_0)
        ERR(ERRMSG_REQ_1_ARG);
    ENSURE_INT(left);
    ENSURE_INT(right);

    return (SCM_INT_VALUE(left) > SCM_INT_VALUE(right)) ? left : right;
}

SCM_EXPORT ScmObj
scm_p_min(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    DECLARE_FUNCTION("min", reduction_operator);

    if (*state == SCM_REDUCE_0)
        ERR(ERRMSG_REQ_1_ARG);
    ENSURE_INT(left);
    ENSURE_INT(right);

    return (SCM_INT_VALUE(left) < SCM_INT_VALUE(right)) ? left : right;
}


SCM_EXPORT ScmObj
scm_p_abs(ScmObj _n)
{
    scm_int_t n;
    DECLARE_FUNCTION("abs", procedure_fixed_1);

    ENSURE_INT(_n);

    n = SCM_INT_VALUE(_n);
    if (n == SCM_INT_MIN)
        ERR(ERRMSG_FIXNUM_OVERFLOW);

    return (n < 0) ? MAKE_INT(-n) : _n;
}

SCM_EXPORT ScmObj
scm_p_quotient(ScmObj _n1, ScmObj _n2)
{
    scm_int_t n1, n2;
    DECLARE_FUNCTION("quotient", procedure_fixed_2);

    ENSURE_INT(_n1);
    ENSURE_INT(_n2);

    n1 = SCM_INT_VALUE(_n1);
    n2 = SCM_INT_VALUE(_n2);

    return MAKE_INT(scm_int_quotient(SCM_MANGLE(name), n1, n2));
}

SCM_EXPORT ScmObj
scm_p_modulo(ScmObj _n1, ScmObj _n2)
{
    scm_int_t n1, n2;
    DECLARE_FUNCTION("modulo", procedure_fixed_2);

    ENSURE_INT(_n1);
    ENSURE_INT(_n2);

    n1 = SCM_INT_VALUE(_n1);
    n2 = SCM_INT_VALUE(_n2);

    return MAKE_INT(scm_int_modulo(SCM_MANGLE(name), n1, n2));
}

SCM_EXPORT ScmObj
scm_p_remainder(ScmObj _n1, ScmObj _n2)
{
    scm_int_t n1, n2;
    DECLARE_FUNCTION("remainder", procedure_fixed_2);

    ENSURE_INT(_n1);
    ENSURE_INT(_n2);

    n1 = SCM_INT_VALUE(_n1);
    n2 = SCM_INT_VALUE(_n2);

    return MAKE_INT(scm_int_remainder(SCM_MANGLE(name), n1, n2));
}

SCM_EXPORT ScmObj
scm_p_expt(ScmObj _base, ScmObj _expo)
{
    scm_int_t base, expo, result;
    DECLARE_FUNCTION("expt", procedure_fixed_2);

    ENSURE_INT(_base);
    ENSURE_INT(_expo);

    base = SCM_INT_VALUE(_base);
    expo = SCM_INT_VALUE(_expo);

    /* SigScheme only implements integer numbers, so negative
       exponents are not allowed. */
    if (expo < 0) ERR(ERRMSG_NEGATIVE_EXP);

    result = 1;
    while (expo > 0) {
        if (expo % 2 == 1)
            result = scm_int_multiply(SCM_MANGLE(name), result, base);
        expo /= 2;
        /* Don't compute the unused square to avoid false overflow. */
        if (expo > 0)
            base = scm_int_multiply(SCM_MANGLE(name), base, base);
    }
    return MAKE_INT(result);
}

static scm_int_t
gcd(const char *func_name, scm_int_t x, scm_int_t y)
{
    /* Note: we do not check the sign of x and y, because
       this does not affect the computation, except maybe
       for the sign of the result. So we do compute the
       absolute value in the end. This is one single
       computation of abs, instead of two. */
    scm_int_t tmp;
    while (x != 0) {
        tmp = x;
        x = scm_int_remainder(func_name, y, x);
        y = tmp;
    }
    if (y == SCM_INT_MIN)
        scm_error(func_name, ERRMSG_FIXNUM_OVERFLOW);
    return (y >= 0) ? y : -y;
}

SCM_EXPORT
ScmObj scm_p_gcd(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    scm_int_t result;
    DECLARE_FUNCTION("gcd", reduction_operator);

    result = 0;
    switch (*state) {
    case SCM_REDUCE_PARTWAY:
    case SCM_REDUCE_LAST:
        ENSURE_INT(left);
        result = SCM_INT_VALUE(left);
        /* Fall through. */
    case SCM_REDUCE_1:
        ENSURE_INT(right);
        result = gcd(SCM_MANGLE(name), result, SCM_INT_VALUE(right));
        /* Fall through. */
    case SCM_REDUCE_0:
        break;
    default:
        SCM_NOTREACHED;
    }
    return MAKE_INT(result);
}

SCM_EXPORT ScmObj
scm_p_lcm(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    scm_int_t result, r;
    DECLARE_FUNCTION("lcm", reduction_operator);

    result = 1;
    switch (*state) {
    case SCM_REDUCE_PARTWAY:
    case SCM_REDUCE_LAST:
        ENSURE_INT(left);
        result = SCM_INT_VALUE(left);
        /* Fall through. */
    case SCM_REDUCE_1:
        ENSURE_INT(right);
        r = SCM_INT_VALUE(right);
        if (result == 0 || r == 0)
            result = 0;
        else
            result = scm_int_multiply(SCM_MANGLE(name), result,
                                      r / gcd(SCM_MANGLE(name), result, r));
        /* Fall through. */
    case SCM_REDUCE_0:
        break;
    default:
        SCM_NOTREACHED;
    }
    if (result == SCM_INT_MIN)
        ERR(ERRMSG_FIXNUM_OVERFLOW);
    if (result < 0) result = -result;
    return MAKE_INT(result);
}

/* SigScheme supports only exact integers. So the following procedures
 * are trivial. */
SCM_EXPORT ScmObj
scm_p_numerator(ScmObj q)
{
    DECLARE_FUNCTION("numerator", procedure_fixed_1);

    ENSURE_INT(q);

    return q;
}

SCM_EXPORT ScmObj
scm_p_denominator(ScmObj q)
{
    DECLARE_FUNCTION("denominator", procedure_fixed_1);

    ENSURE_INT(q);

    return MAKE_INT(1);
}

SCM_EXPORT ScmObj
scm_p_floor(ScmObj x)
{
    DECLARE_FUNCTION("floor", procedure_fixed_1);

    ENSURE_INT(x);

    return x;
}

SCM_EXPORT ScmObj
scm_p_ceiling(ScmObj x)
{
    DECLARE_FUNCTION("ceiling", procedure_fixed_1);

    ENSURE_INT(x);

    return x;
}

SCM_EXPORT ScmObj
scm_p_truncate(ScmObj x)
{
    DECLARE_FUNCTION("truncate", procedure_fixed_1);

    ENSURE_INT(x);

    return x;
}

SCM_EXPORT ScmObj
scm_p_round(ScmObj x)
{
    DECLARE_FUNCTION("round", procedure_fixed_1);

    ENSURE_INT(x);

    return x;
}

SCM_EXPORT ScmObj
scm_p_inexact2exact(ScmObj z)
{
    DECLARE_FUNCTION("inexact->exact", procedure_fixed_1);

    ENSURE_INT(z);

    return z;
}

SCM_EXPORT ScmObj
scm_p_exact2inexact(ScmObj z)
{
    DECLARE_FUNCTION("exact->inexact", procedure_fixed_1);

    ENSURE_INT(z);
    ERR_OBJ(ERRMSG_INEXACT_NOT_SUPPORTED, z);
    /* NOTREACHED */
    return SCM_FALSE;
}
