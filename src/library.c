/*===========================================================================
 *  Filename : library.c
 *  About    : R7RS libraries
 *
 *  Copyright (c) 2026 SigScheme Project https://github.com/uim/sigscheme
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

/*
 * A module is a namespace of a library. An environment whose tail is a
 * module instead of '() is in the module. See env.c for environments.
 *
 * A module is #(marker name buckets n-entries indefinable). BUCKETS is a
 * vector of alists. An entry of the alists is (symbol . location) and a
 * location is (value . #f). Modules may share a location to export and
 * import a binding. INDEFINABLE is #(marker module) for the toplevel of
 * the module where definitions aren't allowed. It isn't a pair because a
 * pair is a non-toplevel environment.
 *
 * The builtin module is the namespace of builtins. The REPL (the global
 * environment) shares the value cells of symbols with the builtin module for
 * speed. If the REPL redefines a builtin, the value cell has a shadow
 * #(marker repl-value builtin-value) to keep the builtin. The builtin module
 * binds each builtin to the symbol itself as its location.
 */

/*=======================================
  File Local Macro Definitions
=======================================*/
#define MODULE_NAME(module)        (SCM_VECTOR_VEC(module)[1])
#define MODULE_BUCKETS(module)     (SCM_VECTOR_VEC(module)[2])
#define MODULE_N_ENTRIES(module)   (SCM_VECTOR_VEC(module)[3])
#define MODULE_INDEFINABLE(module) (SCM_VECTOR_VEC(module)[4])
#define MODULE_SIZE 5

#define INITIAL_N_BUCKETS 16
/* Symbols are aligned so the lower bits aren't useful. */
#define SYMBOL_HASH(sym, n_buckets)                                          \
    ((scm_int_t)(((scm_uintobj_t)(sym) >> 4) & ((n_buckets) - 1)))

/*=======================================
  File Local Type Definitions
=======================================*/

/*=======================================
  Variable Definitions
=======================================*/
#include "functable-r7rs-library.c"

SCM_GLOBAL_VARS_BEGIN(static_library);
#define static
static ScmObj l_module_marker, l_indefinable_marker, l_shadow_marker;
static ScmObj l_builtin_module;
static scm_bool l_builtin_ready;
static scm_int_t l_builtin_definition_depth;
#undef static
SCM_GLOBAL_VARS_END(static_library);
#define l_module_marker      SCM_GLOBAL_VAR(static_library, l_module_marker)
#define l_indefinable_marker SCM_GLOBAL_VAR(static_library, l_indefinable_marker)
#define l_shadow_marker      SCM_GLOBAL_VAR(static_library, l_shadow_marker)
#define l_builtin_module     SCM_GLOBAL_VAR(static_library, l_builtin_module)
#define l_builtin_ready      SCM_GLOBAL_VAR(static_library, l_builtin_ready)
#define l_builtin_definition_depth                                           \
    SCM_GLOBAL_VAR(static_library, l_builtin_definition_depth)
SCM_DEFINE_STATIC_VARS(static_library);

/*=======================================
  File Local Function Declarations
=======================================*/
static ScmObj make_buckets(scm_int_t n_buckets);
static ScmObj module_entry(ScmObj module, ScmObj sym);
static void module_rehash(ScmObj module);

/*=======================================
  Function Definitions
=======================================*/
SCM_EXPORT void
scm_init_library(void)
{
    SCM_GLOBAL_VARS_INIT(static_library);

    /* Use pairs as the unique markers. The symbols are only for
     * human-readability. */
    scm_gc_protect_with_init(&l_module_marker,
                             LIST_1(scm_intern("%%module")));
    scm_gc_protect_with_init(&l_indefinable_marker,
                             LIST_1(scm_intern("%%indefinable-module")));
    scm_gc_protect_with_init(&l_shadow_marker,
                             LIST_1(scm_intern("%%shadow")));
    scm_gc_protect_with_init(&l_builtin_module,
                             scm_make_module(LIST_2(scm_intern("sigscheme"),
                                                    scm_intern("builtin"))));

    scm_register_funcs(scm_functable_r7rs_library);
    l_builtin_ready = scm_true;
}

static ScmObj
make_buckets(scm_int_t n_buckets)
{
    ScmObj *vec;
    scm_int_t i;

    vec = scm_malloc(sizeof(ScmObj) * n_buckets);
    for (i = 0; i < n_buckets; i++)
        vec[i] = SCM_NULL;
    return MAKE_VECTOR(vec, n_buckets);
}

SCM_EXPORT ScmObj
scm_make_module(ScmObj name)
{
    ScmObj module, *vec;

    vec = scm_malloc(sizeof(ScmObj) * MODULE_SIZE);
    vec[0] = l_module_marker;
    vec[1] = name;
    vec[2] = make_buckets(INITIAL_N_BUCKETS);
    vec[3] = MAKE_INT(0);
    vec[4] = SCM_FALSE;
    module = MAKE_VECTOR(vec, MODULE_SIZE);
    vec = scm_malloc(sizeof(ScmObj) * 2);
    vec[0] = l_indefinable_marker;
    vec[1] = module;
    MODULE_INDEFINABLE(module) = MAKE_VECTOR(vec, 2);

    return module;
}

SCM_EXPORT scm_bool
scm_modulep(ScmObj obj)
{
    return (VECTORP(obj) && SCM_VECTOR_LEN(obj) == MODULE_SIZE
            && EQ(SCM_VECTOR_VEC(obj)[0], l_module_marker));
}

/* Returns the toplevel environment of MODULE where definitions aren't
 * allowed. */
SCM_EXPORT ScmObj
scm_module_indefinable(ScmObj module)
{
    SCM_ASSERT(scm_modulep(module));

    return MODULE_INDEFINABLE(module);
}

/* Returns the module if OBJ is a toplevel environment of a module where
 * definitions aren't allowed. Otherwise, returns #f. */
SCM_EXPORT ScmObj
scm_indefinable_module(ScmObj obj)
{
    return (VECTORP(obj) && SCM_VECTOR_LEN(obj) == 2
            && EQ(SCM_VECTOR_VEC(obj)[0], l_indefinable_marker))
           ? SCM_VECTOR_VEC(obj)[1] : SCM_FALSE;
}

/* Returns (sym . location) for SYM or #f. */
static ScmObj
module_entry(ScmObj module, ScmObj sym)
{
    ScmObj buckets, entry, rest;

    buckets = MODULE_BUCKETS(module);
    rest = SCM_VECTOR_VEC(buckets)[SYMBOL_HASH(sym, SCM_VECTOR_LEN(buckets))];
    FOR_EACH (entry, rest) {
        if (EQ(CAR(entry), sym))
            return entry;
    }
    return SCM_FALSE;
}

/* Doubles the buckets to keep the alists short. */
static void
module_rehash(ScmObj module)
{
    ScmObj old, new, entry, rest, *bucket;
    scm_int_t i, n;

    old = MODULE_BUCKETS(module);
    n = SCM_VECTOR_LEN(old) * 2;
    new = make_buckets(n);
    for (i = 0; i < SCM_VECTOR_LEN(old); i++) {
        rest = SCM_VECTOR_VEC(old)[i];
        FOR_EACH (entry, rest) {
            bucket = &SCM_VECTOR_VEC(new)[SYMBOL_HASH(CAR(entry), n)];
            *bucket = CONS(entry, *bucket);
        }
    }
    MODULE_BUCKETS(module) = new;
}

/* Returns the reference to the value of SYM in MODULE or SCM_INVALID_REF. */
SCM_EXPORT ScmRef
scm_module_lookup(ScmObj module, ScmObj sym)
{
    ScmObj entry;

    SCM_ASSERT(scm_modulep(module));

    entry = module_entry(module, sym);
    return (FALSEP(entry)) ? SCM_INVALID_REF : REF_CAR(CDR(entry));
}

/* Binds SYM to LOCATION in MODULE. */
SCM_EXPORT void
scm_module_bind(ScmObj module, ScmObj sym, ScmObj location)
{
    ScmObj entry, buckets, *bucket;
    scm_int_t n_entries;

    SCM_ASSERT(scm_modulep(module));
    SCM_ASSERT(SYMBOLP(sym));

    entry = module_entry(module, sym);
    if (!FALSEP(entry)) {
        SET_CDR(entry, location);
        return;
    }

    n_entries = SCM_INT_VALUE(MODULE_N_ENTRIES(module)) + 1;
    MODULE_N_ENTRIES(module) = MAKE_INT(n_entries);
    if (n_entries > SCM_VECTOR_LEN(MODULE_BUCKETS(module)) * 2)
        module_rehash(module);
    buckets = MODULE_BUCKETS(module);
    bucket = &SCM_VECTOR_VEC(buckets)[SYMBOL_HASH(sym,
                                                  SCM_VECTOR_LEN(buckets))];
    *bucket = CONS(CONS(sym, location), *bucket);
}

/* Defines SYM as VAL in MODULE. A new location is created unless SYM has a
 * location. */
SCM_EXPORT void
scm_module_define(ScmObj module, ScmObj sym, ScmObj val)
{
    ScmRef ref;

    ref = scm_module_lookup(module, sym);
    if (ref != SCM_INVALID_REF)
        SET(ref, val);
    else
        scm_module_bind(module, sym, CONS(val, SCM_FALSE));
}

/* (%%make-module name) is only for tests until define-library is
 * implemented. */
SCM_EXPORT ScmObj
scm_p_make_module(ScmObj name)
{
    DECLARE_FUNCTION("%%make-module", procedure_fixed_1);

    return scm_make_module(name);
}

/*
 * The builtin namespace
 */
SCM_EXPORT ScmObj
scm_builtin_module(void)
{
    return l_builtin_module;
}

/* Builtins are defined between them. They may be nested. */
SCM_EXPORT void
scm_begin_builtin_definitions(void)
{
    l_builtin_definition_depth++;
}

SCM_EXPORT void
scm_end_builtin_definitions(void)
{
    SCM_ASSERT(l_builtin_definition_depth > 0);
    l_builtin_definition_depth--;
}

SCM_EXPORT scm_bool
scm_defining_builtinsp(void)
{
    return l_builtin_definition_depth > 0;
}

/* Registers all bound symbols as builtins. It's for builtins defined before
 * the builtin module is created. */
SCM_EXPORT void
scm_register_bound_symbols_as_builtins(void)
{
    ScmObj lst, sym;
    size_t i;

    for (i = 0; i < scm_symbol_hash_size; i++) {
        lst = scm_symbol_hash[i];
        FOR_EACH (sym, lst) {
            if (SCM_SYMBOL_BOUNDP(sym)
                && FALSEP(module_entry(l_builtin_module, sym)))
                scm_module_bind(l_builtin_module, sym, sym);
        }
    }
}

/* Defines SYM as VAL in the builtin namespace. The REPL also uses VAL as
 * before because a builtin definition overrides the REPL definition. */
SCM_EXPORT void
scm_define_builtin(ScmObj sym, ScmObj val)
{
    /* Builtins defined before the builtin module is created are registered
     * by scm_register_bound_symbols_as_builtins() later. */
    if (l_builtin_ready && !scm_builtinp(sym))
        scm_module_bind(l_builtin_module, sym, sym);
    SCM_SYMBOL_SET_VCELL(sym, val);
}

/* It may be called before the builtin module is created. */
SCM_EXPORT scm_bool
scm_builtinp(ScmObj sym)
{
    return l_builtin_ready && !FALSEP(module_entry(l_builtin_module, sym));
}

SCM_EXPORT ScmObj
scm_make_shadow(ScmObj repl_val, ScmObj builtin_val)
{
    ScmObj *vec;

    vec = scm_malloc(sizeof(ScmObj) * 3);
    vec[0] = l_shadow_marker;
    vec[1] = repl_val;
    vec[2] = builtin_val;
    return MAKE_VECTOR(vec, 3);
}

/* Returns the value for the REPL or the builtin namespace if VAL is a
 * shadow. Otherwise, returns VAL. */
SCM_EXPORT ScmObj
scm_unshadow(ScmObj val, scm_bool builtinp)
{
    if (scm_shadowp(val))
        return SCM_VECTOR_VEC(val)[(builtinp) ? 2 : 1];
    return val;
}

SCM_EXPORT scm_bool
scm_shadowp(ScmObj obj)
{
    return (VECTORP(obj) && SCM_VECTOR_LEN(obj) == 3
            && EQ(SCM_VECTOR_VEC(obj)[0], l_shadow_marker));
}
