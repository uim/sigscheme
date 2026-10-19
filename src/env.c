/*===========================================================================
 *  Filename : env.c
 *  About    : A Scheme environemnt implementation
 *
 *  Copyright (C) 2005      Kazuki Ohta <mover AT hct.zaq.ne.jp>
 *  Copyright (C) 2005-2006 Jun Inoue <jun.lambda AT gmail.com>
 *  Copyright (C) 2005-2006 YAMAMOTO Kengo <yamaken AT bp.iij4u.or.jp>
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

/*
 *   SigScheme's environment object is a list formed as below.
 *
 *     frame = (cons (var1 var2 var3 ...)
 *                   (val1 val2 val3 ...))
 *     env   = (frame1 frame2 frame3 ...)
 *
 *   Other 2 forms are also used to handle dotted args.
 *
 *     frame = (cons (var1 var2 var3 . rest1)
 *                   (val1 val2 val3 var4 var5 ...))
 *
 *     frame = (cons rest2
 *                   (val1 val2 val3 var4 var5 ...))
 *
 *   In this case, rest1 is bound to (var4 var5 ...) and rest2 is bound to
 *   (val1 val2 val3 var4 var5 ...).
 *
 *   The tail of env is '() for the global environment. It's a module for a
 *   library (see library.c) instead of '(). The toplevel environment is the
 *   tail itself.
 *
 *   The environment object should not be manipulated manually, to allow
 *   replacing with another implementation. Use the function interfaces.
 *
 *   To ensure valid use of the environment objects is environment
 *   constructor's responsibility. i.e. Any lookup operations assume that the
 *   environment object is valid. To keep the assumption true, any environemnt
 *   object modification and injection from user code must be
 *   validated. Although the validation for the injection may cost high,
 *   ordinary code only use (interaction-environment) and other R5RS
 *   environment specifiers. Since these 'trusted' specifiers can cheaply be
 *   identified, the validation cost is also. The validation can reject any
 *   handmade invalid environment objects.
 */

#include <config.h>

#include <sigscheme/sigscheme.h>
#include "sigschemeinternal.h"

/*=======================================
  File Local Macro Definitions
=======================================*/
/* Avoid the function call for the common case. */
#define UNWRAP_IDENTIFIER(id)                                                \
    (FARSYMBOLP(id) ? SCM_UNWRAP_KEYWORD(id) : (id))
#if SCM_USE_R7RS
#define QUALIFIED_IDENTIFIERP(id)                                            \
    (FARSYMBOLP(id) && SCM_FARSYMBOL_ENV(id) < 0)
#endif

#define TRUSTED_ENVP(env) (EQ(env, SCM_INTERACTION_ENV)                      \
                           || EQ(env, SCM_R5RS_ENV)                          \
                           || EQ(env, SCM_NULL_ENV))

/*=======================================
  File Local Type Definitions
=======================================*/

/*=======================================
  Variable Definitions
=======================================*/

/*=======================================
  File Local Function Declarations
=======================================*/
static scm_bool valid_framep(ScmObj frame);
static scm_int_t env_depth(ScmObj env);
static ScmObj identifier_toplevel(ScmObj id, ScmObj env);
static inline ScmRef lookup_frames(ScmObj var, ScmObj env,
                                   ScmObj *toplevel);
#if SCM_USE_R7RS
static ScmRef lookup_module(ScmObj var, ScmObj module);
#endif
#if SCM_USE_HYGIENIC_MACRO
static ScmRef lookup_far_symbol(ScmObj var, ScmObj env);
#endif

/*=======================================
  Function Definitions
=======================================*/
SCM_EXPORT scm_bool
scm_toplevel_environmentp(ScmObj env)
{
#if SCM_USE_R7RS
    return NULLP(env) || (!CONSP(env) && scm_modulep(env));
#else
    return NULLP(env);
#endif
}

/* Returns the toplevel environment that is the tail of ENV. */
SCM_EXPORT ScmObj
scm_env_toplevel(ScmObj env)
{
    for (; CONSP(env); env = CDR(env))
        ;
    return env;
}

/* Returns the toplevel environment where the identifier ID is resolved in
 * ENV. A qualified identifier has its toplevel. */
static ScmObj
identifier_toplevel(ScmObj id SCM_UNUSED, ScmObj env)
{
#if SCM_USE_R7RS
    if (QUALIFIED_IDENTIFIERP(id))
        return scm_identifier_toplevel(id);
#endif
    return scm_env_toplevel(env);
}

/* Returns the number of frames of ENV. */
static scm_int_t
env_depth(ScmObj env)
{
    scm_int_t depth;

    for (depth = 0; CONSP(env); env = CDR(env))
        depth++;
    return depth;
}

#if SCM_USE_HYGIENIC_MACRO

/* ScmPackedEnv is scm_int_t. */

SCM_EXPORT ScmPackedEnv
scm_pack_env(ScmObj env)
{
    return env_depth(env);
}

/* Not used. */
SCM_EXPORT ScmObj
scm_unpack_env(ScmPackedEnv packed, ScmObj context)
{
    scm_int_t depth;

    depth = env_depth(context);
    while (depth-- > packed)
        context = CDR(context);
    return context;
}


static ScmRef
lookup_n_frames(ScmObj id, scm_int_t n, ScmObj env)
{
    ScmRef ref;

    while (n--) {
        SCM_ASSERT(ENVP(env));
        ref = scm_lookup_frame(id, CAR(env));
        if (ref != SCM_INVALID_REF)
            return ref;
        env = CDR(env);
    }
    return SCM_INVALID_REF;
}


/**
 * Resolves X in scm_unpack_env(XPENV, ENV), Y in ENV and tests
 * whether they are bound to the same location.  The parameters x and
 * y are thus UNINTERCHANGEABLE.
 *
 * The pattern matcher must compare scm_wrap_identifier(x, xpenv) with
 * y, but for performance we'd like to do that without actually
 * allocating the wrapper.  In the absence of syntax-case or
 * comparable mechanisms allowing for unhygienic transforms, the
 * binding frame of X and Y are always both contained in ENV, so we
 * might as well require that ENV be the environment in which one of
 * the operands (namely, Y) is to be looked up.
 *
 * But this is definitely an ugly interface, and also inconvenient
 * because the function needs a different signature when unhygienic
 * transforms are enabled.  So, FIXME: is there a better way?
 *
 * Moving this to macro.c can be an option, but keep in mind some
 * aspects are inherently tightly coupled with the lookup functions.
 */
SCM_EXPORT scm_bool
scm_identifierequalp(ScmObj x, ScmPackedEnv xpenv,
                     ScmObj y, ScmPackedEnv penv, ScmObj env)
{
    ScmRef yloc;

    SCM_ASSERT(xpenv <= penv);
    SCM_ASSERT(SCM_PENV_EQ(scm_pack_env(env), penv));

    while (penv-- > xpenv) {
        if (scm_lookup_frame(y, CAR(env)) != SCM_INVALID_REF)
            return scm_false;
        env = CDR(env);
    }
    if (EQ(x, y))
        return scm_true;
    yloc = scm_lookup_environment(y, env);
    if (yloc != SCM_INVALID_REF)
        return (scm_lookup_environment(x, env) == yloc);
    if (scm_lookup_environment(x, env) != SCM_INVALID_REF)
        return scm_false;
    return EQ(SCM_UNWRAP_KEYWORD(x), SCM_UNWRAP_KEYWORD(y));
}

/**
 * Returns an identifier that is bound to the same location as ID
 * within ENV (whose packed representation is DEPTH), but is not eq?
 * with ID.
 */
SCM_EXPORT ScmObj
scm_wrap_identifier(ScmObj id, ScmPackedEnv depth, ScmObj env)
{
    scm_int_t id_depth;

    SCM_ASSERT(IDENTIFIERP(id));
    SCM_ASSERT(depth == scm_pack_env(env));

    if (FARSYMBOLP(id)) {
        /* Try to reduce lookup overhead. */
        id_depth = SCM_FARSYMBOL_ENV(id);
        /* A qualified identifier isn't bound in ENV. */
        if (id_depth < 0)
            return id;
        SCM_ASSERT(id_depth <= depth);
        if (lookup_n_frames(id, depth - id_depth, env) == SCM_INVALID_REF) {
            /* ID hasn't been bound since it was captured. */
            return MAKE_FARSYMBOL(SCM_FARSYMBOL_SYM(id), id_depth);
        }
    }
    return MAKE_FARSYMBOL(id, depth);
}
#endif /* SCM_USE_HYGIENIC_MACRO */

/**
 * Construct a new frame on an env
 *
 * @a formals and @a actuals must be valid.
 *
 * @param formals Symbol list as variable names of new frame. It accepts dotted
 *                list to handle function arguments directly.
 * @param actuals Arbitrary Scheme object list as values of new frame.
 *
 * @see scm_eval()
 */
SCM_EXPORT ScmObj
scm_extend_environment(ScmObj formals, ScmObj actuals, ScmObj env)
{
    ScmObj frame;
    DECLARE_INTERNAL_FUNCTION("scm_extend_environment");

    SCM_ASSERT(scm_valid_environment_extensionp(formals, actuals));
    SCM_ASSERT(VALID_ENVP(env));

    frame = CONS(formals, actuals);
    return CONS(frame, env);
}

/**
 * Replace entire content of recentmost frame of an env
 *
 * The environment must be replaced with returned one in caller side even if
 * this implementation returns identical to the one passed. This rule is
 * required to be compatible with future alternative implementations.
 */
SCM_EXPORT ScmObj
scm_replace_environment(ScmObj formals, ScmObj actuals, ScmObj env)
{
    ScmObj frame;
    DECLARE_INTERNAL_FUNCTION("scm_replace_environment");

    SCM_ASSERT(scm_valid_environment_extensionp(formals, actuals));
    SCM_ASSERT(VALID_ENVP(env));
    SCM_ASSERT(CONSP(env));

    frame = CAR(env);
    SET_CAR(frame, formals);
    SET_CDR(frame, actuals);

    return env;
}

/**
 * Replace all actuals of recentmost frame of an env
 *
 * The environment must be replaced with returned one in caller side even if
 * this implementation returns identical to the one passed. This rule is
 * required to be compatible with future alternative implementations.
 */
SCM_EXPORT ScmObj
scm_update_environment(ScmObj actuals, ScmObj env)
{
    ScmObj frame;
    DECLARE_INTERNAL_FUNCTION("scm_update_environment");

    SCM_ASSERT(VALID_ENVP(env));
    SCM_ASSERT(CONSP(env));

    frame = CAR(env);
    SCM_ASSERT(scm_valid_environment_extensionp(CAR(frame), actuals));
    SET_CDR(frame, actuals);

    return env;
}

/** Add a binding to recentmost frame of an env */
SCM_EXPORT ScmObj
scm_add_environment(ScmObj var, ScmObj val, ScmObj env)
{
    ScmObj frame, formals, actuals;
    DECLARE_INTERNAL_FUNCTION("scm_add_environment");

    SCM_ASSERT(IDENTIFIERP(var));
    SCM_ASSERT(VALID_ENVP(env));

    /* add (var, val) pair to recentmost frame of the env */
    if (scm_toplevel_environmentp(env)) {
        frame = CONS(LIST_1(var), LIST_1(val));
        env = CONS(frame, env);
    } else if (CONSP(env)) {
        frame = CAR(env);
        formals = CONS(var, CAR(frame));
        actuals = CONS(val, CDR(frame));
        SET_CAR(frame, formals);
        SET_CDR(frame, actuals);
    } else {
        SCM_NOTREACHED;
    }
    return env;
}

/**
 * Lookup a variable of an env
 *
 * @return Reference to the variable. SCM_INVALID_REF if not found.
 */
SCM_EXPORT ScmRef
scm_lookup_environment(ScmObj var, ScmObj env)
{
    ScmRef ref;
    ScmObj toplevel;
    DECLARE_INTERNAL_FUNCTION("scm_lookup_environment");

    SCM_ASSERT(IDENTIFIERP(var));
    SCM_ASSERT(VALID_ENVP(env));

    ref = lookup_frames(var, env, &toplevel);
#if SCM_USE_HYGIENIC_MACRO
    if (ref == SCM_INVALID_REF && FARSYMBOLP(var))
        ref = lookup_far_symbol(var, env);
#endif
    return ref;
}

/* Lookup a variable in all frames of an env. This is separated from
 * scm_lookup_environment() to keep the common case fast. TOPLEVEL is set to
 * the toplevel environment of ENV if the variable isn't found in the
 * frames. A variable in the global environment or the builtin module isn't
 * found because it's in the value cell of the symbol. */
static inline ScmRef
lookup_frames(ScmObj var, ScmObj env, ScmObj *toplevel)
{
    ScmRef ref;

    for (; CONSP(env); env = CDR(env)) {
        ref = scm_lookup_frame(var, CAR(env));
        if (ref != SCM_INVALID_REF)
            return ref;
    }
    *toplevel = env;
#if SCM_USE_R7RS
    if (!NULLP(env))
        return lookup_module(var, env);
#endif
    return SCM_INVALID_REF;
}

#if SCM_USE_R7RS
/* Lookup a variable in the module that is the tail of an env. This is
 * separated from lookup_frames() to keep lookup_frames() small enough to be
 * inlined. */
static ScmRef
lookup_module(ScmObj var, ScmObj module)
{
    if (!SYMBOLP(var) || EQ(module, scm_builtin_module()))
        return SCM_INVALID_REF;
    return scm_module_lookup(module, var);
}
#endif

#if SCM_USE_HYGIENIC_MACRO
/* Lookup the symbol of a far symbol in the frames where the far symbol was
 * created. */
static ScmRef
lookup_far_symbol(ScmObj var, ScmObj env)
{
    ScmRef ref;
    scm_int_t depth, id_depth;
#if SCM_USE_R7RS
    ScmObj toplevel;
#endif
    DECLARE_INTERNAL_FUNCTION("scm_lookup_environment");

#if SCM_USE_R7RS
    if (QUALIFIED_IDENTIFIERP(var)) {
        /* A qualified identifier is resolved only in its toplevel. */
        toplevel = scm_identifier_toplevel(var);
        return (NULLP(toplevel))
               ? SCM_INVALID_REF
               : lookup_module(SCM_FARSYMBOL_SYM(var), toplevel);
    }
#endif
    depth = env_depth(env);
    id_depth = SCM_FARSYMBOL_ENV(var);
    if (id_depth > depth)
        scm_macro_bad_scope(var);
    for (; depth > id_depth; depth--)
        env = CDR(env);
    ref = lookup_n_frames(SCM_FARSYMBOL_SYM(var), id_depth, env);
    SCM_ASSERT(ref != SCM_INVALID_REF || SYMBOLP(SCM_FARSYMBOL_SYM(var)));
#if SCM_USE_R7RS
    /* The toplevel of a module. */
    if (ref == SCM_INVALID_REF) {
        env = scm_env_toplevel(env);
        if (!NULLP(env))
            ref = lookup_module(SCM_FARSYMBOL_SYM(var), env);
    }
#endif
    return ref;
}
#endif /* SCM_USE_HYGIENIC_MACRO */

/** Lookup a variable in a frame */
SCM_EXPORT ScmRef
scm_lookup_frame(ScmObj var, ScmObj frame)
{
    ScmObj formals;
    ScmRef actuals;
    DECLARE_INTERNAL_FUNCTION("scm_lookup_frame");

    SCM_ASSERT(IDENTIFIERP(var));
    SCM_ASSERT(valid_framep(frame));

    for (formals = CAR(frame), actuals = REF_CDR(frame);
         CONSP(formals);
         formals = CDR(formals), actuals = REF_CDR(DEREF(actuals)))
    {
        if (EQ(var, CAR(formals)))
            return REF_CAR(DEREF(actuals));
    }
    /* dotted list */
    if (EQ(var, formals))
        return actuals;

    return SCM_INVALID_REF;
}

ScmObj
scm_symbol_value(ScmObj var, ScmObj env)
{
    ScmRef ref;
    ScmObj val, toplevel;
    DECLARE_INTERNAL_FUNCTION("scm_symbol_value");

    SCM_ASSERT(IDENTIFIERP(var));

    /* Check far symbols only once here for the common case. */
#if SCM_USE_HYGIENIC_MACRO
    if (FARSYMBOLP(var)) {
        ref = scm_lookup_environment(var, env);
        /* The toplevel is required only if REF is invalid. */
        toplevel = (ref == SCM_INVALID_REF) ? identifier_toplevel(var, env)
                                            : SCM_INVALID;
        var = SCM_FARSYMBOL_SYM(var);
    } else
#endif
    {
        ref = lookup_frames(var, env, &toplevel);
    }

    if (ref != SCM_INVALID_REF) {
        /* Found in the environment. Since scm_s_body() may produce unbound
         * variables as internal definitions, subsequent error check is
         * required. */
        val = DEREF(ref);
    } else {
        /* Fallback to top-level binding. */
        SCM_ASSERT(SYMBOLP(var));
        val = SCM_SYMBOL_VCELL(var);
#if SCM_USE_R7RS
        if (VECTORP(val))
            val = scm_unshadow(val, !NULLP(toplevel));
#endif
    }

    if (EQ(val, SCM_UNBOUND))
        ERR_OBJ("unbound variable", var);

    return val;
}

/*
 * Validators
 */
SCM_EXPORT scm_bool
scm_valid_environmentp(ScmObj env)
{
    ScmObj frame, rest;
    DECLARE_INTERNAL_FUNCTION("scm_valid_environmentp");

    if (TRUSTED_ENVP(env))
        return scm_true;
#if SCM_USE_R7RS
    if (!FALSEP(scm_indefinable_module(env)))
        return scm_true;
#endif

    /*
     * The env is extended and untrusted. Since this case rarely occurs in
     * ordinary codes, the expensive validation cost is acceptable.
     */

    for (rest = env; CONSP(rest); rest = CDR(rest)) {
        frame = CAR(rest);
        if (!valid_framep(frame))
            return scm_false;
    }

    return scm_toplevel_environmentp(rest);
}

static scm_bool
valid_framep(ScmObj frame)
{
    ScmObj formals, actuals;
    DECLARE_INTERNAL_FUNCTION("valid_framep");

    if (CONSP(frame)) {
        formals = CAR(frame);
        actuals = CDR(frame);
        if (scm_valid_environment_extensionp(formals, actuals))
            return scm_true;
    }
    return scm_false;
}

SCM_EXPORT scm_bool
scm_valid_environment_extensionp(ScmObj formals, ScmObj actuals)
{
    scm_int_t formals_len, actuals_len;

    formals_len = scm_validate_formals(formals);
    actuals_len = scm_validate_actuals(actuals);
    return scm_valid_environment_extension_lengthp(formals_len, actuals_len);
}

/* formals_len must be validated by scm_validate_formals() prior to here */
SCM_EXPORT scm_bool
scm_valid_environment_extension_lengthp(scm_int_t formals_len,
                                        scm_int_t actuals_len)
{
    if (SCM_LISTLEN_ERRORP(formals_len))
        return scm_false;
    if (SCM_LISTLEN_DOTTEDP(formals_len)) {
        formals_len = SCM_LISTLEN_DOTTED(formals_len);
        if (SCM_LISTLEN_PROPERP(actuals_len))
            return (formals_len <= actuals_len);

        /* (lambda args (set-cdr! args #t) args) */
        if (SCM_LISTLEN_DOTTEDP(actuals_len))
            return (formals_len <= SCM_LISTLEN_DOTTED(actuals_len));

        /* (lambda args (set-cdr! args args) args) */
        if (SCM_LISTLEN_CIRCULARP(actuals_len))  /* always true */
            return scm_true;
    }
    return (formals_len == actuals_len);
}

SCM_EXPORT scm_int_t
scm_validate_formals(ScmObj formals)
{
#if SCM_STRICT_ARGCHECK
    scm_int_t len;
    DECLARE_INTERNAL_FUNCTION("scm_validate_formals");

    /*
     * SigScheme does not perform the check for duplicate variable name in
     * formals. It is an user's responsibility.
     *
     * R5RS: 4.1.4 Procedures
     * It is an error for a <variable> to appear more than once in <formals>.
     */

    /* This loop goes infinite if the formals is circular. SigSchme expects
     * that user codes are sane here. */
    for (len = 0; CONSP(formals); formals = CDR(formals), len++) {
        if (!IDENTIFIERP(CAR(formals)))
            return SCM_LISTLEN_ENCODE_ERROR(len);
    }
    if (NULLP(formals))
        return len;
    /* dotted list allowed */
    if (IDENTIFIERP(formals))
        return SCM_LISTLEN_ENCODE_DOTTED(len);
    return SCM_LISTLEN_ENCODE_ERROR(len);
#else
    /* Crashless loose validation:
     * Regard any non-list object as symbol. Since the lookup operation search
     * for a variable by EQ, this is safe although loosely allows
     * R5RS-incompatible code. */
    return scm_finite_length(formals);
#endif
}

SCM_EXPORT scm_int_t
scm_validate_actuals(ScmObj actuals)
{
    scm_int_t len;

#if SCM_STRICT_ARGCHECK
    len = scm_length(actuals);
#else
    /* Crashless loose validation:
     * This loop goes infinite if the formals is circular. SigSchme expects
     * that user codes are sane here. */
    len = scm_finite_length(actuals);
#endif
    if (SCM_LISTLEN_DOTTEDP(len))
        return SCM_LISTLEN_ENCODE_ERROR(len);
    return len;
}

/* Returns the value of the identifier ID in the global environment or the
 * builtin module. ENV is used to choose one of them. It may be
 * SCM_UNBOUND. */
SCM_EXPORT ScmObj
scm_toplevel_value(ScmObj id, ScmObj env SCM_UNUSED)
{
    SCM_ASSERT(IDENTIFIERP(id));

#if SCM_USE_R7RS
    return scm_unshadow(SCM_SYMBOL_VCELL(UNWRAP_IDENTIFIER(id)),
                        !NULLP(identifier_toplevel(id, env)));
#else
    return SCM_SYMBOL_VCELL(UNWRAP_IDENTIFIER(id));
#endif
}

#if SCM_USE_R7RS
/* Sets VAL to SYM in the global environment if REPLP. Otherwise, sets it in
 * the builtin module. A shadow keeps the builtin when the global
 * environment changes it. */
static void
set_value_cell(ScmObj sym, ScmObj val, scm_bool replp)
{
    ScmObj cur;

    cur = SCM_SYMBOL_VCELL(sym);
    if (scm_shadowp(cur))
        SCM_VECTOR_VEC(cur)[(replp) ? 1 : 2] = val;
    else if (replp && !EQ(cur, SCM_UNBOUND) && scm_builtinp(sym))
        SCM_SYMBOL_SET_VCELL(sym, scm_make_shadow(val, cur));
    else
        SCM_SYMBOL_SET_VCELL(sym, val);
}
#endif

/* Sets VAL to the bound identifier ID in the toplevel environment of
 * ENV. */
SCM_EXPORT void
scm_set_toplevel(ScmObj id, ScmObj val, ScmObj env SCM_UNUSED)
{
#if SCM_USE_R7RS
    ScmObj sym, toplevel;
    DECLARE_INTERNAL_FUNCTION("set!");
#endif

    SCM_ASSERT(IDENTIFIERP(id));

#if SCM_USE_R7RS
    sym = UNWRAP_IDENTIFIER(id);
    toplevel = identifier_toplevel(id, env);
    if (NULLP(toplevel)) {
        set_value_cell(sym, val, scm_true);
    } else if (EQ(toplevel, scm_builtin_module())) {
        set_value_cell(sym, val, scm_false);
        scm_set_builtin_location(sym, val);
    } else {
        /* A library can't mutate builtins that aren't imported. */
        ERR_OBJ("unbound variable", sym);
    }
#else
    SCM_SYMBOL_SET_VCELL(UNWRAP_IDENTIFIER(id), val);
#endif
}

#if SCM_USE_R7RS
/* Returns true if REF of the identifier ID is a location that the toplevel
 * of ENV imports. */
SCM_EXPORT scm_bool
scm_imported_refp(ScmObj id, ScmRef ref, ScmObj env)
{
    ScmObj toplevel;

    toplevel = identifier_toplevel(id, env);
    if (NULLP(toplevel) || EQ(toplevel, scm_builtin_module()))
        return scm_false;
    return scm_module_imported_refp(toplevel, UNWRAP_IDENTIFIER(id), ref);
}
#endif

/* Defines VAR as VAL in the toplevel environment ENV. */
SCM_EXPORT void
scm_define_toplevel(ScmObj var, ScmObj val, ScmObj env)
{
    SCM_ASSERT(scm_toplevel_environmentp(env));
    SCM_ASSERT(SYMBOLP(var));

#if SCM_USE_R7RS
    if (NULLP(env))
        set_value_cell(var, val, scm_true);
    else if (EQ(env, scm_builtin_module()))
        scm_define_builtin(var, val);
    else
        scm_module_define(env, var, val);
#else
    SCM_SYMBOL_SET_VCELL(var, val);
#endif
}
