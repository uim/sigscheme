/*===========================================================================
 *  Filename : gcroots.c
 *  About    : SigScheme-dependent portable implementation of libgcroots
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

#if HAVE_GETCONTEXT
#include <ucontext.h>
#else
#include <setjmp.h>
#endif

#include "sigscheme.h"
#include "gcroots.h"

/*=======================================
  File Local Macro Definitions
=======================================*/

/*=======================================
  File Local Type Definitions
=======================================*/
struct _GCROOTS_context {
    void *stack_base;
    GCROOTS_mark_proc mark;
    scm_bool scan_entire_system_stack;
};

/*=======================================
  Variable Definitions
=======================================*/
SCM_GLOBAL_VARS_BEGIN(static_gcroots);
#define static
static void *l_findee;
static int l_found;
#undef static
SCM_GLOBAL_VARS_END(static_gcroots);
#define l_findee SCM_GLOBAL_VAR(static_gcroots, l_findee)
#define l_found  SCM_GLOBAL_VAR(static_gcroots, l_found)
SCM_DEFINE_STATIC_VARS(static_gcroots);

/*=======================================
  File Local Function Declarations
=======================================*/
static void mark_internal(GCROOTS_context *ctx);
static void find_obj(void *start, void *end, int is_certain, int is_aligned);

/*=======================================
  Function Definitions
=======================================*/
SCM_EXPORT GCROOTS_context *
GCROOTS_init(GCROOTS_context_alloc_proc allocator, GCROOTS_mark_proc marker,
             int scan_entire_system_stack)
{
    GCROOTS_context *ctx;

    SCM_ASSERT(allocator);
    SCM_ASSERT(marker);
    /* scan_entire_system_stack is not supported by this implementation */
    SCM_ASSERT(!scan_entire_system_stack);

    SCM_GLOBAL_VARS_INIT(static_gcroots);

    ctx = (*allocator)(sizeof(GCROOTS_context));
    if (ctx) {
        ctx->mark = marker;
        ctx->scan_entire_system_stack = scan_entire_system_stack;
        ctx->stack_base = NULL;
    }

    return ctx;
}

SCM_EXPORT void
GCROOTS_fin(GCROOTS_context *ctx)
{
    assert(ctx);

    /* Nothing to do for this implementation. Caller must free ctx. */
}

SCM_EXPORT void *
GCROOTS_call_with_gc_ready_stack(GCROOTS_context *ctx,
                                 GCROOTS_user_proc proc, void *arg)
{
    void *ret;
    void *stack_top; /* approx */
    volatile GCROOTS_user_proc anti_inline_proc;

    assert(ctx);
    assert(proc);

    if (!ctx->stack_base)
        ctx->stack_base = &stack_top;

    anti_inline_proc = proc;
    ret = (*anti_inline_proc)(arg);

    if (ctx->stack_base == &stack_top)
        ctx->stack_base = NULL;

    return ret;
}

SCM_EXPORT void
GCROOTS_mark(GCROOTS_context *ctx)
{
#if HAVE_GETCONTEXT
    ucontext_t uctx;
#else
    jmp_buf env;
#endif
    void (*volatile anti_inline_mark_internal)(GCROOTS_context *);

    assert(ctx);

    if (ctx->stack_base) {
#if HAVE_GETCONTEXT
        getcontext(&uctx);
#else
        setjmp(env);
#endif
        anti_inline_mark_internal = mark_internal;
        (*anti_inline_mark_internal)(ctx);
    }
}

static void
mark_internal(GCROOTS_context *ctx)
{
    void *stack_top; /* approx */

    (*ctx->mark)(ctx->stack_base, &stack_top, scm_false, scm_false);
}

int
GCROOTS_is_protected_context(GCROOTS_context *ctx)
{
    assert(ctx);

    return (ctx->stack_base) ? scm_true : scm_false;
}

int
GCROOTS_is_protected(GCROOTS_context *ctx, void *obj)
{
    GCROOTS_context tmp_ctx;

    assert(ctx);

    if (!GCROOTS_is_protected_context(ctx))
      return scm_false;

    tmp_ctx = *ctx;
    tmp_ctx.mark = find_obj; /* not actually a mark function */
    l_findee = obj;
    l_found = scm_false;
    GCROOTS_mark(&tmp_ctx);

    return l_found;
}

static void
find_obj(void *start, void *end, int is_certain, int is_aligned)
{
    void **p;
    int offset;

    offset = 0;
    do {
        for (p = (void **)start + offset; p < (void **)end; p++) {
            if (*p == l_findee) {
                l_found = scm_true;
                return;
            }
        }
        offset += ALIGNOF_VOID_P;
    } while (!is_aligned
             && SIZEOF_VOID_P != ALIGNOF_VOID_P
             && offset % SIZEOF_VOID_P);
}
