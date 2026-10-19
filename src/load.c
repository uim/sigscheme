/*===========================================================================
 *  Filename : load.c
 *  About    : Code loading
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

#include <ctype.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <sigscheme/sigscheme.h>
#include "sigschemeinternal.h"
#if SCM_USE_MULTIBYTE_CHAR
#include "scmport-config.h"
#include "scmport.h"
#include "scmport-mbchar.h"
#endif
/* A file in another encoding is converted by iconv(3) and read from a
 * string port. */
#define USE_CODING_CONVERSION                                                \
    (SCM_USE_MULTIBYTE_CHAR && SCM_USE_SRFI6 && HAVE_ICONV)
#if USE_CODING_CONVERSION
#include <errno.h>
#include <iconv.h>
#include "scmport-str.h"
#endif

/*=======================================
  File Local Macro Definitions
=======================================*/
/* FIXME: only supports UNIX flavors */
#define PATH_SEPARATOR ':'

#if SCM_USE_MULTIBYTE_CHAR
/* The coding declaration such as ";; -*- coding: euc-jp -*-" must be in
 * the first 2 lines like Emacs. */
#define CODING_DECLARATION_LINES 2
#define CODING_DECLARATION_MAXLEN 512
#define CODING_NAME_MAXLEN 63
#endif

#if SCM_USE_SRFI22
/* SRFI-22: The <script prelude> line may not be longer than 64 characters. */
#define SCRIPT_PRELUDE_MAXLEN 64
#define SCRIPT_PRELUDE_DELIM  " \t\n\r"
#endif

/*=======================================
  File Local Type Definitions
=======================================*/

/*=======================================
  Variable Definitions
=======================================*/
#include "functable-r5rs-load.c"

SCM_GLOBAL_VARS_BEGIN(static_load);
#define static
static char *l_scm_lib_path, *l_scm_system_load_path;
static ScmObj l_load_fallback_encodings;
#undef static
SCM_GLOBAL_VARS_END(static_load);
#define l_scm_lib_path         SCM_GLOBAL_VAR(static_load, l_scm_lib_path)
#define l_scm_system_load_path SCM_GLOBAL_VAR(static_load, l_scm_system_load_path)
#define l_load_fallback_encodings                                            \
    SCM_GLOBAL_VAR(static_load, l_load_fallback_encodings)
SCM_DEFINE_STATIC_VARS(static_load);

/*=======================================
  File Local Function Declarations
=======================================*/
static void *scm_load_internal(const char *filename);
static void load_file(const char *filename, ScmObj env);
#if SCM_USE_MULTIBYTE_CHAR
static ScmObj open_source_file(ScmObj path);
static scm_bool read_coding(FILE *file, char *coding);
static scm_bool same_encodingp(const char *encoding1, const char *encoding2);
#endif
#if USE_CODING_CONVERSION
static char *read_file(FILE *file, size_t *size);
static ScmObj open_input_bytes(char *str, size_t size);
static scm_bool convert(char **str, size_t *size, const char *from,
                        const char *to);
#endif
static char *find_path(const char *filename);
static scm_bool file_existsp(const char *filepath);
#if SCM_USE_SRFI22
static void interpret_script_prelude(ScmObj port);
static char **parse_script_prelude(ScmObj port);
#endif

/*=======================================
  Function Definitions
=======================================*/
SCM_EXPORT void
scm_init_load(void)
{
    SCM_GLOBAL_VARS_INIT(static_load);

    scm_gc_protect_with_init(&l_load_fallback_encodings, SCM_NULL);
    scm_register_funcs(scm_functable_r5rs_load);
}

SCM_EXPORT void
scm_fin_load(void)
{
    free(l_scm_lib_path);
    free(l_scm_system_load_path);

    l_scm_system_load_path = NULL;

    SCM_GLOBAL_VARS_FIN(static_load);
}

/* Don't provide any Scheme procedure to call this function, to avoid security
 * problems. User modification of the value or relative path capability may
 * cause arbitrary C code injection by plugin spoofing when future SigScheme
 * has been added C plugin feature. It could be a serious vulnerability if the
 * libsscm client is a setugid'ed command. -- YamaKen 2006-03-25 */
SCM_EXPORT void
scm_set_lib_path(const char *path)
{
    const char *begin, *end;
    DECLARE_INTERNAL_FUNCTION("scm_set_lib_path");

    begin = path;
    while (begin[0] != '\0') {
        while (begin[0] == PATH_SEPARATOR)
            begin++;

        end = begin;
        while (end[0] != '\0' && end[0] != PATH_SEPARATOR)
            end++;

        if (!ABSOLUTE_PATHP(begin))
            ERR("library path must be absolute but got: ~S", path);
        begin = end;
    }

    free(l_scm_lib_path);
    l_scm_lib_path = (path) ? scm_strdup(path) : NULL;
}

/* SigScheme specific procedure (SIOD compatible) */
SCM_EXPORT ScmObj
scm_p_load_path(void)
{
    DECLARE_FUNCTION("load-path", procedure_fixed_0);

    return CONST_STRING(l_scm_lib_path);
}

/* Encodings that are tried in order for a source file without a coding
 * declaration if it's invalid in the current codec. */
SCM_EXPORT ScmObj
scm_p_load_fallback_encodings(void)
{
    DECLARE_FUNCTION("%%load-fallback-encodings", procedure_fixed_0);

    return l_load_fallback_encodings;
}

SCM_EXPORT ScmObj
scm_p_set_load_fallback_encodingsx(ScmObj encodings)
{
    ScmObj rest, encoding;
    DECLARE_FUNCTION("%%set-load-fallback-encodings!", procedure_fixed_1);

    rest = encodings;
    FOR_EACH (encoding, rest)
        ENSURE_STRING(encoding);
    if (!NULLP(rest))
        ERR_OBJ("proper list required but got", encodings);

    l_load_fallback_encodings = encodings;
    return SCM_UNDEF;
}

SCM_EXPORT void
scm_load_system_file(const char *file)
{
    ScmObj path;
    DECLARE_INTERNAL_FUNCTION("scm_load_system_file");

    path = scm_p_string_append(LIST_3(scm_p_system_load_path(),
                                      CONST_STRING("/"),
                                      CONST_STRING(file)));
#if SCM_USE_R7RS
    /* System files define builtins. */
    load_file(SCM_STRING_STR(path), scm_builtin_module());
#else
    scm_p_load(path);
#endif
}

SCM_EXPORT void
scm_set_system_load_path(const char *path)
{
    DECLARE_INTERNAL_FUNCTION("scm_set_system_load_path");

    if (!ABSOLUTE_PATHP(path))
        ERR("library path must be absolute but got: ~S", path);

    free(l_scm_system_load_path);
    l_scm_system_load_path = (path) ? scm_strdup(path) : NULL;
}

SCM_EXPORT ScmObj
scm_p_system_load_path(void)
{
    const char *path;
    DECLARE_FUNCTION("%%system-load-path", procedure_fixed_0);

    path = (l_scm_system_load_path) ? l_scm_system_load_path : SCMLIBDIR;
    return CONST_STRING(path);
}

/*===========================================================================
  R5RS : 6.6 Input and Output : 6.6.4 System Interface
===========================================================================*/
SCM_EXPORT void
scm_load(const char *filename)
{
    scm_call_with_gc_ready_stack((ScmGCGateFunc)scm_load_internal,
                                 (void *)filename);
}

/* FIXME: scm_current_char_codec on an exception */
static void *
scm_load_internal(const char *filename)
{
    load_file(filename, SCM_INTERACTION_ENV);
    return NULL;
}

/* Evaluates expressions in FILENAME in the toplevel environment ENV. */
static void
load_file(const char *filename, ScmObj env)
{
    ScmObj path, port, sexp;
    char *c_path;
#if SCM_USE_MULTIBYTE_CHAR
    ScmCharCodec *saved_codec;
#endif
    DECLARE_INTERNAL_FUNCTION("load");

    CDBG((SCM_DBG_FILE, "loading ~S", filename));

    c_path = find_path(filename);
    if (!c_path)
        scm_kind_error(SCM_ERRKIND_FILE, SCM_MANGLE(name),
                       "file \"~S\" not found", filename);

    path = MAKE_IMMUTABLE_STRING(c_path, STRLEN_UNKNOWN);
#if SCM_USE_MULTIBYTE_CHAR
    port = open_source_file(path);
#else
    port = scm_p_open_input_file(path);
#endif

#if SCM_USE_MULTIBYTE_CHAR
    saved_codec = scm_current_char_codec;
#endif
#if SCM_USE_SRFI22
    if (scm_port_peek_char(port) == '#')
        interpret_script_prelude(port);
#endif

    /* read & eval cycle */
    while (sexp = scm_read(port), !EOFP(sexp))
        EVAL(sexp, env);

    scm_p_close_input_port(port);
#if SCM_USE_MULTIBYTE_CHAR
    scm_current_char_codec = saved_codec;
#endif

    CDBG((SCM_DBG_FILE, "done."));
}

#if SCM_USE_MULTIBYTE_CHAR
/* Opens the source file PATH. It's converted to the current codec if it
 * has a coding declaration of another encoding. If it doesn't have a
 * coding declaration and it's invalid in the current codec, the fallback
 * encodings are tried. The generic singlebyte codec ISO-8859-1 reads
 * bytes as is. */
static ScmObj
open_source_file(ScmObj path)
{
    FILE *file;
    char coding[CODING_NAME_MAXLEN + sizeof("")];
    const char *encoding;
    scm_bool declaredp;
#if USE_CODING_CONVERSION
    ScmObj rest, fallback;
    char *str;
    size_t size;
#endif
    DECLARE_INTERNAL_FUNCTION("load");

    encoding = SCM_CHARCODEC_ENCODING(scm_current_char_codec);
    if (same_encodingp(encoding, "ISO-8859-1")
        || !(file = fopen(SCM_STRING_STR(path), "rb")))
        return scm_p_open_input_file(path);

    declaredp = read_coding(file, coding);
#if USE_CODING_CONVERSION
    if (declaredp && !same_encodingp(coding, encoding)) {
        str = read_file(file, &size);
        if (!convert(&str, &size, coding, encoding)) {
            free(str);
            ERR("can't convert ~S from ~S to ~S",
                SCM_STRING_STR(path), coding, encoding);
        }
        return open_input_bytes(str, size);
    }
    if (!declaredp && CONSP(l_load_fallback_encodings)) {
        str = read_file(file, &size);
        /* Converting to the current encoding itself validates STR. */
        if (!convert(&str, &size, encoding, encoding)) {
            rest = l_load_fallback_encodings;
            FOR_EACH (fallback, rest) {
                if (convert(&str, &size, SCM_STRING_STR(fallback), encoding))
                    break;
            }
        }
        return open_input_bytes(str, size);
    }
#else
    if (declaredp && !same_encodingp(coding, encoding)) {
        fclose(file);
        ERR("encoding conversion isn't supported: ~S", coding);
    }
#endif
    fclose(file);
    return scm_p_open_input_file(path);
}

/* Reads the encoding name of the coding declaration into CODING. */
static scm_bool
read_coding(FILE *file, char *coding)
{
    char buf[CODING_DECLARATION_MAXLEN + sizeof("")];
    char *p;
    size_t len;
    int c, n_lines;

    len = 0;
    n_lines = 0;
    while (len < CODING_DECLARATION_MAXLEN
           && (c = getc(file)) != EOF) {
        if (c == '\n' && ++n_lines == CODING_DECLARATION_LINES)
            break;
        buf[len++] = c;
    }
    buf[len] = '\0';
    rewind(file);

    for (p = buf; (p = strstr(p, "coding")); ) {
        p += sizeof("coding") - sizeof("");
        if (*p != ':' && *p != '=')
            continue;
        for (p++; *p == ' ' || *p == '\t'; p++)
            ;
        for (len = 0;
             len < CODING_NAME_MAXLEN
                 && (isalnum((unsigned char)*p)
                     || *p == '-' || *p == '_' || *p == '.');
             p++)
            coding[len++] = *p;
        coding[len] = '\0';
        /* Emacs' end-of-line suffix such as utf-8-unix */
        p = strrchr(coding, '-');
        if (p && (strcmp(p, "-unix") == 0 || strcmp(p, "-dos") == 0
                  || strcmp(p, "-mac") == 0))
            *p = '\0';
        return (len > 0);
    }
    return scm_false;
}

/* Compares encoding names ignoring case, '-' and '_': utf8 = UTF-8 */
static scm_bool
same_encodingp(const char *encoding1, const char *encoding2)
{
    for (;;) {
        while (*encoding1 == '-' || *encoding1 == '_')
            encoding1++;
        while (*encoding2 == '-' || *encoding2 == '_')
            encoding2++;
        if (tolower((unsigned char)*encoding1)
            != tolower((unsigned char)*encoding2))
            return scm_false;
        if (*encoding1 == '\0')
            return scm_true;
        encoding1++;
        encoding2++;
    }
}
#endif /* SCM_USE_MULTIBYTE_CHAR */

#if USE_CODING_CONVERSION
/* Returns the whole content of FILE. FILE is closed. */
static char *
read_file(FILE *file, size_t *size)
{
    char *str;
    size_t str_size, len, ret;

    str_size = BUFSIZ;
    str = scm_malloc(str_size);
    len = 0;
    while ((ret = fread(str + len, 1, str_size - len, file)) > 0) {
        len += ret;
        if (len == str_size) {
            str_size *= 2;
            str = scm_realloc(str, str_size);
        }
    }
    fclose(file);

    *size = len;
    return str;
}

/* Returns an input port of STR of SIZE bytes. The port owns STR. */
static ScmObj
open_input_bytes(char *str, size_t size)
{
    ScmBytePort *bport;

    bport = ScmInputStrPort_new_bytes(str, size, NULL);
    return MAKE_PORT(scm_make_char_port(bport), SCM_PORTFLAG_INPUT);
}

/* Converts STR of SIZE bytes from FROM to TO. STR and SIZE are replaced
 * only if the conversion succeeds. */
static scm_bool
convert(char **str, size_t *size, const char *from, const char *to)
{
    iconv_t cd;
    char *in_p, *out, *out_p;
    size_t in_left, out_size, out_left, out_len, ret;
    scm_bool flushed, failed;

    cd = iconv_open(to, from);
    if (cd == (iconv_t)-1)
        return scm_false;

    out_size = *size * 2 + 1;
    out = scm_malloc(out_size);
    in_p = *str;
    in_left = *size;
    out_p = out;
    out_left = out_size;
    flushed = failed = scm_false;
    while (!flushed && !failed) {
        if (in_left > 0) {
            ret = iconv(cd, &in_p, &in_left, &out_p, &out_left);
        } else {
            /* Flush the shift state of a stateful encoding. */
            ret = iconv(cd, NULL, NULL, &out_p, &out_left);
            flushed = (ret != (size_t)-1);
        }
        if (ret == (size_t)-1) {
            if (errno == E2BIG) {
                out_len = out_p - out;
                out_size *= 2;
                out = scm_realloc(out, out_size);
                out_p = out + out_len;
                out_left = out_size - out_len;
            } else {
                failed = scm_true;
            }
        }
    }
    iconv_close(cd);
    if (failed) {
        free(out);
        return scm_false;
    }

    free(*str);
    *str = out;
    *size = out_p - out;
    return scm_true;
}
#endif /* USE_CODING_CONVERSION */

#if SCM_USE_R7RS
/* Returns the absolute path of FILENAME searched in the library path or
 * NULL. The returned path must be freed. */
SCM_EXPORT char *
scm_find_path(const char *filename)
{
    return find_path(filename);
}
#endif

static char *
find_path(const char *filename)
{
    char *path;
    const char *begin, *end;
    size_t lib_path_len, filename_len, path_len;

    SCM_ASSERT(filename);

    /* try absolute path */
    if (file_existsp(filename))
        return scm_strdup(filename);

    /* try under l_scm_lib_path */
    /* l_scm_lib_path is separated with PATH_SEPARATOR */
    if (l_scm_lib_path) {
        begin = l_scm_lib_path;
        while (begin[0] != '\0') {
            while (begin[0] == PATH_SEPARATOR)
                begin++;

            end = begin;
            while (end[0] != '\0' && end[0] != PATH_SEPARATOR)
                end++;

            if (end > begin)
                lib_path_len = end - begin;
            else
                lib_path_len = 0;
            filename_len = strlen(filename);
            path_len = lib_path_len + sizeof((char)'/') + filename_len + sizeof("");

            path = scm_malloc(path_len);
            strncpy(path, begin, lib_path_len);
            path[lib_path_len] = '\0';
            strcat(path, "/");
            strcat(path, filename);
            if (file_existsp(path))
                return path;
            free(path);
            begin = end;
        }
    }

    return NULL;
}

static scm_bool
file_existsp(const char *filepath)
{
    FILE *f;

    SCM_ASSERT(filepath);

    if (!ABSOLUTE_PATHP(filepath))
        return scm_false;

    f = fopen(filepath, "r");
    if (f) {
        fclose(f);
        return scm_true;
    } else {
        return scm_false;
    }
}

SCM_EXPORT ScmObj
scm_p_load(ScmObj filename)
{
    DECLARE_FUNCTION("load", procedure_fixed_1);

    ENSURE_STRING(filename);

    scm_load_internal(SCM_STRING_STR(filename));

    return SCM_UNDEF;
}

#if SCM_USE_SRFI22
static void
interpret_script_prelude(ScmObj port)
{
    char **argv;

    argv = parse_script_prelude(port);
    scm_interpret_argv(argv);
#if SCM_USE_MULTIBYTE_CHAR
    if (SCM_CHARPORT_DYNAMIC_CAST(ScmMultiByteCharPort, SCM_PORT_IMPL(port))) {
        ScmMultiByteCharPort_set_codec(SCM_PORT_IMPL(port),
                                       scm_current_char_codec);
    }
#endif
    scm_free_argv(argv);
}

static char **
parse_script_prelude(ScmObj port)
{
    scm_ichar_t c;
    int argc, len, line_len;
    char **argv, *arg, *p;
    char line[SCRIPT_PRELUDE_MAXLEN];

    for (p = line; p < &line[SCRIPT_PRELUDE_MAXLEN]; p++) {
        c = scm_port_get_char(port);
        if (!ICHAR_ASCIIP(c))
            PLAIN_ERR("non-ASCII char appeared in UNIX script prelude");
        if (c == SCM_NEWLINE_STR[0]) {
            *p = '\0';
            break;
        }
        *p = c;
    }
    if (p == &line[SCRIPT_PRELUDE_MAXLEN])
        PLAIN_ERR("too long UNIX script prelude (max 64)");
    line_len = p - line;

    if (line[0] != '#' || line[1] != '!') {
        PLAIN_ERR("invalid UNIX script prelude");
    }
#if 1
    /* strict check */
    if (line[2] != ' ') {
        PLAIN_ERR("invalid UNIX script prelude: "
                  "SRFI-22 requires a space after hash-bang sequence");
    }
#endif

    argv = scm_malloc(sizeof(char *));
    argv[0] = NULL;
    argc = 0;
    for (p = &line[3]; p < &line[line_len]; p += len + sizeof((char)'\0')) {
        p += strspn(p, SCRIPT_PRELUDE_DELIM);
        len = strcspn(p, SCRIPT_PRELUDE_DELIM);
        if (!len)
            break;
        p[len] = '\0';
        arg = scm_strdup(p);
        argv[argc] = arg;
        argv = scm_realloc(argv, sizeof(char *) * (++argc + 1));
        argv[argc] = NULL;
    }

    return argv;
}
#endif /* SCM_USE_SRFI22 */
