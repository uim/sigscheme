/*===========================================================================
 *  Filename : test-gc-protect.c
 *  About    : garbage collector protection test
 *
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

#include <sigscheme/config.h>

#include "sscm-test.h"
#include "sigscheme.h"
#include "sigschemeinternal.h"


static ScmObj make_obj(void);
static void *make_obj_internal(void *dummy);
static void *protected_func(void *arg);
static void *var_in_protected_func(void *arg);
static void *vars_in_protected_func(void *arg);

/* To disable GC stack protection, remove scm_call_with_gc_ready_stack() */
#undef TST_RUN
#define TST_RUN(fn, s, c) (fn(s, c))

#define N_OBJS 128
ScmObj static_objs[N_OBJS];

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

    TST_TN_FALSE(var_in_protected_func(NULL));
    TST_TN_TRUE (scm_call_with_gc_ready_stack(var_in_protected_func, NULL));
    TST_TN_FALSE(var_in_protected_func(NULL));
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

    TST_TN_FALSE(vars_in_protected_func(NULL));
    TST_TN_TRUE (scm_call_with_gc_ready_stack(vars_in_protected_func, NULL));
    TST_TN_FALSE(vars_in_protected_func(NULL));
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

    /* unprotected */
    for (i = 0; i < N_OBJS; i++)
        static_objs[i] = make_obj();
    for (i = 0; i < N_OBJS; i++)
        TST_TN_FALSE(scm_gc_protectedp(static_objs[i]));

    /* protected */
    for (i = 0; i < N_OBJS; i++) {
        scm_gc_protect(&static_objs[i]);
        static_objs[i] = make_obj();
    }
    for (i = 0; i < N_OBJS; i++)
        TST_TN_TRUE(scm_gc_protectedp(static_objs[i]));

    /* unprotect again */
    for (i = 0; i < N_OBJS; i++)
        scm_gc_unprotect(&static_objs[i]);
    for (i = 0; i < N_OBJS; i++)
        TST_TN_FALSE(scm_gc_protectedp(static_objs[i]));
}

TST_CASE("GC auto variable protection with scm_gc_protect()")
{
    ScmObj auto_objs[N_OBJS];
    int i;

    TST_TN_FALSE(scm_gc_protected_contextp());

    /* unprotected */
    for (i = 0; i < N_OBJS; i++)
        auto_objs[i] = make_obj();
    for (i = 0; i < N_OBJS; i++)
        TST_TN_FALSE(scm_gc_protectedp(auto_objs[i]));

    /* protected */
    for (i = 0; i < N_OBJS; i++) {
        scm_gc_protect(&auto_objs[i]);
        auto_objs[i] = make_obj();
    }
    for (i = 0; i < N_OBJS; i++)
        TST_TN_TRUE(scm_gc_protectedp(auto_objs[i]));

    /* unprotect again */
    for (i = 0; i < N_OBJS; i++)
        scm_gc_unprotect(&auto_objs[i]);
    for (i = 0; i < N_OBJS; i++)
        TST_TN_FALSE(scm_gc_protectedp(auto_objs[i]));
}
