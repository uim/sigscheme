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
 * A module is #(marker name buckets n-entries indefinable id). BUCKETS is a
 * vector of alists. An entry of the alists is (symbol . location) and a
 * location is (value . owner) where OWNER is the module that defines the
 * binding. Modules share a location to export and import a binding. A
 * library can't redefine or mutate an imported binding whose owner isn't
 * the library. INDEFINABLE is #(marker module) for the toplevel of
 * the module where definitions aren't allowed. It isn't a pair because a
 * pair is a non-toplevel environment.
 *
 * The builtin module is the namespace of builtins. The REPL (the global
 * environment) shares the value cells of symbols with the builtin module for
 * speed. If the REPL redefines a builtin, the value cell has a shadow
 * #(marker repl-value builtin-value) to keep the builtin. The builtin module
 * has a location for each builtin to import builtins into libraries. The
 * value of the location is synchronized with the builtin value. If the REPL
 * imports a binding of a library, the REPL value is a forward
 * #(marker location) to share the location.
 *
 * A macro defined at a toplevel may be used at another toplevel. Template
 * identifiers of such macro are qualified by the toplevel where the macro
 * is defined. A qualified identifier is a far symbol whose env is
 * -(ID + 1) where ID is the ID of the toplevel. The ID of the global
 * environment is 0.
 */

/*=======================================
  File Local Macro Definitions
=======================================*/
#define MODULE_NAME(module)        (SCM_VECTOR_VEC(module)[1])
#define MODULE_BUCKETS(module)     (SCM_VECTOR_VEC(module)[2])
#define MODULE_N_ENTRIES(module)   (SCM_VECTOR_VEC(module)[3])
#define MODULE_INDEFINABLE(module) (SCM_VECTOR_VEC(module)[4])
#define MODULE_ID(module)          (SCM_VECTOR_VEC(module)[5])
#define MODULE_SIZE 6

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
static ScmObj l_forward_marker;
static ScmObj l_builtin_module;
static ScmObj l_toplevels;  /* a vector of toplevels indexed by IDs */
static scm_int_t l_n_toplevels;
static scm_bool l_builtin_ready;
static scm_int_t l_builtin_definition_depth;
#undef static
SCM_GLOBAL_VARS_END(static_library);
#define l_module_marker      SCM_GLOBAL_VAR(static_library, l_module_marker)
#define l_indefinable_marker                                                 \
    SCM_GLOBAL_VAR(static_library, l_indefinable_marker)
#define l_shadow_marker      SCM_GLOBAL_VAR(static_library, l_shadow_marker)
#define l_forward_marker     SCM_GLOBAL_VAR(static_library, l_forward_marker)
#define l_builtin_module     SCM_GLOBAL_VAR(static_library, l_builtin_module)
#define l_builtin_ready      SCM_GLOBAL_VAR(static_library, l_builtin_ready)
#define l_toplevels          SCM_GLOBAL_VAR(static_library, l_toplevels)
#define l_n_toplevels        SCM_GLOBAL_VAR(static_library, l_n_toplevels)
#define l_builtin_definition_depth                                           \
    SCM_GLOBAL_VAR(static_library, l_builtin_definition_depth)
SCM_DEFINE_STATIC_VARS(static_library);

/*=======================================
  File Local Function Declarations
=======================================*/
static ScmObj make_null_vector(scm_int_t len);
static ScmObj module_entry(ScmObj module, ScmObj sym);
static void module_rehash(ScmObj module);
static void register_toplevel(ScmObj module);
static scm_bool forwardp(ScmObj obj);
static ScmObj make_forward(ScmObj location);

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
    scm_gc_protect_with_init(&l_forward_marker,
                             LIST_1(scm_intern("%%forward")));
    /* The global environment is the toplevel 0. */
    scm_gc_protect_with_init(&l_toplevels, make_null_vector(16));
    l_n_toplevels = 1;
    scm_gc_protect_with_init(&l_builtin_module,
                             scm_make_module(LIST_2(scm_intern("sigscheme"),
                                                    scm_intern("builtin"))));

    scm_register_funcs(scm_functable_r7rs_library);
    l_builtin_ready = scm_true;
}

static ScmObj
make_null_vector(scm_int_t len)
{
    ScmObj *vec;
    scm_int_t i;

    vec = scm_malloc(sizeof(ScmObj) * len);
    for (i = 0; i < len; i++)
        vec[i] = SCM_NULL;
    return MAKE_VECTOR(vec, len);
}

SCM_EXPORT ScmObj
scm_make_module(ScmObj name)
{
    ScmObj module, *vec;

    vec = scm_malloc(sizeof(ScmObj) * MODULE_SIZE);
    vec[0] = l_module_marker;
    vec[1] = name;
    vec[2] = make_null_vector(INITIAL_N_BUCKETS);
    vec[3] = MAKE_INT(0);
    vec[4] = SCM_FALSE;
    vec[5] = MAKE_INT(l_n_toplevels);
    module = MAKE_VECTOR(vec, MODULE_SIZE);
    register_toplevel(module);
    vec = scm_malloc(sizeof(ScmObj) * 2);
    vec[0] = l_indefinable_marker;
    vec[1] = module;
    MODULE_INDEFINABLE(module) = MAKE_VECTOR(vec, 2);

    return module;
}

/* Adds MODULE to the toplevels. The vector is extended if it's full. */
static void
register_toplevel(ScmObj module)
{
    ScmObj new;
    scm_int_t i, n;

    n = SCM_VECTOR_LEN(l_toplevels);
    if (l_n_toplevels == n) {
        new = make_null_vector(n * 2);
        for (i = 0; i < n; i++)
            SCM_VECTOR_VEC(new)[i] = SCM_VECTOR_VEC(l_toplevels)[i];
        l_toplevels = new;
    }
    SCM_VECTOR_VEC(l_toplevels)[l_n_toplevels++] = module;
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
    new = make_null_vector(n);
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
    ScmObj entry;

    entry = module_entry(module, sym);
    if (FALSEP(entry)) {
        scm_module_bind(module, sym, CONS(val, module));
        return;
    }
    if (!EQ(CDDR(entry), module))
        scm_error_obj("define", "imported binding can't be redefined", sym);
    SET_CAR(CDR(entry), val);
}

/* Returns true if REF is the location of SYM that MODULE imports. */
SCM_EXPORT scm_bool
scm_module_imported_refp(ScmObj module, ScmObj sym, ScmRef ref)
{
    ScmObj entry;

    entry = module_entry(module, sym);
    return (!FALSEP(entry) && REF_CAR(CDR(entry)) == ref
            && !EQ(CDDR(entry), module));
}

/* (%%make-module name) is used by define-library in lib/library.scm. */
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
            if (SCM_SYMBOL_BOUNDP(sym) && !scm_builtinp(sym))
                scm_module_bind(l_builtin_module, sym,
                                CONS(scm_unshadow(SCM_SYMBOL_VCELL(sym),
                                                  scm_true),
                                     l_builtin_module));
        }
    }
}

/* Auxiliary syntax such as else isn't bound but has a location to be
 * imported. The value of the location is unbound. */
SCM_EXPORT void
scm_register_auxiliary_syntax(void)
{
    static const char *const names[] = {"else", "=>", "...", "_", NULL};
    const char *const *name;

    for (name = &names[0]; *name; name++)
        scm_set_builtin_location(scm_intern(*name), SCM_UNBOUND);
}

/* Defines SYM as VAL in the builtin namespace. The REPL also uses VAL as
 * before because a builtin definition overrides the REPL definition. */
SCM_EXPORT void
scm_define_builtin(ScmObj sym, ScmObj val)
{
    /* Builtins defined before the builtin module is created are registered
     * by scm_register_bound_symbols_as_builtins() later. */
    if (l_builtin_ready)
        scm_set_builtin_location(sym, val);
    SCM_SYMBOL_SET_VCELL(sym, val);
}

/* Synchronizes the location of the builtin SYM with VAL. */
SCM_EXPORT void
scm_set_builtin_location(ScmObj sym, ScmObj val)
{
    ScmObj entry;

    entry = module_entry(l_builtin_module, sym);
    if (FALSEP(entry))
        scm_module_bind(l_builtin_module, sym, CONS(val, l_builtin_module));
    else
        SET_CAR(CDR(entry), val);
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
 * shadow or a forward. Otherwise, returns VAL. */
SCM_EXPORT ScmObj
scm_unshadow(ScmObj val, scm_bool builtinp)
{
    if (scm_shadowp(val))
        val = SCM_VECTOR_VEC(val)[(builtinp) ? 2 : 1];
    if (forwardp(val))
        val = CAR(SCM_VECTOR_VEC(val)[1]);
    return val;
}

static scm_bool
forwardp(ScmObj obj)
{
    return (VECTORP(obj) && SCM_VECTOR_LEN(obj) == 2
            && EQ(SCM_VECTOR_VEC(obj)[0], l_forward_marker));
}

static ScmObj
make_forward(ScmObj location)
{
    ScmObj *vec;

    vec = scm_malloc(sizeof(ScmObj) * 2);
    vec[0] = l_forward_marker;
    vec[1] = location;
    return MAKE_VECTOR(vec, 2);
}

SCM_EXPORT scm_bool
scm_shadowp(ScmObj obj)
{
    return (VECTORP(obj) && SCM_VECTOR_LEN(obj) == 3
            && EQ(SCM_VECTOR_VEC(obj)[0], l_shadow_marker));
}

/*
 * Qualified identifiers
 */
/* Returns SYM qualified by the toplevel environment TOPLEVEL. */
SCM_EXPORT ScmObj
scm_qualify_identifier(ScmObj sym, ScmObj toplevel)
{
    scm_int_t id;

    SCM_ASSERT(SYMBOLP(sym));

    id = (NULLP(toplevel)) ? 0 : SCM_INT_VALUE(MODULE_ID(toplevel));
    return MAKE_FARSYMBOL(sym, -(id + 1));
}

/* Returns the toplevel environment of the qualified identifier ID or
 * SCM_INVALID if ID isn't qualified. */
SCM_EXPORT ScmObj
scm_identifier_toplevel(ScmObj id)
{
    scm_int_t toplevel_id;

    if (!FARSYMBOLP(id) || SCM_FARSYMBOL_ENV(id) >= 0)
        return SCM_INVALID;
    toplevel_id = -SCM_FARSYMBOL_ENV(id) - 1;
    return (toplevel_id == 0)
           ? SCM_NULL : SCM_VECTOR_VEC(l_toplevels)[toplevel_id];
}

/*
 * Primitives for lib/library.scm
 */
/* Returns the location of SYM in MODULE or #f. */
SCM_EXPORT ScmObj
scm_p_module_location(ScmObj module, ScmObj sym)
{
    ScmObj entry;
    DECLARE_FUNCTION("%%module-location", procedure_fixed_2);

    if (!scm_modulep(module))
        ERR_OBJ("module required but got", module);
    ENSURE_SYMBOL(sym);

    entry = module_entry(module, sym);
    return (FALSEP(entry)) ? SCM_FALSE : CDR(entry);
}

/* Binds SYM to the imported LOCATION in MODULE. */
SCM_EXPORT ScmObj
scm_p_module_importx(ScmObj module, ScmObj sym, ScmObj location)
{
    ScmObj entry;
    DECLARE_FUNCTION("%%module-import!", procedure_fixed_3);

    if (!scm_modulep(module))
        ERR_OBJ("module required but got", module);
    ENSURE_SYMBOL(sym);
    ENSURE_CONS(location);

    entry = module_entry(module, sym);
    if (!FALSEP(entry) && !EQ(CDR(entry), location))
        ERR_OBJ("identifier is imported with different bindings", sym);
    scm_module_bind(module, sym, location);
    return SCM_UNDEF;
}

/* Returns the location of the builtin SYM or #f. */
SCM_EXPORT ScmObj
scm_p_builtin_location(ScmObj sym)
{
    DECLARE_FUNCTION("%%builtin-location", procedure_fixed_1);

    ENSURE_SYMBOL(sym);

    return scm_p_module_location(l_builtin_module, sym);
}

/* Imports LOCATION as SYM into the REPL. The REPL may redefine it. */
SCM_EXPORT ScmObj
scm_p_global_importx(ScmObj sym, ScmObj location)
{
    ScmObj builtin_location, builtin_val;
    DECLARE_FUNCTION("%%global-import!", procedure_fixed_2);

    ENSURE_SYMBOL(sym);
    ENSURE_CONS(location);

    builtin_val = scm_unshadow(SCM_SYMBOL_VCELL(sym), scm_true);
    builtin_location = scm_p_module_location(l_builtin_module, sym);
    if (EQ(location, builtin_location))
        SCM_SYMBOL_SET_VCELL(sym, builtin_val);
    else if (!FALSEP(builtin_location))
        SCM_SYMBOL_SET_VCELL(sym, scm_make_shadow(make_forward(location),
                                                  builtin_val));
    else
        SCM_SYMBOL_SET_VCELL(sym, make_forward(location));
    return SCM_UNDEF;
}

/* Returns the environment of MODULE for eval. Definitions aren't allowed
 * in it unless strict toplevel definitions are disabled. */
SCM_EXPORT ScmObj
scm_p_module_environment(ScmObj module)
{
    DECLARE_FUNCTION("%%module-environment", procedure_fixed_1);

    if (!scm_modulep(module))
        ERR_OBJ("module required but got", module);

#if SCM_STRICT_TOPLEVEL_DEFINITIONS
    return scm_module_indefinable(module);
#else
    return module;
#endif
}

/* Returns the absolute path of FILENAME searched in the library path or
 * #f. */
SCM_EXPORT ScmObj
scm_p_find_file(ScmObj filename)
{
    char *path;
    DECLARE_FUNCTION("%%find-file", procedure_fixed_1);

    ENSURE_STRING(filename);

    path = scm_find_path(SCM_STRING_STR(filename));
    return (path) ? MAKE_STRING(path, STRLEN_UNKNOWN) : SCM_FALSE;
}

/*
 * R7RS: include and include-ci
 */
/* Returns the forms in FILENAMES. They are read by %%include-files in
 * lib/library.scm. */
SCM_EXPORT ScmObj
scm_include_forms(ScmObj filenames, scm_bool fold_casep)
{
    ScmObj include_files;

    include_files = scm_toplevel_value(scm_intern("%%include-files"),
                                       l_builtin_module);
    return scm_call(include_files,
                    LIST_3(filenames, SCM_FALSE, MAKE_BOOL(fold_casep)));
}

SCM_EXPORT ScmObj
scm_s_include(ScmObj filenames, ScmEvalState *eval_state)
{
    DECLARE_FUNCTION("include", syntax_variadic_tailrec_0);

    return scm_s_begin(scm_include_forms(filenames, scm_false), eval_state);
}

SCM_EXPORT ScmObj
scm_s_include_ci(ScmObj filenames, ScmEvalState *eval_state)
{
    DECLARE_FUNCTION("include-ci", syntax_variadic_tailrec_0);

    return scm_s_begin(scm_include_forms(filenames, scm_true), eval_state);
}
