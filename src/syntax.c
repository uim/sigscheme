/*===========================================================================
 *  Filename : syntax.c
 *  About    : R5RS syntaxes
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

#include <config.h>

#include <sigscheme/sigscheme.h>
#include "sigschemeinternal.h"

/*=======================================
  File Local Macro Definitions
=======================================*/
#define ERRMSG_CLAUSE_REQUIRED     "at least 1 clause required"
#define ERRMSG_EXPRESSION_REQUIRED "at least 1 expression required"
#define ERRMSG_INVALID_BINDINGS    "invalid bindings form"
#define ERRMSG_INVALID_BINDING     "invalid binding form"
#define ERRMSG_SYNTAX_AS_VALUE     "syntactic keyword is passed as value"
#define ERRMSG_DUPLICATE_VARNAME   "duplicate variable name"
#define ERRMSG_BAD_DEFINE_FORM     "bad definition form"

#if SCM_USE_INTERNAL_DEFINITIONS
#define ERRMSG_BAD_DEFINE_PLACEMENT "definitions are valid only at toplevel" \
                                    " or beginning of a binding construct"
#else
#define ERRMSG_BAD_DEFINE_PLACEMENT "internal definitions feature is disabled"
#endif

/* FIXME: temporary hack */
#if SCM_STRICT_TOPLEVEL_DEFINITIONS
#if SCM_USE_R7RS
/* Most environments are pairs, which aren't toplevel ones. */
#define FORBID_TOPLEVEL_DEFINITIONS(env)                                     \
    (CONSP(env) ? (env)                                                      \
     : EQ((env), SCM_INTERACTION_ENV) ? SCM_INTERACTION_ENV_INDEFINABLE      \
     : scm_modulep(env) ? scm_module_indefinable(env) : (env))
#else
#define FORBID_TOPLEVEL_DEFINITIONS(env)                                     \
    (EQ((env), SCM_INTERACTION_ENV) ? SCM_INTERACTION_ENV_INDEFINABLE : (env))
#endif
#else
#define FORBID_TOPLEVEL_DEFINITIONS(env) (env)
#endif

#if SCM_USE_HYGIENIC_MACRO
#define CHECK_VALID_BINDEE(permitted_type, bindee)                           \
    do {                                                                     \
        if (permitted_type == ScmFirstClassObj)                              \
            CHECK_VALID_EVALED_VALUE(bindee);                                \
        else if (permitted_type == ScmMacro)                                 \
            SCM_ASSERT(HMACROP(bindee));                                     \
        else                                                                 \
            SCM_NOTREACHED;                                                  \
    } while (/* CONSTCOND */ 0)
#else
#define CHECK_VALID_BINDEE(permitted_type, bindee)                           \
    do {                                                                     \
        if (permitted_type == ScmFirstClassObj)                              \
            CHECK_VALID_EVALED_VALUE(bindee);                                \
        else                                                                 \
            SCM_NOTREACHED;                                                  \
    } while (/* CONSTCOND */ 0)
#endif

/*=======================================
  File Local Type Definitions
=======================================*/

/*=======================================
  Variable Definitions
=======================================*/
#include "functable-r5rs-syntax.c"

SCM_DEFINE_EXPORTED_VARS(syntax);

SCM_GLOBAL_VARS_BEGIN(static_syntax);
#define static
static ScmObj l_sym_else, l_sym_yields, l_sym_define;
#if SCM_USE_INTERNAL_DEFINITIONS
static ScmObj l_sym_begin, l_syn_lambda;
#if SCM_USE_R7RS
static ScmObj l_sym_define_values, l_sym_define_syntax;
static ScmObj l_sym_include, l_sym_include_ci;
#endif
#endif /* SCM_USE_INTERNAL_DEFINITIONS */
#undef static
SCM_GLOBAL_VARS_END(static_syntax);
#define l_sym_else   SCM_GLOBAL_VAR(static_syntax, l_sym_else)
#define l_sym_yields SCM_GLOBAL_VAR(static_syntax, l_sym_yields)
#define l_sym_define SCM_GLOBAL_VAR(static_syntax, l_sym_define)
#define l_sym_begin  SCM_GLOBAL_VAR(static_syntax, l_sym_begin)
#define l_syn_lambda SCM_GLOBAL_VAR(static_syntax, l_syn_lambda)
#define l_sym_define_values SCM_GLOBAL_VAR(static_syntax, l_sym_define_values)
#define l_sym_define_syntax SCM_GLOBAL_VAR(static_syntax, l_sym_define_syntax)
#define l_sym_include       SCM_GLOBAL_VAR(static_syntax, l_sym_include)
#define l_sym_include_ci    SCM_GLOBAL_VAR(static_syntax, l_sym_include_ci)
SCM_DEFINE_STATIC_VARS(static_syntax);

/*=======================================
  File Local Function Declarations
=======================================*/
static scm_bool keywordp(ScmObj obj, ScmObj keyword, ScmObj env);
#if SCM_USE_INTERNAL_DEFINITIONS
/* Internal definitions found in a <body>. */
typedef struct {
    ScmObj outer_env;           /* The environment of the <body>. */
    ScmObj env;                 /* OUTER_ENV extended with a frame for the
                                 * definitions if there are definitions. */
    ScmQueue def_expq;          /* Queue of (<formals> . <expression>). */
    scm_int_t n_defs;           /* The number of definitions. */
} body_context;

static void add_internal_variable(body_context *ctx, ScmObj var, ScmObj val);
static void add_internal_definition(body_context *ctx, ScmObj formals,
                                    ScmObj exp);
#if SCM_USE_HYGIENIC_MACRO
static ScmObj lookup_macro(ScmObj op, ScmObj env);
#endif
static ScmObj filter_definitions(body_context *ctx, ScmObj body,
                                 scm_bool followed);
static void set_internal_values(ScmObj frame, ScmObj formals, ScmObj vals);
#endif

/*=======================================
  Function Definitions
=======================================*/
SCM_EXPORT void
scm_init_syntax(void)
{
    SCM_GLOBAL_VARS_INIT(syntax);
    SCM_GLOBAL_VARS_INIT(static_syntax);

    scm_register_funcs(scm_functable_r5rs_syntax);

    scm_sym_quote            = scm_intern("quote");
    scm_sym_quasiquote       = scm_intern("quasiquote");
    scm_sym_unquote          = scm_intern("unquote");
    scm_sym_unquote_splicing = scm_intern("unquote-splicing");
    scm_sym_ellipsis         = scm_intern("...");

    l_sym_else   = scm_intern("else");
    l_sym_yields = scm_intern("=>");
    l_sym_define = scm_intern("define");
#if SCM_USE_INTERNAL_DEFINITIONS
    l_sym_begin  = scm_intern("begin");
#if SCM_USE_R7RS
    l_sym_define_values = scm_intern("define-values");
    l_sym_define_syntax = scm_intern("define-syntax");
    l_sym_include       = scm_intern("include");
    l_sym_include_ci    = scm_intern("include-ci");
#endif
    scm_gc_protect_with_init(&l_syn_lambda,
                             scm_symbol_value(scm_intern("lambda"),
                                              SCM_INTERACTION_ENV));
#endif
}

/*=======================================
  R5RS : 4.1 Primitive expression types
=======================================*/
/*===========================================================================
  R5RS : 4.1 Primitive expression types : 4.1.2 Literal expressions
===========================================================================*/
SCM_EXPORT ScmObj
scm_s_quote(ScmObj datum, ScmObj env SCM_UNUSED)
{
    DECLARE_FUNCTION("quote", syntax_fixed_1);

    return SCM_UNWRAP_SYNTAX(datum);
}

/*===========================================================================
  R5RS : 4.1 Primitive expression types : 4.1.4 Procedures
===========================================================================*/
SCM_EXPORT ScmObj
scm_s_lambda(ScmObj formals, ScmObj body, ScmObj env)
{
    DECLARE_FUNCTION("lambda", syntax_variadic_1);

#if SCM_STRICT_ARGCHECK
    if (SCM_LISTLEN_ERRORP(scm_validate_formals(formals)))
        ERR_OBJ("bad formals", formals);

    /* Keeping variable name unique is user's responsibility. R5RS: "It is an
     * error for a <variable> to appear more than once in <formals>.". */
#else
    /* Crashless no-validation:
     * Regard any non-list object as symbol. Since the lookup operation search
     * for a variable by EQ, this is safe although loosely allows
     * R5RS-incompatible code. */
#endif

    /* Internal definitions-only body such as ((define foo bar)) is
     * invalid. But since checking it here is inefficient, it is deferred to
     * scm_s_body() on being called. */
    if (!CONSP(body))
        ERR_OBJ(ERRMSG_EXPRESSION_REQUIRED, body);

    return MAKE_CLOSURE(CONS(formals, body), env);
}

/*===========================================================================
  R5RS : 4.1 Primitive expression types : 4.1.5 Conditionals
===========================================================================*/
SCM_EXPORT ScmObj
scm_s_if(ScmObj test, ScmObj conseq, ScmObj rest, ScmEvalState *eval_state)
{
    ScmObj env, alt;
    DECLARE_FUNCTION("if", syntax_variadic_tailrec_2);

    env = eval_state->env;

    /*=======================================================================
      (if <test> <consequent>)
      (if <test> <consequent> <alternate>)
    =======================================================================*/

    test = EVAL(test, env);
    CHECK_VALID_EVALED_VALUE(test);
    if (TRUEP(test)) {
#if SCM_STRICT_ARGCHECK
        SAFE_POP(rest);
        ASSERT_NO_MORE_ARG(rest);
#endif
        return conseq;
    } else {
        alt = (CONSP(rest)) ? CAR(rest) : SCM_UNDEF;
#if SCM_STRICT_ARGCHECK
        SAFE_POP(rest);
        ASSERT_NO_MORE_ARG(rest);
#endif
        return alt;
    }
}

/*===========================================================================
  R5RS : 4.1 Primitive expression types : 4.1.6 Assignments
===========================================================================*/
SCM_EXPORT ScmObj
scm_s_setx(ScmObj sym, ScmObj exp, ScmObj env)
{
    ScmObj evaled;
    ScmRef locally_bound;
    DECLARE_FUNCTION("set!", syntax_fixed_2);

    ENSURE_IDENTIFIER(sym);

    evaled = EVAL(exp, env);
    CHECK_VALID_EVALED_VALUE(evaled);
    locally_bound = scm_lookup_environment(sym, env);
    if (locally_bound != SCM_INVALID_REF) {
#if SCM_USE_R7RS
        if (scm_imported_refp(sym, locally_bound, env))
            ERR_OBJ("imported binding can't be mutated",
                    SCM_UNWRAP_KEYWORD(sym));
#endif
        SET(locally_bound, evaled);
    } else {
        if (EQ(scm_toplevel_value(sym, env), SCM_UNBOUND))
            ERR_OBJ("unbound variable", SCM_UNWRAP_KEYWORD(sym));

        scm_set_toplevel(sym, evaled, env);
    }

#if SCM_STRICT_R5RS
    return SCM_UNDEF;
#else
    return evaled;
#endif
}


/*=======================================
  R5RS : 4.2 Derived expression types
=======================================*/
/*===========================================================================
  R5RS : 4.2 Derived expression types : 4.2.1 Conditionals
===========================================================================*/
/* Returns true if OBJ is the auxiliary syntax KEYWORD such as else and =>.
 * An identifier inserted by a macro is also the keyword. A locally bound
 * identifier isn't the keyword:
 *
 *   (let ((=> #f)) (cond (#t => 'ok)))  ==>  ok */
static scm_bool
keywordp(ScmObj obj, ScmObj keyword, ScmObj env)
{
    ScmObj sym;
    ScmRef ref;

    sym = obj;
#if SCM_USE_HYGIENIC_MACRO
    /* Avoid the function call for the common case. */
    if (FARSYMBOLP(sym))
        sym = SCM_UNWRAP_KEYWORD(sym);
#endif
    if (!EQ(sym, keyword))
        return scm_false;
    ref = scm_lookup_environment(obj, env);
#if SCM_USE_R7RS
    /* A library may import the keyword. */
    if (ref != SCM_INVALID_REF
        && ref == scm_module_lookup(scm_builtin_module(), keyword))
        return scm_true;
#endif
    return ref == SCM_INVALID_REF;
}

/* body of 'cond' and 'guard' of SRFI-34 */
SCM_EXPORT ScmObj
scm_s_cond_internal(ScmObj clauses, ScmEvalState *eval_state)
{
    ScmObj env, clause, test, exps, proc;
    DECLARE_INTERNAL_FUNCTION("cond" /* , syntax_variadic_tailrec_0 */);

    env = eval_state->env;
#if SCM_STRICT_TOPLEVEL_DEFINITIONS
    eval_state->nest = SCM_NEST_COMMAND;
#endif

    /*
     * (cond <cond clause>+)
     * (cond <cond clause>* (else <sequence>))
     *
     * <cond clause> --> (<test> <sequence>)
     *       | (<test>)
     *       | (<test> => <recipient>)
     * <recipient> --> <expression>
     * <test> --> <expression>
     * <sequence> --> <command>* <expression>
     * <command> --> <expression>
     */

    if (NO_MORE_ARG(clauses))
        ERR(ERRMSG_CLAUSE_REQUIRED);

    /* looping in each clause */
    FOR_EACH (clause, clauses) {
        if (!CONSP(clause))
            ERR_OBJ("bad clause", clause);

        test = CAR(clause);
        exps = CDR(clause);

#if 0
        test = SCM_UNWRAP_SYNTAX(test);  /* FIXME: needed? */
#endif
        if (keywordp(test, l_sym_else, env)) {
            ASSERT_NO_MORE_ARG(clauses);
            return scm_s_begin(exps, eval_state);
        }
        
        test = EVAL(test, env);
        CHECK_VALID_EVALED_VALUE(test);
        if (TRUEP(test)) {
            /*
             * if the selected <clause> contains only the <test> and no
             * <expression>s, then the value of the <test> is returned as the
             * result.
             */
            if (NULLP(exps)) {
                eval_state->ret_type = SCM_VALTYPE_AS_IS;
                return test;
            }

            /*
             * If the selected <clause> uses the => alternate form, then the
             * <expression> is evaluated. Its value must be a procedure that
             * accepts one argument; this procedure is then called on the value
             * of the <test> and the value returned by this procedure is
             * returned by the cond expression.
             */
            if (LIST_2_P(exps) && keywordp(CAR(exps), l_sym_yields, env)) {
                proc = EVAL(CADR(exps), env);
                if (!PROCEDUREP(proc))
                    ERR_OBJ("exp after => must be a procedure but got", proc);

                /*
                 * R5RS: 3.5 Proper tail recursion
                 *
                 * If a `cond' expression is in a tail context, and has a
                 * clause of the form `(<expression1> => <expression2>)' then
                 * the (implied) call to the procedure that results from the
                 * evaluation of <expression2> is in a tail
                 * context. <expression2> itself is not in a tail context.
                 */
                return LIST_2(proc, LIST_2(SYM_QUOTE, test));
            }

            return scm_s_begin(exps, eval_state);
        }
    }
    ASSERT_NO_MORE_ARG(clauses);

    /*
     * To distinguish unmatched status from SCM_UNDEF from a clause, pure
     * internal value SCM_INVALID is returned. Don't pass it to Scheme world.
     */
    eval_state->ret_type = SCM_VALTYPE_AS_IS;
    return SCM_INVALID;
}

SCM_EXPORT ScmObj
scm_s_cond(ScmObj clauses, ScmEvalState *eval_state)
{
    ScmObj ret;
    DECLARE_FUNCTION("cond", syntax_variadic_tailrec_0);

    ret = scm_s_cond_internal(clauses, eval_state);
    return (VALIDP(ret)) ? ret : SCM_UNDEF;
}

SCM_EXPORT ScmObj
scm_s_case(ScmObj key, ScmObj clauses, ScmEvalState *eval_state)
{
    ScmObj clause, test, exps;
#if SCM_USE_R7RS
    ScmObj proc;
#endif
    DECLARE_FUNCTION("case", syntax_variadic_tailrec_1);

    /*
     * (case <expression>
     *   <case clause>+)
     *
     * (case <expression>
     *   <case clause>*
     *   (else <sequence>))
     *
     * <case clause> --> ((<datum>*) <sequence>)
     * <sequence> --> <command>* <expression>
     * <command> --> <expression>
     * <Datum> is what the read procedure (see section 6.6.2 Input)
     * successfully parses.
     */

    if (NO_MORE_ARG(clauses))
        ERR(ERRMSG_CLAUSE_REQUIRED);

    key = EVAL(key, eval_state->env);
    CHECK_VALID_EVALED_VALUE(key);

    FOR_EACH (clause, clauses) {
        if (!CONSP(clause))
            ERR_OBJ("bad clause", clause);

        test = CAR(clause);
        exps = CDR(clause);

        if (keywordp(test, l_sym_else, eval_state->env))
            ASSERT_NO_MORE_ARG(clauses);
        else
            test = scm_p_memv(key, SCM_UNWRAP_SYNTAX(test));

        if (TRUEP(test)) {
#if SCM_USE_R7RS
            /* R7RS: ((<datum>*) => <expression>) and
             * (else => <expression>) call the procedure with the key. The
             * call is in a tail context like cond. */
            if (LIST_2_P(exps)
                && keywordp(CAR(exps), l_sym_yields, eval_state->env)) {
                proc = EVAL(CADR(exps), eval_state->env);
                if (!PROCEDUREP(proc))
                    ERR_OBJ("exp after => must be a procedure but got", proc);
                return LIST_2(proc, LIST_2(SYM_QUOTE, key));
            }
#endif
#if SCM_STRICT_TOPLEVEL_DEFINITIONS
            eval_state->nest = SCM_NEST_COMMAND;
#endif
            return scm_s_begin(exps, eval_state);
        }
    }
    ASSERT_NO_MORE_ARG(clauses);

    return SCM_UNDEF;
}

SCM_EXPORT ScmObj
scm_s_and(ScmObj args, ScmEvalState *eval_state)
{
    ScmObj expr, val, env;
    DECLARE_FUNCTION("and", syntax_variadic_tailrec_0);

    if (NO_MORE_ARG(args)) {
        eval_state->ret_type = SCM_VALTYPE_AS_IS;
        return SCM_TRUE;
    }
    env = FORBID_TOPLEVEL_DEFINITIONS(eval_state->env);

    FOR_EACH_BUTLAST (expr, args) {
        val = EVAL(expr, env);
        CHECK_VALID_EVALED_VALUE(val);
        if (FALSEP(val)) {
            ASSERT_PROPER_ARG_LIST(args);
            eval_state->ret_type = SCM_VALTYPE_AS_IS;
            return SCM_FALSE;
        }
    }
    ASSERT_NO_MORE_ARG(args);

    return expr;
}

SCM_EXPORT ScmObj
scm_s_or(ScmObj args, ScmEvalState *eval_state)
{
    ScmObj expr, val, env;
    DECLARE_FUNCTION("or", syntax_variadic_tailrec_0);

    if (NO_MORE_ARG(args)) {
        eval_state->ret_type = SCM_VALTYPE_AS_IS;
        return SCM_FALSE;
    }
    env = FORBID_TOPLEVEL_DEFINITIONS(eval_state->env);

    FOR_EACH_BUTLAST (expr, args) {
        val = EVAL(expr, env);
        CHECK_VALID_EVALED_VALUE(val);
        if (TRUEP(val)) {
            ASSERT_PROPER_ARG_LIST(args);
            eval_state->ret_type = SCM_VALTYPE_AS_IS;
            return val;
        }
    }
    ASSERT_NO_MORE_ARG(args);

    return expr;
}

/*===========================================================================
  R5RS : 4.2 Derived expression types : 4.2.2 Binding constructs
===========================================================================*/
SCM_EXPORT ScmObj
scm_s_let(ScmObj bindings, ScmObj body, ScmEvalState *eval_state)
{
    DECLARE_FUNCTION("let", syntax_variadic_tailrec_1);

    return scm_s_let_internal(ScmFirstClassObj, bindings, body, eval_state);
}

SCM_EXPORT ScmObj
scm_s_let_internal(enum ScmObjType permitted, ScmObj bindings, ScmObj body,
                   ScmEvalState *eval_state)
{
    ScmObj env, named_let_sym, proc, binding;
    ScmObj formals, var, actuals, val, exp;
    ScmQueue varq, valq;
    DECLARE_INTERNAL_FUNCTION("let" /* , syntax_variadic_tailrec_1 */);

    env = eval_state->env;
    named_let_sym = SCM_FALSE;

    /*=======================================================================
      normal let:

        (let (<binding spec>*) <body>)

      named let:

        (let <variable> (<binding spec>*) <body>)

      <binding spec> --> (<variable> <expression>)
      <body> --> <definition>* <sequence>
      <definition> --> (define <variable> <expression>)
            | (define (<variable> <def formals>) <body>)
            | (begin <definition>*)
      <sequence> --> <command>* <expression>
      <command> --> <expression>
    =======================================================================*/

    /* named let */
    if (IDENTIFIERP(bindings)) {
        named_let_sym = bindings;

        if (!CONSP(body))
            ERR("invalid named let form");
        bindings = POP(body);
    }

    formals = actuals = SCM_NULL;
    SCM_QUEUE_POINT_TO(varq, formals);
    SCM_QUEUE_POINT_TO(valq, actuals);
    FOR_EACH (binding, bindings) {
        if (!LIST_2_P(binding) || !IDENTIFIERP(var = CAR(binding)))
            ERR_OBJ(ERRMSG_INVALID_BINDING, binding);
#if SCM_STRICT_ARGCHECK
        /* Optional check. Keeping variable name unique is user's
         * responsibility. R5RS: "It is an error for a <variable> to appear
         * more than once in the list of variables being bound." */
        if (TRUEP(scm_p_memq(var, formals)))
            ERR_OBJ(ERRMSG_DUPLICATE_VARNAME, var);
#endif
        exp = CADR(binding);
        val = EVAL(exp, env);
        CHECK_VALID_BINDEE(permitted, val);

        SCM_QUEUE_ADD(varq, var);
        SCM_QUEUE_ADD(valq, val);
    }
    if (!NULLP(bindings))
        ERR_OBJ(ERRMSG_INVALID_BINDINGS, bindings);

    env = scm_extend_environment(formals, actuals, env);

    /* named let */
    if (IDENTIFIERP(named_let_sym)) {
        proc = MAKE_CLOSURE(CONS(formals, body), env);
        env = scm_add_environment(named_let_sym, proc, env);
        SCM_CLOSURE_SET_ENV(proc, env);
    }

    eval_state->env = env;
    return scm_s_body(body, eval_state);
}

SCM_EXPORT ScmObj
scm_s_letstar(ScmObj bindings, ScmObj body, ScmEvalState *eval_state)
{
    ScmObj env, var, val, exp, binding;
    DECLARE_FUNCTION("let*", syntax_variadic_tailrec_1);

    env = eval_state->env;

    /*=======================================================================
      (let* (<binding spec>*) <body>)

      <binding spec> --> (<variable> <expression>)
      <body> --> <definition>* <sequence>
      <definition> --> (define <variable> <expression>)
            | (define (<variable> <def formals>) <body>)
            | (begin <definition>*)
      <sequence> --> <command>* <expression>
      <command> --> <expression>
    =======================================================================*/

    FOR_EACH (binding, bindings) {
        if (!LIST_2_P(binding) || !IDENTIFIERP(var = CAR(binding)))
            ERR_OBJ(ERRMSG_INVALID_BINDING, binding);

        exp = CADR(binding);
        val = EVAL(exp, env);
        CHECK_VALID_EVALED_VALUE(val);

        /* extend env for each variable */
        env = scm_extend_environment(LIST_1(var), LIST_1(val), env);
    }
    if (!NULLP(bindings))
        ERR_OBJ(ERRMSG_INVALID_BINDINGS, bindings);

    eval_state->env = env;
    return scm_s_body(body, eval_state);
}

SCM_EXPORT ScmObj
scm_s_letrec(ScmObj bindings, ScmObj body, ScmEvalState *eval_state)
{
    DECLARE_FUNCTION("letrec", syntax_variadic_tailrec_1);

    return scm_s_letrec_internal(ScmFirstClassObj, bindings, body, eval_state);
}

SCM_EXPORT ScmObj
scm_s_letrec_internal(enum ScmObjType permitted, ScmObj bindings, ScmObj body,
                      ScmEvalState *eval_state)
{
    ScmObj binding, formals, actuals, var, val, exp, env;
    DECLARE_INTERNAL_FUNCTION("letrec" /* , syntax_variadic_tailrec_1 */);

    /*=======================================================================
      (letrec (<binding spec>*) <body>)

      <binding spec> --> (<variable> <expression>)
      <body> --> <definition>* <sequence>
      <definition> --> (define <variable> <expression>)
            | (define (<variable> <def formals>) <body>)
            | (begin <definition>*)
      <sequence> --> <command>* <expression>
      <command> --> <expression>
    =======================================================================*/

    /* extend env by placeholder frame for subsequent lambda evaluations */
    env = scm_extend_environment(SCM_NULL, SCM_NULL, eval_state->env);

    formals = actuals = SCM_NULL;
    FOR_EACH (binding, bindings) {
        if (!LIST_2_P(binding) || !IDENTIFIERP(var = CAR(binding)))
            ERR_OBJ(ERRMSG_INVALID_BINDING, binding);
#if SCM_STRICT_ARGCHECK
        /* Optional check. Keeping variable name unique is user's
         * responsibility. R5RS: "It is an error for a <variable> to appear
         * more than once in the list of variables being bound." */
        if (TRUEP(scm_p_memq(var, formals)))
            ERR_OBJ(ERRMSG_DUPLICATE_VARNAME, var);
#endif
        exp = CADR(binding);
        val = EVAL(exp, env);
        CHECK_VALID_BINDEE(permitted, val);

        /* construct formals and actuals list: any <init> must not refer a
         * <variable> at this time */
        formals = CONS(var, formals);
        actuals = CONS(val, actuals);
    }
    if (!NULLP(bindings))
        ERR_OBJ(ERRMSG_INVALID_BINDINGS, bindings);

    /* fill the placeholder frame */
    eval_state->env = scm_replace_environment(formals, actuals, env);

    return scm_s_body(body, eval_state);
}

/*
 * Valid placement for definitions
 *
 * Definitions on SigScheme is strictly conformed to the three rule specified
 * in R5RS (see below), when SCM_USE_INTERNAL_DEFINITIONS is enabled. All
 * conditions that are not specified by the rules cause syntax error.
 *
 * 5.2 Definitions
 *
 * Definitions are valid in some, but not all, contexts where expressions are
 * allowed. They are valid only at the top level of a <program> and at the
 * beginning of a <body>.
 *
 * 5.2.2 Internal definitions
 *
 * Definitions may occur at the beginning of a <body> (that is, the body of a
 * lambda, let, let*, letrec, let-syntax, or letrec-syntax expression or that
 * of a definition of an appropriate form).
 *
 * Wherever an internal definition may occur (begin <definition1> ...) is
 * equivalent to the sequence of definitions that form the body of the begin.
 *
 * 7.1.6 Programs and definitions
 *
 * <definition> --> (define <variable> <expression>)
 *       | (define (<variable> <def formals>) <body>)
 *       | (begin <definition>*)
 */

#if SCM_USE_INTERNAL_DEFINITIONS
static void
add_internal_variable(body_context *ctx, ScmObj var, ScmObj val)
{
    if (EQ(ctx->env, ctx->outer_env))
        ctx->env = scm_extend_environment(SCM_NULL, SCM_NULL, ctx->env);
    ctx->env = scm_add_environment(var, val, ctx->env);
}

/* Adds the variables of FORMALS whose values are evaluated from EXP later. */
static void
add_internal_definition(body_context *ctx, ScmObj formals, ScmObj exp)
{
    ScmObj vars;

    for (vars = formals; CONSP(vars); vars = CDR(vars))
        add_internal_variable(ctx, CAR(vars), SCM_UNBOUND);
    if (!NULLP(vars))
        add_internal_variable(ctx, vars, SCM_UNBOUND);
    SCM_QUEUE_ADD(ctx->def_expq, CONS(formals, exp));
    ctx->n_defs++;
}

#if SCM_USE_HYGIENIC_MACRO
/* Returns the macro bound to OP or #f. */
static ScmObj
lookup_macro(ScmObj op, ScmObj env)
{
    ScmRef ref;
    ScmObj val;

    if (!IDENTIFIERP(op))
        return SCM_FALSE;
    ref = scm_lookup_environment(op, env);
    if (ref != SCM_INVALID_REF)
        val = DEREF(ref);
    else
        val = scm_toplevel_value(op, env);
    return HMACROP(val) ? val : SCM_FALSE;
}
#endif

/* Collects definitions at the beginning of BODY and returns the rest. Macro
 * uses are expanded to find definitions in them. Keywords are compared
 * without the binding information because they may be inserted by a
 * macro. FOLLOWED is true if forms follow BODY in the enclosing <body>. */
static ScmObj
filter_definitions(body_context *ctx, ScmObj body, scm_bool followed)
{
    ScmObj form, exp, var, sym, begin_rest, lambda_formals, lambda_body;
    scm_int_t n_defs;
#if SCM_USE_HYGIENIC_MACRO
    ScmObj macro;
    ScmEvalState state;
#endif
    DECLARE_INTERNAL_FUNCTION("(body)");

    while (CONSP(body)) {
        form = CAR(body);
        if (!CONSP(form))
            break;
        sym = CAR(form);
#if SCM_USE_HYGIENIC_MACRO
        /* Avoid the function call for the common case. */
        if (FARSYMBOLP(sym))
            sym = SCM_UNWRAP_KEYWORD(sym);
#endif
        exp = CDR(form);
        if (EQ(sym, l_sym_begin)) {
            n_defs = ctx->n_defs;
            begin_rest = filter_definitions(ctx, exp,
                                            followed || CONSP(CDR(body)));
            if (!NULLP(begin_rest)) {
                /* no definitions found */
                if (ctx->n_defs == n_defs)
                    return body;

                ERR_OBJ("definitions and expressions intermixed", form);
            }
            /* '(begin)' is a valid R5RS definition form */
        } else if (EQ(sym, l_sym_define)) {
            var = MUST_POP_ARG(exp);
            if (IDENTIFIERP(var)) {
                /* (define <variable> <expression>) */
                if (!LIST_1_P(exp))
                    ERR_OBJ(ERRMSG_BAD_DEFINE_FORM, form);
                exp = CAR(exp);
            } else if (CONSP(var)) {
                /* (define (<variable> . <formals>) <body>) */
                sym            = CAR(var);
                lambda_formals = CDR(var);
                lambda_body    = exp;

                ENSURE_IDENTIFIER(sym);
                var = sym;
                exp = CONS(l_syn_lambda, CONS(lambda_formals, lambda_body));
            } else {
                ERR_OBJ(ERRMSG_BAD_DEFINE_FORM, form);
            }
            add_internal_definition(ctx, LIST_1(var), exp);
#if SCM_USE_R7RS
        } else if (EQ(sym, l_sym_define_values)) {
            /* (define-values <formals> <expression>) */
            if (!LIST_2_P(exp)
                || SCM_LISTLEN_ERRORP(scm_validate_formals(CAR(exp))))
                ERR_OBJ("bad define-values form", form);
            add_internal_definition(ctx, CAR(exp), CADR(exp));
        } else if (EQ(sym, l_sym_define_syntax)) {
            /* (define-syntax <keyword> <transformer spec>): It's evaluated
             * here because the following forms may use it. */
            if (!LIST_2_P(exp) || !IDENTIFIERP(CAR(exp)))
                ERR_OBJ("bad define-syntax form", form);
            /* Evaluate it in the frame for the definitions. */
            add_internal_variable(ctx, CAR(exp), SCM_UNBOUND);
            macro = EVAL(CADR(exp), ctx->env);
            if (!HMACROP(macro))
                ERR_OBJ("syntax-rules required but got", macro);
            SET(scm_lookup_frame(CAR(exp), CAR(ctx->env)), macro);
            ctx->n_defs++;
        } else if (EQ(sym, l_sym_include) || EQ(sym, l_sym_include_ci)) {
            /* The included forms may be definitions. */
            form = scm_include_forms(exp, EQ(sym, l_sym_include_ci));
            body = CONS(CONS(l_sym_begin, form), CDR(body));
            continue;
#endif
        } else {
#if SCM_USE_HYGIENIC_MACRO
            /* The last form doesn't need to be expanded here because it
             * must be an expression. This avoids the extra lookup for the
             * common <body> that has only one expression. */
            if (!followed && !CONSP(CDR(body)))
                break;
            macro = lookup_macro(CAR(form), ctx->env);
            if (!FALSEP(macro)) {
                /* Examine the expansion again. */
                SCM_EVAL_STATE_INIT1(state, ctx->env);
                body = CONS(scm_expand_macro(macro, exp, &state), CDR(body));
                continue;
            }
#endif
            break;
        }
        body = CDR(body);
    }

    return body;
}
#endif /* SCM_USE_INTERNAL_DEFINITIONS */

/* Returns the values of VAL as a list of the values for each variable of
 * FORMALS. If FORMALS has a rest variable, the last element is the list of the
 * rest values. FORMALS must be valid. */
SCM_EXPORT ScmObj
scm_match_values(const char *func_name, ScmObj formals, ScmObj val)
{
    ScmQueue q;
    ScmObj all_vals, vals, matched;
    DECLARE_INTERNAL_FUNCTION(func_name);

    if (VALUEPACKETP(val)) {
        all_vals = SCM_VALUEPACKET_VALUES(val);
    } else {
        CHECK_VALID_EVALED_VALUE(val);
        all_vals = LIST_1(val);
    }

    vals = all_vals;
    matched = SCM_NULL;
    SCM_QUEUE_POINT_TO(q, matched);
    for (; CONSP(formals); formals = CDR(formals)) {
        if (!CONSP(vals))
            ERR_OBJ(ERRMSG_UNMATCHED_VALUES, all_vals);
        SCM_QUEUE_ADD(q, POP(vals));
    }
    if (NULLP(formals)) {
        if (!NULLP(vals))
            ERR_OBJ(ERRMSG_UNMATCHED_VALUES, all_vals);
    } else {
        SCM_QUEUE_ADD(q, vals);
    }

    return matched;
}

#if SCM_USE_INTERNAL_DEFINITIONS
/* Sets VALS to the variables of FORMALS in FRAME. VALS is a result of
 * scm_match_values(). */
static void
set_internal_values(ScmObj frame, ScmObj formals, ScmObj vals)
{
    for (; CONSP(formals); formals = CDR(formals), vals = CDR(vals))
        SET(scm_lookup_frame(CAR(formals), frame), CAR(vals));
    if (!NULLP(formals))
        SET(scm_lookup_frame(formals, frame), CAR(vals));
}

/* <body> part of let, let*, letrec and lambda. This function performs strict
 * form validation for internal definitions as specified in R5RS ("5.2.2
 * Internal definitions" and "7.1.6 Programs and definitions"). */
/* TODO: Introduce compilation phase and reorganize into compile-time syntax
 * transformer */
SCM_EXPORT ScmObj
scm_s_body(ScmObj body, ScmEvalState *eval_state)
{
    body_context ctx;
    ScmObj env, frame, def_exps, defs, def, vals;
    DECLARE_INTERNAL_FUNCTION("(body)" /* , syntax_variadic_tailrec_0 */);

    if (CONSP(body)) {
        /* collect internal definitions */
        ctx.outer_env = ctx.env = eval_state->env;
        def_exps = SCM_NULL;
        SCM_QUEUE_POINT_TO(ctx.def_expq, def_exps);
        ctx.n_defs = 0;
        body = filter_definitions(&ctx, body, scm_false);

        if (!EQ(ctx.env, ctx.outer_env)) {
            /* eval the definitions and fill the variables with the results.
             * Each definition is (<formals> . <expression>). */
            env = ctx.env;
            frame = CAR(env);
            defs = def_exps;
            FOR_EACH (def, defs) {
                vals = scm_match_values("(body)", CAR(def),
                                        EVAL(CDR(def), env));
#if SCM_USE_R7RS
                /* R7RS: as if letrec* */
                set_internal_values(frame, CAR(def), vals);
#else
                /* R5RS: as if letrec */
                SET_CDR(def, vals);
#endif
            }
#if !SCM_USE_R7RS
            FOR_EACH (def, def_exps)
                set_internal_values(frame, CAR(def), CDR(def));
#endif
            eval_state->env = env;
        }
    }
    /* eval rest of the body */
    return scm_s_begin(body, eval_state);
}
#endif /* SCM_USE_INTERNAL_DEFINITIONS */

/*===========================================================================
  R5RS : 4.2 Derived expression types : 4.2.3 Sequencing
===========================================================================*/
SCM_EXPORT ScmObj
scm_s_begin(ScmObj args, ScmEvalState *eval_state)
{
    ScmObj expr, env;
    DECLARE_FUNCTION("begin", syntax_variadic_tailrec_0);

    if (SCM_DEFINABLE_TOPLEVELP(eval_state)) {
        if (!CONSP(args)) {
            /* '(begin)' */
            ASSERT_NO_MORE_ARG(args);
            eval_state->ret_type = SCM_VALTYPE_AS_IS;
            return SCM_UNDEF;
        }
        env = eval_state->env;
#if SCM_STRICT_TOPLEVEL_DEFINITIONS
        eval_state->nest = SCM_NEST_RETTYPE_BEGIN;
#endif
    } else {
        if (!CONSP(args))
            ERR(ERRMSG_EXPRESSION_REQUIRED);
        env = FORBID_TOPLEVEL_DEFINITIONS(eval_state->env);
    }

    FOR_EACH_BUTLAST (expr, args) {
        expr = EVAL(expr, env);
        CHECK_VALID_EVALED_VALUE(expr);
    }
    ASSERT_NO_MORE_ARG(args);

    return expr;
}

/*===========================================================================
  R5RS : 4.2 Derived expression types : 4.2.4 Iteration
===========================================================================*/
SCM_EXPORT ScmObj
scm_s_do(ScmObj bindings, ScmObj test_exps, ScmObj commands,
         ScmEvalState *eval_state)
{
    ScmQueue stepq;
    ScmObj env, orig_env, rest, rest_commands, val, termp;
    ScmObj formals, actuals, steps;
    ScmObj binding, var, init, step;
    ScmObj test, exps, command;
    DECLARE_FUNCTION("do", syntax_variadic_tailrec_2);

    orig_env = eval_state->env;

    /*
     * (do ((<variable1> <init1> <step1>)
     *      (<variable2> <init2> <step2>)
     *      ...)
     *     (<test> <expression> ...)
     *   <command> ...)
     */

    /* extract bindings ((<variable> <init> <step>) ...) */
    env = FORBID_TOPLEVEL_DEFINITIONS(orig_env);
    formals = actuals = steps = SCM_NULL;
    SCM_QUEUE_POINT_TO(stepq, steps);
    rest = bindings;
    FOR_EACH (binding, rest) {
        if (!CONSP(binding))
            goto err;
        var  = POP(binding);
        ENSURE_SYMBOL(var);
#if SCM_STRICT_ARGCHECK
        /* Optional check. Keeping variable name unique is user's
         * responsibility. R5RS: "It is an error for a <variable> to appear
         * more than once in the list of `do' variables.". */
        if (TRUEP(scm_p_memq(var, formals)))
            ERR_OBJ(ERRMSG_DUPLICATE_VARNAME, var);
#endif

        if (!CONSP(binding))
            goto err;
        init = POP(binding);

        step = (CONSP(binding)) ? POP(binding) : var;
        if (!NULLP(binding))
            goto err;

        init = EVAL(init, env);
        CHECK_VALID_EVALED_VALUE(init);
        formals = CONS(var, formals);
        actuals = CONS(init, actuals);
        SCM_QUEUE_ADD(stepq, step);
    }
    if (!NULLP(rest))
        goto err;

    /* (<test> <expression> ...) */
    if (!CONSP(test_exps))
        ERR_OBJ("invalid test form", test_exps);
    test = CAR(test_exps);
    exps = CDR(test_exps);

    /* iteration phase */
    rest_commands = commands;
    /* extend env by <init>s */
    env = scm_extend_environment(formals, actuals, orig_env);
    while (termp = EVAL(test, env), FALSEP(termp)) {
        rest_commands = commands;
        FOR_EACH (command, rest_commands)
            EVAL(command, env);
        ASSERT_NO_MORE_ARG(rest_commands);

        /* Update variables by <step>s: <step>s evaluation must be isolated
         * from the env for the next iteration. */
        actuals = SCM_NULL;
        rest = steps;
        FOR_EACH (step, rest) {
            val = EVAL(step, env);
            CHECK_VALID_EVALED_VALUE(val);
            actuals = CONS(val, actuals);
        }
        /* the envs for each iteration must be isolated and not be
         * overwritten */
        env = scm_extend_environment(formals, actuals, orig_env);
    }
#if SCM_STRICT_ARGCHECK
    /* no iteration occurred */
    if (rest_commands == commands)
        ENSURE_PROPER_ARG_LIST(commands);
#endif

    /* R5RS: If no <expression>s are present, then the value of the `do'
     * expression is unspecified. */
    eval_state->env = env;
    if (NULLP(exps)) {
        eval_state->ret_type = SCM_VALTYPE_AS_IS;
        return SCM_UNDEF;
    } else {
#if SCM_STRICT_TOPLEVEL_DEFINITIONS
        eval_state->nest = SCM_NEST_COMMAND;
#endif
        return scm_s_begin(exps, eval_state);
    }

 err:
    ERR_OBJ(ERRMSG_INVALID_BINDINGS, bindings);
    /* NOTREACHED */
    return SCM_FALSE;
}

/*=======================================
  R5RS : 5.2 Definitions
=======================================*/
SCM_EXPORT void
scm_s_define_internal(enum ScmObjType permitted,
                      ScmObj var, ScmObj exp, ScmObj env)
{
    ScmObj val;
    DECLARE_INTERNAL_FUNCTION("define");

#if SCM_USE_HYGIENIC_MACRO
    SCM_ASSERT(SYMBOLP(var) || SYMBOLP(SCM_FARSYMBOL_SYM(var)));
#else
    SCM_ASSERT(SYMBOLP(var));
#endif
    var = SCM_UNWRAP_KEYWORD(var);
    val = EVAL(exp, env);
    CHECK_VALID_BINDEE(permitted, val);

    scm_define_toplevel(var, val, env);
}

/* To test ScmNestState, scm_s_define() needs eval_state although this is not a
 * tail-recursive syntax */
SCM_EXPORT ScmObj
scm_s_define(ScmObj var, ScmObj rest, ScmEvalState *eval_state)
{
    ScmObj procname, body, formals, proc, env;
    DECLARE_FUNCTION("define", syntax_variadic_tailrec_1);

    /* internal definitions are handled as a virtual letrec in
     * scm_s_body() */
    if (!SCM_DEFINABLE_TOPLEVELP(eval_state)) {
#if SCM_STRICT_TOPLEVEL_DEFINITIONS
        if (scm_toplevel_environmentp(eval_state->env))
            ERR_OBJ("toplevel definition is not allowed here", var);
        else
#endif
            ERR_OBJ(ERRMSG_BAD_DEFINE_PLACEMENT, var);
    }
    env = eval_state->env;

    /*=======================================================================
      (define <variable> <expression>)
    =======================================================================*/
    if (IDENTIFIERP(var)) {
        if (!LIST_1_P(rest))
            goto err;

        scm_s_define_internal(ScmFirstClassObj, var, CAR(rest), env);
    }

    /*=======================================================================
      (define (<variable> . <formals>) <body>)

      => (define <variable>
             (lambda <formals> <body>))
    =======================================================================*/
    else if (CONSP(var)) {
        procname = CAR(var);
        formals  = CDR(var);
        body     = rest;

        ENSURE_IDENTIFIER(procname);
        proc = scm_s_lambda(formals, body, env);
        scm_s_define_internal(ScmFirstClassObj, procname, proc, env);
    } else {
        goto err;
    }

    eval_state->ret_type = SCM_VALTYPE_AS_IS;
#if SCM_STRICT_R5RS
    return SCM_UNDEF;
#else
    return var;
#endif

 err:
    ERR_OBJ(ERRMSG_BAD_DEFINE_FORM,
            CONS(l_sym_define, CONS(var, rest)));
    /* NOTREACHED */
    return SCM_FALSE;
}
