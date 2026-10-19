/*===========================================================================
 *  Filename : number-io.c
 *  About    : Numerical input/output procedures of R5RS numbers
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

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <errno.h>
#include <string.h>
#if (HAVE_STRCASECMP && HAVE_STRINGS_H)
#include <strings.h>
#endif
#if SCM_USE_REAL
#include <float.h>
#include <locale.h>
#include <math.h>
#endif

#include <sigscheme/sigscheme.h>
#include "sigschemeinternal.h"

/*=======================================
  File Local Macro Definitions
=======================================*/
#define VALID_RADIXP(r) ((r) == 2 || (r) == 8 || (r) == 10 || (r) == 16)

/*=======================================
  File Local Type Definitions
=======================================*/

/*=======================================
  Variable Definitions
=======================================*/

/*=======================================
  File Local Function Declarations
=======================================*/
#if SCM_USE_STRING
static int prepare_radix(const char *funcname, ScmObj args);
#endif
#if SCM_USE_REAL
static scm_bool decimalp(const char *str, scm_bool allow_integer);
static double string2double(const char *str);
static ScmObj parse_real(const char *str, char exactness);
static void normalize_decimal_point(char *buf);
#endif

/*=======================================
  Function Definitions
=======================================*/
/*===========================================================================
  R5RS : 6.2 Numbers : 6.2.6 Numerical input and output
===========================================================================*/
#if SCM_USE_STRING
static int
prepare_radix(const char *funcname, ScmObj args)
{
    ScmObj radix;
    int r;
    DECLARE_INTERNAL_FUNCTION("(internal)");

    ASSERT_PROPER_ARG_LIST(args);

    /* dirty hack to replace internal function name */
    SCM_MANGLE(name) = funcname;

    if (NULLP(args)) {
        r = 10;
    } else {
        radix = POP(args);
        ASSERT_NO_MORE_ARG(args);
        ENSURE_INT(radix);
        r = SCM_INT_VALUE(radix);
        if (!VALID_RADIXP(r))
            ERR_OBJ("invalid radix", radix);
    }

    return r;
}

SCM_EXPORT char *
scm_int2string(ScmValueFormat vfmt, uintmax_t n, int radix)
{
    char buf[sizeof("-") + sizeof(uintmax_t) * CHAR_BIT];
    char *p, *end, *str;
    uintmax_t un;  /* must be unsigned to be capable of -INT_MIN */
    int digit, sign_len, pad_len, len;
    scm_bool neg;
    DECLARE_INTERNAL_FUNCTION("scm_int2string");

    SCM_ASSERT(VALID_RADIXP(radix));
    neg = (vfmt.signedp && ((intmax_t)n < 0));
    /* Negation of unsigned integers doesn't overflow. */
    un = (neg) ? -n : n;

    end = p = &buf[sizeof(buf) - 1];
    *end = '\0';

    do {
        digit = un % radix;
        *--p = (digit <= 9) ? '0' + digit : 'a' + digit - 10;
    } while (un /= radix);
    if (neg && vfmt.pad != '0')
        *--p = '-';

    sign_len = (neg && vfmt.pad == '0') ? 1 : 0;
    len = end - p;
    pad_len = (sign_len + len < vfmt.width) ? vfmt.width - sign_len - len : 0;

    str = scm_malloc(sign_len + pad_len + len + sizeof(""));
    strcpy(&str[sign_len + pad_len], p);
    while (pad_len)
        str[sign_len + --pad_len] = vfmt.pad;

    if (sign_len)
        *str = '-';

    return str;
}

SCM_EXPORT ScmObj
scm_p_number2string(ScmObj num, ScmObj args)
{
    char *str;
    intmax_t n;
    int r;
    ScmValueFormat vfmt;
    DECLARE_FUNCTION("number->string", procedure_variadic_1);

    r = prepare_radix(SCM_MANGLE(name), args);
#if SCM_USE_REAL
    if (REALP(num)) {
        if (r != 10)
            ERR_OBJ("radix 10 is required for inexact number", num);
        return MAKE_STRING(scm_real2string(SCM_REAL_VALUE(num)),
                           SCM_STRLEN_UNKNOWN);
    }
#endif
    ENSURE_INT(num);

    n = (intmax_t)SCM_INT_VALUE(num);
    SCM_VALUE_FORMAT_INIT(vfmt);
    str = scm_int2string(vfmt, (uintmax_t)n, r);

    return MAKE_STRING(str, SCM_STRLEN_UNKNOWN);
}
#endif /* SCM_USE_STRING */

SCM_EXPORT scm_int_t
scm_string2number(const char *str, int radix, scm_bool *err)
{
    scm_int_t n;
    char *end;
    scm_bool empty_strp;
    DECLARE_INTERNAL_FUNCTION("string->number");

    SCM_ASSERT(str);
    SCM_ASSERT(VALID_RADIXP(radix));
    SCM_ASSERT(err);

    /* R5RS:
     *
     * - If string is not a syntactically valid notation for a number, then
     *   `string->number' returns #f.
     *
     * - `String->number' is permitted to return #f whenever string contains an
     *   explicit radix prefix.
     *
     * - If all numbers supported by an implementation are real, then
     *   `string->number' is permitted to return #f whenever string uses the
     *   polar or rectangular notations for complex numbers.
     *
     * - If all numbers are integers, then `string->number' may return #f
     *   whenever the fractional notation is used.
     *
     * - If all numbers are exact, then `string->number' may return #f whenever
     *   an exponent marker or explicit exactness prefix is used, or if a #
     *   appears in place of a digit.
     *
     * - If all inexact numbers are integers, then `string->number' may return
     *   #f whenever a decimal point is used.
     */

#if SCM_STRICT_ARGCHECK
    /* Reject "0xa", " 1" etc. */
    if ((*err = str[strspn(str, "0123456789abcdefABCDEF-+")]))
        return 0;
#endif /* SCM_STRICT_ARGCHECK */

    errno = 0;
#if (SIZEOF_SCM_INT_T <= SIZEOF_LONG)
    n = (scm_int_t)strtol(str, &end, radix);
#else
    n = (scm_int_t)strtoll(str, &end, radix);
#endif

    empty_strp = (end == str);  /* apply the first rule above */
    *err = (empty_strp || *end);

    /*
     * glibc warning: Although the manpage describes the behavior as follows,
     * ERANGE is returned for "". The description "may be set to [EINVAL]" is
     * really 'may'. And the ISO C standard does not define errno for the
     * case. So we should not depend on the assumption that ERANGE is returned
     * only when overflow/underflow is occurred.
     *
     * quoted from glibc 2.3:
     *   RETURN VALUE
     *     Upon successful completion, these functions shall return the
     *     converted value, if any. If no conversion could be performed, 0
     *     shall be returned and errno may be set to [EINVAL].
     */
    if ((errno == ERANGE && !empty_strp) || INT_OUT_OF_RANGEP(n)) {
#if 0
        ERR(ERRMSG_FIXNUM_OVERFLOW ": ~S (radix ~D)", str, radix);
#else
        /* R5RS: If string is not a syntactically valid notation for a number,
         *       then `string->number' returns #f.  */
        *err = scm_true;
        n = 0;
#endif
    }

    return n;
}

#if SCM_USE_STRING
SCM_EXPORT ScmObj
scm_p_string2number(ScmObj str, ScmObj args)
{
    int r;
    DECLARE_FUNCTION("string->number", procedure_variadic_1);

    ENSURE_STRING(str);

    r = prepare_radix(SCM_MANGLE(name), args);

    return scm_parse_number(SCM_STRING_STR(str), r);
}
#endif /* SCM_USE_STRING */

/* Parses STR that may have radix and exactness prefixes such as "#x" and
 * "#e". Returns #f if STR isn't a valid number. */
SCM_EXPORT ScmObj
scm_parse_number(const char *str, int radix)
{
    scm_int_t n;
    scm_bool err, radix_prefixed;
    char exactness;

    radix_prefixed = scm_false;
    exactness = '\0';
    while (str[0] == '#') {
        switch (str[1]) {
        case 'b': case 'B': radix = 2;  goto radix_prefix;
        case 'o': case 'O': radix = 8;  goto radix_prefix;
        case 'd': case 'D': radix = 10; goto radix_prefix;
        case 'x': case 'X': radix = 16;
        radix_prefix:
            if (radix_prefixed)
                return SCM_FALSE;
            radix_prefixed = scm_true;
            break;

        case 'e': case 'E': case 'i': case 'I':
            if (exactness)
                return SCM_FALSE;
            exactness = ICHAR_DOWNCASE(str[1]);
            break;

        default:
            return SCM_FALSE;
        }
        str += 2;
    }

    n = scm_string2number(str, radix, &err);
#if SCM_USE_REAL
    if (!err)
        return (exactness == 'i') ? MAKE_REAL((double)n) : MAKE_INT(n);
#else
    if (!err)
        return (exactness == 'i') ? SCM_FALSE : MAKE_INT(n);
#endif

#if SCM_USE_REAL
    /* Only radix 10 has the decimal notation. An integer that is too large is
     * an inexact number only with #i. */
    if (radix == 10 && decimalp(str, exactness == 'i'))
        return parse_real(str, exactness);
#endif
    return SCM_FALSE;
}

#if SCM_USE_REAL
/* Returns true if STR is a decimal notation:
 *
 *   [+-] (<digit>+ [. <digit>*] | . <digit>+) [<exponent>]
 *   [+-] (inf.0 | nan.0)
 *
 * <exponent> is one of "esfdl" (case insensitive), [+-] and <digit>+. At
 * least either "." or <exponent> is required unless ALLOW_INTEGER. */
static scm_bool
decimalp(const char *str, scm_bool allow_integer)
{
    const char *p;
    scm_bool point;
    size_t n_digits;

    p = str;
    if (*p == '+' || *p == '-') {
        p++;
        if (strcasecmp(p, "inf.0") == 0 || strcasecmp(p, "nan.0") == 0)
            return scm_true;
    }

    n_digits = strspn(p, "0123456789");
    p += n_digits;
    point = (*p == '.');
    if (point) {
        p++;
        n_digits += strspn(p, "0123456789");
        p += strspn(p, "0123456789");
    }
    if (!n_digits)
        return scm_false;
    if (*p && strchr("esfdlESFDL", *p)) {
        p++;
        if (*p == '+' || *p == '-')
            p++;
        if (!strspn(p, "0123456789"))
            return scm_false;
        p += strspn(p, "0123456789");
        return !*p;
    }
    return (point || allow_integer) && !*p;
}

/* Converts STR that is a decimal notation or an integer independently of
 * the locale. */
static double
string2double(const char *str)
{
    const char *locale_point;
    char *buf, *p, *point;
    double d;
    size_t locale_point_len;

    if (str[0] && strcasecmp(&str[1], "inf.0") == 0)
        return (str[0] == '-') ? -INFINITY : INFINITY;
    if (str[0] && strcasecmp(&str[1], "nan.0") == 0)
        return NAN;

    locale_point = localeconv()->decimal_point;
    locale_point_len = strlen(locale_point);
    buf = scm_malloc(strlen(str) + locale_point_len + sizeof(""));
    /* strtod() accepts only 'e' as the exponent marker. */
    for (p = buf; *str; str++)
        *p++ = (strchr("sfdlSFDL", *str)) ? 'e' : *str;
    *p = '\0';

    /* strtod() uses the decimal point of the locale. */
    point = strchr(buf, '.');
    if (point && strcmp(locale_point, ".") != 0) {
        memmove(point + locale_point_len, point + 1,
                strlen(point + 1) + sizeof(""));
        memcpy(point, locale_point, locale_point_len);
    }

    d = strtod(buf, NULL);
    free(buf);
    return d;
}

static ScmObj
parse_real(const char *str, char exactness)
{
    double d;
    scm_int_t n;

    d = string2double(str);
    if (exactness != 'e')
        return MAKE_REAL(d);

    /* Only integers are supported as exact numbers. */
    return (scm_real2int(d, &n)) ? MAKE_INT(n) : SCM_FALSE;
}

/* Replaces the decimal point of the locale in BUF with ".". */
static void
normalize_decimal_point(char *buf)
{
    const char *locale_point;
    char *point;
    size_t len;

    locale_point = localeconv()->decimal_point;
    if (strcmp(locale_point, ".") == 0)
        return;
    point = strstr(buf, locale_point);
    if (point) {
        len = strlen(locale_point);
        *point = '.';
        memmove(point + 1, point + len, strlen(point + len) + sizeof(""));
    }
}

/* Returns D in the fixed-point notation with DECIMALS fractional digits.
 * DECIMALS is at most SCHAR_MAX because it's from ScmValueFormat. */
SCM_EXPORT char *
scm_real2fixed(double d, int decimals)
{
    char buf[sizeof("-") + DBL_MAX_10_EXP + sizeof(".") + SCHAR_MAX];

    SCM_ASSERT(0 <= decimals && decimals <= SCHAR_MAX);
    if (!isfinite(d))
        return scm_real2string(d);

    snprintf(buf, sizeof(buf), "%.*f", decimals, d);
    normalize_decimal_point(buf);
    return scm_strdup(buf);
}

/* Returns the shortest notation of D that is read as D again. It uses the
 * fixed-point notation such as "100.0" for moderate exponents. Otherwise,
 * it uses the exponential notation such as "1.5e-07". */
SCM_EXPORT char *
scm_real2string(double d)
{
    char buf[64];
    char *e;
    int precision, exponent, decimals;

    if (isnan(d))
        return scm_strdup("+nan.0");
    if (isinf(d))
        return scm_strdup((d < 0) ? "-inf.0" : "+inf.0");

    for (precision = 1; precision <= 17; precision++) {
        snprintf(buf, sizeof(buf), "%.*e", precision - 1, d);
        normalize_decimal_point(buf);
        if (string2double(buf) == d)
            break;
    }

    e = strchr(buf, 'e');
    exponent = atoi(e + 1);
    if (-4 <= exponent && exponent < 21) {
        decimals = precision - 1 - exponent;
        snprintf(buf, sizeof(buf), "%.*f", (decimals < 0) ? 0 : decimals, d);
        normalize_decimal_point(buf);
        /* "100" -> "100.0" to show that it's inexact. */
        if (!strchr(buf, '.'))
            strcat(buf, ".0");
    } else if (!memchr(buf, '.', e - buf)) {
        /* "5e-324" -> "5.0e-324" */
        memmove(e + 2, e, strlen(e) + sizeof(""));
        memcpy(e, ".0", 2);
    }

    return scm_strdup(buf);
}
#endif /* SCM_USE_REAL */
