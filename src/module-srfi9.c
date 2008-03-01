/*===========================================================================
 *  Filename : module-srfi9.c
 *  About    : SRFI-9 Defining Record Types
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

#include <config.h>

#include "sigscheme.h"
#include "sigschemeinternal.h"

/*=======================================
  File Local Macro Definitions
=======================================*/
#define ERRMSG_MISPLACED_RECORD_DEFINITION                              \
  "record type definition is not allowed here"

#define SYMBOL_VALUE(sym)                                               \
    (scm_symbol_value(scm_intern(sym), SCM_INTERACTION_ENV))

/*=======================================
  File Local Type Definitions
=======================================*/
static void define_record_field(ScmObj type_obj, ScmObj field_spec,
                                ScmObj env);

/*=======================================
  Variable Definitions
=======================================*/
#include "functable-srfi9.c"

SCM_GLOBAL_VARS_BEGIN(static_srfi9);
#define static
static ScmObj l_proc_car;
static ScmObj l_proc_make_record_type;
static ScmObj l_proc_record_constructor, l_proc_record_predicate;
static ScmObj l_proc_record_accessor, l_proc_record_modifier;
#undef static
SCM_GLOBAL_VARS_END(static_srfi9);
#define l_proc_car                SCM_GLOBAL_VAR(static_srfi9, l_proc_car)
#define l_proc_make_record_type   SCM_GLOBAL_VAR(static_srfi9,           \
                                                 l_proc_make_record_type)
#define l_proc_record_constructor SCM_GLOBAL_VAR(static_srfi9,           \
                                                 l_proc_record_constructor)
#define l_proc_record_predicate   SCM_GLOBAL_VAR(static_srfi9,           \
                                                 l_proc_record_predicate)
#define l_proc_record_accessor    SCM_GLOBAL_VAR(static_srfi9,           \
                                                 l_proc_record_accessor)
#define l_proc_record_modifier    SCM_GLOBAL_VAR(static_srfi9,           \
                                                 l_proc_record_modifier)
SCM_DEFINE_STATIC_VARS(static_srfi9);

/*=======================================
  File Local Function Declarations
=======================================*/

/*=======================================
  Function Definitions
=======================================*/
SCM_EXPORT void
scm_initialize_srfi9(void)
{
    SCM_GLOBAL_VARS_INIT(static_srfi9);

    scm_register_funcs(scm_functable_srfi9);

    scm_require_module("srfi-23");
    scm_load_system_file("srfi-9.scm");

    l_proc_car                = SYMBOL_VALUE("car");
    l_proc_make_record_type   = SYMBOL_VALUE("make-record-type");
    l_proc_record_constructor = SYMBOL_VALUE("record-constructor");
    l_proc_record_predicate   = SYMBOL_VALUE("record-predicate");
    l_proc_record_accessor    = SYMBOL_VALUE("record-accessor");
    l_proc_record_modifier    = SYMBOL_VALUE("record-modifier");
}

SCM_EXPORT ScmObj
scm_s_srfi9_define_record_type(ScmObj type_name, ScmObj ctor_spec,
                               ScmObj pred_name, ScmObj field_specs,
                               ScmEvalState *eval_state)
{
    ScmObj env, type_obj, ctor, pred, ctor_name, ctor_tags;
    ScmObj field_tags, field_spec, rest;
    DECLARE_FUNCTION("define-record-type", syntax_variadic_tailrec_3);

    if (!SCM_DEFINABLE_TOPLEVELP(eval_state))
        ERR(ERRMSG_MISPLACED_RECORD_DEFINITION);

    ENSURE_SYMBOL(type_name);
    ENSURE_CONS(ctor_spec);
    ENSURE_SYMBOL(pred_name);

    env = eval_state->env;

    ctor_name = CAR(ctor_spec);
    ctor_tags = CDR(ctor_spec);
    field_tags = scm_map_single_arg(l_proc_car, field_specs);

    type_obj = scm_call(l_proc_make_record_type,
                        LIST_2(type_name, field_tags));
    ctor = scm_call(l_proc_record_constructor, LIST_2(type_obj, ctor_tags));
    pred = scm_call(l_proc_record_predicate, LIST_1(type_obj));
    scm_s_define_internal(ScmFirstClassObj,
                          type_name, LIST_2(SYM_QUOTE, type_obj), env);
    scm_s_define_internal(ScmFirstClassObj, ctor_name, ctor, env);
    scm_s_define_internal(ScmFirstClassObj, pred_name, pred, env);

    rest = field_specs;
    FOR_EACH (field_spec, rest)
        define_record_field(type_obj, field_spec, env);
    SCM_ASSERT(NULLP(rest));

    return SCM_UNDEF;
}

/* define-record-field is not a part of SRFI-9. */
static void
define_record_field(ScmObj type_obj, ScmObj field_spec, ScmObj env)
{
    ScmObj field_tag, accessor_name, modifier_name, accessor, modifier, rest;
    DECLARE_INTERNAL_FUNCTION("define-record-type");

    rest = field_spec;
    field_tag     = MUST_POP_ARG(rest);
    accessor_name = MUST_POP_ARG(rest);
    ENSURE_SYMBOL(field_tag);
    ENSURE_SYMBOL(accessor_name);

    accessor = scm_call(l_proc_record_accessor, LIST_2(type_obj, field_tag));
    scm_s_define_internal(ScmFirstClassObj, accessor_name, accessor, env);

    if (!NO_MORE_ARG(rest)) {
        modifier_name = POP(rest);
        ENSURE_SYMBOL(modifier_name);

        modifier = scm_call(l_proc_record_modifier,
                            LIST_2(type_obj, field_tag));
        scm_s_define_internal(ScmFirstClassObj, modifier_name, modifier, env);
    }
    ENSURE_PROPER_LIST_TERMINATION(rest, field_spec);
}
