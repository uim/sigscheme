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

/* compare_numbers() returns it if a NaN is compared. */
#define UNORDERED 2

#if SCM_USE_REAL
/* LEFT and RIGHT are SCM_INVALID for SCM_REDUCE_0. */
#define REAL_OPERANDP(left, right, state)                                    \
    ((state) != SCM_REDUCE_0 && (REALP(left) || REALP(right)))
#endif

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
#if SCM_USE_REAL
static double real_gcd(double x, double y);
static double real_denominator(double d);
#endif
static int compare_numbers(const char *func_name, ScmObj x, ScmObj y);
#if SCM_USE_REAL
static int compare_int_real(scm_int_t i, double d);
static double integer_real_value(const char *func_name, ScmObj n);
#endif

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

#if SCM_USE_REAL
/* Returns N as a double. */
SCM_EXPORT double
scm_real_value(const char *func_name, ScmObj n)
{
    if (INTP(n))
        return (double)SCM_INT_VALUE(n);
    if (!REALP(n))
        scm_error_obj(func_name, "number required but got", n);
    return SCM_REAL_VALUE(n);
}

/* Stores D to N and returns true if D is an exact integer of SigScheme. */
SCM_EXPORT scm_bool
scm_real2int(double d, scm_int_t *n)
{
    /* The bounds are powers of 2 that are exact as double. */
    if (!((double)SCM_INT_MIN <= d && d < -(double)SCM_INT_MIN))
        return scm_false;
    *n = (scm_int_t)d;
    return d == (double)*n;
}

/* Returns N that is an integer as a double. */
static double
integer_real_value(const char *func_name, ScmObj n)
{
    double d;

    d = scm_real_value(func_name, n);
    if (!INTP(n) && !scm_real_integerp(d))
        scm_error_obj(func_name, "integer required but got", n);
    return d;
}

/* Compares I and D exactly. (double)I may be rounded. */
static int
compare_int_real(scm_int_t i, double d)
{
    double di;

    di = (double)i;
    if (di != d)
        return (di > d) - (di < d);
    /* D is an integer. The bound is a power of 2 that is exact as double. */
    if (d >= -(double)SCM_INT_MIN)
        return -1;
    return (i > (scm_int_t)d) - (i < (scm_int_t)d);
}
#endif /* SCM_USE_REAL */

/* Returns a negative, zero or positive integer if X is less than, equal to
 * or greater than Y respectively. Returns UNORDERED for NaN. */
static int
compare_numbers(const char *func_name, ScmObj x, ScmObj y)
{
#if SCM_USE_REAL
    double dx, dy;

    if (!INTP(x) || !INTP(y)) {
        dx = scm_real_value(func_name, x);
        dy = scm_real_value(func_name, y);
        if (isnan(dx) || isnan(dy))
            return UNORDERED;
        if (INTP(x))
            return compare_int_real(SCM_INT_VALUE(x), dy);
        if (INTP(y))
            return -compare_int_real(SCM_INT_VALUE(y), dx);
        return (dx > dy) - (dx < dy);
    }
#else
    if (!INTP(x))
        scm_error_obj(func_name, "integer required but got", x);
    if (!INTP(y))
        scm_error_obj(func_name, "integer required but got", y);
#endif
    return (SCM_INT_VALUE(x) > SCM_INT_VALUE(y))
           - (SCM_INT_VALUE(x) < SCM_INT_VALUE(y));
}

/* Returns the truncated quotient, the remainder, the modulo or the floored
 * quotient of integers N1 and N2 for OP 'q', 'r', 'm' or 'f' respectively.
 * The result is inexact if N1 or N2 is inexact. */
SCM_EXPORT ScmObj
scm_integer_divide(const char *func_name, ScmObj n1, ScmObj n2, char op)
{
    scm_int_t i1, i2, q, r;
#if SCM_USE_REAL
    double d1, d2, dr;

    if (REALP(n1) || REALP(n2)) {
        d1 = integer_real_value(func_name, n1);
        d2 = integer_real_value(func_name, n2);
        if (d2 == 0.0)
            scm_error(func_name, ERRMSG_DIV_BY_ZERO);
        if (op == 'q')
            return MAKE_REAL(trunc(d1 / d2));
        if (op == 'f')
            return MAKE_REAL(floor(d1 / d2));
        dr = fmod(d1, d2);
        if (op == 'm' && dr != 0.0 && (dr < 0.0) != (d2 < 0.0))
            dr += d2;
        return MAKE_REAL(dr);
    }
#endif
    if (!INTP(n1))
        scm_error_obj(func_name, "integer required but got", n1);
    if (!INTP(n2))
        scm_error_obj(func_name, "integer required but got", n2);
    i1 = SCM_INT_VALUE(n1);
    i2 = SCM_INT_VALUE(n2);

    switch (op) {
    case 'q':
        return MAKE_INT(scm_int_quotient(func_name, i1, i2));
    case 'r':
        return MAKE_INT(scm_int_remainder(func_name, i1, i2));
    case 'm':
        return MAKE_INT(scm_int_modulo(func_name, i1, i2));
    default:
        SCM_ASSERT(op == 'f');
        q = scm_int_quotient(func_name, i1, i2);
        r = scm_int_remainder(func_name, i1, i2);
        /* Q - 1 doesn't overflow because R is 0 if I2 is 1 or -1. */
        return MAKE_INT((r && ((r < 0) != (i2 < 0))) ? q - 1 : q);
    }
}

/*===========================================================================
  R5RS : 6.2 Numbers : 6.2.5 Numerical Operations
===========================================================================*/
/* Note: SigScheme supports only exact integers and inexact reals of the
 * numerical tower. If an operand is inexact, the result is inexact. LEFT is
 * RIGHT for SCM_REDUCE_1. */

SCM_EXPORT ScmObj
scm_p_add(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    scm_int_t result, l, r;
    DECLARE_FUNCTION("+", reduction_operator);

#if SCM_USE_REAL
    if (REAL_OPERANDP(left, right, *state)) {
        if (*state == SCM_REDUCE_1)
            return right;
        return MAKE_REAL(scm_real_value(SCM_MANGLE(name), left)
                         + scm_real_value(SCM_MANGLE(name), right));
    }
#endif

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

#if SCM_USE_REAL
    if (REAL_OPERANDP(left, right, *state)) {
        if (*state == SCM_REDUCE_1)
            return right;
        return MAKE_REAL(scm_real_value(SCM_MANGLE(name), left)
                         * scm_real_value(SCM_MANGLE(name), right));
    }
#endif

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

#if SCM_USE_REAL
    if (REAL_OPERANDP(left, right, *state)) {
        if (*state == SCM_REDUCE_1)
            return MAKE_REAL(-SCM_REAL_VALUE(right));
        return MAKE_REAL(scm_real_value(SCM_MANGLE(name), left)
                         - scm_real_value(SCM_MANGLE(name), right));
    }
#endif

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
    scm_int_t result, val, quotient;
    DECLARE_FUNCTION("/", reduction_operator);

#if SCM_USE_REAL
    if (REAL_OPERANDP(left, right, *state)) {
        if (*state == SCM_REDUCE_1)
            return MAKE_REAL(1.0 / SCM_REAL_VALUE(right));
        return MAKE_REAL(scm_real_value(SCM_MANGLE(name), left)
                         / scm_real_value(SCM_MANGLE(name), right));
    }
#endif

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
        quotient = scm_int_quotient(SCM_MANGLE(name), result, val);
#if SCM_USE_REAL
        /* Rationals aren't supported. */
        if (quotient * val != result)
            return MAKE_REAL((double)result / val);
#endif
        result = quotient;
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
        cmp = compare_numbers(SCM_MANGLE(name), left, right);                \
        if (cmp != UNORDERED && cmp op 0)                                    \
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
    int cmp;
    DECLARE_FUNCTION("=", reduction_operator);

    COMPARATOR_BODY(==);
}

SCM_EXPORT ScmObj
scm_p_less(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    int cmp;
    DECLARE_FUNCTION("<", reduction_operator);

    COMPARATOR_BODY(<);
}

SCM_EXPORT ScmObj
scm_p_less_equal(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    int cmp;
    DECLARE_FUNCTION("<=", reduction_operator);

    COMPARATOR_BODY(<=);
}

SCM_EXPORT ScmObj
scm_p_greater(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    int cmp;
    DECLARE_FUNCTION(">", reduction_operator);

    COMPARATOR_BODY(>);
}

SCM_EXPORT ScmObj
scm_p_greater_equal(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    int cmp;
    DECLARE_FUNCTION(">=", reduction_operator);

    COMPARATOR_BODY(>=);
}

#undef COMPARATOR_BODY

SCM_EXPORT ScmObj
scm_p_zerop(ScmObj n)
{
    DECLARE_FUNCTION("zero?", procedure_fixed_1);

#if SCM_USE_REAL
    if (REALP(n))
        return MAKE_BOOL(SCM_REAL_VALUE(n) == 0.0);
#endif
    ENSURE_INT(n);

    return MAKE_BOOL(SCM_INT_VALUE(n) == 0);
}

SCM_EXPORT ScmObj
scm_p_positivep(ScmObj n)
{
    DECLARE_FUNCTION("positive?", procedure_fixed_1);

#if SCM_USE_REAL
    if (REALP(n))
        return MAKE_BOOL(SCM_REAL_VALUE(n) > 0.0);
#endif
    ENSURE_INT(n);

    return MAKE_BOOL(SCM_INT_VALUE(n) > 0);
}

SCM_EXPORT ScmObj
scm_p_negativep(ScmObj n)
{
    DECLARE_FUNCTION("negative?", procedure_fixed_1);

#if SCM_USE_REAL
    if (REALP(n))
        return MAKE_BOOL(SCM_REAL_VALUE(n) < 0.0);
#endif
    ENSURE_INT(n);

    return MAKE_BOOL(SCM_INT_VALUE(n) < 0);
}

SCM_EXPORT ScmObj
scm_p_oddp(ScmObj n)
{
    DECLARE_FUNCTION("odd?", procedure_fixed_1);

#if SCM_USE_REAL
    if (REALP(n))
        return MAKE_BOOL(fmod(integer_real_value(SCM_MANGLE(name), n), 2.0)
                         != 0.0);
#endif
    ENSURE_INT(n);

    return MAKE_BOOL(SCM_INT_VALUE(n) & 0x1);
}

SCM_EXPORT ScmObj
scm_p_evenp(ScmObj n)
{
    DECLARE_FUNCTION("even?", procedure_fixed_1);

#if SCM_USE_REAL
    if (REALP(n))
        return MAKE_BOOL(fmod(integer_real_value(SCM_MANGLE(name), n), 2.0)
                         == 0.0);
#endif
    ENSURE_INT(n);

    return MAKE_BOOL(!(SCM_INT_VALUE(n) & 0x1));
}

/* If an argument is inexact, the result is inexact. A NaN is the result if
 * a NaN is compared. */
SCM_EXPORT ScmObj
scm_p_max(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    int cmp;
    DECLARE_FUNCTION("max", reduction_operator);

    if (*state == SCM_REDUCE_0)
        ERR(ERRMSG_REQ_1_ARG);
    cmp = compare_numbers(SCM_MANGLE(name), left, right);
#if SCM_USE_REAL
    if (REALP(left) || REALP(right)) {
        if (cmp == UNORDERED)
            return MAKE_REAL(NAN);
        return MAKE_REAL(scm_real_value(SCM_MANGLE(name),
                                    (cmp > 0) ? left : right));
    }
#endif

    return (cmp > 0) ? left : right;
}

SCM_EXPORT ScmObj
scm_p_min(ScmObj left, ScmObj right, enum ScmReductionState *state)
{
    int cmp;
    DECLARE_FUNCTION("min", reduction_operator);

    if (*state == SCM_REDUCE_0)
        ERR(ERRMSG_REQ_1_ARG);
    cmp = compare_numbers(SCM_MANGLE(name), left, right);
#if SCM_USE_REAL
    if (REALP(left) || REALP(right)) {
        if (cmp == UNORDERED)
            return MAKE_REAL(NAN);
        return MAKE_REAL(scm_real_value(SCM_MANGLE(name),
                                    (cmp < 0) ? left : right));
    }
#endif

    return (cmp < 0) ? left : right;
}


SCM_EXPORT ScmObj
scm_p_abs(ScmObj _n)
{
    scm_int_t n;
    DECLARE_FUNCTION("abs", procedure_fixed_1);

#if SCM_USE_REAL
    if (REALP(_n))
        return MAKE_REAL(fabs(SCM_REAL_VALUE(_n)));
#endif
    ENSURE_INT(_n);

    n = SCM_INT_VALUE(_n);
    if (n == SCM_INT_MIN)
        ERR(ERRMSG_FIXNUM_OVERFLOW);

    return (n < 0) ? MAKE_INT(-n) : _n;
}

SCM_EXPORT ScmObj
scm_p_quotient(ScmObj n1, ScmObj n2)
{
    DECLARE_FUNCTION("quotient", procedure_fixed_2);

    return scm_integer_divide(SCM_MANGLE(name), n1, n2, 'q');
}

SCM_EXPORT ScmObj
scm_p_modulo(ScmObj n1, ScmObj n2)
{
    DECLARE_FUNCTION("modulo", procedure_fixed_2);

    return scm_integer_divide(SCM_MANGLE(name), n1, n2, 'm');
}

SCM_EXPORT ScmObj
scm_p_remainder(ScmObj n1, ScmObj n2)
{
    DECLARE_FUNCTION("remainder", procedure_fixed_2);

    return scm_integer_divide(SCM_MANGLE(name), n1, n2, 'r');
}

SCM_EXPORT ScmObj
scm_p_expt(ScmObj _base, ScmObj _expo)
{
    scm_int_t base, expo, result;
#if SCM_USE_REAL
    double b, e;
#endif
    DECLARE_FUNCTION("expt", procedure_fixed_2);

#if SCM_USE_REAL
    if (REALP(_base) || REALP(_expo)) {
        b = scm_real_value(SCM_MANGLE(name), _base);
        e = scm_real_value(SCM_MANGLE(name), _expo);
        if (b < 0.0 && !scm_real_integerp(e) && isfinite(e))
            ERR_OBJ(ERRMSG_COMPLEX_NOT_SUPPORTED, LIST_2(_base, _expo));
        return MAKE_REAL(pow(b, e));
    }
#endif
    ENSURE_INT(_base);
    ENSURE_INT(_expo);

    base = SCM_INT_VALUE(_base);
    expo = SCM_INT_VALUE(_expo);

    if (expo < 0) {
#if SCM_USE_REAL
        /* Rationals aren't supported. */
        if (base == 0)
            ERR(ERRMSG_DIV_BY_ZERO);
        return MAKE_REAL(pow((double)base, (double)expo));
#else
        ERR(ERRMSG_NEGATIVE_EXP);
#endif
    }

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

#if SCM_USE_REAL
static double
real_gcd(double x, double y)
{
    double tmp;

    while (y != 0.0) {
        tmp = fmod(x, y);
        x = y;
        y = tmp;
    }
    return fabs(x);
}
#endif

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

#if SCM_USE_REAL
    if (REAL_OPERANDP(left, right, *state))
        return MAKE_REAL(real_gcd(
            (*state == SCM_REDUCE_1)
            ? 0.0 : integer_real_value(SCM_MANGLE(name), left),
            integer_real_value(SCM_MANGLE(name), right)));
#endif

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
#if SCM_USE_REAL
    double x, y;
#endif
    DECLARE_FUNCTION("lcm", reduction_operator);

#if SCM_USE_REAL
    if (REAL_OPERANDP(left, right, *state)) {
        x = (*state == SCM_REDUCE_1)
            ? 1.0 : integer_real_value(SCM_MANGLE(name), left);
        y = integer_real_value(SCM_MANGLE(name), right);
        if (x == 0.0 || y == 0.0)
            return MAKE_REAL(0.0);
        return MAKE_REAL(fabs(x / real_gcd(x, y) * y));
    }
#endif

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

#if SCM_USE_REAL
/* Returns the denominator of D in the lowest terms. It's a power of 2. */
static double
real_denominator(double d)
{
    double denominator;

    for (denominator = 1.0; !scm_real_integerp(d); denominator *= 2.0)
        d *= 2.0;
    return denominator;
}
#endif

/* The denominator of an exact integer is 1. */
SCM_EXPORT ScmObj
scm_p_numerator(ScmObj q)
{
    DECLARE_FUNCTION("numerator", procedure_fixed_1);

#if SCM_USE_REAL
    if (REALP(q) && isfinite(SCM_REAL_VALUE(q)))
        return MAKE_REAL(SCM_REAL_VALUE(q)
                         * real_denominator(SCM_REAL_VALUE(q)));
#endif
    ENSURE_INT(q);

    return q;
}

SCM_EXPORT ScmObj
scm_p_denominator(ScmObj q)
{
    DECLARE_FUNCTION("denominator", procedure_fixed_1);

#if SCM_USE_REAL
    if (REALP(q) && isfinite(SCM_REAL_VALUE(q)))
        return MAKE_REAL(real_denominator(SCM_REAL_VALUE(q)));
#endif
    ENSURE_INT(q);

    return MAKE_INT(1);
}

SCM_EXPORT ScmObj
scm_p_floor(ScmObj x)
{
    DECLARE_FUNCTION("floor", procedure_fixed_1);

#if SCM_USE_REAL
    if (REALP(x))
        return MAKE_REAL(floor(SCM_REAL_VALUE(x)));
#endif
    ENSURE_INT(x);

    return x;
}

SCM_EXPORT ScmObj
scm_p_ceiling(ScmObj x)
{
    DECLARE_FUNCTION("ceiling", procedure_fixed_1);

#if SCM_USE_REAL
    if (REALP(x))
        return MAKE_REAL(ceil(SCM_REAL_VALUE(x)));
#endif
    ENSURE_INT(x);

    return x;
}

SCM_EXPORT ScmObj
scm_p_truncate(ScmObj x)
{
    DECLARE_FUNCTION("truncate", procedure_fixed_1);

#if SCM_USE_REAL
    if (REALP(x))
        return MAKE_REAL(trunc(SCM_REAL_VALUE(x)));
#endif
    ENSURE_INT(x);

    return x;
}

SCM_EXPORT ScmObj
scm_p_round(ScmObj x)
{
    DECLARE_FUNCTION("round", procedure_fixed_1);

#if SCM_USE_REAL
    /* rint() rounds to even with the default rounding mode. */
    if (REALP(x))
        return MAKE_REAL(rint(SCM_REAL_VALUE(x)));
#endif
    ENSURE_INT(x);

    return x;
}

/* Returns Z as an exact number. Only integers are supported. */
SCM_EXPORT ScmObj
scm_exact(const char *func_name, ScmObj z)
{
#if SCM_USE_REAL
    scm_int_t n;

    if (REALP(z)) {
        if (!scm_real2int(SCM_REAL_VALUE(z), &n))
            scm_error_obj(func_name, "exact integer can't represent", z);
        return MAKE_INT(n);
    }
#endif
    if (!INTP(z))
        scm_error_obj(func_name, "number required but got", z);

    return z;
}

/* Returns Z as an inexact number. */
SCM_EXPORT ScmObj
scm_inexact(const char *func_name, ScmObj z)
{
#if SCM_USE_REAL
    if (REALP(z))
        return z;
    if (INTP(z))
        return MAKE_REAL((double)SCM_INT_VALUE(z));
    scm_error_obj(func_name, "number required but got", z);
#else
    if (!INTP(z))
        scm_error_obj(func_name, "number required but got", z);
    scm_error_obj(func_name, ERRMSG_INEXACT_NOT_SUPPORTED, z);
#endif
    /* NOTREACHED */
    return SCM_FALSE;
}

SCM_EXPORT ScmObj
scm_p_inexact2exact(ScmObj z)
{
    DECLARE_FUNCTION("inexact->exact", procedure_fixed_1);

    return scm_exact(SCM_MANGLE(name), z);
}

SCM_EXPORT ScmObj
scm_p_exact2inexact(ScmObj z)
{
    DECLARE_FUNCTION("exact->inexact", procedure_fixed_1);

    return scm_inexact(SCM_MANGLE(name), z);
}
