/*===========================================================================
 *  Filename : global.h
 *  About    : Global object handlings
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

#ifndef __SCM_GLOBAL_H
#define __SCM_GLOBAL_H

#include <sigscheme/config.h>
#include <sigscheme/config-old.h>

#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

/*=======================================
  Macro Definitions
=======================================*/
/* Consumes sizeof(void *) per struct to suppress the extra semicolon warnings
 * by default. Disable SCM_USE_WARNING_SUPPRESSOR to minimize memory
 * consumption. */
#if SCM_USE_WARNING_SUPPRESSOR
#define SCM_GLOBAL_STRUCT_WARNING_SUPPRESSOR void *dummy
#else
#define SCM_GLOBAL_STRUCT_WARNING_SUPPRESSOR
#endif

#define SCM_DEFINE_STATIC_VARS(_namespace)                                   \
    static struct scm_g_##_namespace scm_g_instance_##_namespace
#define SCM_GLOBAL_VARS_INIT(_namespace)                                     \
    (memset(&scm_g_instance_##_namespace, 0,                                 \
            sizeof(scm_g_instance_##_namespace)))
#define SCM_GLOBAL_VARS_FIN(_namespace) SCM_EMPTY_EXPR

#define SCM_GLOBAL_VARS_INSTANCE(_namespace)                                 \
    (scm_g_instance_##_namespace)

#define SCM_GLOBAL_VARS_BEGIN(_namespace)                                    \
    struct scm_g_##_namespace {                                              \
    SCM_GLOBAL_STRUCT_WARNING_SUPPRESSOR
#define SCM_GLOBAL_VARS_END(_namespace)                                      \
    }

#define SCM_GLOBAL_VAR(_namespace, _var_name)                                \
    (SCM_GLOBAL_VARS_INSTANCE(_namespace)._var_name)

#if SCM_COMBINED_SOURCE
/* define at declaration in the header file */
#define SCM_DECLARE_EXPORTED_VARS(_namespace)                                \
    SCM_DEFINE_STATIC_VARS(_namespace)
#define SCM_DEFINE_EXPORTED_VARS(_namespace)                                 \
    /* dummy statement to prevent static prefix */                           \
    struct scm_g_dummy_##_namespace { int dummy; }
#else /* SCM_COMBINED_SOURCE */
#define SCM_DECLARE_EXPORTED_VARS(_namespace)                                \
    SCM_EXTERN(struct scm_g_##_namespace scm_g_instance_##_namespace)
#define SCM_DEFINE_EXPORTED_VARS(_namespace)                                 \
    /* dummy statement to prevent static prefix */                           \
    struct scm_g_dummy_##_namespace { int dummy; };                          \
    SCM_EXPORT struct scm_g_##_namespace scm_g_instance_##_namespace
#endif /* SCM_COMBINED_SOURCE */

#if (SCM_COMBINED_SOURCE && !SCM_EXPORT_API)
#define SCM_EXTERN(_decl) extern int scm_g_dummy
#define SCM_EXPORT static

/* FIXME: reflect SCM_COMBINED_SOURCE */
#elif (defined(_WIN32) || defined(_WIN64))
#define SCM_EXTERN(_decl) extern _decl
#if SCM_COMPILING_LIBSSCM
#define SCM_EXPORT __declspec(dllexport)
#else /* SCM_COMPILING_LIBSSCM */
#define SCM_EXPORT __declspec(dllimport)
#endif /* SCM_COMPILING_LIBSSCM */

#else
#define SCM_EXTERN(_decl) extern _decl
#define SCM_EXPORT
#endif

/*=======================================
  Type Definitions
=======================================*/

/*=======================================
  Variable Declarations
=======================================*/

/*=======================================
  Function Declarations
=======================================*/

#ifdef __cplusplus
}
#endif

#endif /* __SCM_GLOBAL_H */
