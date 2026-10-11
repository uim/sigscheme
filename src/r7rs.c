/*===========================================================================
 *  Filename : r7rs.c
 *  About    : R7RS procedures (preliminary)
 *
 *  Copyright (c) 2026 SigScheme Project <uim-en AT googlegroups.com>
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

#include <string.h>

#include <sigscheme/sigscheme.h>
#include "sigschemeinternal.h"

/*=======================================
  File Local Macro Definitions
=======================================*/
#define BOOLEANP(o)       (EQ((o), SCM_FALSE) || EQ((o), SCM_TRUE))
#define ENSURE_BOOLEAN(o) ENSURE_TYPE(BOOLEANP, "boolean", (o))

/*=======================================
  File Local Type Definitions
=======================================*/
typedef scm_ichar_t (*case_converter)(scm_ichar_t ch);

/*=======================================
  Variable Definitions
=======================================*/

/*=======================================
  File Local Function Declarations
=======================================*/
static scm_ichar_t upcase(scm_ichar_t ch);
static scm_ichar_t downcase(scm_ichar_t ch);
static scm_ichar_t foldcase(scm_ichar_t ch);
static ScmObj convert_string_case(ScmObj str, case_converter convert);

/*=======================================
  Function Definitions
=======================================*/
/*===========================================================================
  R7RS : 6.3 Booleans
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_boolean_equalp(ScmObj boolean1, ScmObj boolean2, ScmObj rest)
{
    ScmObj boolean;
    scm_bool equalp;
    DECLARE_FUNCTION("boolean=?", procedure_variadic_2);

    ENSURE_BOOLEAN(boolean1);
    ENSURE_BOOLEAN(boolean2);
    equalp = EQ(boolean1, boolean2);
    FOR_EACH (boolean, rest) {
        ENSURE_BOOLEAN(boolean);
        if (!EQ(boolean, boolean1))
            equalp = scm_false;
    }

    return MAKE_BOOL(equalp);
}

/*===========================================================================
  R7RS : 6.5 Symbols
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_symbol_equalp(ScmObj symbol1, ScmObj symbol2, ScmObj rest)
{
    ScmObj symbol;
    scm_bool equalp;
    DECLARE_FUNCTION("symbol=?", procedure_variadic_2);

    ENSURE_SYMBOL(symbol1);
    ENSURE_SYMBOL(symbol2);
    equalp = EQ(symbol1, symbol2);
    FOR_EACH (symbol, rest) {
        ENSURE_SYMBOL(symbol);
        if (!EQ(symbol, symbol1))
            equalp = scm_false;
    }

    return MAKE_BOOL(equalp);
}

/*===========================================================================
  R7RS : 6.6 Characters
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_digit_value(ScmObj ch)
{
    scm_ichar_t val;
    DECLARE_FUNCTION("digit-value", procedure_fixed_1);

    ENSURE_CHAR(ch);

    /* Only ASCII digits are supported. */
    val = SCM_CHAR_VALUE(ch);
    if (!ICHAR_NUMERICP(val))
        return SCM_FALSE;

    return MAKE_INT(val - '0');
}

SCM_EXPORT ScmObj
scm_p_char_foldcase(ScmObj ch)
{
    DECLARE_FUNCTION("char-foldcase", procedure_fixed_1);

    ENSURE_CHAR(ch);

    return MAKE_CHAR(ICHAR_FOLDCASE(SCM_CHAR_VALUE(ch)));
}

/*===========================================================================
  R7RS : 6.7 Strings
===========================================================================*/
/* Only ASCII characters are converted like char-upcase and so on. */
static scm_ichar_t
upcase(scm_ichar_t ch)
{
    return ICHAR_UPCASE(ch);
}

static scm_ichar_t
downcase(scm_ichar_t ch)
{
    return ICHAR_DOWNCASE(ch);
}

static scm_ichar_t
foldcase(scm_ichar_t ch)
{
    return ICHAR_FOLDCASE(ch);
}

/* Only single byte characters are converted. So the conversion doesn't
 * change the size of the string. */
static ScmObj
convert_string_case(ScmObj str, case_converter convert)
{
#if SCM_USE_MULTIBYTE_CHAR
    ScmMultibyteString mbs;
    scm_ichar_t ch;
#endif
    char *new_str, *p;
    DECLARE_INTERNAL_FUNCTION("convert_string_case");

    new_str = scm_strdup(SCM_STRING_STR(str));
#if SCM_USE_MULTIBYTE_CHAR
    SCM_MBS_INIT2(mbs, new_str, strlen(new_str));
    while (SCM_MBS_GET_SIZE(mbs)) {
        p = (char *)SCM_MBS_GET_STR(mbs);
        ch = SCM_CHARCODEC_READ_CHAR(scm_current_char_codec, mbs);
        if (SCM_MBS_GET_STR(mbs) - p == 1)
            *p = convert(ch);
    }
#else
    for (p = new_str; *p; p++)
        *p = convert((unsigned char)*p);
#endif

#if SCM_USE_NULL_CAPABLE_STRING
    /* FIXME: the result is truncated at null and incorrect */
    return MAKE_STRING(new_str, STRLEN_UNKNOWN);
#else
    return MAKE_STRING(new_str, SCM_STRING_LEN(str));
#endif
}

SCM_EXPORT ScmObj
scm_p_string_upcase(ScmObj str)
{
    DECLARE_FUNCTION("string-upcase", procedure_fixed_1);

    ENSURE_STRING(str);

    return convert_string_case(str, upcase);
}

SCM_EXPORT ScmObj
scm_p_string_downcase(ScmObj str)
{
    DECLARE_FUNCTION("string-downcase", procedure_fixed_1);

    ENSURE_STRING(str);

    return convert_string_case(str, downcase);
}

SCM_EXPORT ScmObj
scm_p_string_foldcase(ScmObj str)
{
    DECLARE_FUNCTION("string-foldcase", procedure_fixed_1);

    ENSURE_STRING(str);

    return convert_string_case(str, foldcase);
}
