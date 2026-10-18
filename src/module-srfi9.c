/*===========================================================================
 *  Filename : module-srfi9.c
 *  About    : SRFI-9 Defining Record Types
 *
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

/*
 * define-record-type is defined by syntax-rules in lib/srfi-9.scm. It uses
 * the following procedures.
 *
 * A record type is #(type-marker name field-names). A record is
 * #(record-marker type value ...). The markers are unique objects. Records
 * aren't vectors for vector? but other vector procedures accept them.
 */

/*=======================================
  File Local Macro Definitions
=======================================*/
#define RECORD_TYPE_NAME(type)   (SCM_VECTOR_VEC(type)[1])
#define RECORD_TYPE_FIELDS(type) (SCM_VECTOR_VEC(type)[2])
#define RECORD_TYPE(record)      (SCM_VECTOR_VEC(record)[1])
/* The index of the first field in a record. */
#define RECORD_FIELD_OFFSET 2

/*=======================================
  File Local Type Definitions
=======================================*/

/*=======================================
  Variable Definitions
=======================================*/
#include "functable-srfi9.c"

SCM_GLOBAL_VARS_BEGIN(static_srfi9);
#define static
static scm_bool l_initialized;
static ScmObj l_record_marker, l_record_type_marker, l_sym_data;
#undef static
SCM_GLOBAL_VARS_END(static_srfi9);
#define l_initialized        SCM_GLOBAL_VAR(static_srfi9, l_initialized)
#define l_record_marker      SCM_GLOBAL_VAR(static_srfi9, l_record_marker)
#define l_record_type_marker SCM_GLOBAL_VAR(static_srfi9, l_record_type_marker)
#define l_sym_data           SCM_GLOBAL_VAR(static_srfi9, l_sym_data)
SCM_DEFINE_STATIC_VARS(static_srfi9);

/*=======================================
  File Local Function Declarations
=======================================*/
static scm_bool record_ofp(ScmObj obj, ScmObj type);
static ScmObj make_record_procedure(enum ScmFuncTypeCode functype,
                                    ScmFuncType func, ScmObj formals,
                                    ScmObj data);
static ScmObj construct_record(ScmObj data, ScmObj args);
static ScmObj test_record(ScmObj type, ScmObj obj);
static ScmObj access_record(ScmObj data, ScmObj obj);
static ScmObj modify_record(ScmObj data, ScmObj obj, ScmObj value);
static ScmObj field_index(const char *func_name, ScmObj type, ScmObj field);

/*=======================================
  Function Definitions
=======================================*/
SCM_EXPORT void
scm_initialize_srfi9(void)
{
    SCM_GLOBAL_VARS_INIT(static_srfi9);

    /* Use pairs as the unique markers. The symbols are only for
     * human-readability. */
    scm_gc_protect_with_init(&l_record_marker,
                             LIST_1(scm_intern("%%record")));
    scm_gc_protect_with_init(&l_record_type_marker,
                             LIST_1(scm_intern("%%record-type")));
    l_sym_data = scm_intern("%%record-data");
    l_initialized = scm_true;

    scm_register_funcs(scm_functable_srfi9);
    /* lib/srfi-9.scm uses error. */
    scm_require_module("srfi-23");
    scm_load_system_file("srfi-9.scm");
}

/* They are used by write and equal?. They return false before SRFI-9 is
 * initialized. */
SCM_EXPORT scm_bool
scm_recordp(ScmObj obj)
{
    return (l_initialized && VECTORP(obj)
            && SCM_VECTOR_LEN(obj) >= RECORD_FIELD_OFFSET
            && EQ(SCM_VECTOR_VEC(obj)[0], l_record_marker));
}

SCM_EXPORT scm_bool
scm_record_typep(ScmObj obj)
{
    return (l_initialized && VECTORP(obj) && SCM_VECTOR_LEN(obj) == 3
            && EQ(SCM_VECTOR_VEC(obj)[0], l_record_type_marker));
}

/* Returns the name of the record type of RECORD or of the record type. */
SCM_EXPORT ScmObj
scm_record_type_name(ScmObj obj)
{
    return RECORD_TYPE_NAME(scm_recordp(obj) ? RECORD_TYPE(obj) : obj);
}

static scm_bool
record_ofp(ScmObj obj, ScmObj type)
{
    return scm_recordp(obj) && EQ(RECORD_TYPE(obj), type);
}

/* Returns (lambda FORMALS (FUNC DATA . FORMALS)). DATA is bound to a hidden
 * variable because a vector isn't self-evaluating with
 * strict_vector_form. */
static ScmObj
make_record_procedure(enum ScmFuncTypeCode functype, ScmFuncType func,
                      ScmObj formals, ScmObj data)
{
    ScmObj env, call;

    env = scm_extend_environment(LIST_1(l_sym_data), LIST_1(data),
                                 SCM_INTERACTION_ENV);
    call = CONS(MAKE_FUNC(functype, func),
                CONS(l_sym_data, CONSP(formals) ? formals : LIST_1(formals)));
    return MAKE_CLOSURE(LIST_2(formals, call), env);
}

/* Returns the index of FIELD in a record of TYPE. */
static ScmObj
field_index(const char *func_name, ScmObj type, ScmObj field)
{
    ScmObj fields;
    scm_int_t i;

    fields = RECORD_TYPE_FIELDS(type);
    for (i = RECORD_FIELD_OFFSET; CONSP(fields); fields = CDR(fields), i++) {
        if (EQ(CAR(fields), field))
            return MAKE_INT(i);
    }
    scm_error_obj(func_name, "record type has no such field", field);
    /* NOTREACHED */
    return SCM_FALSE;
}

/* FIELD-SPECS is ((field accessor [modifier]) ...). */
SCM_EXPORT ScmObj
scm_p_srfi9_make_record_type(ScmObj name, ScmObj field_specs)
{
    ScmQueue q;
    ScmObj fields, spec;
    ScmObj *vec;
    DECLARE_FUNCTION("%%make-record-type", procedure_fixed_2);

    ENSURE_SYMBOL(name);

    fields = SCM_NULL;
    SCM_QUEUE_POINT_TO(q, fields);
    FOR_EACH (spec, field_specs) {
        if (!CONSP(spec) || !SYMBOLP(CAR(spec)))
            ERR_OBJ("invalid field spec", spec);
        if (TRUEP(scm_p_memq(CAR(spec), fields)))
            ERR_OBJ("duplicate field", CAR(spec));
        SCM_QUEUE_ADD(q, CAR(spec));
    }

    vec = scm_malloc(sizeof(ScmObj) * 3);
    vec[0] = l_record_type_marker;
    vec[1] = name;
    vec[2] = fields;
    return MAKE_VECTOR(vec, 3);
}

SCM_EXPORT ScmObj
scm_p_srfi9_record_constructor(ScmObj type, ScmObj fields)
{
    ScmQueue q;
    ScmObj indexes, field;
    DECLARE_FUNCTION("%%record-constructor", procedure_fixed_2);

    if (!scm_record_typep(type))
        ERR_OBJ("record type required but got", type);

    indexes = SCM_NULL;
    SCM_QUEUE_POINT_TO(q, indexes);
    FOR_EACH (field, fields)
        SCM_QUEUE_ADD(q, field_index(SCM_MANGLE(name), type, field));

    return make_record_procedure(SCM_PROCEDURE_FIXED_2,
                                 (ScmFuncType)construct_record,
                                 scm_intern("args"), CONS(type, indexes));
}

/* DATA is (type index ...). */
static ScmObj
construct_record(ScmObj data, ScmObj args)
{
    ScmObj type, indexes, record, *vec;
    scm_int_t i, len;
    DECLARE_INTERNAL_FUNCTION("record constructor");

    type = CAR(data);
    indexes = CDR(data);
    if (scm_length(args) != scm_length(indexes))
        ERR_OBJ("wrong number of arguments for record type",
                RECORD_TYPE_NAME(type));

    len = RECORD_FIELD_OFFSET + scm_length(RECORD_TYPE_FIELDS(type));
    vec = scm_malloc(sizeof(ScmObj) * len);
    vec[0] = l_record_marker;
    vec[1] = type;
    for (i = RECORD_FIELD_OFFSET; i < len; i++)
        vec[i] = SCM_UNDEF;
    record = MAKE_VECTOR(vec, len);
    for (; CONSP(indexes); indexes = CDR(indexes), args = CDR(args))
        vec[SCM_INT_VALUE(CAR(indexes))] = CAR(args);
    return record;
}

SCM_EXPORT ScmObj
scm_p_srfi9_record_predicate(ScmObj type)
{
    DECLARE_FUNCTION("%%record-predicate", procedure_fixed_1);

    if (!scm_record_typep(type))
        ERR_OBJ("record type required but got", type);

    return make_record_procedure(SCM_PROCEDURE_FIXED_2,
                                 (ScmFuncType)test_record,
                                 LIST_1(scm_intern("obj")), type);
}

static ScmObj
test_record(ScmObj type, ScmObj obj)
{
    return MAKE_BOOL(record_ofp(obj, type));
}

SCM_EXPORT ScmObj
scm_p_srfi9_record_accessor(ScmObj type, ScmObj field)
{
    ScmObj index;
    DECLARE_FUNCTION("%%record-accessor", procedure_fixed_2);

    if (!scm_record_typep(type))
        ERR_OBJ("record type required but got", type);
    index = field_index(SCM_MANGLE(name), type, field);

    return make_record_procedure(SCM_PROCEDURE_FIXED_2,
                                 (ScmFuncType)access_record,
                                 LIST_1(scm_intern("obj")),
                                 CONS(type, index));
}

/* DATA is (type . index). */
static ScmObj
access_record(ScmObj data, ScmObj obj)
{
    DECLARE_INTERNAL_FUNCTION("record accessor");

    if (!record_ofp(obj, CAR(data)))
        ERR_OBJ("record of the type required but got", obj);
    return SCM_VECTOR_VEC(obj)[SCM_INT_VALUE(CDR(data))];
}

SCM_EXPORT ScmObj
scm_p_srfi9_record_modifier(ScmObj type, ScmObj field)
{
    ScmObj index;
    DECLARE_FUNCTION("%%record-modifier", procedure_fixed_2);

    if (!scm_record_typep(type))
        ERR_OBJ("record type required but got", type);
    index = field_index(SCM_MANGLE(name), type, field);

    return make_record_procedure(SCM_PROCEDURE_FIXED_3,
                                 (ScmFuncType)modify_record,
                                 LIST_2(scm_intern("obj"),
                                        scm_intern("value")),
                                 CONS(type, index));
}

/* DATA is (type . index). */
static ScmObj
modify_record(ScmObj data, ScmObj obj, ScmObj value)
{
    DECLARE_INTERNAL_FUNCTION("record modifier");

    if (!record_ofp(obj, CAR(data)))
        ERR_OBJ("record of the type required but got", obj);
    SCM_VECTOR_VEC(obj)[SCM_INT_VALUE(CDR(data))] = value;
    return SCM_UNDEF;
}

/* Records and record types aren't vectors. */
SCM_EXPORT ScmObj
scm_p_srfi9_vectorp(ScmObj obj)
{
    DECLARE_FUNCTION("vector?", procedure_fixed_1);

    return MAKE_BOOL(VECTORP(obj) && !scm_recordp(obj)
                     && !scm_record_typep(obj));
}
