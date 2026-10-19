/*===========================================================================
 *  Filename : r7rs.c
 *  About    : R7RS procedures (preliminary)
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

#if SCM_USE_REAL
#include <math.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <time.h>

#include <sigscheme/sigscheme.h>
#include "sigschemeinternal.h"
#include "scmport-config.h"
#include "scmport.h"
#include "scmport-file.h"
#include "scmport-sbchar.h"
#include "scmport-str.h"

/*=======================================
  File Local Macro Definitions
=======================================*/
#define BOOLEANP(o)       (EQ((o), SCM_FALSE) || EQ((o), SCM_TRUE))
#define ENSURE_BOOLEAN(o) ENSURE_TYPE(BOOLEANP, "boolean", (o))
#define BINARY_PORTP(o)                                                      \
    (PORTP(o) && (SCM_PORT_FLAG(o) & SCM_PORTFLAG_BINARY))
#define ENSURE_BINARY_PORT(o) ENSURE_TYPE(BINARY_PORTP, "binary port", (o))

/*=======================================
  File Local Type Definitions
=======================================*/
typedef scm_ichar_t (*case_converter)(scm_ichar_t ch);
typedef ScmObj (*comparator)(ScmObj obj1, ScmObj obj2);

/*=======================================
  Variable Definitions
=======================================*/
#include "functable-r7rs.c"

/* POSIX doesn't declare it in any header. */
extern char **environ;

SCM_GLOBAL_VARS_BEGIN(static_r7rs);
#define static
static const char *const *l_command_line;
static time_t l_jiffy_epoch;
#undef static
SCM_GLOBAL_VARS_END(static_r7rs);
#define l_command_line SCM_GLOBAL_VAR(static_r7rs, l_command_line)
#define l_jiffy_epoch  SCM_GLOBAL_VAR(static_r7rs, l_jiffy_epoch)
SCM_DEFINE_STATIC_VARS(static_r7rs);

/*=======================================
  File Local Function Declarations
=======================================*/
static scm_ichar_t upcase(scm_ichar_t ch);
static scm_ichar_t downcase(scm_ichar_t ch);
static scm_ichar_t foldcase(scm_ichar_t ch);
static ScmObj convert_string_case(ScmObj str, case_converter convert);
static ScmObj vector_to_list(ScmObj vec, scm_int_t start, scm_int_t end);
static ScmObj compare_all(comparator compare,
                          ScmObj obj1, ScmObj obj2, ScmObj rest);
static ScmObj read_chars(ScmObj port, scm_int_t n, scm_ichar_t end_ch);
static ScmObj make_binary_port(ScmBytePort *bport, enum ScmPortFlag flag);
static ScmObj prepare_binary_port(const char *func_name, ScmObj args,
                                  ScmObj default_port);
static ScmBytePort *binary_port_byte_port(ScmObj port);
static ScmObj map_sequences(const char *func_name, ScmObj proc, ScmObj seqs,
                            scm_bool vectorp, scm_bool collect);
static ScmObj bind_values(const char *func_name, ScmObj bindings,
                          scm_bool sequential, ScmObj env);
static ScmObj dispatch_case_lambda(ScmObj clauses, ScmObj args,
                                   ScmEvalState *eval_state);
static ScmObj make_thunk(ScmObj func, ScmObj data, ScmObj env);
static ScmObj parameter_value(ScmObj data);
static ScmObj parameter_data(ScmObj obj);
static ScmObj swap_parameter_values(ScmObj bindings);

/*=======================================
  Function Definitions
=======================================*/
SCM_EXPORT void
scm_init_r7rs(void)
{
    struct timeval now;

    SCM_GLOBAL_VARS_INIT(static_r7rs);

    scm_register_funcs(scm_functable_r7rs);

    gettimeofday(&now, NULL);
    l_jiffy_epoch = now.tv_sec;
}

/* ARGV is the arguments after the options of sscm. The first one is the
 * script name. */
SCM_EXPORT void
scm_set_command_line(const char *const *argv)
{
    l_command_line = argv;
}

/*===========================================================================
  R7RS : 4.2 Derived expression types : 4.2.1 Conditionals
===========================================================================*/
/* Evaluates BODY when TEST is EXPECTED. */
static ScmObj
eval_body_when(const char *func_name, ScmObj test, ScmObj body,
               scm_bool expected, ScmEvalState *eval_state)
{
    ScmObj expr, env;
    DECLARE_INTERNAL_FUNCTION(func_name);

    env = eval_state->env;
    test = EVAL(test, env);
    CHECK_VALID_EVALED_VALUE(test);
    if (TRUEP(test) != expected) {
        eval_state->ret_type = SCM_VALTYPE_AS_IS;
        return SCM_UNDEF;
    }

    if (!CONSP(body))
        ERR_OBJ("at least 1 expression required", body);
    FOR_EACH_BUTLAST (expr, body) {
        expr = EVAL(expr, env);
        CHECK_VALID_EVALED_VALUE(expr);
    }
    ASSERT_NO_MORE_ARG(body);

    return expr;
}

SCM_EXPORT ScmObj
scm_s_when(ScmObj test, ScmObj body, ScmEvalState *eval_state)
{
    DECLARE_FUNCTION("when", syntax_variadic_tailrec_1);

    return eval_body_when(SCM_MANGLE(name), test, body, scm_true, eval_state);
}

SCM_EXPORT ScmObj
scm_s_unless(ScmObj test, ScmObj body, ScmEvalState *eval_state)
{
    DECLARE_FUNCTION("unless", syntax_variadic_tailrec_1);

    return eval_body_when(SCM_MANGLE(name), test, body, scm_false,
                          eval_state);
}

/*===========================================================================
  R7RS : 4.2 Derived expression types : 4.2.2 Binding constructs
===========================================================================*/
/* Each <init> is evaluated after the preceding variables are bound. */
SCM_EXPORT ScmObj
scm_s_letrec_star(ScmObj bindings, ScmObj body, ScmEvalState *eval_state)
{
    ScmObj binding, var, val, env;
    DECLARE_FUNCTION("letrec*", syntax_variadic_tailrec_1);

    env = scm_extend_environment(SCM_NULL, SCM_NULL, eval_state->env);
    FOR_EACH (binding, bindings) {
        if (!LIST_2_P(binding) || !IDENTIFIERP(var = CAR(binding)))
            ERR_OBJ("invalid binding form", binding);
        val = EVAL(CADR(binding), env);
        CHECK_VALID_EVALED_VALUE(val);
        env = scm_add_environment(var, val, env);
    }
    if (!NULLP(bindings))
        ERR_OBJ("invalid bindings form", bindings);

    eval_state->env = env;

    return scm_s_body(body, eval_state);
}

/* Binds the formals of each binding in BINDINGS to the values of its <init>
 * in a new frame. If SEQUENTIAL is true, each <init> is evaluated after the
 * preceding formals are bound. Otherwise, all <init>s are evaluated in ENV. */
static ScmObj
bind_values(const char *func_name, ScmObj bindings, scm_bool sequential,
            ScmObj env)
{
    ScmObj binding, formals, vals, new_env;
    DECLARE_INTERNAL_FUNCTION(func_name);

    new_env = env;
    FOR_EACH (binding, bindings) {
        if (!LIST_2_P(binding)
            || SCM_LISTLEN_ERRORP(scm_validate_formals(CAR(binding))))
            ERR_OBJ("invalid binding form", binding);
        formals = CAR(binding);
        vals = scm_match_values(func_name, formals,
                                EVAL(CADR(binding),
                                     sequential ? new_env : env));
        new_env = scm_extend_environment(SCM_NULL, SCM_NULL, new_env);
        for (; CONSP(formals); formals = CDR(formals))
            new_env = scm_add_environment(CAR(formals), POP(vals), new_env);
        if (!NULLP(formals))
            new_env = scm_add_environment(formals, CAR(vals), new_env);
    }
    if (!NULLP(bindings))
        ERR_OBJ("invalid bindings form", bindings);

    return new_env;
}

SCM_EXPORT ScmObj
scm_s_let_values(ScmObj bindings, ScmObj body, ScmEvalState *eval_state)
{
    DECLARE_FUNCTION("let-values", syntax_variadic_tailrec_1);

    eval_state->env = bind_values("let-values", bindings, scm_false,
                                  eval_state->env);

    return scm_s_body(body, eval_state);
}

SCM_EXPORT ScmObj
scm_s_let_star_values(ScmObj bindings, ScmObj body, ScmEvalState *eval_state)
{
    DECLARE_FUNCTION("let*-values", syntax_variadic_tailrec_1);

    eval_state->env = bind_values("let*-values", bindings, scm_true,
                                  eval_state->env);

    return scm_s_body(body, eval_state);
}

/*===========================================================================
  R7RS : 4.2 Derived expression types : 4.2.9 Case-lambda
===========================================================================*/
/* Applies the first closure in the vector CLAUSES that accepts ARGS. */
static ScmObj
dispatch_case_lambda(ScmObj clauses, ScmObj args, ScmEvalState *eval_state)
{
    ScmObj clause;
    scm_int_t i, args_len;
    DECLARE_INTERNAL_FUNCTION("case-lambda");

    args_len = scm_length(args);
    for (i = 0; i < SCM_VECTOR_LEN(clauses); i++) {
        clause = SCM_VECTOR_VEC(clauses)[i];
        if (scm_valid_environment_extension_lengthp(
                scm_length(CAR(SCM_CLOSURE_EXP(clause))), args_len))
            return scm_p_apply(clause, args, SCM_NULL, eval_state);
    }
    ERR_OBJ("no clause matches the arguments", args);
    /* NOTREACHED */
    return SCM_FALSE;
}

SCM_EXPORT ScmObj
scm_s_case_lambda(ScmObj clauses, ScmObj env)
{
    ScmQueue q;
    ScmObj clause, closures, dispatch, args;
    DECLARE_FUNCTION("case-lambda", syntax_variadic_0);

    closures = SCM_NULL;
    SCM_QUEUE_POINT_TO(q, closures);
    FOR_EACH (clause, clauses) {
        if (!CONSP(clause))
            ERR_OBJ("invalid clause", clause);
        SCM_QUEUE_ADD(q, scm_s_lambda(CAR(clause), CDR(clause), env));
    }
    if (!NULLP(clauses))
        ERR_OBJ("invalid clauses", clauses);

    /* (lambda args (DISPATCH #(CLOSURE ...) args)). DISPATCH and the vector
     * are evaluated to themselves. A vector is self-evaluating because R7RS
     * conflicts with strict_vector_form. */
    dispatch = MAKE_FUNC(SCM_PROCEDURE_FIXED_TAILREC_2,
                         (ScmFuncType)dispatch_case_lambda);
    args = scm_intern("args");
    return MAKE_CLOSURE(LIST_2(args,
                               LIST_3(dispatch,
                                      scm_p_list2vector(closures),
                                      args)),
                        env);
}

/*===========================================================================
  R7RS : 4.2 Derived expression types : 4.2.6 Dynamic bindings
===========================================================================*/
/* Returns (lambda () (FUNC DATA)). FUNC and DATA must be evaluated to
 * themselves. */
static ScmObj
make_thunk(ScmObj func, ScmObj data, ScmObj env)
{
    return MAKE_CLOSURE(LIST_2(SCM_NULL, LIST_2(func, data)), env);
}

/* A parameter object is (lambda () (parameter_value DATA)). DATA is
 * #(VALUE CONVERTER). */
static ScmObj
parameter_value(ScmObj data)
{
    return SCM_VECTOR_VEC(data)[0];
}

/* Returns DATA of the parameter object OBJ or #f if OBJ isn't a parameter
 * object. */
static ScmObj
parameter_data(ScmObj obj)
{
    ScmObj body;

    if (!CLOSUREP(obj))
        return SCM_FALSE;
    body = CDR(SCM_CLOSURE_EXP(obj));
    if (!LIST_1_P(body) || !LIST_2_P(CAR(body)) || !FUNCP(CAAR(body))
        || SCM_FUNC_CFUNC(CAAR(body)) != (ScmFuncType)parameter_value)
        return SCM_FALSE;
    return CADR(CAR(body));
}

SCM_EXPORT ScmObj
scm_p_make_parameter(ScmObj value, ScmObj args)
{
    ScmObj converter, func;
    DECLARE_FUNCTION("make-parameter", procedure_variadic_1);

    if (NULLP(args)) {
        converter = SCM_FALSE;
    } else {
        converter = POP(args);
        ASSERT_NO_MORE_ARG(args);
        ENSURE_PROCEDURE(converter);
        value = scm_call(converter, LIST_1(value));
    }

    func = MAKE_FUNC(SCM_PROCEDURE_FIXED_1, (ScmFuncType)parameter_value);
    return make_thunk(func, scm_p_list2vector(LIST_2(value, converter)),
                      SCM_INTERACTION_ENV);
}

/* BINDINGS is #((DATA . VALUE) ...). Swaps the value of each parameter
 * object and VALUE. So calling this twice restores the values. */
static ScmObj
swap_parameter_values(ScmObj bindings)
{
    ScmObj binding, *value, tmp;
    scm_int_t i;

    for (i = 0; i < SCM_VECTOR_LEN(bindings); i++) {
        binding = SCM_VECTOR_VEC(bindings)[i];
        value = &SCM_VECTOR_VEC(CAR(binding))[0];
        tmp = *value;
        *value = CDR(binding);
        SET_CDR(binding, tmp);
    }
    return SCM_UNDEF;
}

SCM_EXPORT ScmObj
scm_s_parameterize(ScmObj bindings, ScmObj body, ScmObj env)
{
    ScmQueue q;
    ScmObj binding, data, value, converter, swaps, swap;
    DECLARE_FUNCTION("parameterize", syntax_variadic_1);

    swaps = SCM_NULL;
    SCM_QUEUE_POINT_TO(q, swaps);
    FOR_EACH (binding, bindings) {
        if (!LIST_2_P(binding))
            ERR_OBJ("invalid binding form", binding);
        data = parameter_data(EVAL(CAR(binding), env));
        if (FALSEP(data))
            ERR_OBJ("parameter object required but got", CAR(binding));
        value = EVAL(CADR(binding), env);
        CHECK_VALID_EVALED_VALUE(value);
        converter = SCM_VECTOR_VEC(data)[1];
        if (!FALSEP(converter))
            value = scm_call(converter, LIST_1(value));
        SCM_QUEUE_ADD(q, CONS(data, value));
    }
    if (!NULLP(bindings))
        ERR_OBJ("invalid bindings form", bindings);

    swap = make_thunk(MAKE_FUNC(SCM_PROCEDURE_FIXED_1,
                                (ScmFuncType)swap_parameter_values),
                      scm_p_list2vector(swaps), env);
    return scm_dynamic_wind(swap, scm_s_lambda(SCM_NULL, body, env), swap);
}

/*===========================================================================
  R7RS : 4.2 Derived expression types : 4.2.5 Delayed evaluation
===========================================================================*/
SCM_EXPORT ScmObj
scm_s_delay_force(ScmObj exp, ScmObj env)
{
    DECLARE_FUNCTION("delay-force", syntax_fixed_1);

    return scm_make_delay_force_promise(scm_s_lambda(SCM_NULL, LIST_1(exp),
                                                     env));
}

SCM_EXPORT ScmObj
scm_p_make_promise(ScmObj obj)
{
    DECLARE_FUNCTION("make-promise", procedure_fixed_1);

    return scm_promisep(obj) ? obj : scm_make_forced_promise(obj);
}

SCM_EXPORT ScmObj
scm_p_promisep(ScmObj obj)
{
    DECLARE_FUNCTION("promise?", procedure_fixed_1);

    return MAKE_BOOL(scm_promisep(obj));
}

/*===========================================================================
  R7RS : 4.3 Macros : 4.3.3 Signaling errors in macro transformers
===========================================================================*/
/* Macros are expanded when they are evaluated. So it's signaled when the
 * expansion is evaluated. ARGS aren't evaluated. */
SCM_EXPORT ScmObj
scm_s_syntax_error(ScmObj message, ScmObj args, ScmObj env)
{
    DECLARE_FUNCTION("syntax-error", syntax_variadic_1);

    ENSURE_STRING(message);

    return scm_p_srfi23_error(message, args);
}

/*===========================================================================
  R7RS : 5.3 Variable definitions : 5.3.3 Multiple-value definitions
===========================================================================*/
/* Internal definitions are handled in scm_s_body(). */
SCM_EXPORT ScmObj
scm_s_define_values(ScmObj formals, ScmObj exp, ScmEvalState *eval_state)
{
    ScmObj vals, var;
    DECLARE_FUNCTION("define-values", syntax_fixed_tailrec_2);

    if (!SCM_DEFINABLE_TOPLEVELP(eval_state))
        ERR_OBJ("define-values is not allowed here", formals);
    if (SCM_LISTLEN_ERRORP(scm_validate_formals(formals)))
        ERR_OBJ("bad formals", formals);

    vals = scm_match_values("define-values", formals,
                            EVAL(exp, eval_state->env));
    for (; CONSP(formals); formals = CDR(formals)) {
        var = SCM_UNWRAP_KEYWORD(CAR(formals));
        SCM_SYMBOL_SET_VCELL(var, POP(vals));
    }
    if (!NULLP(formals))
        SCM_SYMBOL_SET_VCELL(SCM_UNWRAP_KEYWORD(formals), CAR(vals));

    eval_state->ret_type = SCM_VALTYPE_AS_IS;
    return SCM_UNDEF;
}

/*===========================================================================
  R7RS : 6.2 Numbers
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_exact_integerp(ScmObj obj)
{
    DECLARE_FUNCTION("exact-integer?", procedure_fixed_1);

    return MAKE_BOOL(INTP(obj));
}

SCM_EXPORT ScmObj
scm_p_finitep(ScmObj z)
{
    DECLARE_FUNCTION("finite?", procedure_fixed_1);

    ENSURE_NUMBER(z);

#if SCM_USE_REAL
    if (REALP(z))
        return MAKE_BOOL(isfinite(SCM_REAL_VALUE(z)));
#endif
    return SCM_TRUE;
}

SCM_EXPORT ScmObj
scm_p_infinitep(ScmObj z)
{
    DECLARE_FUNCTION("infinite?", procedure_fixed_1);

    ENSURE_NUMBER(z);

#if SCM_USE_REAL
    if (REALP(z))
        return MAKE_BOOL(isinf(SCM_REAL_VALUE(z)));
#endif
    return SCM_FALSE;
}

SCM_EXPORT ScmObj
scm_p_nanp(ScmObj z)
{
    DECLARE_FUNCTION("nan?", procedure_fixed_1);

    ENSURE_NUMBER(z);

#if SCM_USE_REAL
    if (REALP(z))
        return MAKE_BOOL(isnan(SCM_REAL_VALUE(z)));
#endif
    return SCM_FALSE;
}

SCM_EXPORT ScmObj
scm_p_floor_slash(ScmObj n1, ScmObj n2)
{
    DECLARE_FUNCTION("floor/", procedure_fixed_2);

    return scm_p_values(
        LIST_2(scm_integer_divide(SCM_MANGLE(name), n1, n2, 'f'),
               scm_integer_divide(SCM_MANGLE(name), n1, n2, 'm')));
}

SCM_EXPORT ScmObj
scm_p_floor_quotient(ScmObj n1, ScmObj n2)
{
    DECLARE_FUNCTION("floor-quotient", procedure_fixed_2);

    return scm_integer_divide(SCM_MANGLE(name), n1, n2, 'f');
}

SCM_EXPORT ScmObj
scm_p_floor_remainder(ScmObj n1, ScmObj n2)
{
    DECLARE_FUNCTION("floor-remainder", procedure_fixed_2);

    return scm_integer_divide(SCM_MANGLE(name), n1, n2, 'm');
}

SCM_EXPORT ScmObj
scm_p_truncate_slash(ScmObj n1, ScmObj n2)
{
    DECLARE_FUNCTION("truncate/", procedure_fixed_2);

    return scm_p_values(
        LIST_2(scm_integer_divide(SCM_MANGLE(name), n1, n2, 'q'),
               scm_integer_divide(SCM_MANGLE(name), n1, n2, 'r')));
}

SCM_EXPORT ScmObj
scm_p_truncate_quotient(ScmObj n1, ScmObj n2)
{
    DECLARE_FUNCTION("truncate-quotient", procedure_fixed_2);

    return scm_integer_divide(SCM_MANGLE(name), n1, n2, 'q');
}

SCM_EXPORT ScmObj
scm_p_truncate_remainder(ScmObj n1, ScmObj n2)
{
    DECLARE_FUNCTION("truncate-remainder", procedure_fixed_2);

    return scm_integer_divide(SCM_MANGLE(name), n1, n2, 'r');
}

SCM_EXPORT ScmObj
scm_p_square(ScmObj z)
{
    DECLARE_FUNCTION("square", procedure_fixed_1);

#if SCM_USE_REAL
    if (REALP(z))
        return MAKE_REAL(SCM_REAL_VALUE(z) * SCM_REAL_VALUE(z));
#endif
    ENSURE_INT(z);

    return MAKE_INT(scm_int_multiply(SCM_MANGLE(name),
                                     SCM_INT_VALUE(z), SCM_INT_VALUE(z)));
}

/* Returns the largest s that satisfies s * s <= k and k - s * s. */
SCM_EXPORT ScmObj
scm_p_exact_integer_sqrt(ScmObj k)
{
    scm_int_t n, root, next;
    DECLARE_FUNCTION("exact-integer-sqrt", procedure_fixed_1);

    ENSURE_INT(k);
    n = SCM_INT_VALUE(k);
    if (n < 0)
        ERR_OBJ("non-negative integer required but got", k);

    /* Newton's method. The first next is (n + n / n) / 2 without
     * overflow. */
    root = n;
    if (1 < n) {
        next = n / 2 + n % 2;
        while (next < root) {
            root = next;
            next = (root + n / root) / 2;
        }
    }

    return scm_p_values(LIST_2(MAKE_INT(root), MAKE_INT(n - root * root)));
}

SCM_EXPORT ScmObj
scm_p_exact(ScmObj z)
{
    DECLARE_FUNCTION("exact", procedure_fixed_1);

    return scm_exact(SCM_MANGLE(name), z);
}

SCM_EXPORT ScmObj
scm_p_inexact(ScmObj z)
{
    DECLARE_FUNCTION("inexact", procedure_fixed_1);

    return scm_inexact(SCM_MANGLE(name), z);
}

/*===========================================================================
  R7RS : 6.3 Booleans
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_boolean_equalp(ScmObj boolean1, ScmObj boolean2, ScmObj rest)
{
    ScmObj boolean;
    scm_bool equalp;
    DECLARE_FUNCTION("boolean=?", procedure_variadic_2);

    ENSURE_BOOLEAN(boolean1);
    ENSURE_BOOLEAN(boolean2);
    equalp = EQ(boolean1, boolean2);
    FOR_EACH (boolean, rest) {
        ENSURE_BOOLEAN(boolean);
        if (!EQ(boolean, boolean1))
            equalp = scm_false;
    }

    return MAKE_BOOL(equalp);
}

/*===========================================================================
  R7RS : 6.4 Pairs and lists
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_make_list(ScmObj k, ScmObj args)
{
    ScmObj fill, lst;
    scm_int_t len;
    DECLARE_FUNCTION("make-list", procedure_variadic_1);

    ENSURE_INT(k);
    len = SCM_INT_VALUE(k);
    if (len < 0)
        ERR_OBJ("non-negative integer required but got", k);
    fill = NULLP(args) ? SCM_UNDEF : POP(args);
    ASSERT_NO_MORE_ARG(args);

    lst = SCM_NULL;
    while (len--)
        lst = CONS(fill, lst);

    return lst;
}

SCM_EXPORT ScmObj
scm_p_list_setx(ScmObj lst, ScmObj k, ScmObj obj)
{
    ScmObj pair;
    scm_int_t i;
    DECLARE_FUNCTION("list-set!", procedure_fixed_3);

    ENSURE_INT(k);
    i = SCM_INT_VALUE(k);
    if (i < 0)
        ERR_OBJ("index out of range", k);
    for (pair = lst; i && CONSP(pair); i--)
        pair = CDR(pair);
    if (!CONSP(pair))
        ERR_OBJ("index out of range", k);
    SET_CAR(pair, obj);

    return SCM_UNDEF;
}

/* Copies the pairs of OBJ. The last cdr of an improper list is kept.
 * OBJ is returned as is if it isn't a pair. */
SCM_EXPORT ScmObj
scm_p_list_copy(ScmObj obj)
{
    ScmQueue q;
    ScmObj copy, rest;
    DECLARE_FUNCTION("list-copy", procedure_fixed_1);

    copy = SCM_NULL;
    SCM_QUEUE_POINT_TO(q, copy);
    for (rest = obj; CONSP(rest); rest = CDR(rest))
        SCM_QUEUE_ADD(q, CAR(rest));
    SCM_QUEUE_SLOPPY_APPEND(q, rest);

    return copy;
}

/* Overrides R5RS member to support COMPARE. */
SCM_EXPORT ScmObj
scm_p_r7rs_member(ScmObj obj, ScmObj lst, ScmObj args)
{
    ScmObj compare, rest;
    DECLARE_FUNCTION("member", procedure_variadic_2);

    if (NULLP(args))
        return scm_p_member(obj, lst);

    compare = POP(args);
    ASSERT_NO_MORE_ARG(args);
    ENSURE_PROCEDURE(compare);
    for (rest = lst; CONSP(rest); rest = CDR(rest)) {
        if (TRUEP(scm_call(compare, LIST_2(obj, CAR(rest)))))
            return rest;
    }
    CHECK_PROPER_LIST_TERMINATION(rest, lst);

    return SCM_FALSE;
}

/* Overrides R5RS assoc to support COMPARE. */
SCM_EXPORT ScmObj
scm_p_r7rs_assoc(ScmObj obj, ScmObj alist, ScmObj args)
{
    ScmObj compare, rest, pair;
    DECLARE_FUNCTION("assoc", procedure_variadic_2);

    if (NULLP(args))
        return scm_p_assoc(obj, alist);

    compare = POP(args);
    ASSERT_NO_MORE_ARG(args);
    ENSURE_PROCEDURE(compare);
    for (rest = alist; CONSP(rest); rest = CDR(rest)) {
        pair = CAR(rest);
        ENSURE_CONS(pair);
        if (TRUEP(scm_call(compare, LIST_2(obj, CAR(pair)))))
            return pair;
    }
    CHECK_PROPER_LIST_TERMINATION(rest, alist);

    return SCM_FALSE;
}

/*===========================================================================
  R7RS : 6.5 Symbols
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_symbol_equalp(ScmObj symbol1, ScmObj symbol2, ScmObj rest)
{
    ScmObj symbol;
    scm_bool equalp;
    DECLARE_FUNCTION("symbol=?", procedure_variadic_2);

    ENSURE_SYMBOL(symbol1);
    ENSURE_SYMBOL(symbol2);
    equalp = EQ(symbol1, symbol2);
    FOR_EACH (symbol, rest) {
        ENSURE_SYMBOL(symbol);
        if (!EQ(symbol, symbol1))
            equalp = scm_false;
    }

    return MAKE_BOOL(equalp);
}

/*===========================================================================
  R7RS : 6.6 Characters
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_r7rs_char_equalp(ScmObj ch1, ScmObj ch2, ScmObj rest)
{
    DECLARE_FUNCTION("char=?", procedure_variadic_2);

    return compare_all(scm_p_char_equalp, ch1, ch2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_char_lessp(ScmObj ch1, ScmObj ch2, ScmObj rest)
{
    DECLARE_FUNCTION("char<?", procedure_variadic_2);

    return compare_all(scm_p_char_lessp, ch1, ch2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_char_greaterp(ScmObj ch1, ScmObj ch2, ScmObj rest)
{
    DECLARE_FUNCTION("char>?", procedure_variadic_2);

    return compare_all(scm_p_char_greaterp, ch1, ch2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_char_less_equalp(ScmObj ch1, ScmObj ch2, ScmObj rest)
{
    DECLARE_FUNCTION("char<=?", procedure_variadic_2);

    return compare_all(scm_p_char_less_equalp, ch1, ch2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_char_greater_equalp(ScmObj ch1, ScmObj ch2, ScmObj rest)
{
    DECLARE_FUNCTION("char>=?", procedure_variadic_2);

    return compare_all(scm_p_char_greater_equalp, ch1, ch2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_char_ci_equalp(ScmObj ch1, ScmObj ch2, ScmObj rest)
{
    DECLARE_FUNCTION("char-ci=?", procedure_variadic_2);

    return compare_all(scm_p_char_ci_equalp, ch1, ch2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_char_ci_lessp(ScmObj ch1, ScmObj ch2, ScmObj rest)
{
    DECLARE_FUNCTION("char-ci<?", procedure_variadic_2);

    return compare_all(scm_p_char_ci_lessp, ch1, ch2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_char_ci_greaterp(ScmObj ch1, ScmObj ch2, ScmObj rest)
{
    DECLARE_FUNCTION("char-ci>?", procedure_variadic_2);

    return compare_all(scm_p_char_ci_greaterp, ch1, ch2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_char_ci_less_equalp(ScmObj ch1, ScmObj ch2, ScmObj rest)
{
    DECLARE_FUNCTION("char-ci<=?", procedure_variadic_2);

    return compare_all(scm_p_char_ci_less_equalp, ch1, ch2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_char_ci_greater_equalp(ScmObj ch1, ScmObj ch2, ScmObj rest)
{
    DECLARE_FUNCTION("char-ci>=?", procedure_variadic_2);

    return compare_all(scm_p_char_ci_greater_equalp, ch1, ch2, rest);
}

SCM_EXPORT ScmObj
scm_p_digit_value(ScmObj ch)
{
    scm_ichar_t val;
    DECLARE_FUNCTION("digit-value", procedure_fixed_1);

    ENSURE_CHAR(ch);

    /* Only ASCII digits are supported. */
    val = SCM_CHAR_VALUE(ch);
    if (!ICHAR_NUMERICP(val))
        return SCM_FALSE;

    return MAKE_INT(val - '0');
}

SCM_EXPORT ScmObj
scm_p_char_foldcase(ScmObj ch)
{
    DECLARE_FUNCTION("char-foldcase", procedure_fixed_1);

    ENSURE_CHAR(ch);

    return MAKE_CHAR(ICHAR_FOLDCASE(SCM_CHAR_VALUE(ch)));
}

/*===========================================================================
  R7RS : 6.7 Strings
===========================================================================*/
/* Only ASCII characters are converted like char-upcase and so on. */
static scm_ichar_t
upcase(scm_ichar_t ch)
{
    return ICHAR_UPCASE(ch);
}

static scm_ichar_t
downcase(scm_ichar_t ch)
{
    return ICHAR_DOWNCASE(ch);
}

static scm_ichar_t
foldcase(scm_ichar_t ch)
{
    return ICHAR_FOLDCASE(ch);
}

/* Only single byte characters are converted. So the conversion doesn't
 * change the size of the string. */
static ScmObj
convert_string_case(ScmObj str, case_converter convert)
{
#if SCM_USE_MULTIBYTE_CHAR
    ScmMultibyteString mbs;
    scm_ichar_t ch;
#endif
    char *new_str, *p;
    DECLARE_INTERNAL_FUNCTION("convert_string_case");

    new_str = scm_strdup(SCM_STRING_STR(str));
#if SCM_USE_MULTIBYTE_CHAR
    SCM_MBS_INIT2(mbs, new_str, strlen(new_str));
    while (SCM_MBS_GET_SIZE(mbs)) {
        p = (char *)SCM_MBS_GET_STR(mbs);
        ch = SCM_CHARCODEC_READ_CHAR(scm_current_char_codec, mbs);
        if (SCM_MBS_GET_STR(mbs) - p == 1)
            *p = convert(ch);
    }
#else
    for (p = new_str; *p; p++)
        *p = convert((unsigned char)*p);
#endif

#if SCM_USE_NULL_CAPABLE_STRING
    /* FIXME: the result is truncated at null and incorrect */
    return MAKE_STRING(new_str, STRLEN_UNKNOWN);
#else
    return MAKE_STRING(new_str, SCM_STRING_LEN(str));
#endif
}

SCM_EXPORT ScmObj
scm_p_string_upcase(ScmObj str)
{
    DECLARE_FUNCTION("string-upcase", procedure_fixed_1);

    ENSURE_STRING(str);

    return convert_string_case(str, upcase);
}

SCM_EXPORT ScmObj
scm_p_string_downcase(ScmObj str)
{
    DECLARE_FUNCTION("string-downcase", procedure_fixed_1);

    ENSURE_STRING(str);

    return convert_string_case(str, downcase);
}

SCM_EXPORT ScmObj
scm_p_string_foldcase(ScmObj str)
{
    DECLARE_FUNCTION("string-foldcase", procedure_fixed_1);

    ENSURE_STRING(str);

    return convert_string_case(str, foldcase);
}

/* Returns #t if all adjacent objects in OBJ1, OBJ2 and REST satisfy
 * COMPARE. All objects are checked by COMPARE even if the result is
 * determined. */
static ScmObj
compare_all(comparator compare, ScmObj obj1, ScmObj obj2, ScmObj rest)
{
    ScmObj obj;
    scm_bool satisfied;

    satisfied = TRUEP(compare(obj1, obj2));
    FOR_EACH (obj, rest) {
        if (!TRUEP(compare(obj2, obj)))
            satisfied = scm_false;
        obj2 = obj;
    }

    return MAKE_BOOL(satisfied);
}

/* Overrides R5RS string comparisons to accept more than two strings. */
SCM_EXPORT ScmObj
scm_p_r7rs_stringequalp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string=?", procedure_variadic_2);

    return compare_all(scm_p_stringequalp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_lessp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string<?", procedure_variadic_2);

    return compare_all(scm_p_string_lessp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_greaterp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string>?", procedure_variadic_2);

    return compare_all(scm_p_string_greaterp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_less_equalp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string<=?", procedure_variadic_2);

    return compare_all(scm_p_string_less_equalp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_greater_equalp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string>=?", procedure_variadic_2);

    return compare_all(scm_p_string_greater_equalp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_ci_equalp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string-ci=?", procedure_variadic_2);

    return compare_all(scm_p_string_ci_equalp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_ci_lessp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string-ci<?", procedure_variadic_2);

    return compare_all(scm_p_string_ci_lessp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_ci_greaterp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string-ci>?", procedure_variadic_2);

    return compare_all(scm_p_string_ci_greaterp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_ci_less_equalp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string-ci<=?", procedure_variadic_2);

    return compare_all(scm_p_string_ci_less_equalp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_ci_greater_equalp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string-ci>=?", procedure_variadic_2);

    return compare_all(scm_p_string_ci_greater_equalp, str1, str2, rest);
}

/* Overrides R5RS string->list to support START and END. The R5RS
 * version is used without them to keep its behavior. */
SCM_EXPORT ScmObj
scm_p_r7rs_string2list(ScmObj str, ScmObj args)
{
    scm_int_t start, end;
    DECLARE_FUNCTION("string->list", procedure_variadic_1);

    if (NULLP(args))
        return scm_p_string2list(str);

    ENSURE_STRING(str);
    scm_parse_range(SCM_MANGLE(name), args, SCM_STRING_LEN(str), &start, &end);

    return scm_p_string2list(scm_p_substring(str, MAKE_INT(start),
                                             MAKE_INT(end)));
}

/* Overrides R5RS string-copy to support START and END. The R5RS
 * version is used without them to keep its behavior. For example, it
 * copies the string as is even if the current character codec differs
 * from the codec of the string. */
SCM_EXPORT ScmObj
scm_p_r7rs_string_copy(ScmObj str, ScmObj args)
{
    scm_int_t start, end;
    DECLARE_FUNCTION("string-copy", procedure_variadic_1);

    if (NULLP(args))
        return scm_p_string_copy(str);

    ENSURE_STRING(str);
    scm_parse_range(SCM_MANGLE(name), args, SCM_STRING_LEN(str), &start, &end);

    return scm_p_substring(str, MAKE_INT(start), MAKE_INT(end));
}

/* string-set! is used to handle multibyte characters. */
SCM_EXPORT ScmObj
scm_p_string_copyx(ScmObj to, ScmObj at, ScmObj from, ScmObj args)
{
    ScmObj chars, ch;
    scm_int_t to_start, start, end;
    DECLARE_FUNCTION("string-copy!", procedure_variadic_3);

    ENSURE_STRING(to);
    ENSURE_MUTABLE_STRING(to);
    ENSURE_INT(at);
    ENSURE_STRING(from);
    scm_parse_range(SCM_MANGLE(name), args, SCM_STRING_LEN(from),
                    &start, &end);

    to_start = SCM_INT_VALUE(at);
    if (!(0 <= to_start && end - start <= SCM_STRING_LEN(to) - to_start))
        ERR_OBJ("index out of range", at);

    /* Extract characters before modifying TO because TO and FROM may be the
     * same string. */
    chars = scm_p_string2list(scm_p_substring(from, MAKE_INT(start),
                                              MAKE_INT(end)));
    FOR_EACH (ch, chars)
        scm_p_string_setx(to, MAKE_INT(to_start++), ch);

    return SCM_UNDEF;
}

/* Overrides R5RS string-fill! to support START and END. The R5RS
 * version is used without them. string-set! is used to handle
 * multibyte characters with them. */
SCM_EXPORT ScmObj
scm_p_r7rs_string_fillx(ScmObj str, ScmObj ch, ScmObj args)
{
    scm_int_t start, end, i;
    DECLARE_FUNCTION("string-fill!", procedure_variadic_2);

    if (NULLP(args))
        return scm_p_string_fillx(str, ch);

    ENSURE_STRING(str);
    ENSURE_MUTABLE_STRING(str);
    ENSURE_CHAR(ch);
    scm_parse_range(SCM_MANGLE(name), args, SCM_STRING_LEN(str), &start, &end);

    for (i = start; i < end; i++)
        scm_p_string_setx(str, MAKE_INT(i), ch);

    return SCM_UNDEF;
}

/* Calls PROC with the characters at the same index of STRS until the
 * shortest string ends. Returns the results as a string if COLLECT. */
static ScmObj
map_sequences(const char *func_name, ScmObj proc, ScmObj seqs,
              scm_bool vectorp, scm_bool collect)
{
    ScmObj lists, list, seq, args, results, result;
    ScmQueue lists_q, args_q, results_q;

    if (!PROCEDUREP(proc))
        scm_error_obj(func_name, "procedure required but got", proc);
    lists = SCM_NULL;
    SCM_QUEUE_POINT_TO(lists_q, lists);
    FOR_EACH (seq, seqs) {
        if (vectorp) {
            if (!VECTORP(seq))
                scm_error_obj(func_name, "vector required but got", seq);
            SCM_QUEUE_ADD(lists_q, scm_p_vector2list(seq));
        } else {
            if (!STRINGP(seq))
                scm_error_obj(func_name, "string required but got", seq);
            SCM_QUEUE_ADD(lists_q, scm_p_string2list(seq));
        }
    }

    results = SCM_NULL;
    SCM_QUEUE_POINT_TO(results_q, results);
    for (;;) {
        args = SCM_NULL;
        SCM_QUEUE_POINT_TO(args_q, args);
        for (list = lists; CONSP(list); list = CDR(list)) {
            if (NULLP(CAR(list))) {
                if (!collect)
                    return SCM_UNDEF;
                return vectorp ? scm_p_list2vector(results)
                               : scm_p_list2string(results);
            }
            SCM_QUEUE_ADD(args_q, CAR(CAR(list)));
            SET_CAR(list, CDR(CAR(list)));
        }
        result = scm_call(proc, args);
        if (collect)
            SCM_QUEUE_ADD(results_q, result);
    }
}

SCM_EXPORT ScmObj
scm_p_string_map(ScmObj proc, ScmObj str, ScmObj rest)
{
    DECLARE_FUNCTION("string-map", procedure_variadic_2);

    return map_sequences(SCM_MANGLE(name), proc, CONS(str, rest), scm_false,
                         scm_true);
}

SCM_EXPORT ScmObj
scm_p_string_for_each(ScmObj proc, ScmObj str, ScmObj rest)
{
    DECLARE_FUNCTION("string-for-each", procedure_variadic_2);

    return map_sequences(SCM_MANGLE(name), proc, CONS(str, rest), scm_false,
                         scm_false);
}

/*===========================================================================
  R7RS : 6.8 Vectors
===========================================================================*/
static ScmObj
vector_to_list(ScmObj vec, scm_int_t start, scm_int_t end)
{
    ScmQueue q;
    ScmObj ret, *v;
    scm_int_t i;

    v = SCM_VECTOR_VEC(vec);
    ret = SCM_NULL;
    SCM_QUEUE_POINT_TO(q, ret);
    for (i = start; i < end; i++)
        SCM_QUEUE_ADD(q, v[i]);

    return ret;
}

/* Overrides R5RS vector->list to support START and END. The R5RS
 * version is used without them. */
SCM_EXPORT ScmObj
scm_p_r7rs_vector2list(ScmObj vec, ScmObj args)
{
    scm_int_t start, end;
    DECLARE_FUNCTION("vector->list", procedure_variadic_1);

    if (NULLP(args))
        return scm_p_vector2list(vec);

    ENSURE_VECTOR(vec);
    scm_parse_range(SCM_MANGLE(name), args, SCM_VECTOR_LEN(vec), &start, &end);

    return vector_to_list(vec, start, end);
}

SCM_EXPORT ScmObj
scm_p_vector2string(ScmObj vec, ScmObj args)
{
    scm_int_t start, end;
    DECLARE_FUNCTION("vector->string", procedure_variadic_1);

    ENSURE_VECTOR(vec);
    scm_parse_range(SCM_MANGLE(name), args, SCM_VECTOR_LEN(vec), &start, &end);

    return scm_p_list2string(vector_to_list(vec, start, end));
}

SCM_EXPORT ScmObj
scm_p_string2vector(ScmObj str, ScmObj args)
{
    scm_int_t start, end;
    DECLARE_FUNCTION("string->vector", procedure_variadic_1);

    ENSURE_STRING(str);
    scm_parse_range(SCM_MANGLE(name), args, SCM_STRING_LEN(str), &start, &end);

    return scm_p_list2vector(
        scm_p_string2list(scm_p_substring(str, MAKE_INT(start),
                                          MAKE_INT(end))));
}

SCM_EXPORT ScmObj
scm_p_vector_copy(ScmObj vec, ScmObj args)
{
    ScmObj *copy;
    scm_int_t start, end;
    DECLARE_FUNCTION("vector-copy", procedure_variadic_1);

    ENSURE_VECTOR(vec);
    scm_parse_range(SCM_MANGLE(name), args, SCM_VECTOR_LEN(vec), &start, &end);

    copy = scm_malloc(sizeof(ScmObj) * (end - start));
    memcpy(copy, &SCM_VECTOR_VEC(vec)[start], sizeof(ScmObj) * (end - start));

    return MAKE_VECTOR(copy, end - start);
}

SCM_EXPORT ScmObj
scm_p_vector_copyx(ScmObj to, ScmObj at, ScmObj from, ScmObj args)
{
    scm_int_t to_start, start, end;
    DECLARE_FUNCTION("vector-copy!", procedure_variadic_3);

    ENSURE_VECTOR(to);
    ENSURE_MUTABLE_VECTOR(to);
    ENSURE_INT(at);
    ENSURE_VECTOR(from);
    scm_parse_range(SCM_MANGLE(name), args, SCM_VECTOR_LEN(from),
                    &start, &end);

    to_start = SCM_INT_VALUE(at);
    if (!(0 <= to_start && end - start <= SCM_VECTOR_LEN(to) - to_start))
        ERR_OBJ("index out of range", at);

    /* TO and FROM may be the same vector. */
    memmove(&SCM_VECTOR_VEC(to)[to_start], &SCM_VECTOR_VEC(from)[start],
            sizeof(ScmObj) * (end - start));

    return SCM_UNDEF;
}

SCM_EXPORT ScmObj
scm_p_vector_append(ScmObj args)
{
    ScmObj rest, vec, *appended;
    scm_int_t len, offset;
    DECLARE_FUNCTION("vector-append", procedure_variadic_0);

    len = 0;
    rest = args;
    FOR_EACH (vec, rest) {
        ENSURE_VECTOR(vec);
        len += SCM_VECTOR_LEN(vec);
    }

    appended = scm_malloc(sizeof(ScmObj) * len);
    offset = 0;
    FOR_EACH (vec, args) {
        memcpy(&appended[offset], SCM_VECTOR_VEC(vec),
               sizeof(ScmObj) * SCM_VECTOR_LEN(vec));
        offset += SCM_VECTOR_LEN(vec);
    }

    return MAKE_VECTOR(appended, len);
}

/* Overrides R5RS vector-fill! to support START and END. The R5RS
 * version is used without them. */
SCM_EXPORT ScmObj
scm_p_r7rs_vector_fillx(ScmObj vec, ScmObj fill, ScmObj args)
{
    ScmObj *v;
    scm_int_t start, end, i;
    DECLARE_FUNCTION("vector-fill!", procedure_variadic_2);

    if (NULLP(args))
        return scm_p_vector_fillx(vec, fill);

    ENSURE_VECTOR(vec);
    ENSURE_MUTABLE_VECTOR(vec);
    scm_parse_range(SCM_MANGLE(name), args, SCM_VECTOR_LEN(vec), &start, &end);

    v = SCM_VECTOR_VEC(vec);
    for (i = start; i < end; i++)
        v[i] = fill;

    return SCM_UNDEF;
}

/*===========================================================================
  R7RS : 6.10 Control features
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_vector_map(ScmObj proc, ScmObj vec, ScmObj rest)
{
    DECLARE_FUNCTION("vector-map", procedure_variadic_2);

    return map_sequences(SCM_MANGLE(name), proc, CONS(vec, rest), scm_true,
                         scm_true);
}

SCM_EXPORT ScmObj
scm_p_vector_for_each(ScmObj proc, ScmObj vec, ScmObj rest)
{
    DECLARE_FUNCTION("vector-for-each", procedure_variadic_2);

    return map_sequences(SCM_MANGLE(name), proc, CONS(vec, rest), scm_true,
                         scm_false);
}

/* Overrides R5RS map. Lists may have different lengths. It stops when
 * the shortest list ends. */
SCM_EXPORT ScmObj
scm_p_r7rs_map(ScmObj proc, ScmObj lst, ScmObj rest)
{
    DECLARE_FUNCTION("map", procedure_variadic_2);

    if (NULLP(rest))
        return scm_map_single_arg(proc, lst);

    return scm_map_multiple_args(proc, CONS(lst, rest), scm_true);
}

/* Overrides R5RS for-each. Lists may have different lengths. It stops
 * when the shortest list ends. */
SCM_EXPORT ScmObj
scm_p_r7rs_for_each(ScmObj proc, ScmObj lst, ScmObj rest)
{
    DECLARE_FUNCTION("for-each", procedure_variadic_2);

    scm_p_r7rs_map(proc, lst, rest);

    return SCM_UNDEF;
}

/*===========================================================================
  R7RS : 6.11 Exceptions
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_raise_continuable(ScmObj obj)
{
    DECLARE_FUNCTION("raise-continuable", procedure_fixed_1);

    return scm_raise_continuable(obj);
}

SCM_EXPORT ScmObj
scm_p_r7rs_error_objectp(ScmObj obj)
{
    DECLARE_FUNCTION("error-object?", procedure_fixed_1);

    return MAKE_BOOL(ERROBJP(obj));
}

SCM_EXPORT ScmObj
scm_p_error_object_message(ScmObj obj)
{
    DECLARE_FUNCTION("error-object-message", procedure_fixed_1);

    ENSURE_ERROBJ(obj);

    return ERROBJ_REASON(obj);
}

SCM_EXPORT ScmObj
scm_p_error_object_irritants(ScmObj obj)
{
    DECLARE_FUNCTION("error-object-irritants", procedure_fixed_1);

    ENSURE_ERROBJ(obj);

    return ERROBJ_IRRITANTS(obj);
}

SCM_EXPORT ScmObj
scm_p_file_errorp(ScmObj obj)
{
    DECLARE_FUNCTION("file-error?", procedure_fixed_1);

    return MAKE_BOOL(ERROBJP(obj) && ERROBJ_KIND(obj) == SCM_ERRKIND_FILE);
}

SCM_EXPORT ScmObj
scm_p_read_errorp(ScmObj obj)
{
    DECLARE_FUNCTION("read-error?", procedure_fixed_1);

    return MAKE_BOOL(ERROBJP(obj) && ERROBJ_KIND(obj) == SCM_ERRKIND_READ);
}

/*===========================================================================
  R7RS : 6.13 Input and output : 6.13.1 Ports
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_portp(ScmObj obj)
{
    DECLARE_FUNCTION("port?", procedure_fixed_1);

    return MAKE_BOOL(PORTP(obj));
}

SCM_EXPORT ScmObj
scm_p_textual_portp(ScmObj obj)
{
    DECLARE_FUNCTION("textual-port?", procedure_fixed_1);

    return MAKE_BOOL(PORTP(obj) && !BINARY_PORTP(obj));
}

SCM_EXPORT ScmObj
scm_p_binary_portp(ScmObj obj)
{
    DECLARE_FUNCTION("binary-port?", procedure_fixed_1);

    return MAKE_BOOL(BINARY_PORTP(obj));
}

/* A binary port is a port whose character is a byte. */
static ScmObj
make_binary_port(ScmBytePort *bport, enum ScmPortFlag flag)
{
    return MAKE_PORT(ScmSingleByteCharPort_new(bport),
                     flag | SCM_PORTFLAG_BINARY);
}

/* Returns the binary port in optional ARGS. */
static ScmObj
prepare_binary_port(const char *func_name, ScmObj args, ScmObj default_port)
{
    ScmObj port;

    port = scm_prepare_port(args, default_port);
    if (!BINARY_PORTP(port))
        scm_error_obj(func_name, "binary port required but got", port);
    return port;
}

static ScmBytePort *
binary_port_byte_port(ScmObj port)
{
    ScmBaseCharPort *cport;

    SCM_ENSURE_LIVE_PORT(port);
    cport = SCM_CHARPORT_DYNAMIC_CAST(ScmBaseCharPort, SCM_PORT_IMPL(port));
    return cport->bport;
}

SCM_EXPORT ScmObj
scm_p_open_binary_input_file(ScmObj filepath)
{
    ScmBytePort *bport;
    DECLARE_FUNCTION("open-binary-input-file", procedure_fixed_1);

    ENSURE_STRING(filepath);

    bport = ScmFilePort_open_input_file(SCM_STRING_STR(filepath));
    if (!bport)
        scm_kind_error_obj(SCM_ERRKIND_FILE, SCM_MANGLE(name),
                           "cannot open file", filepath);

    return make_binary_port(bport, SCM_PORTFLAG_INPUT);
}

SCM_EXPORT ScmObj
scm_p_open_binary_output_file(ScmObj filepath)
{
    ScmBytePort *bport;
    DECLARE_FUNCTION("open-binary-output-file", procedure_fixed_1);

    ENSURE_STRING(filepath);

    bport = ScmFilePort_open_output_file(SCM_STRING_STR(filepath));
    if (!bport)
        scm_kind_error_obj(SCM_ERRKIND_FILE, SCM_MANGLE(name),
                           "cannot open file", filepath);

    return make_binary_port(bport, SCM_PORTFLAG_OUTPUT);
}

SCM_EXPORT ScmObj
scm_p_open_input_bytevector(ScmObj bv)
{
    char *bytes;
    scm_int_t len;
    DECLARE_FUNCTION("open-input-bytevector", procedure_fixed_1);

    ENSURE_BYTEVECTOR(bv);

    len = SCM_BYTEVECTOR_LEN(bv);
    bytes = scm_malloc(len);
    memcpy(bytes, SCM_BYTEVECTOR_VEC(bv), len);

    return make_binary_port(ScmInputStrPort_new_bytes(bytes, len, NULL),
                            SCM_PORTFLAG_INPUT);
}

SCM_EXPORT ScmObj
scm_p_open_output_bytevector(void)
{
    DECLARE_FUNCTION("open-output-bytevector", procedure_fixed_0);

    return make_binary_port(ScmOutputStrPort_new(NULL), SCM_PORTFLAG_OUTPUT);
}

SCM_EXPORT ScmObj
scm_p_get_output_bytevector(ScmObj port)
{
    ScmBytePort *bport;
    scm_byte_t *bytes;
    size_t len;
    DECLARE_FUNCTION("get-output-bytevector", procedure_fixed_1);

    ENSURE_BINARY_PORT(port);

    bport = binary_port_byte_port(port);
    len = ScmOutputStrPort_c_strlen(bport);
    bytes = scm_malloc(len);
    memcpy(bytes, ScmOutputStrPort_str(bport), len);

    return MAKE_BYTEVECTOR(bytes, len);
}

SCM_EXPORT ScmObj
scm_p_input_port_openp(ScmObj port)
{
    DECLARE_FUNCTION("input-port-open?", procedure_fixed_1);

    ENSURE_PORT(port);

    return MAKE_BOOL(SCM_PORT_FLAG(port) & SCM_PORTFLAG_LIVE_INPUT);
}

SCM_EXPORT ScmObj
scm_p_output_port_openp(ScmObj port)
{
    DECLARE_FUNCTION("output-port-open?", procedure_fixed_1);

    ENSURE_PORT(port);

    return MAKE_BOOL(SCM_PORT_FLAG(port) & SCM_PORTFLAG_LIVE_OUTPUT);
}

SCM_EXPORT ScmObj
scm_p_call_with_port(ScmObj port, ScmObj proc)
{
    ScmObj ret;
    DECLARE_FUNCTION("call-with-port", procedure_fixed_2);

    ENSURE_PORT(port);
    ENSURE_PROCEDURE(proc);

    ret = scm_call(proc, LIST_1(port));
    scm_p_close_port(port);
    return ret;
}

SCM_EXPORT ScmObj
scm_p_close_port(ScmObj port)
{
    DECLARE_FUNCTION("close-port", procedure_fixed_1);

    scm_p_close_input_port(port);
    return scm_p_close_output_port(port);
}

SCM_EXPORT ScmObj
scm_p_r7rs_current_error_port(void)
{
    DECLARE_FUNCTION("current-error-port", procedure_fixed_0);

    return scm_p_current_error_port();
}

/*===========================================================================
  R7RS : 6.13 Input and output : 6.13.2 Input
===========================================================================*/
/* Reads characters from PORT until END_CH, that isn't included, or N
 * characters. N < 0 means no limit. Returns EOF if no character is read
 * before EOF. */
static ScmObj
read_chars(ScmObj port, scm_int_t n, scm_ichar_t end_ch)
{
    ScmQueue q;
    ScmObj chars;
    scm_ichar_t ch;

    chars = SCM_NULL;
    SCM_QUEUE_POINT_TO(q, chars);
    for (; n != 0; n--) {
        ch = scm_port_get_char(port);
        if (ch == SCM_ICHAR_EOF) {
            if (NULLP(chars))
                return SCM_EOF;
            break;
        }
        if (ch == end_ch)
            break;
        SCM_QUEUE_ADD(q, MAKE_CHAR(ch));
    }
    return scm_p_list2string(chars);
}

SCM_EXPORT ScmObj
scm_p_read_line(ScmObj args)
{
    DECLARE_FUNCTION("read-line", procedure_variadic_0);

    return read_chars(scm_prepare_port(args, scm_in), -1, '\n');
}

SCM_EXPORT ScmObj
scm_p_read_string(ScmObj k, ScmObj args)
{
    DECLARE_FUNCTION("read-string", procedure_variadic_1);

    ENSURE_INT(k);
    if (SCM_INT_VALUE(k) < 0)
        ERR_OBJ("non-negative integer required but got", k);

    return read_chars(scm_prepare_port(args, scm_in), SCM_INT_VALUE(k),
                      SCM_ICHAR_EOF);
}

SCM_EXPORT ScmObj
scm_p_read_u8(ScmObj args)
{
    scm_ichar_t byte;
    DECLARE_FUNCTION("read-u8", procedure_variadic_0);

    byte = scm_port_get_char(prepare_binary_port(SCM_MANGLE(name), args,
                                                 scm_in));
    return (byte == SCM_ICHAR_EOF) ? SCM_EOF : MAKE_INT(byte);
}

SCM_EXPORT ScmObj
scm_p_peek_u8(ScmObj args)
{
    scm_ichar_t byte;
    DECLARE_FUNCTION("peek-u8", procedure_variadic_0);

    byte = scm_port_peek_char(prepare_binary_port(SCM_MANGLE(name), args,
                                                  scm_in));
    return (byte == SCM_ICHAR_EOF) ? SCM_EOF : MAKE_INT(byte);
}

SCM_EXPORT ScmObj
scm_p_u8_readyp(ScmObj args)
{
    DECLARE_FUNCTION("u8-ready?", procedure_variadic_0);

    return MAKE_BOOL(scm_port_char_readyp(
                         prepare_binary_port(SCM_MANGLE(name), args, scm_in)));
}

SCM_EXPORT ScmObj
scm_p_read_bytevector(ScmObj k, ScmObj args)
{
    ScmObj port;
    scm_byte_t *bytes;
    scm_int_t len, n;
    scm_ichar_t byte;
    DECLARE_FUNCTION("read-bytevector", procedure_variadic_1);

    ENSURE_INT(k);
    len = SCM_INT_VALUE(k);
    if (len < 0)
        ERR_OBJ("non-negative integer required but got", k);
    port = prepare_binary_port(SCM_MANGLE(name), args, scm_in);

    bytes = scm_malloc(len);
    for (n = 0; n < len; n++) {
        byte = scm_port_get_char(port);
        if (byte == SCM_ICHAR_EOF)
            break;
        bytes[n] = byte;
    }
    if (n == 0 && len > 0) {
        free(bytes);
        return SCM_EOF;
    }

    return MAKE_BYTEVECTOR(bytes, n);
}

SCM_EXPORT ScmObj
scm_p_read_bytevectorx(ScmObj bv, ScmObj args)
{
    ScmObj port;
    scm_int_t start, end, i;
    scm_ichar_t byte;
    DECLARE_FUNCTION("read-bytevector!", procedure_variadic_1);

    ENSURE_BYTEVECTOR(bv);
    ENSURE_MUTABLE_BYTEVECTOR(bv);
    port = scm_in;
    if (CONSP(args))
        port = POP(args);
    port = prepare_binary_port(SCM_MANGLE(name), LIST_1(port), scm_in);
    scm_parse_range(SCM_MANGLE(name), args, SCM_BYTEVECTOR_LEN(bv),
                    &start, &end);

    for (i = start; i < end; i++) {
        byte = scm_port_get_char(port);
        if (byte == SCM_ICHAR_EOF)
            break;
        SCM_BYTEVECTOR_VEC(bv)[i] = byte;
    }
    if (i == start && start < end)
        return SCM_EOF;

    return MAKE_INT(i - start);
}

SCM_EXPORT ScmObj
scm_p_eof_object(void)
{
    DECLARE_FUNCTION("eof-object", procedure_fixed_0);

    return SCM_EOF;
}

/*===========================================================================
  R7RS : 6.13 Input and output : 6.13.3 Output
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_write_shared(ScmObj obj, ScmObj args)
{
    DECLARE_FUNCTION("write-shared", procedure_variadic_1);

    scm_write_ss(scm_prepare_port(args, scm_out), obj);
    return SCM_UNDEF;
}

/* SigScheme's write doesn't use datum labels. */
SCM_EXPORT ScmObj
scm_p_write_simple(ScmObj obj, ScmObj args)
{
    DECLARE_FUNCTION("write-simple", procedure_variadic_1);

    scm_write(scm_prepare_port(args, scm_out), obj);
    return SCM_UNDEF;
}

SCM_EXPORT ScmObj
scm_p_write_string(ScmObj str, ScmObj args)
{
    ScmObj port;
    scm_int_t start, end;
    DECLARE_FUNCTION("write-string", procedure_variadic_1);

    ENSURE_STRING(str);
    port = scm_out;
    if (CONSP(args)) {
        port = POP(args);
        ENSURE_PORT(port);
    }
    scm_parse_range(SCM_MANGLE(name), args, SCM_STRING_LEN(str), &start, &end);

    scm_display(port, scm_p_substring(str, MAKE_INT(start), MAKE_INT(end)));
    return SCM_UNDEF;
}

SCM_EXPORT ScmObj
scm_p_write_u8(ScmObj byte, ScmObj args)
{
    DECLARE_FUNCTION("write-u8", procedure_variadic_1);

    ENSURE_BYTE(byte);
    scm_port_put_char(prepare_binary_port(SCM_MANGLE(name), args, scm_out),
                      SCM_INT_VALUE(byte));
    return SCM_UNDEF;
}

SCM_EXPORT ScmObj
scm_p_write_bytevector(ScmObj bv, ScmObj args)
{
    ScmObj port;
    scm_int_t start, end;
    DECLARE_FUNCTION("write-bytevector", procedure_variadic_1);

    ENSURE_BYTEVECTOR(bv);
    port = scm_out;
    if (CONSP(args))
        port = POP(args);
    port = prepare_binary_port(SCM_MANGLE(name), LIST_1(port), scm_out);
    scm_parse_range(SCM_MANGLE(name), args, SCM_BYTEVECTOR_LEN(bv),
                    &start, &end);

    /* The single byte character port has no buffer. So we can write bytes
     * to the byte port directly. */
    SCM_BYTEPORT_WRITE(binary_port_byte_port(port), end - start,
                       (const char *)&SCM_BYTEVECTOR_VEC(bv)[start]);
    return SCM_UNDEF;
}

SCM_EXPORT ScmObj
scm_p_flush_output_port(ScmObj args)
{
    DECLARE_FUNCTION("flush-output-port", procedure_variadic_0);

    scm_port_flush(scm_prepare_port(args, scm_out));
    return SCM_UNDEF;
}

/*===========================================================================
  R7RS : 6.14 System interface
===========================================================================*/
SCM_EXPORT ScmObj
scm_p_file_existsp(ScmObj filename)
{
    struct stat st;
    DECLARE_FUNCTION("file-exists?", procedure_fixed_1);

    ENSURE_STRING(filename);

    return MAKE_BOOL(stat(SCM_STRING_STR(filename), &st) == 0);
}

SCM_EXPORT ScmObj
scm_p_delete_file(ScmObj filename)
{
    DECLARE_FUNCTION("delete-file", procedure_fixed_1);

    ENSURE_STRING(filename);

    if (remove(SCM_STRING_STR(filename)) != 0)
        scm_kind_error_obj(SCM_ERRKIND_FILE, SCM_MANGLE(name),
                           "cannot delete file", filename);
    return SCM_UNDEF;
}

SCM_EXPORT ScmObj
scm_p_command_line(void)
{
    ScmQueue q;
    ScmObj args;
    const char *const *argp;
    DECLARE_FUNCTION("command-line", procedure_fixed_0);

    args = SCM_NULL;
    SCM_QUEUE_POINT_TO(q, args);
    for (argp = l_command_line; argp && *argp; argp++)
        SCM_QUEUE_ADD(q, CONST_STRING(*argp));
    return args;
}

SCM_EXPORT ScmObj
scm_p_emergency_exit(ScmObj args)
{
    DECLARE_FUNCTION("emergency-exit", procedure_variadic_0);

    exit(scm_exit_status(SCM_MANGLE(name), args));
}

SCM_EXPORT ScmObj
scm_p_get_environment_variable(ScmObj name)
{
    const char *value;
    DECLARE_FUNCTION("get-environment-variable", procedure_fixed_1);

    ENSURE_STRING(name);

    value = getenv(SCM_STRING_STR(name));
    return value ? MAKE_STRING_COPYING(value, STRLEN_UNKNOWN) : SCM_FALSE;
}

SCM_EXPORT ScmObj
scm_p_get_environment_variables(void)
{
    ScmQueue q;
    ScmObj vars;
    char **envp, *name;
    const char *sep;
    DECLARE_FUNCTION("get-environment-variables", procedure_fixed_0);

    vars = SCM_NULL;
    SCM_QUEUE_POINT_TO(q, vars);
    for (envp = environ; *envp; envp++) {
        sep = strchr(*envp, '=');
        if (!sep)
            continue;
        name = scm_malloc(sep - *envp + sizeof(""));
        memcpy(name, *envp, sep - *envp);
        name[sep - *envp] = '\0';
        SCM_QUEUE_ADD(q, CONS(MAKE_STRING(name, STRLEN_UNKNOWN),
                              MAKE_STRING_COPYING(sep + 1, STRLEN_UNKNOWN)));
    }
    return vars;
}

/* SigScheme doesn't support inexact numbers. So it's an exact integer. */
SCM_EXPORT ScmObj
scm_p_current_second(void)
{
    DECLARE_FUNCTION("current-second", procedure_fixed_0);

    return MAKE_INT(time(NULL));
}

/* Jiffies are milliseconds since the initialization to avoid overflow. */
SCM_EXPORT ScmObj
scm_p_current_jiffy(void)
{
    struct timeval now;
    DECLARE_FUNCTION("current-jiffy", procedure_fixed_0);

    gettimeofday(&now, NULL);
    return MAKE_INT((scm_int_t)(now.tv_sec - l_jiffy_epoch) * 1000
                    + now.tv_usec / 1000);
}

SCM_EXPORT ScmObj
scm_p_jiffies_per_second(void)
{
    DECLARE_FUNCTION("jiffies-per-second", procedure_fixed_0);

    return MAKE_INT(1000);
}

/* Returns the provided features as symbols. require's records such as
 * "*foo.scm-loaded*" aren't features. */
SCM_EXPORT ScmObj
scm_p_features(void)
{
    ScmObj provided, features, feature;
    const char *name;
    DECLARE_FUNCTION("features", procedure_fixed_0);

    provided = scm_features();
    features = SCM_NULL;
    FOR_EACH (feature, provided) {
        name = SCM_STRING_STR(feature);
        if (name[0] != '*')
            features = CONS(scm_intern(name), features);
    }
    return features;
}
