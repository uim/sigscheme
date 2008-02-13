/*===========================================================================
 *  Filename : test-array2list.c
 *  About    : test for C array <-> Scheme list conversion functions
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

#include <assert.h>

#include "sscm-test.h"
#include "sigschemeinternal.h"


static char *char_ary[] = {
    "abc",
    "def",
    "gh",
    NULL
};

static ScmObj
make_str(void *str)
{
    return MAKE_STRING_COPYING((char *)str, SCM_STRLEN_UNKNOWN);
}

static void *
refer_c_str(ScmObj str)
{
    return SCM_STRING_STR(str);
}

TST_CASE("scm_array2list()")
{
    void **ary;

    ary = (void **)char_ary;

    TST_TN_EQ_INT(0, scm_length(scm_array2list(ary, 0, make_str)));
    TST_TN_TRUE  (        NULLP(scm_array2list(ary, 0, make_str)));

    TST_TN_EQ_INT(1, scm_length(scm_array2list(ary, 1, make_str)));
    TST_TN_TRUE  (EQUALP(scm_eval_c_string("'(\"abc\")"),
                         scm_array2list(ary, 1, make_str)));

    TST_TN_EQ_INT(2, scm_length(scm_array2list(ary, 2, make_str)));
    TST_TN_TRUE  (EQUALP(scm_eval_c_string("'(\"abc\" \"def\")"),
                         scm_array2list(ary, 2, make_str)));

    TST_TN_EQ_INT(3, scm_length(scm_array2list(ary, 3, make_str)));
    TST_TN_TRUE  (EQUALP(scm_eval_c_string("'(\"abc\" \"def\" \"gh\")"),
                         scm_array2list(ary, 3, make_str)));
}

TST_CASE("scm_array2list() without conversion")
{
    ScmObj obj_ary[4];
    void **ary;

    obj_ary[0] = make_str(char_ary[0]);
    obj_ary[1] = make_str(char_ary[1]);
    obj_ary[2] = make_str(char_ary[2]);
    obj_ary[3] = SCM_EOF;
    ary = (void **)obj_ary;

    TST_TN_EQ_INT(0, scm_length(scm_array2list(ary, 0, NULL)));
    TST_TN_TRUE  (        NULLP(scm_array2list(ary, 0, NULL)));

    TST_TN_EQ_INT(1, scm_length(scm_array2list(ary, 1, NULL)));
    TST_TN_TRUE  (EQUALP(scm_eval_c_string("'(\"abc\")"),
                         scm_array2list(ary, 1, NULL)));

    TST_TN_EQ_INT(2, scm_length(scm_array2list(ary, 2, NULL)));
    TST_TN_TRUE  (EQUALP(scm_eval_c_string("'(\"abc\" \"def\")"),
                         scm_array2list(ary, 2, NULL)));

    TST_TN_EQ_INT(3, scm_length(scm_array2list(ary, 3, NULL)));
    TST_TN_TRUE  (EQUALP(scm_eval_c_string("'(\"abc\" \"def\" \"gh\")"),
                         scm_array2list(ary, 3, NULL)));
}

TST_CASE("scm_list2array()")
{
    const char *list1 = "'(\"abc\")";
    const char *list3 = "'(\"abc\" \"def\" \"gh\")";
    void **ary;
    size_t len;

    ary = scm_list2array(SCM_NULL, &len, refer_c_str);
    TST_TN_EQ_INT(0, len);

    ary = scm_list2array(scm_eval_c_string(list1), &len, refer_c_str);
    TST_TN_EQ_INT(1, len);
    TST_TN_EQ_STR("abc", ary[0]);

    ary = scm_list2array(scm_eval_c_string(list3), &len, refer_c_str);
    TST_TN_EQ_INT(3, len);
    TST_TN_EQ_STR("abc", ary[0]);
    TST_TN_EQ_STR("def", ary[1]);
    TST_TN_EQ_STR("gh",  ary[2]);
}

TST_CASE("scm_list2array() without conversion")
{
    const char *list1 = "'(\"abc\")";
    const char *list3 = "'(\"abc\" \"def\" \"gh\")";
    void **ary;
    size_t len;

    ary = scm_list2array(SCM_NULL, &len, NULL);
    TST_TN_EQ_INT(0, len);

    ary = scm_list2array(scm_eval_c_string(list1), &len, NULL);
    TST_TN_EQ_INT(1, len);
    TST_TN_TRUE(EQUALP(CONST_STRING("abc"), (ScmObj)ary[0]));

    ary = scm_list2array(scm_eval_c_string(list3), &len, NULL);
    TST_TN_EQ_INT(3, len);
    TST_TN_TRUE(EQUALP(CONST_STRING("abc"), (ScmObj)ary[0]));
    TST_TN_TRUE(EQUALP(CONST_STRING("def"), (ScmObj)ary[1]));
    TST_TN_TRUE(EQUALP(CONST_STRING("gh"),  (ScmObj)ary[2]));
}
