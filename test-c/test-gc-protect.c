/*===========================================================================
 *  Filename : test-gc-protect.c
 *  About    : garbage collector protection test
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

#include <sigscheme/config.h>

#include "sscm-test.h"
#include "sigscheme.h"
#include "sigschemeinternal.h"

/* Due to the conservative GC algorithm, an object cannot be detected as "this
 * object is NOT protected", although "IS protected" can. But since testing
 * such uncertain unprotected objects helps GC debugging, this file try such
 * tests iff --enable-debug is specified although they may fail.
 *   -- YamaKen 2008-04-27 */
#define TRY_TESTS_THAT_PASS_IN_MOST_CASES SCM_DEBUG

static ScmObj make_obj(void);
static void *make_obj_internal(void *dummy);
static void *protected_func(void *arg);
static void *var_in_protected_func(void *arg);
static void *vars_in_protected_func(void *arg);
static void *test_implicit_protection(void *dummy);

/* To disable GC stack protection, remove scm_call_with_gc_ready_stack() */
#undef TST_RUN
#define TST_RUN(fn, s, c) (fn(s, c))

#define N_OBJS 128
static ScmObj static_objs[N_OBJS];
static ScmObj protected_lst, unprotected_lst;

static ScmObj
make_obj(void)
{
    return (ScmObj)scm_call_with_gc_ready_stack(make_obj_internal, NULL);
}

static void *
make_obj_internal(void *dummy)
{
    return (void *)CONS(SCM_FALSE, SCM_FALSE);
}

TST_CASE("scm_gc_protected_contextp()")
{
    TST_TN_FALSE(scm_gc_protected_contextp());

    TST_TN_FALSE(protected_func(NULL));
    TST_TN_TRUE (scm_call_with_gc_ready_stack(protected_func, NULL));
    TST_TN_FALSE(protected_func(NULL));
}

static void *
protected_func(void *arg)
{
    return (void *)scm_gc_protected_contextp();
}

TST_CASE("GC stack protection")
{
    TST_TN_FALSE(scm_gc_protected_contextp());

#if TRY_TESTS_THAT_PASS_IN_MOST_CASES
    TST_TN_FALSE(var_in_protected_func(NULL));
#endif
    TST_TN_TRUE (scm_call_with_gc_ready_stack(var_in_protected_func, NULL));
#if TRY_TESTS_THAT_PASS_IN_MOST_CASES
    TST_TN_FALSE(var_in_protected_func(NULL));
#endif
}

static void *
var_in_protected_func(void *arg)
{
    ScmObj obj;

    obj = make_obj();
    return (void *)scm_gc_protectedp(obj);
}

TST_CASE("GC stack protection for long array")
{
    TST_TN_FALSE(scm_gc_protected_contextp());

#if TRY_TESTS_THAT_PASS_IN_MOST_CASES
    TST_TN_FALSE(vars_in_protected_func(NULL));
#endif
    TST_TN_TRUE (scm_call_with_gc_ready_stack(vars_in_protected_func, NULL));
#if TRY_TESTS_THAT_PASS_IN_MOST_CASES
    TST_TN_FALSE(vars_in_protected_func(NULL));
#endif
}

static void *
vars_in_protected_func(void *arg)
{
    ScmObj objs[N_OBJS];
    int i;
    scm_bool protectedp;

    for (i = 0; i < N_OBJS; i++)
        objs[i] = make_obj();
    for (i = 0, protectedp = scm_true; i < N_OBJS; i++)
        protectedp = protectedp && scm_gc_protectedp(objs[i]);

    return (void *)protectedp;
}

TST_CASE("GC static variable protection")
{
    int i;

    TST_TN_FALSE(scm_gc_protected_contextp());

#if TRY_TESTS_THAT_PASS_IN_MOST_CASES
    /* unprotected */
    for (i = 0; i < N_OBJS; i++)
        static_objs[i] = make_obj();
    for (i = 0; i < N_OBJS; i++)
        TST_TN_FALSE(scm_gc_protectedp(static_objs[i]));
#endif

    /* protected */
    for (i = 0; i < N_OBJS; i++) {
        scm_gc_protect(&static_objs[i]);
        static_objs[i] = make_obj();
    }
    for (i = 0; i < N_OBJS; i++)
        TST_TN_TRUE(scm_gc_protectedp(static_objs[i]));

#if TRY_TESTS_THAT_PASS_IN_MOST_CASES
    /* unprotect again */
    for (i = 0; i < N_OBJS; i++)
        scm_gc_unprotect(&static_objs[i]);
    for (i = 0; i < N_OBJS; i++)
        TST_TN_FALSE(scm_gc_protectedp(static_objs[i]));
#endif
}

TST_CASE("GC auto variable protection with scm_gc_protect()")
{
    ScmObj auto_objs[N_OBJS];
    int i;

    TST_TN_FALSE(scm_gc_protected_contextp());

#if TRY_TESTS_THAT_PASS_IN_MOST_CASES
    /* unprotected */
    for (i = 0; i < N_OBJS; i++)
        auto_objs[i] = make_obj();
    for (i = 0; i < N_OBJS; i++)
        TST_TN_FALSE(scm_gc_protectedp(auto_objs[i]));
#endif

    /* protected */
    for (i = 0; i < N_OBJS; i++) {
        scm_gc_protect(&auto_objs[i]);
        auto_objs[i] = make_obj();
    }
    for (i = 0; i < N_OBJS; i++)
        TST_TN_TRUE(scm_gc_protectedp(auto_objs[i]));

#if TRY_TESTS_THAT_PASS_IN_MOST_CASES
    /* unprotect again */
    for (i = 0; i < N_OBJS; i++)
        scm_gc_unprotect(&auto_objs[i]);
    for (i = 0; i < N_OBJS; i++)
        TST_TN_FALSE(scm_gc_protectedp(auto_objs[i]));
#endif
}

static void *
test_implicit_protection(void *dummy)
{
    scm_bool result;
    ScmObj lst;

    lst = LIST_2(SCM_FALSE, SCM_FALSE);
    unprotected_lst = CDR(lst);

    result = scm_gc_protectedp(lst);
    /* the cdr is implicitly protected since indirectly referred from the lst */
    result = result && scm_gc_protectedp(unprotected_lst);
    /* unlink the indirect reference */
    lst = SCM_FALSE;
    /* it makes the variable unprotected */
#if 0
    /* This condition may not be met since the values of unprotected_lst or
     * lst may be remained in registers */
    result = result && !scm_gc_protectedp(unprotected_lst);
#endif

    return (void *)result;
}

TST_CASE("GC indirect protection via on-heap object reference")
{
    ScmObj lst;  /* unprotected */

    TST_TN_FALSE(scm_gc_protected_contextp());

    TST_TN_TRUE (scm_call_with_gc_ready_stack(test_implicit_protection, NULL));

#if TRY_TESTS_THAT_PASS_IN_MOST_CASES
    /* unprotected lst */
    lst = LIST_2(SCM_FALSE, SCM_FALSE);
    unprotected_lst = CDR(lst);

    TST_TN_FALSE(scm_gc_protectedp(lst));
    TST_TN_FALSE(scm_gc_protectedp(unprotected_lst));
    lst = SCM_FALSE;
    TST_TN_FALSE(scm_gc_protectedp(unprotected_lst));

    /* unprotected static lst */
    protected_lst = LIST_2(SCM_FALSE, SCM_FALSE);
    unprotected_lst = CDR(protected_lst);

    TST_TN_FALSE(scm_gc_protectedp(protected_lst));
    TST_TN_FALSE(scm_gc_protectedp(unprotected_lst));
    lst = SCM_FALSE;
    TST_TN_FALSE(scm_gc_protectedp(unprotected_lst));
#endif

    /* protected static lst */
    scm_gc_protect(&protected_lst);
    protected_lst = LIST_2(SCM_FALSE, SCM_FALSE);
    unprotected_lst = CDR(protected_lst);

    TST_TN_TRUE (scm_gc_protectedp(protected_lst));
    TST_TN_TRUE (scm_gc_protectedp(unprotected_lst));
    protected_lst = SCM_FALSE;
#if TRY_TESTS_THAT_PASS_IN_MOST_CASES
    TST_TN_FALSE(scm_gc_protectedp(unprotected_lst));
#endif
}
