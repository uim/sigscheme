/*===========================================================================
 *  Filename : legacy-macro.c
 *  About    : Legacy 'define-macro' syntax
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

/*=======================================
  File Local Type Definitions
=======================================*/

/*=======================================
  Variable Definitions
=======================================*/
#include "functable-legacy-macro.c"

SCM_DEFINE_EXPORTED_VARS(legacy_macro);

/*=======================================
  File Local Function Declarations
=======================================*/

/*=======================================
  Function Definitions
=======================================*/
SCM_EXPORT void
scm_init_legacy_macro(void)
{
    ScmObj syn_closure_env;

    SCM_GLOBAL_VARS_INIT(legacy_macro);

    scm_register_funcs(scm_functable_legacy_macro);

    /* dummy environment as syntactic closure marker */
    syn_closure_env
        = scm_extend_environment(LIST_1(scm_intern("define-macro")),
                                 LIST_1(SCM_FALSE),
                                 SCM_INTERACTION_ENV);
    scm_gc_protect_with_init(&scm_syntactic_closure_env, syn_closure_env);
}

/* To test ScmNestState, scm_s_define() needs ScmEvalState although this is not
 * a tail-recursive syntax */
SCM_EXPORT ScmObj
scm_s_define_macro(ScmObj identifier, ScmObj rest, ScmEvalState *eval_state)
{
    ScmObj closure;
    DECLARE_FUNCTION("define-macro", syntax_variadic_tailrec_1);

    scm_s_define(identifier, rest, eval_state);

    /*=======================================================================
      (define-macro <identifier> <closure>)
    =======================================================================*/
    if (IDENTIFIERP(identifier)) {
    }

    /*=======================================================================
      (define-macro (<identifier> . <formals>) <body>)

      => (define-macro <identifier>
             (lambda <formals> <body>))
    =======================================================================*/
    else if (CONSP(identifier)) {
        identifier = CAR(identifier);
    } else {
        ERR_OBJ("bad define-macro form",
                CONS(scm_intern("define-macro"), CONS(identifier, rest)));
    }

#if SCM_USE_HYGIENIC_MACRO
    SCM_ASSERT(SYMBOLP(identifier) || SYMBOLP(SCM_FARSYMBOL_SYM(identifier)));
#else
    SCM_ASSERT(SYMBOLP(identifier));
#endif
    identifier = SCM_UNWRAP_KEYWORD(identifier);

    closure = SCM_SYMBOL_VCELL(identifier);
    if (!CLOSUREP(closure))
        SCM_SYMBOL_SET_VCELL(identifier, SCM_UNBOUND);
    ENSURE_CLOSURE(closure);
    if (!scm_toplevel_environmentp(SCM_CLOSURE_ENV(closure)))
        ERR("syntactic closure in SigScheme must have toplevel environment");
    /* destructively mark the closure as syntactic */
    SCM_CLOSURE_SET_ENV(closure, SCM_SYNTACTIC_CLOSURE_ENV);

    eval_state->ret_type = SCM_VALTYPE_AS_IS;
    return SCM_UNDEF;
}
