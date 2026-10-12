/*===========================================================================
 *  Filename : r7rs.c
 *  About    : R7RS procedures (preliminary)
 *
 *  Copyright (c) 2026 SigScheme Project <uim-en AT googlegroups.com>
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

#include <string.h>

#include <sigscheme/sigscheme.h>
#include "sigschemeinternal.h"

/*=======================================
  File Local Macro Definitions
=======================================*/
#define BOOLEANP(o)       (EQ((o), SCM_FALSE) || EQ((o), SCM_TRUE))
#define ENSURE_BOOLEAN(o) ENSURE_TYPE(BOOLEANP, "boolean", (o))

/*=======================================
  File Local Type Definitions
=======================================*/
typedef scm_ichar_t (*case_converter)(scm_ichar_t ch);
typedef ScmObj (*string_comparator)(ScmObj str1, ScmObj str2);

/*=======================================
  Variable Definitions
=======================================*/

/*=======================================
  File Local Function Declarations
=======================================*/
static scm_ichar_t upcase(scm_ichar_t ch);
static scm_ichar_t downcase(scm_ichar_t ch);
static scm_ichar_t foldcase(scm_ichar_t ch);
static ScmObj convert_string_case(ScmObj str, case_converter convert);
static void parse_range(const char *func_name, ScmObj args, scm_int_t len,
                        scm_int_t *start, scm_int_t *end);
static void get_division_operands(const char *func_name, ScmObj n1,
                                  ScmObj n2, scm_int_t *dividend,
                                  scm_int_t *divisor);
static void floor_divide(const char *func_name, scm_int_t dividend,
                         scm_int_t divisor, scm_int_t *quotient,
                         scm_int_t *remainder);
static ScmObj vector_to_list(ScmObj vec, scm_int_t start, scm_int_t end);
static ScmObj compare_strings(string_comparator compare,
                              ScmObj str1, ScmObj str2, ScmObj rest);
static ScmObj map_strings(const char *func_name, ScmObj proc, ScmObj strs,
                          scm_bool collect);
static ScmObj bind_values(const char *func_name, ScmObj bindings,
                          scm_bool sequential, ScmObj env);
static ScmObj dispatch_case_lambda(ScmObj clauses, ScmObj args,
                                   ScmEvalState *eval_state);

/*=======================================
  Function Definitions
=======================================*/
/* Parses optional START and END in ARGS for a sequence whose length is
 * LEN. They must satisfy 0 <= START <= END <= LEN. */
static void
parse_range(const char *func_name, ScmObj args, scm_int_t len,
            scm_int_t *start, scm_int_t *end)
{
    ScmObj obj;

    *start = 0;
    *end = len;
    if (NULLP(args))
        return;

    obj = CAR(args);
    if (!INTP(obj))
        scm_error_obj(func_name, "integer required but got", obj);
    *start = SCM_INT_VALUE(obj);
    args = CDR(args);
    if (CONSP(args)) {
        obj = CAR(args);
        if (!INTP(obj))
            scm_error_obj(func_name, "integer required but got", obj);
        *end = SCM_INT_VALUE(obj);
        args = CDR(args);
    }
    if (!NULLP(args))
        scm_error_obj(func_name, "superfluous argument(s)", args);
    if (!(0 <= *start && *start <= *end && *end <= len))
        scm_error_obj(func_name, "invalid range",
                      LIST_2(MAKE_INT(*start), MAKE_INT(*end)));
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
/* SigScheme supports only exact integers. So the following procedures
 * are trivial. */
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

    ENSURE_INT(z);

    return SCM_TRUE;
}

SCM_EXPORT ScmObj
scm_p_infinitep(ScmObj z)
{
    DECLARE_FUNCTION("infinite?", procedure_fixed_1);

    ENSURE_INT(z);

    return SCM_FALSE;
}

SCM_EXPORT ScmObj
scm_p_nanp(ScmObj z)
{
    DECLARE_FUNCTION("nan?", procedure_fixed_1);

    ENSURE_INT(z);

    return SCM_FALSE;
}

/* Ensures that N1 and N2 are integers. */
static void
get_division_operands(const char *func_name, ScmObj n1, ScmObj n2,
                      scm_int_t *dividend, scm_int_t *divisor)
{
    if (!INTP(n1))
        scm_error_obj(func_name, "integer required but got", n1);
    if (!INTP(n2))
        scm_error_obj(func_name, "integer required but got", n2);

    *dividend = SCM_INT_VALUE(n1);
    *divisor = SCM_INT_VALUE(n2);
}

/* Returns the quotient and the remainder of floor division. */
static void
floor_divide(const char *func_name, scm_int_t dividend, scm_int_t divisor,
             scm_int_t *quotient, scm_int_t *remainder)
{
    *quotient = scm_int_quotient(func_name, dividend, divisor);
    *remainder = scm_int_remainder(func_name, dividend, divisor);
    if (*remainder && ((*remainder < 0) != (divisor < 0))) {
        *quotient -= 1;
        *remainder += divisor;
    }
}

SCM_EXPORT ScmObj
scm_p_floor_slash(ScmObj n1, ScmObj n2)
{
    scm_int_t dividend, divisor, quotient, remainder;
    DECLARE_FUNCTION("floor/", procedure_fixed_2);

    get_division_operands(SCM_MANGLE(name), n1, n2, &dividend, &divisor);
    floor_divide(SCM_MANGLE(name), dividend, divisor, &quotient, &remainder);

    return scm_p_values(LIST_2(MAKE_INT(quotient), MAKE_INT(remainder)));
}

SCM_EXPORT ScmObj
scm_p_floor_quotient(ScmObj n1, ScmObj n2)
{
    scm_int_t dividend, divisor, quotient, remainder;
    DECLARE_FUNCTION("floor-quotient", procedure_fixed_2);

    get_division_operands(SCM_MANGLE(name), n1, n2, &dividend, &divisor);
    floor_divide(SCM_MANGLE(name), dividend, divisor, &quotient, &remainder);

    return MAKE_INT(quotient);
}

SCM_EXPORT ScmObj
scm_p_floor_remainder(ScmObj n1, ScmObj n2)
{
    scm_int_t dividend, divisor;
    DECLARE_FUNCTION("floor-remainder", procedure_fixed_2);

    get_division_operands(SCM_MANGLE(name), n1, n2, &dividend, &divisor);

    return MAKE_INT(scm_int_modulo(SCM_MANGLE(name), dividend, divisor));
}

SCM_EXPORT ScmObj
scm_p_truncate_slash(ScmObj n1, ScmObj n2)
{
    scm_int_t dividend, divisor;
    DECLARE_FUNCTION("truncate/", procedure_fixed_2);

    get_division_operands(SCM_MANGLE(name), n1, n2, &dividend, &divisor);

    return scm_p_values(
        LIST_2(MAKE_INT(scm_int_quotient(SCM_MANGLE(name), dividend, divisor)),
               MAKE_INT(scm_int_remainder(SCM_MANGLE(name), dividend,
                                          divisor))));
}

SCM_EXPORT ScmObj
scm_p_truncate_quotient(ScmObj n1, ScmObj n2)
{
    scm_int_t dividend, divisor;
    DECLARE_FUNCTION("truncate-quotient", procedure_fixed_2);

    get_division_operands(SCM_MANGLE(name), n1, n2, &dividend, &divisor);

    return MAKE_INT(scm_int_quotient(SCM_MANGLE(name), dividend, divisor));
}

SCM_EXPORT ScmObj
scm_p_truncate_remainder(ScmObj n1, ScmObj n2)
{
    scm_int_t dividend, divisor;
    DECLARE_FUNCTION("truncate-remainder", procedure_fixed_2);

    get_division_operands(SCM_MANGLE(name), n1, n2, &dividend, &divisor);

    return MAKE_INT(scm_int_remainder(SCM_MANGLE(name), dividend, divisor));
}

SCM_EXPORT ScmObj
scm_p_square(ScmObj z)
{
    DECLARE_FUNCTION("square", procedure_fixed_1);

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

    ENSURE_INT(z);

    return z;
}

SCM_EXPORT ScmObj
scm_p_inexact(ScmObj z)
{
    DECLARE_FUNCTION("inexact", procedure_fixed_1);

    ENSURE_INT(z);
    ERR_OBJ(ERRMSG_INEXACT_NOT_SUPPORTED, z);
    /* NOTREACHED */
    return SCM_FALSE;
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

/* Returns #t if all adjacent strings in STR1, STR2 and REST satisfy
 * COMPARE. */
static ScmObj
compare_strings(string_comparator compare,
                ScmObj str1, ScmObj str2, ScmObj rest)
{
    ScmObj str;
    scm_bool satisfied;

    satisfied = TRUEP(compare(str1, str2));
    FOR_EACH (str, rest) {
        if (!TRUEP(compare(str2, str)))
            satisfied = scm_false;
        str2 = str;
    }

    return MAKE_BOOL(satisfied);
}

/* Overrides R5RS string comparisons to accept more than two strings. */
SCM_EXPORT ScmObj
scm_p_r7rs_stringequalp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string=?", procedure_variadic_2);

    return compare_strings(scm_p_stringequalp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_lessp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string<?", procedure_variadic_2);

    return compare_strings(scm_p_string_lessp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_greaterp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string>?", procedure_variadic_2);

    return compare_strings(scm_p_string_greaterp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_less_equalp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string<=?", procedure_variadic_2);

    return compare_strings(scm_p_string_less_equalp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_greater_equalp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string>=?", procedure_variadic_2);

    return compare_strings(scm_p_string_greater_equalp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_ci_equalp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string-ci=?", procedure_variadic_2);

    return compare_strings(scm_p_string_ci_equalp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_ci_lessp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string-ci<?", procedure_variadic_2);

    return compare_strings(scm_p_string_ci_lessp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_ci_greaterp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string-ci>?", procedure_variadic_2);

    return compare_strings(scm_p_string_ci_greaterp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_ci_less_equalp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string-ci<=?", procedure_variadic_2);

    return compare_strings(scm_p_string_ci_less_equalp, str1, str2, rest);
}

SCM_EXPORT ScmObj
scm_p_r7rs_string_ci_greater_equalp(ScmObj str1, ScmObj str2, ScmObj rest)
{
    DECLARE_FUNCTION("string-ci>=?", procedure_variadic_2);

    return compare_strings(scm_p_string_ci_greater_equalp, str1, str2, rest);
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
    parse_range(SCM_MANGLE(name), args, SCM_STRING_LEN(str), &start, &end);

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
    parse_range(SCM_MANGLE(name), args, SCM_STRING_LEN(str), &start, &end);

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
    parse_range(SCM_MANGLE(name), args, SCM_STRING_LEN(from), &start, &end);

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
    parse_range(SCM_MANGLE(name), args, SCM_STRING_LEN(str), &start, &end);

    for (i = start; i < end; i++)
        scm_p_string_setx(str, MAKE_INT(i), ch);

    return SCM_UNDEF;
}

/* Calls PROC with the characters at the same index of STRS until the
 * shortest string ends. Returns the results as a string if COLLECT. */
static ScmObj
map_strings(const char *func_name, ScmObj proc, ScmObj strs,
            scm_bool collect)
{
    ScmObj lists, list, str, args, results, result;
    ScmQueue lists_q, args_q, results_q;

    if (!PROCEDUREP(proc))
        scm_error_obj(func_name, "procedure required but got", proc);
    lists = SCM_NULL;
    SCM_QUEUE_POINT_TO(lists_q, lists);
    FOR_EACH (str, strs) {
        if (!STRINGP(str))
            scm_error_obj(func_name, "string required but got", str);
        SCM_QUEUE_ADD(lists_q, scm_p_string2list(str));
    }

    results = SCM_NULL;
    SCM_QUEUE_POINT_TO(results_q, results);
    for (;;) {
        args = SCM_NULL;
        SCM_QUEUE_POINT_TO(args_q, args);
        for (list = lists; CONSP(list); list = CDR(list)) {
            if (NULLP(CAR(list)))
                return collect ? scm_p_list2string(results) : SCM_UNDEF;
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

    return map_strings(SCM_MANGLE(name), proc, CONS(str, rest), scm_true);
}

SCM_EXPORT ScmObj
scm_p_string_for_each(ScmObj proc, ScmObj str, ScmObj rest)
{
    DECLARE_FUNCTION("string-for-each", procedure_variadic_2);

    return map_strings(SCM_MANGLE(name), proc, CONS(str, rest), scm_false);
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
    parse_range(SCM_MANGLE(name), args, SCM_VECTOR_LEN(vec), &start, &end);

    return vector_to_list(vec, start, end);
}

SCM_EXPORT ScmObj
scm_p_vector2string(ScmObj vec, ScmObj args)
{
    scm_int_t start, end;
    DECLARE_FUNCTION("vector->string", procedure_variadic_1);

    ENSURE_VECTOR(vec);
    parse_range(SCM_MANGLE(name), args, SCM_VECTOR_LEN(vec), &start, &end);

    return scm_p_list2string(vector_to_list(vec, start, end));
}

SCM_EXPORT ScmObj
scm_p_string2vector(ScmObj str, ScmObj args)
{
    scm_int_t start, end;
    DECLARE_FUNCTION("string->vector", procedure_variadic_1);

    ENSURE_STRING(str);
    parse_range(SCM_MANGLE(name), args, SCM_STRING_LEN(str), &start, &end);

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
    parse_range(SCM_MANGLE(name), args, SCM_VECTOR_LEN(vec), &start, &end);

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
    parse_range(SCM_MANGLE(name), args, SCM_VECTOR_LEN(from), &start, &end);

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
    parse_range(SCM_MANGLE(name), args, SCM_VECTOR_LEN(vec), &start, &end);

    v = SCM_VECTOR_VEC(vec);
    for (i = start; i < end; i++)
        v[i] = fill;

    return SCM_UNDEF;
}

/*===========================================================================
  R7RS : 6.10 Control features
===========================================================================*/
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
