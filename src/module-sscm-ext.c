/*===========================================================================
 *  Filename : module-sscm-ext.c
 *  About    : SigScheme-specific extensions
 *
 *  Copyright (C) 2005-2006 Kazuki Ohta <mover AT hct.zaq.ne.jp>
 *  Copyright (C) 2005-2006 Jun Inoue <jun.lambda AT gmail.com>
 *  Copyright (C) 2005-2006 YAMAMOTO Kengo <yamaken AT bp.iij4u.or.jp>
 *  Copyright (c) 2007-2008 SigScheme Project <uim-en AT googlegroups.com>
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

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "sigscheme.h"
#include "sigschemeinternal.h"

/*=======================================
  File Local Macro Definitions
=======================================*/
#define ERRMSG_INVALID_BINDINGS    "invalid bindings form"
#define ERRMSG_INVALID_BINDING     "invalid binding form"

/*=======================================
  File Local Type Definitions
=======================================*/

/*=======================================
  Variable Definitions
=======================================*/
#include "functable-sscm-ext.c"

/*=======================================
  File Local Function Declarations
=======================================*/
static void *scm_require_internal(const char *filename);
static ScmObj make_loaded_str(const char *filename);

/*=======================================
  Function Definitions
=======================================*/
SCM_EXPORT void
scm_initialize_sscm_extensions(void)
{
    scm_register_funcs(scm_functable_sscm_ext);

    scm_define_alias("call/cc", "call-with-current-continuation");
}

/*
 * TODO:
 * - describe compatibility with de facto standard of other Scheme
 *   implementations (accept env as optional arg, etc)
 *
 * NOTE: Gauche 0.8.6 has deprecated symbol-bound? and is going to replace the
 * procedure with global-variable-bound?.
 */
/* The implementation is fully compatible with SIOD */
SCM_EXPORT ScmObj
scm_p_symbol_boundp(ScmObj sym, ScmObj rest)
{
    ScmObj env;
    ScmRef ref;
    DECLARE_FUNCTION("symbol-bound?", procedure_variadic_1);

    ENSURE_SYMBOL(sym);

    if (NULLP(rest)) {
        env = SCM_INTERACTION_ENV;
    } else {
        env = POP(rest);
        ASSERT_NO_MORE_ARG(rest);
        ENSURE_VALID_ENV(env);
    }
    ref = scm_lookup_environment(sym, env);

    return MAKE_BOOL(ref != SCM_INVALID_REF || SCM_SYMBOL_BOUNDP(sym));
}

SCM_EXPORT ScmObj
scm_p_sscm_version(void)
{
    DECLARE_FUNCTION("sscm-version", procedure_fixed_0);

    /* PACKAGE_VERSION may be overridden by a master package such as uim. */
    return CONST_STRING(SSCM_VERSION_STRING);
}

SCM_EXPORT ScmObj
scm_p_current_environment(ScmEvalState *eval_state)
{
    DECLARE_FUNCTION("%%current-environment", procedure_fixed_tailrec_0);

    eval_state->ret_type = SCM_VALTYPE_AS_IS;

    return eval_state->env;
}

SCM_EXPORT ScmObj
scm_p_current_char_codec(void)
{
    const char *encoding;
    DECLARE_FUNCTION("%%current-char-codec", procedure_fixed_0);

#if SCM_USE_MULTIBYTE_CHAR
    encoding = SCM_CHARCODEC_ENCODING(scm_current_char_codec);
#else
    encoding = "ISO-8859-1";
#endif

    return CONST_STRING(encoding);
}

SCM_EXPORT ScmObj
scm_p_set_current_char_codecx(ScmObj encoding)
{
    ScmCharCodec *codec;    
    DECLARE_FUNCTION("%%set-current-char-codec!", procedure_fixed_1);

    ENSURE_STRING(encoding);

#if SCM_USE_MULTIBYTE_CHAR
    codec = scm_mb_find_codec(SCM_STRING_STR(encoding));
    if (!codec)
        ERR_OBJ(ERRMSG_UNSUPPORTED_ENCODING, encoding);
    scm_current_char_codec = codec;
#else
    ERR(ERRMSG_CODEC_SW_NOT_SUPPORTED);
#endif

    return scm_p_current_char_codec();
}

SCM_EXPORT ScmObj
scm_p_prealloc_heaps(ScmObj n)
{
    DECLARE_FUNCTION("%%prealloc-heaps", procedure_fixed_1);

    ENSURE_INT(n);
    if (SCM_INT_VALUE(n) < 0)
        ERR_OBJ("non-negative number required but got", n);

    scm_prealloc_heaps((size_t)SCM_INT_VALUE(n));

    return n;
}

SCM_EXPORT ScmObj
scm_p_pair_mutablep(ScmObj kons)
{
    DECLARE_FUNCTION("%%pair-mutable?", procedure_fixed_1);

    ENSURE_CONS(kons);

    return MAKE_BOOL(SCM_CONS_MUTABLEP(kons));
}

/* R6RS (R5.91RS) compatible */
SCM_EXPORT ScmObj
scm_p_fixnum_width(void)
{
    DECLARE_FUNCTION("fixnum-width", procedure_fixed_0);

    return MAKE_INT(SCM_INT_BITS);
}

/* R6RS (R5.91RS) compatible */
SCM_EXPORT ScmObj
scm_p_least_fixnum(void)
{
    DECLARE_FUNCTION("least-fixnum", procedure_fixed_0);

    return MAKE_INT(SCM_INT_MIN);
}

/* R6RS (R5.91RS) compatible */
SCM_EXPORT ScmObj
scm_p_greatest_fixnum(void)
{
    DECLARE_FUNCTION("greatest-fixnum", procedure_fixed_0);

    return MAKE_INT(SCM_INT_MAX);
}

SCM_EXPORT void
scm_require(const char *filename)
{
    scm_call_with_gc_ready_stack((ScmGCGateFunc)scm_require_internal,
                                 (void *)filename);
}

static void *
scm_require_internal(const char *filename)
{
    ScmObj loaded_str;

    loaded_str = make_loaded_str(filename);
    if (!scm_providedp(loaded_str)) {
        scm_load(filename);
        scm_provide(loaded_str);
    }
    return NULL;
}

SCM_EXPORT ScmObj
scm_p_require(ScmObj filename)
{
#if SCM_COMPAT_SIOD
    ScmObj loaded_str, retsym;
#endif
    DECLARE_FUNCTION("require", procedure_fixed_1);

    ENSURE_STRING(filename);

    scm_require_internal(SCM_STRING_STR(filename));

#if SCM_COMPAT_SIOD
    loaded_str = make_loaded_str(SCM_STRING_STR(filename));
    retsym = scm_intern(SCM_STRING_STR(loaded_str));
    SCM_SYMBOL_SET_VCELL(retsym, SCM_TRUE);

    return retsym;
#else
    return SCM_TRUE;
#endif
}

static ScmObj
make_loaded_str(const char *filename)
{
    char *loaded_str;
    size_t size;

    size = strlen(filename) + sizeof("*-loaded*");
    loaded_str = scm_malloc(size);
    sprintf(loaded_str, "*%s-loaded*", filename);

    return MAKE_IMMUTABLE_STRING(loaded_str, STRLEN_UNKNOWN);
}

/*
 * TODO: replace original specification with a SRFI standard or other de facto
 * standard
 */
SCM_EXPORT ScmObj
scm_p_provide(ScmObj feature)
{
    DECLARE_FUNCTION("provide", procedure_fixed_1);

    ENSURE_STRING(feature);

    scm_provide(feature);

    return SCM_TRUE;
}

/*
 * TODO: replace original specification with a SRFI standard or other de facto
 * standard
 */
SCM_EXPORT ScmObj
scm_p_providedp(ScmObj feature)
{
    DECLARE_FUNCTION("provided?", procedure_fixed_1);

    ENSURE_STRING(feature);

    return MAKE_BOOL(scm_providedp(feature));
}

#if 0
/*
 * Disabled to avoid API confusion.  -- YamaKen 2006-03-26
 *
 * TODO: describe compatibility with de facto standard of other Scheme
 * implementations. Consider compatibility with following uim predicates. The
 * names are based on existing extensions of major Scheme implementations.
 *
 * - file-readable?
 * - file-writable?
 * - file-executable?
 * - file-regular?
 * - file-directory?
 */
SCM_EXPORT ScmObj
scm_p_file_existsp(ScmObj filepath)
{
    FILE *f;
    /* a dummy comment is inserted to be hidden from build_func_table.rb */
    DECLARE_FUNCTION/**/("file-exists?", procedure_fixed_1);

    ENSURE_STRING(filepath);

    f = fopen(SCM_STRING_STR(filepath), "r");
    if (!f)
        return SCM_FALSE;
    fclose(f);

    return SCM_TRUE;
}
#endif

/* to avoid being typo of length+, this procedure did not name as length++ */
/* FIXME: replace with a SRFI or de facto standard equivalent if exist */
/*
 * Dotted list length is returned as follows:
 *
 * list            SRFI-1 dotted length    length* result
 * 'term                    0                    -1
 * '(1 . term)              1                    -2
 * '(1 2 . term)            2                    -3
 * '(1 2 3 . term)          3                    -4
 */
SCM_EXPORT ScmObj
scm_p_lengthstar(ScmObj lst)
{
    scm_int_t len;
    DECLARE_FUNCTION("length*", procedure_fixed_1);

    len = scm_length(lst);
    if (!SCM_LISTLEN_PROPERP(len)) { /* make fast path for proper list */
        if (SCM_LISTLEN_DOTTEDP(len))
            len = -SCM_LISTLEN_DOTTED(len) - 1;
        else if (SCM_LISTLEN_CIRCULARP(len))
            return SCM_FALSE;
    }

    return MAKE_INT(len);
}

SCM_EXPORT ScmObj
scm_p_exit(ScmObj args)
{
    ScmObj explicit_status;
    int status;
    DECLARE_FUNCTION("exit", procedure_variadic_0);

    if (NULLP(args)) {
        status = EXIT_SUCCESS;
    } else {
        explicit_status = POP(args);
        ASSERT_NO_MORE_ARG(args);
        ENSURE_INT(explicit_status);
        status = SCM_INT_VALUE(explicit_status);
    }

    scm_finalize();
    exit(status);
}

/* Conforms to the specification and the behavior of Gauche 0.8.8.
 * http://gauche.sourceforge.jp/doc/gauche-refe_82.html */
SCM_EXPORT ScmObj
scm_s_let_optionalsstar(ScmObj args, ScmObj bindings, ScmObj body,
                        ScmEvalState *eval_state)
{
    ScmObj env, var, val, exp, binding;
    DECLARE_FUNCTION("let-optionals*", syntax_variadic_tailrec_2);

    env = eval_state->env;

    args = EVAL(args, env);
    ENSURE_LIST(args);

    /*=======================================================================
      (let-optionals* <restargs> (<binding spec>*) <body>)
      (let-optionals* <restargs> (<binding spec>+ . <restvar>) <body>)
      (let-optionals* <restargs> <restvar> <body>)  ;; Gauche 0.8.8

      <binding spec> --> (<variable> <expression>)
            | <variable>
      <restvar> --> <variable>
      <body> --> <definition>* <sequence>
      <definition> --> (define <variable> <expression>)
            | (define (<variable> <def formals>) <body>)
            | (begin <definition>*)
      <sequence> --> <command>* <expression>
      <command> --> <expression>
    =======================================================================*/

    FOR_EACH (binding, bindings) {
        if (LIST_2_P(binding)) {
            var = CAR(binding);
            exp = CADR(binding);
        } else {
            var = binding;
            exp = SCM_UNDEF;
        }
        if (!IDENTIFIERP(var))
            ERR_OBJ(ERRMSG_INVALID_BINDING, binding);

        if (NULLP(args)) {
            /* the second element is only evaluated when there are not enough
             * arguments */
            val = EVAL(exp, env);
            CHECK_VALID_EVALED_VALUE(val);
        } else {
            val = POP(args);
        }

        /* extend env for each variable */
        env = scm_extend_environment(LIST_1(var), LIST_1(val), env);
    }
    if (IDENTIFIERP(bindings)) {
        var = bindings;
        env = scm_extend_environment(LIST_1(var), LIST_1(args), env);
    } else if (!NULLP(bindings)) {
        ERR_OBJ(ERRMSG_INVALID_BINDINGS, bindings);
    }

    eval_state->env = env;
    return scm_s_body(body, eval_state);
}
