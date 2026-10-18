/*===========================================================================
 *  Filename : bytevector.c
 *  About    : R7RS bytevectors
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

#include <string.h>

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
static ScmObj make_bytevector_copying(const scm_byte_t *bytes, scm_int_t len);
static void ensure_utf8_codec(const char *func_name);

/*=======================================
  Function Definitions
=======================================*/
static ScmObj
make_bytevector_copying(const scm_byte_t *bytes, scm_int_t len)
{
    scm_byte_t *vec;

    vec = scm_malloc(len);
    memcpy(vec, bytes, len);
    return MAKE_BYTEVECTOR(vec, len);
}

/* Strings are stored in the current character codec. Only UTF-8 strings can
 * be converted from/to UTF-8 bytes as is. */
static void
ensure_utf8_codec(const char *func_name)
{
#if SCM_USE_MULTIBYTE_CHAR
    if (SCM_CHARCODEC_CCS(scm_current_char_codec) == SCM_CCS_UNICODE)
        return;
#endif
    scm_error_obj(func_name, "UTF-8 character codec required", SCM_NULL);
}

/*===========================================================================
  R7RS : 6.9 Bytevectors
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_bytevectorp(ScmObj obj)
{
    DECLARE_FUNCTION("bytevector?", procedure_fixed_1);

    return MAKE_BOOL(BYTEVECTORP(obj));
}

SCM_EXPORT ScmObj
scm_p_make_bytevector(ScmObj scm_len, ScmObj args)
{
    ScmObj fill;
    scm_byte_t *vec;
    scm_int_t len;
    DECLARE_FUNCTION("make-bytevector", procedure_variadic_1);

    ENSURE_INT(scm_len);

    len = SCM_INT_VALUE(scm_len);
    if (len < 0)
        ERR_OBJ("length must be a non-negative integer", scm_len);

    if (NULLP(args)) {
        fill = MAKE_INT(0);
    } else {
        fill = POP(args);
        ASSERT_NO_MORE_ARG(args);
        ENSURE_BYTE(fill);
    }
    vec = scm_malloc(len);
    memset(vec, SCM_INT_VALUE(fill), len);

    return MAKE_BYTEVECTOR(vec, len);
}

SCM_EXPORT ScmObj
scm_p_bytevector(ScmObj args)
{
    ScmObj rest, obj;
    scm_byte_t *vec;
    scm_int_t len, i;
    DECLARE_FUNCTION("bytevector", procedure_variadic_0);

    /* ARGS may be an improper list from the reader. */
    len = scm_length(args);
    if (!SCM_LISTLEN_PROPERP(len))
        ERR_OBJ("proper list required but got", args);
    vec = scm_malloc(len);
    i = 0;
    rest = args;
    FOR_EACH (obj, rest) {
        ENSURE_BYTE(obj);
        vec[i++] = SCM_INT_VALUE(obj);
    }

    return MAKE_BYTEVECTOR(vec, len);
}

SCM_EXPORT ScmObj
scm_p_bytevector_u8_ref(ScmObj bv, ScmObj k)
{
    DECLARE_FUNCTION("bytevector-u8-ref", procedure_fixed_2);

    ENSURE_BYTEVECTOR(bv);
    ENSURE_INT(k);
    if (!SCM_BYTEVECTOR_VALID_INDEXP(bv, SCM_INT_VALUE(k)))
        ERR_OBJ("index out of range", k);

    return MAKE_INT(SCM_BYTEVECTOR_VEC(bv)[SCM_INT_VALUE(k)]);
}

SCM_EXPORT ScmObj
scm_p_bytevector_u8_setx(ScmObj bv, ScmObj k, ScmObj byte)
{
    DECLARE_FUNCTION("bytevector-u8-set!", procedure_fixed_3);

    ENSURE_BYTEVECTOR(bv);
    ENSURE_MUTABLE_BYTEVECTOR(bv);
    ENSURE_INT(k);
    ENSURE_BYTE(byte);
    if (!SCM_BYTEVECTOR_VALID_INDEXP(bv, SCM_INT_VALUE(k)))
        ERR_OBJ("index out of range", k);

    SCM_BYTEVECTOR_VEC(bv)[SCM_INT_VALUE(k)] = SCM_INT_VALUE(byte);

    return SCM_UNDEF;
}

SCM_EXPORT ScmObj
scm_p_bytevector_length(ScmObj bv)
{
    DECLARE_FUNCTION("bytevector-length", procedure_fixed_1);

    ENSURE_BYTEVECTOR(bv);

    return MAKE_INT(SCM_BYTEVECTOR_LEN(bv));
}

SCM_EXPORT ScmObj
scm_p_bytevector_copy(ScmObj bv, ScmObj args)
{
    scm_int_t start, end;
    DECLARE_FUNCTION("bytevector-copy", procedure_variadic_1);

    ENSURE_BYTEVECTOR(bv);
    scm_parse_range(SCM_MANGLE(name), args, SCM_BYTEVECTOR_LEN(bv),
                    &start, &end);

    return make_bytevector_copying(&SCM_BYTEVECTOR_VEC(bv)[start],
                                   end - start);
}

SCM_EXPORT ScmObj
scm_p_bytevector_copyx(ScmObj to, ScmObj at, ScmObj from, ScmObj args)
{
    scm_int_t to_start, start, end;
    DECLARE_FUNCTION("bytevector-copy!", procedure_variadic_3);

    ENSURE_BYTEVECTOR(to);
    ENSURE_MUTABLE_BYTEVECTOR(to);
    ENSURE_INT(at);
    ENSURE_BYTEVECTOR(from);
    scm_parse_range(SCM_MANGLE(name), args, SCM_BYTEVECTOR_LEN(from),
                    &start, &end);

    to_start = SCM_INT_VALUE(at);
    if (!(0 <= to_start
          && end - start <= SCM_BYTEVECTOR_LEN(to) - to_start))
        ERR_OBJ("index out of range", at);

    /* TO and FROM may be the same bytevector. */
    memmove(&SCM_BYTEVECTOR_VEC(to)[to_start],
            &SCM_BYTEVECTOR_VEC(from)[start], end - start);

    return SCM_UNDEF;
}

SCM_EXPORT ScmObj
scm_p_bytevector_append(ScmObj args)
{
    ScmObj rest, bv;
    scm_byte_t *appended;
    scm_int_t len, offset;
    DECLARE_FUNCTION("bytevector-append", procedure_variadic_0);

    len = 0;
    rest = args;
    FOR_EACH (bv, rest) {
        ENSURE_BYTEVECTOR(bv);
        len += SCM_BYTEVECTOR_LEN(bv);
    }

    appended = scm_malloc(len);
    offset = 0;
    FOR_EACH (bv, args) {
        memcpy(&appended[offset], SCM_BYTEVECTOR_VEC(bv),
               SCM_BYTEVECTOR_LEN(bv));
        offset += SCM_BYTEVECTOR_LEN(bv);
    }

    return MAKE_BYTEVECTOR(appended, len);
}

SCM_EXPORT ScmObj
scm_p_utf82string(ScmObj bv, ScmObj args)
{
#if SCM_USE_MULTIBYTE_CHAR
    ScmMultibyteString mbs;
    ScmMultibyteCharInfo mbc;
#endif
    const char *bytes;
    char *str;
    scm_int_t start, end, len;
    DECLARE_FUNCTION("utf8->string", procedure_variadic_1);

    ENSURE_BYTEVECTOR(bv);
    scm_parse_range(SCM_MANGLE(name), args, SCM_BYTEVECTOR_LEN(bv),
                    &start, &end);
    ensure_utf8_codec(SCM_MANGLE(name));

    bytes = (const char *)&SCM_BYTEVECTOR_VEC(bv)[start];
#if !SCM_USE_NULL_CAPABLE_STRING
    if (memchr(bytes, '\0', end - start))
        ERR(SCM_ERRMSG_NULL_IN_STRING);
#endif
    len = 0;
#if SCM_USE_MULTIBYTE_CHAR
    SCM_MBS_INIT2(mbs, bytes, end - start);
    while (SCM_MBS_GET_SIZE(mbs)) {
        mbc = SCM_CHARCODEC_SCAN_CHAR(scm_current_char_codec, mbs);
        if (SCM_MBCINFO_ERRORP(mbc) || SCM_MBCINFO_INCOMPLETEP(mbc))
            ERR_OBJ("invalid UTF-8 bytes", bv);
        SCM_MBS_SKIP_CHAR(mbs, mbc);
        len++;
    }
#endif

    str = scm_malloc(end - start + sizeof(""));
    memcpy(str, bytes, end - start);
    str[end - start] = '\0';

    return MAKE_STRING(str, len);
}

SCM_EXPORT ScmObj
scm_p_string2utf8(ScmObj str, ScmObj args)
{
#if SCM_USE_MULTIBYTE_CHAR
    ScmMultibyteString mbs;
#endif
    scm_int_t start, end;
    DECLARE_FUNCTION("string->utf8", procedure_variadic_1);

    ENSURE_STRING(str);
    scm_parse_range(SCM_MANGLE(name), args, SCM_STRING_LEN(str),
                    &start, &end);
    ensure_utf8_codec(SCM_MANGLE(name));

#if SCM_USE_MULTIBYTE_CHAR
    SCM_MBS_INIT2(mbs, SCM_STRING_STR(str), strlen(SCM_STRING_STR(str)));
    mbs = scm_mb_substring(scm_current_char_codec, mbs, start, end - start);
    return make_bytevector_copying((const scm_byte_t *)SCM_MBS_GET_STR(mbs),
                                   SCM_MBS_GET_SIZE(mbs));
#else
    /* NOTREACHED */
    return SCM_FALSE;
#endif
}
