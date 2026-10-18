/*===========================================================================
 *  Filename : promise.c
 *  About    : R5RS delayed evaluation
 *
 *  Copyright (C) 2006 YAMAMOTO Kengo <yamaken AT bp.iij4u.or.jp>
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

#include <sigscheme/sigscheme.h>
#include "sigschemeinternal.h"

/*=======================================
  File Local Macro Definitions
=======================================*/
/*
 * A promise is (box . tag) like chibi-scheme. tag is the unique object to
 * distinguish promises. box is (state . value) and it's shared by promises
 * chained by delay-force of R7RS:
 *
 *   PROMISE_DONE:        value is the forced value
 *   PROMISE_DELAY:       value is a thunk that returns the value
 *   PROMISE_DELAY_FORCE: value is a thunk that returns a promise
 */
#define PROMISE_DONE        0
#define PROMISE_DELAY       1
#define PROMISE_DELAY_FORCE 2

#define PROMISE_BOX(p)   CAR(p)
#define PROMISE_STATE(p) SCM_INT_VALUE(CAR(PROMISE_BOX(p)))
#define PROMISE_VALUE(p) CDR(PROMISE_BOX(p))

/*=======================================
  File Local Type Definitions
=======================================*/

/*=======================================
  Variable Definitions
=======================================*/
#include "functable-r5rs-promise.c"

SCM_GLOBAL_VARS_BEGIN(static_promise);
#define static
static ScmObj l_promise_tag;
#undef static
SCM_GLOBAL_VARS_END(static_promise);
#define l_promise_tag SCM_GLOBAL_VAR(static_promise, l_promise_tag)
SCM_DEFINE_STATIC_VARS(static_promise);

/*=======================================
  File Local Function Declarations
=======================================*/
static ScmObj make_promise(int state, ScmObj value);

/*=======================================
  Function Definitions
=======================================*/
SCM_EXPORT void
scm_init_promise(void)
{
    SCM_GLOBAL_VARS_INIT(static_promise);

    scm_register_funcs(scm_functable_r5rs_promise);

    /* Use a pair as the unique tag. The symbol %%promise is only for
     * human-readability. */
    scm_gc_protect_with_init(&l_promise_tag, LIST_1(scm_intern("%%promise")));
}

static ScmObj
make_promise(int state, ScmObj value)
{
    return CONS(CONS(MAKE_INT(state), value), l_promise_tag);
}

SCM_EXPORT scm_bool
scm_promisep(ScmObj obj)
{
    return CONSP(obj) && EQ(CDR(obj), l_promise_tag);
}

/* make-promise of R7RS without the check whether VALUE is a promise. */
SCM_EXPORT ScmObj
scm_make_forced_promise(ScmObj value)
{
    return make_promise(PROMISE_DONE, value);
}

/* delay-force of R7RS: THUNK returns a promise. */
SCM_EXPORT ScmObj
scm_make_delay_force_promise(ScmObj thunk)
{
    return make_promise(PROMISE_DELAY_FORCE, thunk);
}

/*===========================================================================
  R5RS : 4.2 Derived expression types : 4.2.5 Delayed evaluation
===========================================================================*/
SCM_EXPORT ScmObj
scm_s_delay(ScmObj exp, ScmObj env)
{
    DECLARE_FUNCTION("delay", syntax_fixed_1);

    return make_promise(PROMISE_DELAY,
                        scm_s_lambda(SCM_NULL, LIST_1(exp), env));
}

/*===========================================================================
  R5RS : 6.4 Control features
===========================================================================*/
/* This is the iterative version of force of the R7RS reference
 * implementation. So a long chain of delay-force runs in constant space. */
SCM_EXPORT ScmObj
scm_p_force(ScmObj promise)
{
    ScmObj thunk, result;
    int state;
    DECLARE_FUNCTION("force", procedure_fixed_1);

    if (!scm_promisep(promise))
        ERR_OBJ("promise required but got", promise);

    for (;;) {
        state = PROMISE_STATE(promise);
        if (state == PROMISE_DONE)
            return PROMISE_VALUE(promise);

        thunk = PROMISE_VALUE(promise);
        result = scm_call(thunk, SCM_NULL);

        /* R5RS:
         *   Rationale: A promise may refer to its own value, as in the last
         *   example above. Forcing such a promise may cause the promise to be
         *   forced a second time before the value of the first force has been
         *   computed. This complicates the definition of `make-promise'. */
        if (PROMISE_STATE(promise) == PROMISE_DONE)
            return PROMISE_VALUE(promise);

        if (state == PROMISE_DELAY) {
            SET_CAR(PROMISE_BOX(promise), MAKE_INT(PROMISE_DONE));
            SET_CDR(PROMISE_BOX(promise), result);
            return result;
        }

        /* delay-force: Share the box of RESULT and force it. */
        if (!scm_promisep(result))
            ERR_OBJ("delay-force requires a promise but got", result);
        SET_CAR(PROMISE_BOX(promise), CAR(PROMISE_BOX(result)));
        SET_CDR(PROMISE_BOX(promise), CDR(PROMISE_BOX(result)));
        SET_CAR(result, PROMISE_BOX(promise));
    }
}
