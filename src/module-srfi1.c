/*===========================================================================
 *  Filename : module-srfi1.c
 *  About    : SRFI-1 List Library
 *
 *  Copyright (C) 2005      Kazuki Ohta <mover AT hct.zaq.ne.jp>
 *  Copyright (C) 2005-2006 YAMAMOTO Kengo <yamaken AT bp.iij4u.or.jp>
 *  Copyright (c) 2007 SigScheme Project <uim AT freedesktop.org>
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

/*
 * Do not use this implementation for production code.
 *
 * This SRFI-1 implementation is still broken, and not using the SigScheme's
 * safe and simple coding elements.
 */

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
#include "functable-srfi1.c"

/*=======================================
  File Local Function Declarations
=======================================*/

/*=======================================
  Function Definitions
=======================================*/
SCM_EXPORT void
scm_initialize_srfi1(void)
{
    scm_require(SCMLIBDIR "/srfi-1.scm");

    scm_define_alias("srfi-1:map",      "map");
    scm_define_alias("srfi-1:for-each", "for-each");
    scm_define_alias("srfi-1:member",   "member");
    scm_define_alias("srfi-1:assoc",    "assoc");

#if 0
    /* Although SigScheme's map is faster than srfi-1.scm and in-order, it is
     * not conforming to SRFI-1 specification since it rejects unequal length
     * arguments. If you need to use the efficient C version of map and
     * for-each, evaluate (define map r5rs:map) and (define for-each
     * r5rs:for-each) in your code after (use srfi-1). */
    scm_define_alias("map-in-order", "r5rs:map");
    scm_define_alias("map",          "r5rs:map");
    scm_define_alias("for-each",     "r5rs:for-each");
#endif

    /* overwrite Scheme procedures with efficient C implementations */
    scm_register_funcs(scm_functable_srfi1);
}

/*===========================================================================
  Predicates
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_srfi1_proper_listp(ScmObj obj)
{
    DECLARE_FUNCTION("proper-list?", procedure_fixed_1);

    return MAKE_BOOL(PROPER_LISTP(obj));
}

SCM_EXPORT ScmObj
scm_p_srfi1_circular_listp(ScmObj obj)
{
    DECLARE_FUNCTION("circular-list?", procedure_fixed_1);

    return MAKE_BOOL(CIRCULAR_LISTP(obj));
}

SCM_EXPORT ScmObj
scm_p_srfi1_dotted_listp(ScmObj obj)
{
    DECLARE_FUNCTION("dotted-list?", procedure_fixed_1);

    return MAKE_BOOL(DOTTED_LISTP(obj));
}

/*===========================================================================
  Selectors
===========================================================================*/
/* SRFI1: drop returns all but the first i elements of list x.
 * x may be any value -- a proper, circular, or dotted list. */
SCM_EXPORT ScmObj
scm_p_srfi1_drop(ScmObj lst, ScmObj scm_idx)
{
    ScmObj ret;
    scm_int_t idx, i;
    DECLARE_FUNCTION("drop", procedure_fixed_2);

    ENSURE_INT(scm_idx);

    idx = SCM_INT_VALUE(scm_idx);
    ret = lst;
    for (i = 0; i < idx; i++) {
        if (!CONSP(ret))
            ERR_OBJ("illegal index is specified for", lst);

        ret = CDR(ret);
    }

    return ret;
}

/* SRFI-1: last-pair returns the last pair in the non-empty, finite list
 * pair. */
SCM_EXPORT ScmObj
scm_p_srfi1_last_pair(ScmObj lst)
{
    DECLARE_FUNCTION("last-pair", procedure_fixed_1);

    ENSURE_CONS(lst);

    for (; CONSP(CDR(lst)); lst = CDR(lst))
        ;

    return lst;
}

/*===========================================================================
  Miscellaneous
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_srfi1_lengthplus(ScmObj lst)
{
    scm_int_t len;
    DECLARE_FUNCTION("length+", procedure_fixed_1);

    len = scm_length(lst);
    /* although SRFI-1 does not specify the behavior for dotted list
     * explicitly, the description indicates that dotted list is treated as
     * same as R5RS 'length' procedure. So produce an error here. */
    if (SCM_LISTLEN_DOTTEDP(len))
        ERR_OBJ("proper or circular list required but got", lst);

    return (SCM_LISTLEN_PROPERP(len)) ? MAKE_INT(len) : SCM_FALSE;
}

/*===========================================================================
  Searching
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_srfi1_find_tail(ScmObj pred, ScmObj lst)
{
    ScmObj tail, elm, found, term;
    DECLARE_FUNCTION("find-tail", procedure_fixed_2);

    ENSURE_PROCEDURE(pred);

    FOR_EACH_PAIR (tail, lst) {
        elm = CAR(tail);
        found = scm_call(pred, LIST_1(elm));
        if (TRUEP(found))
            return tail;
    }
    term = CONSP(tail) ? CDR(tail) : tail;
    CHECK_PROPER_LIST_TERMINATION(term, lst);

    return SCM_FALSE;
}
