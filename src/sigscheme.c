/*===========================================================================
 *  Filename : sigscheme.c
 *  About    : Client interfaces
 *
 *  Copyright (C) 2005      Kazuki Ohta <mover AT hct.zaq.ne.jp>
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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "sigscheme.h"
#include "sigschemeinternal.h"
#if SCM_USE_MULTIBYTE_CHAR
#include "encoding.h"
#else
#include "encoding-dummy.h"
#endif
#if SCM_USE_EVAL_C_STRING
#include "scmport-config.h"
#include "scmport.h"
#include "scmport-str.h"
#endif

/*=======================================
  File Local Macro Definitions
=======================================*/
#if !SCM_USE_CONTINUATION
#define scm_p_call_with_current_continuation NULL
#define scm_p_dynamic_wind                   NULL
#endif

/*=======================================
  File Local Type Definitions
=======================================*/

/*=======================================
  Variable Definitions
=======================================*/
#include "functable-sscm-core.c"
#include "functable-r5rs-core.c"
#if SCM_USE_READER
#include "functable-r5rs-read.c"
#endif
#if SCM_USE_QUASIQUOTE
#include "functable-r5rs-qquote.c"
#endif
#if SCM_USE_NUMBER
#include "functable-r5rs-number.c"
#endif
#if (SCM_USE_NUMBER_IO && SCM_USE_STRING)
#include "functable-r5rs-number-io.c"
#endif
#if SCM_USE_CHAR
#include "functable-r5rs-char.c"
#endif
#if SCM_USE_STRING
#include "functable-r5rs-string.c"
#endif
#if SCM_USE_STRING_PROCEDURE
#include "functable-r5rs-string-procedure.c"
#endif
#if SCM_USE_VECTOR
#include "functable-r5rs-vector.c"
#endif
#if SCM_USE_DEEP_CADRS
#include "functable-r5rs-deep-cadrs.c"
#endif

SCM_GLOBAL_VARS_BEGIN(static_sigscheme);
#define static
static scm_bool l_scm_initialized;
#undef static
SCM_GLOBAL_VARS_END(static_sigscheme);
#define l_scm_initialized SCM_GLOBAL_VAR(static_sigscheme, l_scm_initialized)
SCM_DEFINE_STATIC_VARS(static_sigscheme);

static const char *const builtin_features[] = {
    "sigscheme",
#if SCM_USE_INTERNAL_DEFINITIONS
    "internal-definitions",
#endif
#if SCM_STRICT_TOPLEVEL_DEFINITIONS
    "strict-toplevel-definitions",
#endif
#if SCM_NESTED_CONTINUATION_ONLY
    "nested-continuation-only",
#endif
#if SCM_STRICT_R5RS
    "strict-r5rs",
#endif
#if SCM_STRICT_ARGCHECK
    "strict-argcheck",
#endif
#if SCM_STRICT_NULL_FORM
    "strict-null-form",
#endif
#if SCM_STRICT_VECTOR_FORM
    "strict-vector-form",
#endif
#if SCM_STRICT_ENCODING_CHECK
    "strict-encoding-check",
#endif
#if (SCM_CONST_LIST_LITERAL && SCM_HAS_IMMUTABLE_CONS)
    "const-list-literal",
#endif
#if (SCM_CONST_VECTOR_LITERAL && SCM_HAS_IMMUTABLE_VECTOR)
    "const-vector-literal",
#endif
#if SCM_USE_DEEP_CADRS
    "deep-cadrs",
#endif
#if SCM_COMPAT_SIOD
    "compat-siod",
#endif
#if SCM_COMPAT_SIOD_BUGS
    "siod-bugs",
#endif
#if SCM_USE_NULL_CAPABLE_STRING
    "null-capable-string",
#endif
#if SCM_HAS_IMMEDIATE_CHAR_ONLY
    "immediate-char-only",
#endif
#if SCM_HAS_IMMEDIATE_NUMBER_ONLY
    "immediate-number-only",
#endif
#if SCM_USE_MULTIBYTE_CHAR
    "multibyte-char",
#endif
#if SCM_USE_UTF8
    "utf-8",
#endif
#if SCM_USE_EUCCN
    "euc-cn",
#endif
#if SCM_USE_EUCJP
    "euc-jp",
#endif
#if SCM_USE_EUCKR
    "euc-kr",
#endif
#if SCM_USE_SJIS
    "shift-jis",
#endif
    NULL
};

/*=======================================
  File Local Function Declarations
=======================================*/
static char **scm_initialize_internal(const char *const *argv);
#if SCM_USE_EVAL_C_STRING
static void *scm_eval_c_string_internal(const char *exp);
#endif
static void argv_err(char **argv, const char *err_msg);

/*=======================================
  Function Definitions
=======================================*/
/**
 * Initialize the interpreter
 *
 * @param storage_conf Storage configuration parameters. NULL instructs
 *                     default.
 */
SCM_EXPORT char **
scm_initialize(const ScmStorageConf *storage_conf, const char *const *argv)
{
    char **rest_argv;

    SCM_AGGREGATED_GLOBAL_VARS_INIT();

    scm_encoding_init();
    scm_init_storage(storage_conf);

    rest_argv = scm_call_with_gc_ready_stack((ScmGCGateFunc)scm_initialize_internal, (void *)argv);

    l_scm_initialized = scm_true;

    return rest_argv;
}

static char **
scm_initialize_internal(const char *const *argv)
{
    const char *const *feature;
    char **rest_argv;

    rest_argv = (char **)argv;

    /* size constraints */
    /* FIXME: check at compile-time */
    if (!((SCM_SAL_PTR_BITS <= SIZEOF_VOID_P * CHAR_BIT)
          && (SCM_SAL_CHAR_BITS <= SIZEOF_SCM_ICHAR_T * CHAR_BIT)
          && (SCM_SAL_INT_BITS <= SIZEOF_SCM_INT_T * CHAR_BIT)
          && (SCM_SAL_STRLEN_BITS <= SCM_SAL_INT_BITS)
          && (SCM_SAL_VECLEN_BITS <= SCM_SAL_INT_BITS)))
        scm_fatal_error("bit width constraints of the storage implementation are broken");

    if (!((SCM_SAL_CHAR_MAX <= SCM_ICHAR_T_MAX)
          && (SCM_INT_T_MIN <= SCM_SAL_INT_MIN
              && SCM_SAL_INT_MAX <= SCM_INT_T_MAX)
          && (SCM_SAL_STRLEN_MAX <= SCM_SAL_INT_MAX)
          && (SCM_SAL_VECLEN_MAX <= SCM_SAL_INT_MAX)))
        scm_fatal_error("size constraints of the storage implementation are broken");

    /*=======================================================================
      Core
    =======================================================================*/
    SCM_GLOBAL_VARS_INIT(procedure);
    SCM_GLOBAL_VARS_INIT(static_sigscheme);

    scm_init_error();
    scm_set_debug_categories(SCM_DBG_ERRMSG | SCM_DBG_BACKTRACE
                             | scm_predefined_debug_categories());

#if SCM_USE_WRITER
    scm_init_writer();
#endif
#if SCM_USE_FORMAT
    /* FIXME: duplicate call with scm_initialize_srfi{28,48}() */
    scm_init_format();
#endif
#if SCM_USE_READER
    scm_register_funcs(scm_functable_r5rs_read);
#endif
#if SCM_USE_LOAD
    scm_init_load();
#endif
    scm_init_module();

    /* fallback to unibyte */
    scm_identifier_codec = scm_mb_find_codec("UTF-8");

    /*=======================================================================
      Register Built-in Functions
    =======================================================================*/
    /* pseudo procedure to deliver multiple values to an arbitrary procedure
     * (assigns an invalid continuation as unique ID) */
    scm_gc_protect_with_init(&scm_values_applier, MAKE_CONTINUATION());

    /* SigScheme-specific core syntaxes and procedures */
    scm_register_funcs(scm_functable_sscm_core);

    /* R5RS Syntaxes */
    scm_init_syntax();
#if SCM_USE_QUASIQUOTE
    scm_register_funcs(scm_functable_r5rs_qquote);
#endif
#if SCM_USE_HYGIENIC_MACRO
    scm_init_macro();
#endif
#if SCM_USE_PROMISE
    scm_init_promise();
#endif

    /* R5RS Procedures */
    scm_register_funcs(scm_functable_r5rs_core);
#if !SCM_USE_CONTINUATION
    SCM_SYMBOL_SET_VCELL(scm_intern("call-with-current-continuation"), SCM_UNBOUND);
    SCM_SYMBOL_SET_VCELL(scm_intern("call-with-values"), SCM_UNBOUND);
#endif
#if SCM_USE_NUMBER
    scm_register_funcs(scm_functable_r5rs_number);
#endif
#if (SCM_USE_NUMBER_IO && SCM_USE_STRING)
    scm_register_funcs(scm_functable_r5rs_number_io);
#endif
#if SCM_USE_CHAR
    scm_register_funcs(scm_functable_r5rs_char);
#endif
#if SCM_USE_STRING
    scm_register_funcs(scm_functable_r5rs_string);
#endif
#if SCM_USE_STRING_PROCEDURE
    scm_register_funcs(scm_functable_r5rs_string_procedure);
#endif
#if SCM_USE_VECTOR
    scm_register_funcs(scm_functable_r5rs_vector);
#endif
#if SCM_USE_DEEP_CADRS
    scm_register_funcs(scm_functable_r5rs_deep_cadrs);
#endif

    /* for distinction from SRFI-1 versions */
    scm_define_alias("r5rs:map",      "map");
    scm_define_alias("r5rs:for-each", "for-each");
    scm_define_alias("r5rs:member",   "member");
    scm_define_alias("r5rs:assoc",    "assoc");

    /* for distinction from SRFI-9 overridings */
    scm_define_alias("r5rs:vector?", "vector?");
    scm_define_alias("r5rs:eval",    "eval");

#if SCM_USE_LEGACY_MACRO
    scm_init_legacy_macro();
#endif
#if SCM_USE_SSCM_EXTENSIONS
    scm_require_module("sscm-ext");
#endif
#if SCM_USE_EVAL_C_STRING
    scm_require_module("srfi-6");
#endif

    /*=======================================================================
      Fixing up
    =======================================================================*/
    /* to evaluate SigScheme-dependent scheme codes conditionally */
    for (feature = &builtin_features[0]; *feature; feature++)
        scm_provide(CONST_STRING(*feature));

    /* Since SCM_SAL_PTR_BITS may use sizeof() instead of autoconf SIZEOF
     * macro, #if is not safe here. */
    if (SCM_PTR_BITS == 64)
        scm_provide(CONST_STRING("64bit-addr"));

    if (argv)
        rest_argv = scm_interpret_argv((char **)argv);  /* safe cast */

#if SCM_USE_PORT
    /* To apply -C <encoding> option for scm_{in,out,err} ports, this
     * invocation is placed after scm_interpret_argv() */
    scm_init_port();
#endif
#if SCM_USE_LOAD
    /* Load additional procedures written in Scheme */
    scm_load_system_file("sigscheme-init.scm");
#endif

#if SCM_USE_SRFI55
    /* require-extension is enabled by default */
    scm_require_module("srfi-55");
#endif
#if SCM_USE_SRFI0
    /* cond-expand is enabled by default */
    scm_s_srfi55_require_extension(LIST_1(LIST_2(scm_intern("srfi"),
                                                 MAKE_INT(0))),
                                   SCM_INTERACTION_ENV);
#endif

    return rest_argv;
}

SCM_EXPORT void
scm_finalize()
{
#if SCM_USE_LOAD
    scm_fin_load();
#endif
    scm_fin_module();
    scm_fin_storage();
    l_scm_initialized = scm_false;

    SCM_GLOBAL_VARS_FIN(procedure);
    SCM_GLOBAL_VARS_FIN(static_sigscheme);
    SCM_AGGREGATED_GLOBAL_VARS_FIN();
}

#if SCM_USE_EVAL_C_STRING
SCM_EXPORT ScmObj
scm_eval_c_string(const char *exp)
{
    return (ScmObj)scm_call_with_gc_ready_stack((ScmGCGateFunc)scm_eval_c_string_internal, (void *)exp);
}

static void *
scm_eval_c_string_internal(const char *exp)
{
    ScmObj str_port, ret;
    ScmBytePort *bport;
    ScmCharPort *cport;

    bport = ScmInputStrPort_new_const(exp, NULL);
    cport = scm_make_char_port(bport);
    str_port = MAKE_PORT(cport, SCM_PORTFLAG_INPUT);

    ret = scm_read(str_port);
    ret = EVAL(ret, SCM_INTERACTION_ENV);

    return (void *)ret;
}
#endif /* SCM_USE_EVAL_C_STRING */

SCM_EXPORT ScmObj
scm_array2list(void **ary, size_t len, ScmObj (*conv)(void *))
{
    void **p;
    ScmObj elm, lst;
    ScmQueue q;
    DECLARE_INTERNAL_FUNCTION("scm_array2list");

    SCM_ASSERT(ary);
    SCM_ASSERT(len <= SCM_INT_T_MAX);

    lst = SCM_NULL;
    SCM_QUEUE_POINT_TO(q, lst);
    for (p = &ary[0]; p < &ary[len]; p++) {
        elm = (conv) ? (*conv)(*p) : (ScmObj)(*p);
        SCM_QUEUE_ADD(q, elm);
    }

    return lst;
}

SCM_EXPORT void **
scm_list2array(ScmObj lst, size_t *len, void *(*conv)(ScmObj))
{
    scm_int_t scm_len;
    void **ary, **p;
    ScmObj elm;
    DECLARE_INTERNAL_FUNCTION("scm_list2array");

    scm_len = scm_length(lst);
    if (!SCM_LISTLEN_PROPERP(scm_len))
        ERR("proper list required");

    *len = (size_t)scm_len;
    p = ary = scm_malloc(*len * sizeof(void *));
    FOR_EACH (elm, lst)
        *p++ = (conv) ? (*conv)(elm) : (void *)elm;

    return ary;
}

static void
argv_err(char **argv, const char *err_msg)
{
    DECLARE_INTERNAL_FUNCTION("scm_interpret_argv");

    if (l_scm_initialized) {
        scm_free_argv(argv);
        ERR(err_msg);
    } else {
        fputs(SCM_ERR_HEADER, stderr);
        fputs(err_msg, stderr);
        fputs("\n", stderr);
        exit(EXIT_FAILURE);
    }
}

/* TODO: parse properly */
/* don't access ScmObj if (!l_scm_initialized) */
SCM_EXPORT char **
scm_interpret_argv(char **argv)
{
    char **argp, **rest;
    const char *encoding, *sys_load_path;
#if SCM_USE_MULTIBYTE_CHAR
    ScmCharCodec *specified_codec;
    ScmObj err_obj;
#endif
    DECLARE_INTERNAL_FUNCTION("scm_interpret_argv");

    encoding = sys_load_path = NULL;
    argp = &argv[0];
    if (strcmp(argv[0], "/usr/bin/env") == 0)
        argp++;
    if (*argp)
        argp++;  /* skip executable name */

    /* parse options */
    for (; *argp; argp++) {
        if ((*argp)[0] != '-')
            break;  /* script name appeared */

        if (strcmp(*argp, "-C") == 0) {
            /* character encoding */
            encoding = *++argp;
            if (!encoding)
                argv_err(argv, "no encoding name specified");
        } else if (strcmp(*argp, "--system-load-path") == 0) {
            /* system load path */
            sys_load_path = *++argp;
            if (!sys_load_path)
                argv_err(argv, "no system load path specified");
        } else {
            argv_err(argv, "invalid option");
        }
    }
    rest = argp;

    /* apply options */
    if (encoding) {
#if SCM_USE_MULTIBYTE_CHAR
        specified_codec = scm_mb_find_codec(encoding);
        if (!specified_codec) {
            if (l_scm_initialized) {
                err_obj = CONST_STRING(encoding);
                scm_free_argv(argv);
                ERR_OBJ(ERRMSG_UNSUPPORTED_ENCODING, err_obj);
            } else {
                fprintf(stderr,
                        SCM_ERR_HEADER ERRMSG_UNSUPPORTED_ENCODING ": %s\n",
                        encoding);
                exit(EXIT_FAILURE);
            }
        }
        scm_current_char_codec = specified_codec;
#else
        argv_err(argv, ERRMSG_CODEC_SW_NOT_SUPPORTED);
#endif
    }

    if (sys_load_path) {
        scm_set_system_load_path(sys_load_path);
    }

    return rest;
}

SCM_EXPORT void
scm_free_argv(char **argv)
{
    char **argp;

    for (argp = &argv[0]; *argp; argp++) {
        free(*argp);
    }
    free(argv);
}
