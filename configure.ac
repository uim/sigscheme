AC_PREREQ(2.60b)
AC_INIT([SigScheme], [0.9.4], [sigscheme-ja@googlegroups.com], [sigscheme])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_SRCDIR([src/sigscheme.c])
AC_CONFIG_HEADERS([src/config.h])
AM_INIT_AUTOMAKE([1.10 foreign dist-bzip2])

# Enable this iff asprintf(3) or another GNU extension is needed. This macro
# must be invoked immediately after initialization.
#AC_GNU_SOURCE

# --enable-maintainer-mode is requied to build Git repository version of
# SigScheme.
AM_MAINTAINER_MODE

#
# Checks for programs
#

AC_PROG_CC
AC_PROG_LIBTOOL
AC_PROG_LN_S
AC_PROG_EGREP
# Prefers GNU sed if found. GNU sed is required for generating
# test-c/collect.sh from Git repository version of SigScheme.
AC_PROG_SED

# These programs are only needed on make dist
AC_PATH_PROGS(RUBY, ruby18 ruby)
AC_PATH_PROGS(PERL, perl5 perl)
AC_PATH_PROG(ASCIIDOC, asciidoc)
AC_PATH_PROG(SH, sh)
AC_PATH_PROGS(MD5, md5 md5sum)
AC_PATH_PROGS(SHA1, sha1 sha1sum)
AC_PATH_PROGS(SHA256, sha256 sha256sum)

#
# Checks for libraries
#

AX_LIB_GLIBC

#
# Checks for header files
#

AC_HEADER_STDC
AC_CHECK_HEADERS([stdint.h inttypes.h sys/inttypes.h sys/types.h \
                  limits.h malloc.h stddef.h stdlib.h string.h \
                  strings.h unistd.h assert.h])

#
# Checks for typedefs, structures, and compiler characteristics
#

# FIXME: depending on the internal variable name
AC_DEFUN([AX_LANG_WNOERROR], [ac_[]_AC_LANG_ABBREV[]_werror_flag=])

AC_C_CONST
AC_C_VOLATILE
AC_C_STRINGIZE

AC_C_RESTRICT
AC_C_INLINE

AC_C_CHAR_UNSIGNED
AX_C_ARITHMETIC_RSHIFT
AX_C___ATTRIBUTE__
AX_C_REFERENCEABLE_PASSED_VA_LIST
if test "x$ax_cv_c_referenceable_passed_va_list" = xno; then
  # Temporary workaround: Assumes that va_list passed via an arg equals to
  # &va_list[0].
  AC_DEFINE(HAVE_AUTOREFERRED_PASSED_VA_LIST, 1,
            [Define to 1 if va_list is an array type.])
fi

AC_C_BIGENDIAN
if test "x$ac_cv_c_bigendian" = xyes; then
  ax_c_endian=big
elif test "x$ac_cv_c_bigendian" = xno; then
  ax_c_endian=little
else
  ax_c_endian=$ac_cv_c_bigendian
fi

# a submacro of ax_create_stdint_h.m4
AX_CHECK_DATA_MODEL

AC_TYPE_LONG_LONG_INT
AC_TYPE_UNSIGNED_LONG_LONG_INT
AC_TYPE_LONG_DOUBLE
AC_TYPE_LONG_DOUBLE_WIDER

# stdint types
AC_TYPE_INT8_T
AC_TYPE_INT16_T
AC_TYPE_INT32_T
AC_TYPE_INT64_T
AC_TYPE_INTMAX_T
AC_TYPE_INTPTR_T
AC_TYPE_UINT8_T
AC_TYPE_UINT16_T
AC_TYPE_UINT32_T
AC_TYPE_UINT64_T
AC_TYPE_UINTMAX_T
AC_TYPE_UINTPTR_T

AC_CHECK_SIZEOF(char)
AC_CHECK_SIZEOF(short)
AC_CHECK_SIZEOF(int)
AC_CHECK_SIZEOF(long)
AC_CHECK_SIZEOF(long long)
AC_CHECK_SIZEOF(float)
AC_CHECK_SIZEOF(double)
AC_CHECK_SIZEOF(long double)
AC_CHECK_SIZEOF(void *)
AC_CHECK_SIZEOF(size_t)

# Do not assume (sizeof(int32_t) == 4) and so on (i.e. do not (CHAR_BIT == 8)).
AC_CHECK_SIZEOF(int8_t)
AC_CHECK_SIZEOF(int16_t)
AC_CHECK_SIZEOF(int32_t)
AC_CHECK_SIZEOF(int64_t)
AC_CHECK_SIZEOF(intmax_t)
AC_CHECK_SIZEOF(intptr_t)
#AC_CHECK_SIZEOF(int_least8_t)
#AC_CHECK_SIZEOF(int_least16_t)
#AC_CHECK_SIZEOF(int_least32_t)
#AC_CHECK_SIZEOF(int_least64_t)
#AC_CHECK_SIZEOF(int_fast8_t)
#AC_CHECK_SIZEOF(int_fast16_t)
#AC_CHECK_SIZEOF(int_fast32_t)
#AC_CHECK_SIZEOF(int_fast64_t)

AC_CHECK_ALIGNOF(char)
AC_CHECK_ALIGNOF(short)
AC_CHECK_ALIGNOF(int)
AC_CHECK_ALIGNOF(long)
AC_CHECK_ALIGNOF(long long)
AC_CHECK_ALIGNOF(float)
AC_CHECK_ALIGNOF(double)
AC_CHECK_ALIGNOF(long double)
AC_CHECK_ALIGNOF(void *)
AC_CHECK_ALIGNOF(size_t)

AC_CHECK_ALIGNOF(int8_t)
AC_CHECK_ALIGNOF(int16_t)
AC_CHECK_ALIGNOF(int32_t)
AC_CHECK_ALIGNOF(int64_t)
AC_CHECK_ALIGNOF(intmax_t)
AC_CHECK_ALIGNOF(intptr_t)
#AC_CHECK_ALIGNOF(int_least8_t)
#AC_CHECK_ALIGNOF(int_least16_t)
#AC_CHECK_ALIGNOF(int_least32_t)
#AC_CHECK_ALIGNOF(int_least64_t)
#AC_CHECK_ALIGNOF(int_fast8_t)
#AC_CHECK_ALIGNOF(int_fast16_t)
#AC_CHECK_ALIGNOF(int_fast32_t)
#AC_CHECK_ALIGNOF(int_fast64_t)

AC_TYPE_SIZE_T
AC_TYPE_SSIZE_T

#AC_TYPE_MBSTATE_T
#AC_TYPE_MODE_T
#AC_TYPE_OFF_T
#AC_TYPE_PID_T
#AC_TYPE_SIGNAL
#AC_TYPE_UID_T

if $CC --version >/dev/null 2>/dev/null; then
  ax_prog_cc_version=`$CC --version | head -n 1`
else
  ax_prog_cc_version="unknown"
fi

AX_CHECK_COMPILE_FLAG([-pedantic])
AX_CHECK_COMPILE_FLAG([-Wall])
AX_CHECK_COMPILE_FLAG([-Wchar-subscripts])
AX_CHECK_COMPILE_FLAG([-Wmissing-declarations])
AX_CHECK_COMPILE_FLAG([-Wredundant-decls])
AX_CHECK_COMPILE_FLAG([-Wmissing-prototypes])
AX_CHECK_COMPILE_FLAG([-Wnested-externs])
AX_CHECK_COMPILE_FLAG([-Wpointer-arith])
AX_CHECK_COMPILE_FLAG([-Wcast-align])
AX_CHECK_COMPILE_FLAG([-Wsign-compare])

# Suppress warnings about strings longer than ISO C 89 maximum length (509).
AX_CHECK_COMPILE_FLAG([-Wno-overlength-strings])

# Disable the problematic preprocessing on Mac OS X
AX_CHECK_COMPILE_FLAG([-no-cpp-precomp])

#
# Checks for library functions
#

AX_FUNC_SIGSETJMP

AC_CHECK_FUNCS([getcontext strtoll strtoimax \
                memalign \
                fileno getcwd getpagesize])

AC_CHECK_FUNCS(posix_memalign,
  [
    # For posix_memalign(3). although this value is overridden by _GNU_SOURCE
    # on glibc, keep this for other environments.
    AC_DEFINE(_POSIX_C_SOURCE, 200112L)
  ])
AH_VERBATIM(_POSIX_C_SOURCE,
[/* Define to 200112L to enable posix_memalign(3). */
#if SCM_COMPILING_LIBSSCM
#undef _POSIX_C_SOURCE
#endif])

AC_CHECK_FUNCS(memalign)

AC_CHECK_FUNCS(strdup,
  [
    # Overrides _POSIX_C_SOURCE
    AC_DEFINE(_XOPEN_SOURCE, 500)
  ])
AH_VERBATIM(_XOPEN_SOURCE,
[/* Define to 500 to enable strdup(3). */
#if SCM_COMPILING_LIBSSCM
#undef _XOPEN_SOURCE
#endif])

AC_CHECK_FUNCS(strcasecmp,
  [
    if test "x$ax_cv_lib_glibc" = xyes; then
      AC_DEFINE(_BSD_SOURCE, 1)
    fi
  ],
  [
    AC_LIBOBJ(strcasecmp)
  ])
AH_VERBATIM(_BSD_SOURCE,
[/* Define to 1 if it is needed to enable strcasecmp(3). */
#if SCM_COMPILING_LIBSSCM
#undef _BSD_SOURCE
#endif])

AX_CHECK_PAGE_ALIGNED_MALLOC


#####################
# Optional packages #
#####################

AC_ARG_WITH(master-pkg,
            AS_HELP_STRING([--with-master-pkg@<:@=NAME@:>@],
                           [specify alternative package name for pkgdatadir.
                            @<:@default=sigscheme@:>@]))

case "${with_master_pkg:=no}" in
  no|yes)
    SSCM_MASTER_PKG="sigscheme"
  ;;
  *)
    SSCM_MASTER_PKG="${with_master_pkg}"
  ;;
esac

AC_SUBST(SSCM_MASTER_PKG)
AM_CONDITIONAL(WITH_MASTER_PKG, [test "x$with_master_pkg" != xno])

AC_ARG_WITH(libgcroots,
            AS_HELP_STRING([--with-libgcroots@<:@=WHICH@:>@],
                           [use alternative libgcroots instead of
                            package-bundled one.
                            WHICH=(installed|tiny-subst)
                            @<:@default=installed@:>@]))

case "${with_libgcroots:=no}" in
  no)
    # bundled libgcroots package

    ac_configure_args="$ac_configure_args "
    AC_CONFIG_SUBDIRS([libgcroots])

    # Specify absolute directories to make being usable from superordinate
    # packages such as uim.
    GCROOTS_LIBS='$(sscm_abs_top_builddir)/libgcroots/libgcroots.la'
    GCROOTS_CFLAGS='-I$(sscm_abs_top_srcdir)/libgcroots/include'
    use_libgcroots="bundled one"
    GCROOTS_REQ=gcroots
  ;;
  yes|installed)
    PKG_CHECK_MODULES(GCROOTS, [gcroots >= 0.2.3],
                      [],
                      [AC_MSG_ERROR([installed libgcroots is not found.])])
    use_libgcroots="installed one"
    GCROOTS_REQ=gcroots
  ;;
  tiny-subst)
    # use src/gcroots/gcroots.[hc]
    with_libgcroots=tiny_subst
    GCROOTS_CFLAGS='-I$(sscm_abs_top_srcdir)/src/gcroots'
    use_libgcroots="tiny substitution in src/gcroots"
  ;;
  *)
    AC_MSG_ERROR([invalid argument for --with-libgcroots.])
  ;;
esac

AC_SUBST(GCROOTS_REQ)
AC_SUBST(GCROOTS_LIBS)
AC_SUBST(GCROOTS_CFLAGS)
AM_CONDITIONAL(USE_LIBGCROOTS, [test "x$with_libgcroots" != xtiny_subst])
AM_CONDITIONAL(USE_LIBGCROOTS_BUNDLED, [test "x$with_libgcroots" = xno])
AM_CONDITIONAL(USE_LIBGCROOTS_TINY_SUBST,
               [test "x$with_libgcroots" = xtiny_subst])


########################################
# Configure features with dependencies #
########################################

# Init with default prefixes for shell var, AC_DEFINE, AM_CONDITIONAL
AX_FEATURE_CONFIGURATOR([use_], [SCM_USE_], [USE_])

#
# Acquire the feature configuration variables from user
#

# Pseudo feature as base dependency: Features that required to run current
# SigScheme implementation depends on this.
AX_FEATURE_VAR_Y(sigscheme, [pseudo feature for dependency resolution])

# Specify a set of default variable settings
AX_FEATURE_ARG_X(conf, [select base configuration of SigScheme.
                        CONF=(regular|full|small|r5rs|siod|dev|uim) @<:@regular@:>@],
                       [regular], [^(regular|full|small|r5rs|siod|dev|uim)$],
  [
    # multibyte char handlings
    case "$enable_conf" in
      full|dev)
        use_utf8=yes
        use_euccn=yes
        use_eucjp=yes
        use_euckr=yes
        use_sjis=yes
        ;;
      small|siod)
        use_default_encoding=singlebyte
        use_utf8=no
        use_euccn=no
        use_eucjp=no
        use_euckr=no
        use_sjis=no
        use_strict_encoding_check=no
        ;;
      uim)
        use_default_encoding=singlebyte
        use_utf8=yes
        use_euccn=no
        use_eucjp=yes
        use_euckr=no
        use_sjis=no
        use_strict_encoding_check=no
        ;;
    esac

    # R5RS behaviors
    case "$enable_conf" in
      r5rs)
        use_strict_r5rs=yes
        ;;
      full|dev)
        use_strict_r5rs=no
        #use_const_list_literal=yes
        use_const_vector_literal=yes
        #use_strict_null_form=yes
        use_strict_vector_form=yes
        use_strict_argcheck=yes
        use_strict_toplevel_definitions=yes
        use_internal_definitions=yes
        ;;
      uim)
        use_strict_r5rs=no
        #use_const_list_literal=yes
        use_const_vector_literal=yes
        use_strict_null_form=no
        use_strict_vector_form=yes
        use_strict_argcheck=yes
        use_strict_toplevel_definitions=yes
        use_internal_definitions=yes
        ;;
      small|siod)
        use_strict_r5rs=no
        use_const_list_literal=no
        use_const_vector_literal=no
        use_strict_null_form=no
        use_strict_vector_form=no
        use_strict_argcheck=no
        use_strict_toplevel_definitions=no
        use_internal_definitions=no
        ;;
    esac

    # R5RS features
    case "$enable_conf" in
      full|r5rs|dev)
        use_continuation=yes
        use_quasiquote=yes
        use_promise=yes
        use_int=yes
        use_numeric_io=yes
        use_char=yes
        use_string=yes
        use_string_procedures=yes
        use_deep_cadrs=yes
        use_vector=yes
        use_port=yes
        use_reader=yes
        use_writer=yes
        use_load=yes
        ;;
      small)
        use_continuation=no
        use_quasiquote=no
        use_promise=no
        use_int=yes
        use_numeric_io=yes
        use_char=yes
        use_string=yes
        use_string_procedures=yes
        use_deep_cadrs=no
        use_vector=no
        use_port=yes
        use_reader=yes
        use_writer=yes
        use_load=yes
        ;;
      siod)
        use_continuation=no
        use_quasiquote=no
        use_promise=no
        use_int=yes
        use_numeric_io=yes
        use_char=no
        use_string=yes
        use_string_procedures=no
        use_deep_cadrs=no
        use_vector=no
        use_port=yes
        use_reader=yes
        use_writer=yes
        use_load=yes
        ;;
      uim)
        use_continuation=yes
        use_quasiquote=yes
        use_promise=yes
        use_int=yes
        use_numeric_io=yes
        use_char=yes
        use_string=yes
        use_string_procedures=yes
        use_deep_cadrs=no
        use_vector=yes
        use_port=yes
        use_reader=yes
        use_writer=yes
        use_load=yes
        ;;
    esac

    # experimental features
    case "$enable_conf" in
      dev)
        use_hygienic_macro=yes
        ;;
      *)
        use_hygienic_macro=no
        ;;
    esac

    # SRFIs
    case "$enable_conf" in
      full|r5rs|dev|uim)
        use_srfi0=yes
        use_srfi1=yes
        use_srfi2=yes
        use_srfi6=yes
        use_srfi8=yes
        use_srfi9=yes
        use_srfi22=yes
        use_srfi23=yes
        use_srfi28=yes
        use_srfi34=yes
        use_srfi38=yes
        use_srfi43=yes
        use_srfi48=yes
        use_srfi55=yes
        use_srfi60=yes
        use_srfi69=yes
        use_srfi95=yes
        ;;
      small|siod)
        use_srfi0=no
        use_srfi1=no
        use_srfi2=no
        use_srfi6=no
        use_srfi8=no
        use_srfi9=no
        use_srfi22=no
        use_srfi23=no
        use_srfi28=no
        use_srfi34=no
        use_srfi38=no
        use_srfi43=no
        use_srfi48=no
        use_srfi55=no
        use_srfi60=no
        use_srfi69=no
        use_srfi95=no
        ;;
    esac

    # SigScheme-specific extensions
    case "$enable_conf" in
      full|r5rs|dev)
        use_legacy_macro=yes
        use_sscm_extensions=yes
        use_sscm_format_extension=yes
        use_compat_siod=no
        use_compat_siod_bugs=no
        use_eval_c_string=yes
        ;;
      small)
        use_legacy_macro=no
        use_sscm_extensions=no
        use_sscm_format_extension=no
        use_compat_siod=no
        use_compat_siod_bugs=no
        use_eval_c_string=no
        ;;
      siod)
        use_legacy_macro=no
        use_sscm_extensions=yes
        use_sscm_format_extension=no
        use_compat_siod=yes
        use_compat_siod_bugs=yes
        use_eval_c_string=yes
        ;;
      uim)
        use_legacy_macro=yes
        use_sscm_extensions=yes
        use_sscm_format_extension=yes
        use_compat_siod=yes
        use_compat_siod_bugs=no
        use_eval_c_string=yes
        ;;
    esac

    # R6RS features
    case "$enable_conf" in
      full|dev|uim)
        use_r6rs_named_chars=yes
        use_r6rs_chars=yes
        ;;
      r5rs|small|siod)
        use_r6rs_named_chars=no
        use_r6rs_chars=no
        ;;
    esac

    # Debugging features
    case "$enable_conf" in
      dev)
        use_backtrace=yes
        use_debug=yes
        use_warning_suppressor=yes
        ;;
    esac
  ])

# If the variable is preexisting, it is used as default value. explicit
# --enable or --disable can override it.

# Storage configuration
AX_FEATURE_ARG_X(storage,   [specify underlying storage implementation.
                             STORAGE=(compact|fatty) @<:@compact@:>@],
                            [compact], [^(compact|fatty)$])
AX_FEATURE_ARG_X(fixnum,    [specify Scheme integer (fixnum) size.
                             FIXNUM=(long|int|int32_t|int64_t) @<:@long@:>@],
                            [long], [^(long|int|int32_t|int64_t)$])
AX_FEATURE_VAR_X(scmref,    [specify scm_intref_t (don't touch)],
                            [intptr_t], [^(intptr_t|int32_t|int64_t)$])
AX_FEATURE_VAR_N(valuecons, [valuecons for efficient multiple values handling])
AX_FEATURE_VAR_N(dump,      [storage dump (not implemented yet)])

# String configuration
#AX_FEATURE_VAR_N(const-width-string, [strings consist of constant-width characters (not implemented yet)])
AX_FEATURE_VAR_N(null-capable-string, [null character in a middle of a string (experimental)])

# Character encodings
AX_FEATURE_VAR_N(multibyte,    [multibyte character encodings])
AX_FEATURE_ARG_X(default-encoding,
                               [specify default character encoding.
                                ENCODING=(utf8|singlebyte|euccn|eucjp|euckr|sjis) @<:@utf8@:>@],
                               [utf8],
                               [^(utf8|singlebyte|euccn|eucjp|euckr|sjis)$])
AX_FEATURE_ARG_Y(utf8,         [UTF-8 character encoding])
AX_FEATURE_ARG_N(euccn,        [EUC-CN character encoding])
AX_FEATURE_ARG_N(eucjp,        [EUC-JP character encoding])
AX_FEATURE_ARG_N(euckr,        [EUC-KR character encoding])
AX_FEATURE_ARG_N(sjis,         [Shift_JIS character encoding])
AX_FEATURE_ARG_Y(strict-encoding-check, [all feasible encoding error checks])

# Other internal SigScheme features
AX_FEATURE_VAR_N(format,       [intermediate format strings])
AX_FEATURE_VAR_N(raw-c-format, [internal format which takes raw C values from va_list])

# R5RS behaviors
AX_FEATURE_ARG_N(strict-r5rs,          [strict R5RS conformance checks])
AX_FEATURE_ARG_N(const-list-literal,   [immutable list literals])
AX_FEATURE_ARG_Y(const-vector-literal, [immutable vector literals])
AX_FEATURE_ARG_N(strict-null-form,     [rejecting quote-less ()])
AX_FEATURE_ARG_Y(strict-vector-form,   [rejecting quote-less vector literal])
AX_FEATURE_ARG_Y(strict-argcheck,      [strict check for form arguments])
AX_FEATURE_ARG_Y(strict-toplevel-definitions, [strict check for R5RS top-level definitions])
AX_FEATURE_ARG_Y(internal-definitions, [R5RS internal definitions])

# R5RS features
AX_FEATURE_ARG_Y(continuation,   [R5RS continuation])
AX_FEATURE_ARG_Y(quasiquote,     [R5RS quasiquotation])
AX_FEATURE_ARG_N(hygienic-macro, [R5RS hygienic macros (experimental)])
AX_FEATURE_ARG_Y(promise,        [R5RS promises])
AX_FEATURE_VAR_N(number,         [R5RS numbers])
AX_FEATURE_ARG_Y(int,            [R5RS integer numbers])
AX_FEATURE_VAR_N(rational,       [R5RS rational numbers (not implemented yet)])
AX_FEATURE_VAR_N(real,           [R5RS real numbers (not implemented yet)])
AX_FEATURE_VAR_N(complex,        [R5RS complex numbers (not implemented yet)])
AX_FEATURE_ARG_Y(numeric-io,     [R5RS 'number->string' and 'string->number'])
AX_FEATURE_ARG_Y(char,           [R5RS characters])
AX_FEATURE_ARG_Y(string,         [primary procedures of R5RS strings])
AX_FEATURE_ARG_Y(string-procedures, [rest procedures of R5RS strings])
AX_FEATURE_ARG_Y(deep-cadrs, [all c@<:@ad@:>@+r procedures defined in R5RS])
AX_FEATURE_ARG_Y(vector,         [R5RS vectors])
AX_FEATURE_ARG_Y(port,           [R5RS ports])
AX_FEATURE_ARG_Y(reader,         [R5RS 'read'])
AX_FEATURE_ARG_Y(writer,         [R5RS 'write' and 'display'])
AX_FEATURE_ARG_Y(load,           [R5RS 'load'])

# SRFIs
AX_FEATURE_ARG_Y(srfi0,          [SRFI-0 'cond-expand'])
AX_FEATURE_ARG_Y(srfi1,          [SRFI-1 list library])
AX_FEATURE_ARG_Y(srfi2,          [SRFI-2 'and-let*'])
AX_FEATURE_ARG_Y(srfi6,          [SRFI-6 basic string ports])
AX_FEATURE_ARG_Y(srfi8,          [SRFI-8 'receive'])
AX_FEATURE_ARG_Y(srfi9,          [SRFI-9 defining record types])
AX_FEATURE_ARG_Y(srfi22,         [SRFI-22 running scheme scripts on Unix (partial)])
AX_FEATURE_ARG_Y(srfi23,         [SRFI-23 'error'])
AX_FEATURE_ARG_Y(srfi28,         [SRFI-28 'format'])
AX_FEATURE_ARG_Y(srfi34,         [SRFI-34 exception handling for programs])
AX_FEATURE_ARG_Y(srfi38,         [SRFI-38 'write/ss' ('read/ss' is not provided)])
AX_FEATURE_ARG_Y(srfi43,         [SRFI-43 vector library])
AX_FEATURE_ARG_Y(srfi48,         [SRFI-48 'format' (superset of SRFI-28)])
AX_FEATURE_ARG_Y(srfi55,         [SRFI-55 'require-extension'])
AX_FEATURE_ARG_Y(srfi60,         [SRFI-60 integers as bits (partial)])
AX_FEATURE_ARG_Y(srfi69,         [SRFI-69 basic hash tables])
AX_FEATURE_ARG_Y(srfi95,         [SRFI-95 sorting and merging])

# R6RS features (preliminary)
AX_FEATURE_ARG_Y(r6rs-named-chars, [named characters of R6RS (preliminary)])
AX_FEATURE_ARG_Y(r6rs-chars,       [R6RS characters (preliminary)])

# Common Scheme features
AX_FEATURE_VAR_N(syntax-case,      ['syntax-case' (not implemented yet)])
AX_FEATURE_VAR_N(unhygienic-macro, [syntactic closure (not implemented yet)])
AX_FEATURE_ARG_Y(legacy-macro,     ['define-macro' syntactic closure])

# SigScheme-specific features
AX_FEATURE_ARG_Y(sscm-extensions,     [SigScheme-specific extensions])
AX_FEATURE_ARG_Y(sscm-format-extension, [SigScheme-specific 'format+'])
AX_FEATURE_ARG_N(compat-siod,         [some SIOD compatible features])
AX_FEATURE_ARG_N(compat-siod-bugs,    [emulating the buggy behaviors of SIOD])
AX_FEATURE_ARG_Y(eval-c-string,       [eval_c_string() of libsscm])
AX_FEATURE_ARG_N(backtrace,           [showing backtrace on error])
AX_FEATURE_ARG_Y(libsscm,             [building libsscm])
AX_FEATURE_ARG_Y(shell,               [the 'sscm' interactive shell])

# Developer-only debugging features
AX_FEATURE_ARG_N(debug,               [debug mode])
AX_FEATURE_ARG_N(debug-port,          [port debugging])
AX_FEATURE_ARG_N(debug-parser,        [parser debugging])
AX_FEATURE_ARG_N(debug-macro,         [macro and pattern matching debugging])
AX_FEATURE_ARG_N(debug-encoding,      [encoding-related functions debugging])
AX_FEATURE_ARG_N(debug-backtrace-sep, [frame-separator on backtrace])
AX_FEATURE_ARG_N(debug-backtrace-val, [values printing on backtrace])
AX_FEATURE_ARG_N(soft-assert,         [recovery from failed SCM_ASSERT()])
AX_FEATURE_ARG_N(accessor-assert,     [type assertion on Scheme object accessors])
AX_FEATURE_ARG_Y(warning-suppressor,  [suppressing compiler warnings])

#
# Resolve dependency of the features
#

# Resolve required dependencies
AX_FEATURE_RESOLVE_DEPENDENCIES([required], [
sigscheme: raw_c_format
backtrace: continuation port writer
debug: raw_c_format
debug_backtrace_val: debug backtrace raw_c_format

format: writer port string
srfi28: format
srfi48: format srfi28
sscm_format_extension: format srfi48
raw_c_format: format

hygienic_macro:
syntax_case: unhygienic_macro
string_procedures: string_procedure
string_procedure: string char
reader: port
writer: port raw_c_format
load: port reader string
sscm_extensions: load
eval_c_string: reader srfi6
srfi0: load srfi55 legacy_macro srfi1 srfi23
srfi1: continuation deep_cadrs load sscm_extensions srfi8 srfi23
srfi6: port string
srfi9: load vector srfi23
srfi34: continuation srfi23
srfi38: writer
srfi43: load vector srfi8 srfi23 sscm_extensions
srfi55: load sscm_extensions
srfi60: int
srfi69: load int string vector srfi9 srfi23
srfi95: load int
r6rs_named_chars: char
r6rs_chars: char utf8 reader r6rs_named_chars

compat_siod: sscm_extensions srfi60 eval_c_string
compat_siod_bugs: compat_siod
strict_r5rs: strict_null_form strict_vector_form strict_argcheck internal_definitions strict_toplevel_definitions const_vector_literal

int:        number
rational:   number
real:       number
complex:    number
numeric_io: number_io
number_io:  number string

fixnum_long:     long_fixnum
fixnum_int:      int_fixnum
fixnum_int32_t:  32bit_fixnum
fixnum_int64_t:  64bit_fixnum
scmref_intptr_t: intptr_scmref
scmref_int32_t:  32bit_scmref
scmref_int64_t:  64bit_scmref

multibyte: multibyte_char
utf8:  multibyte_char
eucjp: multibyte_char
euckr: multibyte_char
euccn: multibyte_char
sjis:  multibyte_char
default_encoding_utf8:       utf8  utf8_as_default
default_encoding_singlebyte: singlebyte_as_default
default_encoding_euccn:      euccn euccn_as_default
default_encoding_eucjp:      eucjp eucjp_as_default
default_encoding_euckr:      euckr euckr_as_default
default_encoding_sjis:       sjis  sjis_as_default

shell: libsscm
])

# Resolve recommended dependencies (not required)
AX_FEATURE_RESOLVE_DEPENDENCIES([recommended], [
conf_dev: warning_suppressor
storage_fatty: valuecons const_list_literal const_vector_literal
debug: accessor_assert strict_argcheck strict_encoding_check
backtrace: srfi38
srfi69: srfi38
])

# Resolve weak dependencies required if and only if available
dnl AX_FEATURE_RESOLVE_WEAK_DEPENDENCIES([
dnl strict_r5rs: const_list_literal
dnl ])

# Check conflicts between the features
AX_FEATURE_DETECT_CONFLICTS([
storage_fatty storage_compact
storage_compact valuecons
storage_compact const_list_literal
debug_no null_capable_string
strict_r5rs compat_siod_bugs
strict_r5rs strict_vector_form_no
strict_r5rs strict_null_form_no
strict_r5rs strict_toplevel_definitions_no
strict_r5rs internal_definitions_no
compat_siod_bugs strict_null_form
long_fixnum int_fixnum 32bit_fixnum 64bit_fixnum
intptr_scmref 32bit_scmref 64bit_scmref
singlebyte_as_default utf8_as_default eucjp_as_default euckr_as_default euccn_as_default sjis_as_default
],
[if-conflict])

#
# Define configured results
#

# Storage configuration
AX_FEATURE_DEFINE(storage_compact)
AX_FEATURE_DEFINE(storage_fatty)
AX_FEATURE_DEFINE(long_fixnum)
AX_FEATURE_DEFINE(int_fixnum)
AX_FEATURE_DEFINE(32bit_fixnum)
AX_FEATURE_DEFINE(64bit_fixnum)
AX_FEATURE_DEFINE(intptr_scmref)
AX_FEATURE_DEFINE(32bit_scmref)
AX_FEATURE_DEFINE(64bit_scmref)
AX_FEATURE_DEFINE(valuecons)
AX_FEATURE_DEFINE(dump)

# String configuration
#AX_FEATURE_DEFINE(const_width_string)
AX_FEATURE_DEFINE(null_capable_string)

# Character encodings
AX_FEATURE_DEFINE(multibyte_char)
AX_FEATURE_DEFINE(utf8)
AX_FEATURE_DEFINE(euccn)
AX_FEATURE_DEFINE(eucjp)
AX_FEATURE_DEFINE(euckr)
AX_FEATURE_DEFINE(sjis)
AX_FEATURE_DEFINE(utf8_as_default)
AX_FEATURE_DEFINE(singlebyte_as_default)
AX_FEATURE_DEFINE(euccn_as_default)
AX_FEATURE_DEFINE(eucjp_as_default)
AX_FEATURE_DEFINE(euckr_as_default)
AX_FEATURE_DEFINE(sjis_as_default)
AX_FEATURE_DEFINE(strict_encoding_check, SCM_STRICT_ENCODING_CHECK, STRICT_ENCODING_CHECK)

# Other internal SigScheme features
AX_FEATURE_DEFINE(format)
AX_FEATURE_DEFINE(raw_c_format)

# R5RS behaviors
AX_FEATURE_DEFINE(strict_r5rs,        SCM_STRICT_R5RS,      STRICT_R5RS)
AX_FEATURE_DEFINE(const_list_literal, SCM_CONST_LIST_LITERAL, CONST_LIST_LITERAL)
AX_FEATURE_DEFINE(const_vector_literal, SCM_CONST_VECTOR_LITERAL, CONST_VECTOR_LITERAL)
AX_FEATURE_DEFINE(strict_null_form,   SCM_STRICT_NULL_FORM,  STRICT_NULL_FORM)
AX_FEATURE_DEFINE(strict_vector_form, SCM_STRICT_VECTOR_FORM, STRICT_VECTOR_FORM)
AX_FEATURE_DEFINE(strict_argcheck,    SCM_STRICT_ARGCHECK,  STRICT_ARGCHECK)
AX_FEATURE_DEFINE(strict_toplevel_definitions, SCM_STRICT_TOPLEVEL_DEFINITIONS, STRICT_TOPLEVEL_DEFINITIONS)
AX_FEATURE_DEFINE(internal_definitions)

# R5RS features
AX_FEATURE_DEFINE(continuation)
AX_FEATURE_DEFINE(quasiquote)
AX_FEATURE_DEFINE(hygienic_macro)
AX_FEATURE_DEFINE(promise)
AX_FEATURE_DEFINE(number)
AX_FEATURE_DEFINE(int)
AX_FEATURE_DEFINE(rational)
AX_FEATURE_DEFINE(real)
AX_FEATURE_DEFINE(complex)
AX_FEATURE_DEFINE(number_io)
AX_FEATURE_DEFINE(char)
AX_FEATURE_DEFINE(string)
AX_FEATURE_DEFINE(string_procedure)
AX_FEATURE_DEFINE(deep_cadrs)
AX_FEATURE_DEFINE(vector)
AX_FEATURE_DEFINE(port)
AX_FEATURE_DEFINE(reader)
AX_FEATURE_DEFINE(writer)
AX_FEATURE_DEFINE(load)

# SRFIs
AX_FEATURE_DEFINE(srfi0)
AX_FEATURE_DEFINE(srfi1)
AX_FEATURE_DEFINE(srfi2)
AX_FEATURE_DEFINE(srfi6)
AX_FEATURE_DEFINE(srfi8)
AX_FEATURE_DEFINE(srfi9)
AX_FEATURE_DEFINE(srfi22)
AX_FEATURE_DEFINE(srfi23)
AX_FEATURE_DEFINE(srfi28)
AX_FEATURE_DEFINE(srfi34)
AX_FEATURE_DEFINE(srfi38)
AX_FEATURE_DEFINE(srfi43)
AX_FEATURE_DEFINE(srfi48)
AX_FEATURE_DEFINE(srfi55)
AX_FEATURE_DEFINE(srfi60)
AX_FEATURE_DEFINE(srfi69)
AX_FEATURE_DEFINE(srfi95)

# R6RS features (preliminary)
AX_FEATURE_DEFINE(r6rs_named_chars)
AX_FEATURE_DEFINE(r6rs_chars)

# Common Scheme features
AX_FEATURE_DEFINE(syntax_case)
AX_FEATURE_DEFINE(unhygienic_macro)
AX_FEATURE_DEFINE(legacy_macro)

# SigScheme-specific features
AX_FEATURE_DEFINE(sscm_extensions)
AX_FEATURE_DEFINE(sscm_format_extension)
AX_FEATURE_DEFINE(compat_siod,        SCM_COMPAT_SIOD,      COMPAT_SIOD)
AX_FEATURE_DEFINE(compat_siod_bugs,   SCM_COMPAT_SIOD_BUGS, COMPAT_SIOD_BUGS)
AX_FEATURE_DEFINE(eval_c_string)
AX_FEATURE_DEFINE(backtrace)
AX_FEATURE_DEFINE(libsscm)
AX_FEATURE_DEFINE(shell)

# Developer-only debugging features
AX_FEATURE_DEFINE(debug,               SCM_DEBUG,           DEBUG)
AX_FEATURE_DEFINE(debug_port,          SCM_DEBUG_PORT,      DEBUG_PORT)
AX_FEATURE_DEFINE(debug_parser,        SCM_DEBUG_PARSER,    DEBUG_PARSER)
AX_FEATURE_DEFINE(debug_macro,         SCM_DEBUG_MACRO,     DEBUG_MACRO)
AX_FEATURE_DEFINE(debug_encoding,      SCM_DEBUG_ENCODING,  DEBUG_ENCODING)
AX_FEATURE_DEFINE(debug_backtrace_sep, SCM_DEBUG_BACKTRACE_SEP, DEBUG_BACKTRACE_SEP)
AX_FEATURE_DEFINE(debug_backtrace_val, SCM_DEBUG_BACKTRACE_VAL, DEBUG_BACKTRACE_VAL)
AX_FEATURE_DEFINE(soft_assert,         SCM_SOFT_ASSERT,     SOFT_ASSERT)
AX_FEATURE_DEFINE(accessor_assert,     SCM_ACCESSOR_ASSERT, ACCESSOR_ASSERT)
AX_FEATURE_DEFINE(warning_suppressor)

AC_SUBST(use_storage)
AC_SUBST(use_fixnum)
AC_SUBST(use_multibyte_char)
AC_SUBST(use_default_encoding)
AC_SUBST(use_utf8)
AC_SUBST(use_euccn)
AC_SUBST(use_eucjp)
AC_SUBST(use_euckr)
AC_SUBST(use_sjis)
AC_SUBST(use_strict_r5rs)
AC_SUBST(use_const_list_literal)
AC_SUBST(use_const_vector_literal)
AC_SUBST(use_strict_null_form)
AC_SUBST(use_strict_vector_form)
AC_SUBST(use_strict_argcheck)
AC_SUBST(use_strict_toplevel_definitions)
AC_SUBST(use_internal_definitions)
AC_SUBST(use_continuation)
AC_SUBST(use_quasiquote)
AC_SUBST(use_hygienic_macro)
AC_SUBST(use_promise)
AC_SUBST(use_int)
AC_SUBST(use_number_io)
AC_SUBST(use_char)
AC_SUBST(use_string)
AC_SUBST(use_string_procedure)
AC_SUBST(use_deep_cadrs)
AC_SUBST(use_vector)
AC_SUBST(use_port)
AC_SUBST(use_reader)
AC_SUBST(use_writer)
AC_SUBST(use_load)
AC_SUBST(use_srfi0)
AC_SUBST(use_srfi1)
AC_SUBST(use_srfi2)
AC_SUBST(use_srfi6)
AC_SUBST(use_srfi8)
AC_SUBST(use_srfi9)
AC_SUBST(use_srfi22)
AC_SUBST(use_srfi23)
AC_SUBST(use_srfi28)
AC_SUBST(use_srfi34)
AC_SUBST(use_srfi38)
AC_SUBST(use_srfi43)
AC_SUBST(use_srfi48)
AC_SUBST(use_srfi55)
AC_SUBST(use_srfi60)
AC_SUBST(use_srfi69)
AC_SUBST(use_srfi95)
AC_SUBST(use_r6rs_chars)
AC_SUBST(use_r6rs_named_chars)
AC_SUBST(use_legacy_macro)
AC_SUBST(use_sscm_extensions)
AC_SUBST(use_sscm_format_extension)
AC_SUBST(use_compat_siod)
AC_SUBST(use_compat_siod_bugs)
AC_SUBST(use_eval_c_string)
AC_SUBST(use_backtrace)
AC_SUBST(use_debug)

#########
# Fixup #
#########

#
# Hardwired configurations
#

AC_DEFINE(SCM_ENCODING_USE_WITH_SIGSCHEME, 1,
  [Define to 1 to adapt encoding.c to SigScheme.])
AC_DEFINE(SCM_SCMPORT_USE_WITH_SIGSCHEME, 1,
  [Define to 1 to adapt scmport*.[hc] to SigScheme.])

#
# Compiler options
#

# Debugging-related flags
if test "x$use_debug" = xyes; then
  if test "x$ac_cv_prog_cc_g" = xyes; then
    CFLAGS="$CFLAGS -g3"
  fi
else
  CFLAGS="$CFLAGS -DNDEBUG"
fi

#
# System directories
#
scmlibdir='${pkgdatadir}/lib'
AC_SUBST(scmlibdir)
SSCM_DEFS='-DPKGDATADIR="\"$(pkgdatadir)\"" -DSCMLIBDIR="\"$(scmlibdir)\""'
AC_SUBST(SSCM_DEFS)

###############################
# Output configuration result #
###############################

# This include guard is required to prevent being overridden by
# system-installed config.h on a source that is compiled on
# !SCM_COMPILING_LIBSSCM such as test-c/test-*.c.
AH_TOP([#ifndef __SIGSCHEME_CONFIG_H
#define __SIGSCHEME_CONFIG_H])

# FIXME: temporary solution
AH_BOTTOM([
/* FIXME: temporary solution */
#include "config-old.h"

#endif /* __SIGSCHEME_CONFIG_H */])

AC_CONFIG_FILES([sigscheme.pc
                 libgcroots.mk
                 sigscheme.mk
                 Makefile
                 doc/Makefile
                 m4/Makefile
                 tools/Makefile
                 include/Makefile
                 include/sigscheme/Makefile
                 src/Makefile
                 lib/Makefile
                 test/Makefile
                 test/run-singletest.sh
                 test-c/Makefile
                 test-c/collect.sh
                 bench/Makefile])

AC_OUTPUT

AC_MSG_RESULT([[
SigScheme has been configured as follows:

base config:  $use_conf

[Storage configuration]
Storage impl: $use_storage
Fixnum size:  $use_fixnum
getcontext:   $ac_cv_func_getcontext
libgcroots:   $use_libgcroots

[Multibyte character handlings]
Multibyte chars:  ${use_multibyte_char:-no}
Default encoding: $use_default_encoding
UTF-8 codec:      $use_utf8
EUC-CN codec:     $use_euccn
EUC-JP codec:     $use_eucjp
EUC-KR codec:     $use_euckr
Shift_JIS codec:  $use_sjis

[R5RS behaviors]
Strict R5RS:           $use_strict_r5rs
Const list literal:    $use_const_list_literal
Const vector literal:  $use_const_vector_literal
Strict null form:      $use_strict_null_form
Strict vector form:    $use_strict_vector_form
Strict argcheck:       $use_strict_argcheck
Strict top-level defs: $use_strict_toplevel_definitions
Internal definitions:  $use_internal_definitions

[R5RS features]
Continuation:       $use_continuation
Quasiquote:         $use_quasiquote
Hygienic macros:    $use_hygienic_macro
Promise:            $use_promise
Integer:            $use_int
Numeric I/O:        ${use_number_io:-no}
Charcters:          $use_char
Strings:            $use_string
String procedures:  ${use_string_procedure:-no}
Deep c[ad]+r procs: $use_deep_cadrs
Vectors:            $use_vector
Ports:              $use_port
Reader:             $use_reader
Writer:             $use_writer
Load:               $use_load

[SRFIs]
SRFI-0:  $use_srfi0
SRFI-1:  $use_srfi1
SRFI-2:  $use_srfi2
SRFI-6:  $use_srfi6
SRFI-8:  $use_srfi8
SRFI-9:  $use_srfi9
SRFI-22: $use_srfi22
SRFI-23: $use_srfi23
SRFI-28: $use_srfi28
SRFI-34: $use_srfi34
SRFI-38: $use_srfi38
SRFI-43: $use_srfi43
SRFI-48: $use_srfi48
SRFI-55: $use_srfi55
SRFI-60: $use_srfi60
SRFI-69: $use_srfi69
SRFI-95: $use_srfi95

[R6RS features (preliminary)]
R6RS characters:  $use_r6rs_chars
R6RS named chars: $use_r6rs_named_chars

[SigScheme-specific extensions]
define-macro:         $use_legacy_macro
SigScheme extensions: $use_sscm_extensions
format+ procedure:    $use_sscm_format_extension
SIOD compatibilities: $use_compat_siod
SIOD bugs emulation:  $use_compat_siod_bugs
eval_c_string():      $use_eval_c_string
Backtrace:            $use_backtrace
Library:              $use_libsscm
Interactive shell:    $use_shell

[Developer-only debugging features]
Debug:              $use_debug]])

if test "x$use_debug" = xyes; then
  AC_MSG_RESULT(
[[Debug port:         $use_debug
Debug parser:       $use_debug
Debug macro:        $use_debug
Debug encoding:     $use_debug
Soft assert:        $use_soft_assert
Accessor assert:    $use_accessor_assert
Warning suppressor: $use_warning_suppressor]])
fi

AC_MSG_RESULT([[
[Build information (provide this on bug reports)]
Package:                $PACKAGE_STRING
build (compile on):     $ac_cv_build
host (compile for):     $ac_cv_host
host data model:        $ac_cv_data_model
host align (C/S/I/L/P): ${ac_cv_alignof_char}/${ac_cv_alignof_short}/${ac_cv_alignof_int}/${ac_cv_alignof_long}/${ac_cv_alignof_void_p}
host endian:            $ax_c_endian
host char unsigned:     $ac_cv_c_char_unsigned
host arithmetic rshift: $ax_cv_c_arithmetic_rshift
host safe va_list ref:  $ax_cv_c_referenceable_passed_va_list
Compiler:               $CC
Compiler version:       $ax_prog_cc_version
CFLAGS='$CFLAGS']])
