/*===========================================================================
 *  Filename : module-srfi55.c
 *  About    : require-extension
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

/*=======================================
  File Local Type Definitions
=======================================*/

/*=======================================
  Variable Definitions
=======================================*/
#include "functable-srfi55.c"

SCM_GLOBAL_VARS_BEGIN(static_srfi55);
#define static
static ScmObj l_sym_require_extension;
#undef static
SCM_GLOBAL_VARS_END(static_srfi55);
#define l_sym_require_extension SCM_GLOBAL_VAR(static_srfi55, \
                                               l_sym_require_extension)
SCM_DEFINE_STATIC_VARS(static_srfi55);

/*=======================================
  File Local Function Declarations
=======================================*/

/*=======================================
  Function Definitions
=======================================*/
SCM_EXPORT void
scm_initialize_srfi55(void)
{
    scm_register_funcs(scm_functable_srfi55);

    l_sym_require_extension = scm_intern("%require-extension");

    scm_require_module("sscm-ext");  /* for 'provided?' and 'provide' */
    scm_load_system_file("srfi-55.scm");
}

SCM_EXPORT ScmObj
scm_s_srfi55_require_extension(ScmObj clauses, ScmObj env)
{
    ScmObj proc;
    DECLARE_FUNCTION("require-extension", syntax_variadic_0);

    /*=======================================================================
      (require-extension <clause> ...)

      <clause> ::= (<extension-identifier>)
                   | (<extension-identifier> <extension-argument> ...)
      <extension-identifier> ::= <symbol>
      <extension-argument> ::= <any Scheme value>
    =======================================================================*/
    proc = scm_symbol_value(l_sym_require_extension, SCM_INTERACTION_ENV);

    return scm_call(proc, clauses);
}
