/*===========================================================================
 *  Filename : storage-gc.c
 *  About    : Garbage Collection
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

/*
 * The GC performs conservative mark-and-sweep.
 *
 * [1] Mark phase : gc_mark()
 *   - gc_mark_locations()
 *       marks Scheme objects that held in the registers.
 *
 *   - gc_mark_locations_n()
 *       marks Scheme objects that located on the stack.
 *
 *   - gc_mark_protected_var()
 *       marks Scheme objects held in off-heap locations that registered by
 *       scm_gc_protect().
 *
 *   - gc_mark_definite_locations_n()
 *       marks Scheme objects that held in the symbol table.
 *
 * [2] Sweep phase : gc_sweep()
 *   - collects unmarked objects on heaps into the freelist.
 */

#include <config.h>

#include <stddef.h>
#include <stdlib.h>

#include "sigscheme.h"
#include "sigschemeinternal.h"

/*=======================================
  File Local Macro Definitions
=======================================*/
#define SCMOBJ_ALIGNEDP(ptr) (!((uintptr_t)(ptr) % sizeof(ScmObj)))
#if SCM_DEBUG
#define SCM_BEGIN_GC_SUBCONTEXT() (scm_ensure_proper_freelist(l_freelist), \
                                   ++l_gcing)
#define SCM_END_GC_SUBCONTEXT()   (scm_ensure_proper_freelist(l_freelist), \
                                   --l_gcing)
#else /* not SCM_DEBUG */
#define SCM_BEGIN_GC_SUBCONTEXT() SCM_EMPTY_EXPR
#define SCM_END_GC_SUBCONTEXT()   SCM_EMPTY_EXPR
#endif /* not SCM_DEBUG */

/*=======================================
  File Local Type Definitions
=======================================*/
typedef ScmCell *ScmObjHeap;

/*=======================================
  Variable Definitions
=======================================*/
SCM_GLOBAL_VARS_BEGIN(static_gc);
#define static
static size_t l_heap_size, l_heap_alloc_threshold;
static size_t l_n_heaps, l_n_heaps_max;
static ScmObjHeap *l_heaps;
static ScmCell *l_heaps_lowest, *l_heaps_highest;
/* Do not declare the type of l_freelist as ScmCell *, because the freelist
 * head should be capable of non-pointer cell reference such as heap number &
 * cell index pair. Although it costs NULLP() on every cell allocation, source
 * reusability takes precedence over such little performance gain.
 *   -- YamaKen 2006-05-29 */
static ScmObj l_freelist;

static ScmObj **l_protected_vars;
static size_t l_protected_vars_size, l_n_empty_protected_vars;
static GCROOTS_context *l_gcroots_ctx;
#if SCM_DEBUG
static size_t l_gcing;
static scm_bool l_allocating;
#endif /* SCM_DEBUG */
#undef static
SCM_GLOBAL_VARS_END(static_gc);
#define l_heap_size            SCM_GLOBAL_VAR(static_gc, l_heap_size)
#define l_heap_alloc_threshold SCM_GLOBAL_VAR(static_gc, l_heap_alloc_threshold)
#define l_n_heaps              SCM_GLOBAL_VAR(static_gc, l_n_heaps)
#define l_n_heaps_max          SCM_GLOBAL_VAR(static_gc, l_n_heaps_max)
#define l_heaps                SCM_GLOBAL_VAR(static_gc, l_heaps)
#define l_heaps_lowest         SCM_GLOBAL_VAR(static_gc, l_heaps_lowest)
#define l_heaps_highest        SCM_GLOBAL_VAR(static_gc, l_heaps_highest)
#define l_freelist             SCM_GLOBAL_VAR(static_gc, l_freelist)
#define l_protected_vars       SCM_GLOBAL_VAR(static_gc, l_protected_vars)
#define l_protected_vars_size  SCM_GLOBAL_VAR(static_gc, l_protected_vars_size)
#define l_n_empty_protected_vars                                             \
    SCM_GLOBAL_VAR(static_gc, l_n_empty_protected_vars)
#define l_gcroots_ctx          SCM_GLOBAL_VAR(static_gc, l_gcroots_ctx)
#if SCM_DEBUG
#define l_gcing                SCM_GLOBAL_VAR(static_gc, l_gcing)
#define l_allocating           SCM_GLOBAL_VAR(static_gc, l_allocating)
#endif /* SCM_DEBUG */
SCM_DEFINE_STATIC_VARS(static_gc);

/*=======================================
  File Local Function Declarations
=======================================*/
static ScmObj **locate_protected_var(ScmObj *var);

static void initialize_heap(const ScmStorageConf *conf);
static void add_heap(void);
static void finalize_heap(void);

static void gc_mark_and_sweep(void);

/* GC Mark Related Functions */
static void mark_obj(ScmObj obj);
static scm_bool within_heapp(ScmObj obj);

static void gc_mark_protected_var();
static void gc_mark_locations_n(ScmObj *start, size_t n);
static void gc_mark_definite_locations_n(ScmObj *start, size_t n);
static void gc_mark_locations(ScmObj *start, ScmObj *end,
                              int is_certain, int is_aligned);
static void gc_mark(void);
static void gc_mark_global_vars(void);

/* GC Sweep Related Functions */
static void free_cell(ScmCell *cell);
static size_t gc_sweep(void);

static void finalize_protected_var(void);

#if SCM_DEBUG
static void scm_ensure_proper_freelist(ScmObj flst);  /* FIXME */
#endif

/*=======================================
  Function Definitions
=======================================*/
#if SCM_DEBUG
static void
scm_ensure_proper_freelist(ScmObj flst)
{
    size_t len;
    ScmObj c;

    for (c = flst, len = 0; !SCM_NULLP(c); c = SCM_FREECELL_NEXT(c), len++) {
        assert(SCM_FREECELLP(c));
        assert(len <= SCM_INT_MAX);  /* not circular list */
    }
    SCM_ASSERT(SCM_NULLP(c));
}
#endif

SCM_EXPORT void
scm_init_gc(const ScmStorageConf *conf)
{
    SCM_GLOBAL_VARS_INIT(static_gc);

#if SCM_DEBUG
    l_gcing = 0;
    l_allocating = scm_false;
#endif

    l_gcroots_ctx = GCROOTS_init(scm_malloc,
                                 (GCROOTS_mark_proc)gc_mark_locations,
                                 scm_false);

    initialize_heap(conf);
}

SCM_EXPORT void
scm_fin_gc(void)
{
    finalize_heap();
    finalize_protected_var();

    GCROOTS_fin(l_gcroots_ctx);
    free(l_gcroots_ctx);

    SCM_GLOBAL_VARS_FIN(static_gc);
}

SCM_EXPORT ScmObj
scm_alloc_cell(void)
{
    ScmObj ret;

#if SCM_DEBUG
    SCM_ASSERT(!l_gcing);
    SCM_ASSERT(!l_allocating);
    l_allocating = scm_true;
#endif

    if (NULLP(l_freelist))
        gc_mark_and_sweep();
    SCM_ASSERT(SCM_FREECELLP(l_freelist));

    ret = l_freelist;
    l_freelist = SCM_FREECELL_NEXT(l_freelist);

#if SCM_DEBUG
    l_allocating = scm_false;
#endif

    return ret;
}

SCM_EXPORT void
scm_prealloc_heaps(size_t n)
{
    size_t i;

    if (!n)
        n = l_n_heaps + 1;

    if (n > l_n_heaps_max)
        PLAIN_ERR("heap number ~ZU exceeded maxmum number ~ZU",
                  n, l_n_heaps_max);

    for (i = l_n_heaps; i < n; i++)
        add_heap();
}

/*===========================================================================
  ScmObj Protection
===========================================================================*/
/*
 * Registered veriable locations are held in vector instead of linked list to
 * maximize space and performance efficiency.
 */
static ScmObj **
locate_protected_var(ScmObj *var)
{
    ScmObj **slot;

    if (l_protected_vars) {
        for (slot = l_protected_vars;
             slot < &l_protected_vars[l_protected_vars_size];
             slot++)
        {
            if (*slot == var)
                return slot;
        }
    }

    return NULL;
}

/* var must be initialized with a valid ScmObj before invocation */
SCM_EXPORT void
scm_gc_protect(ScmObj *var)
{
    ScmObj **slot;
    size_t new_size;

    if (l_n_empty_protected_vars) {
        slot = locate_protected_var(NULL);
        l_n_empty_protected_vars--;
    } else {
        new_size = sizeof(ScmObj *) * (l_protected_vars_size + 1);
        l_protected_vars = scm_realloc(l_protected_vars, new_size);
        slot = &l_protected_vars[l_protected_vars_size++];
    }
    *slot = var;
}

SCM_EXPORT void
scm_gc_protect_with_init(ScmObj *var, ScmObj init_val)
{
    *var = init_val;
    scm_gc_protect(var);
}

SCM_EXPORT void
scm_gc_unprotect(ScmObj *var)
{
    ScmObj **slot;

    slot = locate_protected_var(var);
    if (slot) {
        *slot = NULL;
        l_n_empty_protected_vars++;
    }
}

/* Usage:
 *
 *   assert(scm_gc_protectedp(obj));
 *
 * Don't use this predicate to ensure that an object is UNPROTECTED:
 *
 *   assert(!scm_gc_protectedp(obj));  // may cause unexpected failure
 *
 * This predicate cannot ensure that an object is UNPROTECTED, when
 * scm_gc_protected_contextp() is true. i.e. An object may be identified as
 * protected even if it is not placed on directly or indirectly protected
 * location since an expired register variable may refer the object.
 *   -- YamaKen 2007-03-25 */
/* Though immediate values and symbols are GC safe even if not being
 * explicitly protected, the condition may vary according to build
 * configuration or future specification changes. So libsscm users should
 * explicitly protect such objects.  -- YamaKen 2007-01-26 */
SCM_EXPORT scm_bool
scm_gc_protectedp(ScmObj obj)
{
    ScmObj **slot;

    /* constants or objects referred from registers or stack */
    if (
#if SCM_USE_STORAGE_COMPACT
        SCM_IMMP(obj)
#else
        SCM_CONSTANTP(obj)
#endif
        || GCROOTS_is_protected(l_gcroots_ctx, (void *)obj))
        return scm_true;

    /* referred from static variables */
    if (l_protected_vars) {
        for (slot = l_protected_vars;
             slot < &l_protected_vars[l_protected_vars_size];
             slot++)
        {
            if (*slot && **slot == obj)
                return scm_true;
        }
    }

    /* referred from on-heap objects */
    if (scm_gc_protected_contextp()) {
        /* mark registers, stack and global vars */
        gc_mark();
    } else {
        /* doesn't mark registers and stack */
        gc_mark_global_vars();
    }
    gc_sweep();

#if SCM_USE_STORAGE_COMPACT
    return !SCM_CELL_FREECELLP(SCM_UNTAG_PTR(obj));
#else
    return !SCM_FREECELLP(obj);
#endif
}

SCM_EXPORT void *
scm_call_with_gc_ready_stack(ScmGCGateFunc func, void *arg)
{
    return GCROOTS_call_with_gc_ready_stack(l_gcroots_ctx, func, arg);
}

SCM_EXPORT scm_bool
scm_gc_protected_contextp(void)
{
  return GCROOTS_is_protected_context(l_gcroots_ctx);
}

/*===========================================================================
  Heap Allocator & Garbage Collector
===========================================================================*/
static void
initialize_heap(const ScmStorageConf *conf)
{
    l_heap_size            = conf->heap_size;
    l_heap_alloc_threshold = conf->heap_alloc_threshold;
    l_n_heaps_max          = conf->n_heaps_max;
    l_n_heaps = 0;
    l_heaps = NULL;
    l_heaps_lowest = (void *)UINTPTR_MAX;
    l_heaps_highest = NULL;
    l_freelist = SCM_NULL;

    /* Since maximum length of list can be represented by a Scheme integer,
     * SCM_INT_MAX limits the number of cons cells. */
    if (SCM_INT_MAX < l_n_heaps_max * l_heap_size
        || SCM_INT_MAX < conf->n_heaps_init * l_heap_size)
        scm_fatal_error("too large heap size specified");

    scm_prealloc_heaps(conf->n_heaps_init);
}

static void
add_heap(void)
{
    ScmObjHeap heap;
    ScmCell *cell;
    ScmObj next;

    SCM_BEGIN_GC_SUBCONTEXT();

    if (l_n_heaps_max <= l_n_heaps)
        scm_fatal_error("heap exhausted");

    l_heaps = scm_realloc(l_heaps, sizeof(ScmObjHeap) * (l_n_heaps + 1));
    heap = scm_malloc_aligned(sizeof(ScmCell) * l_heap_size);
    l_heaps[l_n_heaps++] = heap;

    /* update the enclosure */
    if (l_heaps_highest < &heap[l_heap_size])
        l_heaps_highest = &heap[l_heap_size];
    if (&heap[0] < l_heaps_lowest)
        l_heaps_lowest = &heap[0];

    /* link as address-increasing order */
    next = l_freelist;
    for (cell = &heap[l_heap_size - 1]; cell >= &heap[0]; cell--)
        next = SCM_CELL_RECLAIM_CELL(cell, next);
    l_freelist = next;

    SCM_END_GC_SUBCONTEXT();
}

static void
finalize_heap(void)
{
    size_t i;
    ScmCell *cell;
    ScmObjHeap heap;

    for (i = 0; i < l_n_heaps; i++) {
        heap = l_heaps[i];
        for (cell = &heap[0]; cell < &heap[l_heap_size]; cell++)
            free_cell(cell);
        free(heap);
    }
    free(l_heaps);
}

static void
gc_mark_and_sweep(void)
{
    size_t n_collected;

    SCM_BEGIN_GC_SUBCONTEXT();

    CDBG((SCM_DBG_GC, "[ gc start ]"));

    gc_mark();
    n_collected = gc_sweep();

    if (n_collected < l_heap_alloc_threshold) {
        CDBG((SCM_DBG_GC, "enough number of free cells cannot be collected. allocating new heap."));
        add_heap();
    }

    SCM_END_GC_SUBCONTEXT();
}


#if SCM_USE_STORAGE_COMPACT
static void
mark_obj(ScmObj obj)
{
#if SCM_USE_VECTOR
    scm_int_t i, len;
    ScmObj *vec;
#endif

mark_loop:
    /* no need to mark immediates */
    if (SCM_IMMP(obj))
        return;

    /* avoid cyclic marking */
    if (SCM_MARKEDP(obj))
        return;

    /* mark this object */
    SCM_MARK(obj);

    /* mark recursively */
    switch (SCM_PTAG(obj)) {
    case SCM_PTAG_CONS:
        /* CONS accessors bypass tag manipulation by default so we
         * have to do it specially here. */
        obj = SCM_DROP_GCBIT(obj);
        mark_obj(SCM_CONS_CAR(obj));
        obj = SCM_CONS_CDR(obj);
        goto mark_loop;

    case SCM_PTAG_CLOSURE:
        mark_obj(SCM_CLOSURE_EXP(obj));
        obj = SCM_CLOSURE_ENV(obj);
        goto mark_loop;

    case SCM_PTAG_MISC:
        if (SYMBOLP(obj)) {
            obj = SCM_SYMBOL_VCELL(obj);
            goto mark_loop;
#if SCM_USE_HYGIENIC_MACRO
        } else if (SCM_WRAPPERP(obj)) { /* Macro-related wrapper. */
            obj = SCM_WRAPPER_OBJ(obj);
            goto mark_loop;
#endif /* SCM_USE_HYGIENIC_MACRO */
#if SCM_USE_VECTOR
        /* Alert: objects that store a non-ScmObj in obj_x must
         * explicitly drop the GC bit here.  This currently applies
         * only to vectors. */
        } else if (VECTORP(obj)) {
            len = SCM_VECTOR_LEN(obj);
            vec = SCM_VECTOR_VEC(obj);
            vec = (ScmObj *)SCM_DROP_GCBIT((scm_intobj_t)vec);
            for (i = 0; i < len; i++) {
                mark_obj(vec[i]);
            }
#endif /* SCM_USE_VECTOR */
        } else if (VALUEPACKETP(obj)) {
            obj = SCM_VALUEPACKET_VALUES(obj);
            goto mark_loop;
        }
        break;

    default:
        break;
    }
}
#elif SCM_USE_STORAGE_FATTY
static void
mark_obj(ScmObj obj)
{
#if SCM_USE_VECTOR
    scm_int_t i;
#endif

mark_loop:
    /* no need to mark constants */
    if (SCM_CONSTANTP(obj))
        return;

    /* avoid cyclic marking */
    if (SCM_MARKEDP(obj))
        return;

    /* mark this object */
    SCM_MARK(obj);

    /* mark recursively */
    switch (SCM_TYPE(obj)) {
    case ScmCons:
        mark_obj(CAR(obj));
        obj = CDR(obj);
        goto mark_loop;

    case ScmSymbol:
        obj = SCM_SYMBOL_VCELL(obj);
        goto mark_loop;

    case ScmClosure:
        mark_obj(SCM_CLOSURE_EXP(obj));
        obj = SCM_CLOSURE_ENV(obj);
        goto mark_loop;

#if SCM_USE_HYGIENIC_MACRO
    case ScmMacro:
        /* Assumes that ScmPackedEnv is an integer. */
        obj = SCM_HMACRO_RULES(obj);
        goto mark_loop;

    case ScmFarsymbol:
        /* Assumes that ScmPackedEnv is an integer. */
        obj = SCM_FARSYMBOL_SYM(obj);
        goto mark_loop;

    case ScmSubpat:
        obj = SCM_SUBPAT_OBJ(obj);
        goto mark_loop;
#endif /* SCM_USE_HYGIENIC_MACRO */

    case ScmValuePacket:
#if SCM_USE_VALUECONS
        mark_obj(SCM_VALUECONS_CAR(obj));
        obj = SCM_VALUECONS_CDR(obj);
#else
        obj = SCM_VALUEPACKET_VALUES(obj);
#endif
        goto mark_loop;

#if SCM_USE_VECTOR
    case ScmVector:
        for (i = 0; i < SCM_VECTOR_LEN(obj); i++) {
            mark_obj(SCM_VECTOR_VEC(obj)[i]);
        }
        break;
#endif

    default:
        break;
    }
}
#else
#error "mark_obj() is not implemented for this storage"
#endif

static void
finalize_protected_var(void)
{
    free(l_protected_vars);
}

/* The core part of Conservative GC */

static scm_bool
within_heapp(ScmObj obj)
{
    ScmCell *heap, *ptr;
    size_t i;

#if SCM_USE_STORAGE_COMPACT
    if (SCM_IMMP(obj))
        return scm_false;
    /* The pointer on the stack is 'tagged' to represent its types.
     * So we need to ignore the tag to get its real pointer value. */
    ptr = (ScmCell *)SCM_DROP_TAG(obj);
#else /* SCM_USE_STORAGE_COMPACT */
    ptr = obj;
#endif /* SCM_USE_STORAGE_COMPACT */
    /*
     * Reject by rough conditions:
     * - heaps must be aligned to sizeof(ScmCell)
     * - ptr is pointing to outside of the enclosure which covers all heaps
     */
    if (((uintptr_t)ptr % sizeof(ScmCell))
        || (ptr < l_heaps_lowest || l_heaps_highest <= ptr))
        return scm_false;

    for (i = 0; i < l_n_heaps; i++) {
        heap = l_heaps[i];
        if (heap && &heap[0] <= ptr && ptr < &heap[l_heap_size]) {
#if SCM_USE_STORAGE_COMPACT
            /* Check the consistency between obj's tag and *ptr. */
            if (!SCM_TAG_CONSISTENTP(obj, *ptr))
                return scm_false;
#endif /* SCM_USE_STORAGE_COMPACT */
            return scm_true;
        }
    }

    return scm_false;
}

static void
gc_mark_protected_var(void)
{
    ScmObj **slot;

    SCM_BEGIN_GC_SUBCONTEXT();

    if (l_protected_vars) {
        for (slot = l_protected_vars;
             slot < &l_protected_vars[l_protected_vars_size];
             slot++)
        {
            if (*slot)
                mark_obj(**slot);
        }
    }

    SCM_END_GC_SUBCONTEXT();
}

/* mark a contiguous region such as stack */
static void
gc_mark_locations_n(ScmObj *start, size_t n)
{
    ScmObj *objp;

    SCM_BEGIN_GC_SUBCONTEXT();

    SCM_ASSERT(SCMOBJ_ALIGNEDP(start));

    for (objp = start; objp < &start[n]; objp++) {
        if (within_heapp(*objp))
            mark_obj(*objp);
    }

    SCM_END_GC_SUBCONTEXT();
}

static void
gc_mark_definite_locations_n(ScmObj *start, size_t n)
{
    ScmObj *objp;

    SCM_BEGIN_GC_SUBCONTEXT();

    SCM_ASSERT(SCMOBJ_ALIGNEDP(start));

    for (objp = start; objp < &start[n]; objp++)
        mark_obj(*objp);

    SCM_END_GC_SUBCONTEXT();
}

static void
gc_mark_locations(ScmObj *start, ScmObj *end, int is_certain, int is_aligned)
{
    ScmObj *adjusted_start, *tmp;
    ptrdiff_t len;
    unsigned int offset;

    SCM_BEGIN_GC_SUBCONTEXT();

    /* swap end and start if (end < start) */
    if (end < start) {
        tmp = end - 1;
        end = start + 1;
        start = tmp;
    }

    /*
     * workaround for non-aligned ScmObj on stack:
     *
     * Some architectures such as m68k does not align machine-word-size data on
     * stack with its own size (i.e. 2byte-aligned 4byte-length words are
     * used). So we scans the stack region (sizeof(ScmObj) / alignof(ScmObj))
     * times with possible offsets. Since this implementation adopted the
     * conservative GC strategy, it will not be a problem.
     *   -- YamaKen 2006-12-09
     */
    for (offset = 0; offset < sizeof(ScmObj); offset += ALIGNOF_SCMOBJ) {
        adjusted_start = (ScmObj *)((char *)start + offset);
        len = end - adjusted_start;
        CDBG((SCM_DBG_GC, "gc_mark_locations: start = ~P, end = ~P, len = ~TD, offset = ~U",
              adjusted_start, end, len, offset));

        if (is_certain)
            gc_mark_definite_locations_n(adjusted_start, len);
        else
            gc_mark_locations_n(adjusted_start, len);

        if (is_aligned)
            break;
    }

    SCM_END_GC_SUBCONTEXT();
}

static void
gc_mark(void)
{
    SCM_BEGIN_GC_SUBCONTEXT();

    /* Mark stack and all machine-dependent contexts such as registers,
     * register windows (SPARC), register stack backing store (IA-64) etc. */
    GCROOTS_mark(l_gcroots_ctx);

    gc_mark_global_vars();

    SCM_END_GC_SUBCONTEXT();
}

static void
gc_mark_global_vars(void)
{
    SCM_BEGIN_GC_SUBCONTEXT();

    gc_mark_protected_var();
    if (scm_symbol_hash)
        gc_mark_definite_locations_n(scm_symbol_hash, scm_symbol_hash_size);

    SCM_END_GC_SUBCONTEXT();
}

static void
free_cell(ScmCell *cell)
{
#if SCM_USE_STORAGE_COMPACT
    if (SCM_CELL_MISCP(*cell)) {
        if (SCM_CELL_SYMBOLP(*cell))
            SCM_CELL_SYMBOL_FIN(*cell);
#if SCM_USE_STRING
        else if (SCM_CELL_STRINGP(*cell))
            SCM_CELL_STRING_FIN(*cell);
#endif
#if SCM_USE_VECTOR
        else if (SCM_CELL_VECTORP(*cell))
            SCM_CELL_VECTOR_FIN(*cell);
#endif
#if SCM_USE_PORT
        else if (SCM_CELL_PORTP(*cell))
            SCM_CELL_PORT_FIN(*cell);
#endif
#if SCM_USE_CONTINUATION
        else if (SCM_CELL_CONTINUATIONP(*cell))
            SCM_CELL_CONTINUATION_FIN(*cell);
#endif
    }
#else /* SCM_USE_STORAGE_COMPACT */
    switch (SCM_TYPE(cell)) {
    case ScmCons:
#if SCM_USE_INT
    case ScmInt:
#endif
#if SCM_USE_CHAR
    case ScmChar:
#endif
        break;

    case ScmSymbol:
        free(SCM_SYMBOL_NAME(cell));
        break;

#if SCM_USE_STRING
    case ScmString:
        free(SCM_STRING_STR(cell));
        break;
#endif

    case ScmFreeCell:
    case ScmConstant:
        break;

#if SCM_USE_VECTOR
    case ScmVector:
        free(SCM_VECTOR_VEC(cell));
        break;
#endif

    /* rarely swept objects */
#if SCM_USE_PORT
    case ScmPort:
        if (SCM_PORT_IMPL(cell))
            scm_port_close(cell);
        break;
#endif

#if SCM_USE_CONTINUATION
    case ScmContinuation:
        /*
         * Since continuation object is not so many, destructing the object by
         * function call will not cost high. This function interface makes
         * continuation module substitution easy without preparing
         * module-specific header file which contains the module-specific
         * destruction macro.
         */
        scm_destruct_continuation(cell);
        break;
#endif

    case ScmClosure:
    case ScmFunc:
    case ScmMacro:
    case ScmFarsymbol:
    case ScmSubpat:
    case ScmCFuncPointer:
    case ScmCPointer:
    case ScmValuePacket:
        break;
#if SCM_DEBUG
    case ScmRational:
    case ScmReal:
    case ScmComplex:
#endif
    default:
        SCM_NOTREACHED;
    }
#endif /* SCM_USE_STORAGE_COMPACT */
}

static size_t
gc_sweep(void)
{
    size_t i, sum_collected, n_collected;
    ScmObjHeap heap;
    ScmCell *cell;
    ScmObj new_freelist;

    SCM_BEGIN_GC_SUBCONTEXT();

    /* Because l_freelist may not be exhausted on an user-instructed GC, do not
     * assume that l_freelist is null here. -- YamaKen */
    new_freelist = l_freelist;

    sum_collected = 0;
    for (i = 0; i < l_n_heaps; i++) {
        n_collected = 0;
        heap = l_heaps[i];

        for (cell = &heap[0]; cell < &heap[l_heap_size]; cell++) {
            if (SCM_CELL_MARKEDP(cell)) {
                SCM_CELL_UNMARK(cell);
            } else if (!SCM_CELL_FREECELLP(cell)) {
                /* scm_gc_protectedp() causes GC sweep on heaps that contain
                 * freecells. So !SCM_CELL_FREECELLP(cell) is required. */
                free_cell(cell);
                new_freelist = SCM_CELL_RECLAIM_CELL(cell, new_freelist);
                n_collected++;
            }
        }

        sum_collected += n_collected;
        CDBG((SCM_DBG_GC, "heap[~ZU] swept = ~ZU", i, n_collected));
    }
    l_freelist = new_freelist;

    SCM_END_GC_SUBCONTEXT();

    return sum_collected;
}
