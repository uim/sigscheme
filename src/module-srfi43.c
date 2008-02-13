/*===========================================================================
 *  Filename : module-srfi43.c
 *  About    : SRFI-43 Vector library
 *
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

#include "sigscheme.h"
#include "sigschemeinternal.h"

/*=======================================
  File Local Macro Definitions
=======================================*/
#define QUOTE(obj) (LIST_2(SYM_QUOTE, (obj)))

/*=======================================
  File Local Type Definitions
=======================================*/

/*=======================================
  File Local Function Declarations
=======================================*/
SCM_EXPORT ScmObj scm_s_let_vector_start_plus_end(ScmObj callee, ScmObj vec,
                                                  ScmObj args,
                                                  ScmObj start_plus_end,
                                                  ScmObj body,
                                                  ScmEvalState *eval_state);

/*=======================================
  Variable Definitions
=======================================*/
#include "functable-srfi43.c"

SCM_GLOBAL_VARS_BEGIN(static_srfi43);
#define static
static ScmObj l_sym_vector_parse_start_plus_end;
static ScmObj l_sym_check_type, l_sym_vectorp;
#undef static
SCM_GLOBAL_VARS_END(static_srfi43);
#define l_sym_vector_parse_start_plus_end                               \
    SCM_GLOBAL_VAR(static_srfi43, l_sym_vector_parse_start_plus_end)
#define l_sym_check_type SCM_GLOBAL_VAR(static_srfi43, l_sym_check_type)
#define l_sym_vectorp    SCM_GLOBAL_VAR(static_srfi43, l_sym_vectorp)
SCM_DEFINE_STATIC_VARS(static_srfi43);

/*=======================================
  Function Definitions
=======================================*/
SCM_EXPORT void
scm_initialize_srfi43(void)
{
    SCM_GLOBAL_VARS_INIT(static_srfi43);

    scm_register_funcs(scm_functable_srfi43);

    scm_require_module("srfi-8");
    scm_require_module("srfi-23");
    scm_require_module("sscm-ext");  /* for let-optionals* */
    scm_load_system_file("srfi-43.scm");

    l_sym_vector_parse_start_plus_end = scm_intern("vector-parse-start+end");
    l_sym_check_type                  = scm_intern("check-type");
    l_sym_vectorp                     = scm_intern("vector?");

    scm_define_alias("let*-optionals", "let-optionals*");
}

/* let-vector-start+end is not a part of SRFI-43. */
SCM_EXPORT ScmObj
scm_s_let_vector_start_plus_end(ScmObj callee, ScmObj vec,
                                ScmObj args, ScmObj start_plus_end,
                                ScmObj body,
                                ScmEvalState *eval_state)
{
    ScmObj env, start_name, end_name, proc_check_type, check_type_args;
    ScmObj receive_expr;
    DECLARE_FUNCTION("let-vector-start+end", syntax_variadic_tailrec_4);

    if (!LIST_2_P(start_plus_end))
        ERR_OBJ("invalid start+end form", start_plus_end);
    /* The responsibility of type checks for other args are delegated to
     * 'check-type' and 'receive'. */

    env = eval_state->env;

    proc_check_type = EVAL(l_sym_check_type, env);
    check_type_args = LIST_3(EVAL(l_sym_vectorp, env),
                             EVAL(vec, env),
                             EVAL(callee, env));
    vec = scm_call(proc_check_type, check_type_args);

    start_name = QUOTE(CAR(start_plus_end));
    end_name   = QUOTE(CADR(start_plus_end));
    receive_expr = CONS(l_sym_vector_parse_start_plus_end,
                        LIST_5(QUOTE(vec), args, start_name, end_name, callee));
    return scm_s_srfi8_receive(start_plus_end, receive_expr, body, eval_state);
}
