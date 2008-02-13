/*===========================================================================
 *  Filename : promise.c
 *  About    : R5RS delayed evaluation
 *
 *  Copyright (C) 2006 YAMAMOTO Kengo <yamaken AT bp.iij4u.or.jp>
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
#define PROMISE_FORCEDP(p) (!EQ(CAR(p), l_tag_unforced))

/*=======================================
  File Local Type Definitions
=======================================*/

/*=======================================
  Variable Definitions
=======================================*/
#include "functable-r5rs-promise.c"

SCM_GLOBAL_VARS_BEGIN(static_promise);
#define static
static ScmObj l_tag_unforced;
#undef static
SCM_GLOBAL_VARS_END(static_promise);
#define l_tag_unforced SCM_GLOBAL_VAR(static_promise, l_tag_unforced)
SCM_DEFINE_STATIC_VARS(static_promise);

/*=======================================
  File Local Function Declarations
=======================================*/

/*=======================================
  Function Definitions
=======================================*/
SCM_EXPORT void
scm_init_promise(void)
{
    SCM_GLOBAL_VARS_INIT(static_promise);

    scm_register_funcs(scm_functable_r5rs_promise);

    /* Use a pair as the unique tag. The symbol %%unforced-promise is only for
     * human-readability. */
    scm_gc_protect_with_init(&l_tag_unforced,
                             LIST_1(scm_intern("%%unforced-promise")));
}

/*===========================================================================
  R5RS : 4.2 Derived expression types : 4.2.5 Delayed evaluation
===========================================================================*/
SCM_EXPORT ScmObj
scm_s_delay(ScmObj exp, ScmObj env)
{
    ScmObj proc;
    DECLARE_FUNCTION("delay", syntax_fixed_1);

    proc = scm_s_lambda(SCM_NULL, LIST_1(exp), env);

    /* (result . proc) */
    return CONS(l_tag_unforced, proc);
}

/*===========================================================================
  R5RS : 6.4 Control features
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_force(ScmObj promise)
{
    ScmObj proc, result;
    DECLARE_FUNCTION("force", procedure_fixed_1);

    ENSURE_CONS(promise);

    proc = CDR(promise);
    ENSURE_PROCEDURE(proc);

    if (PROMISE_FORCEDP(promise))
        return CAR(promise);

    /* R5RS:
     *   Rationale: A promise may refer to its own value, as in the last
     *   example above. Forcing such a promise may cause the promise to be
     *   forced a second time before the value of the first force has been
     *   computed. This complicates the definition of `make-promise'. */
    result = scm_call(proc, SCM_NULL);
    if (PROMISE_FORCEDP(promise))
        return CAR(promise);
    SET_CAR(promise, result);
    return result;
}
