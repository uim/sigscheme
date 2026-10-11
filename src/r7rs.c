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

/*=======================================
  Variable Definitions
=======================================*/

/*=======================================
  File Local Function Declarations
=======================================*/

/*=======================================
  Function Definitions
=======================================*/
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
