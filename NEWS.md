# NEWS

## 1.0.1 - 2026-11-22

This release adds SRFI-64 (A Scheme API for test suites) and the
`--load` option of `sscm`. It also fixes build failures and test
failures with some features disabled.

### Incompatible changes

  * Removed `--enable-numeric-io` and `-Dnumeric_io`. `number->string`
    and `string->number` are always enabled. A build failed without
    them.

  * Required Meson 1.1.0 or later.

  * `lambda`, `define` and `case-lambda` reject an improper body such
    as `(lambda () 1 . 1)` on creating a procedure with strict
    argument check. It was rejected on calling the procedure.

### Improvements

  * Added SRFI-64 A Scheme API for test suites (`--enable-srfi64` and
    `-Dsrfi64=true`). It's enabled by default. See "SRFI-64 A Scheme
    API for test suites" in `doc/spec.txt` for details.

  * Added `--load` option to `sscm`. `sscm --load FILE SCRIPT` loads
    `FILE` before `SCRIPT`.

  * Installed `COPYING` and `README.md`.

  * Added support for AddressSanitizer. See "AddressSanitizer" in
    `README.md` for details.

  * Suppressed false positives of Valgrind on the stack scan of the
    GC (`-Dvalgrind=enabled`). It's enabled by default when
    `valgrind/memcheck.h` exists on build.
    * [uim/uim#60](https://github.com/uim/uim/issues/60)

  * Updated bundled libgcroots to 0.3.8.

### Fixes

  * Fixed a bug that `define-macro` kept its identifier as a normal
    procedure when it failed for a closure that doesn't have the
    toplevel environment.

  * Fixed memory leaks on an error of `make-vector`, `list->string`,
    `bytevector`, `read-bytevector`, `write` and `display` of a pair
    or a vector with R7RS, `format` of a number and a script prelude
    with a relative `--system-load-path`.

  * Fixed build failures and test failures with some features
    disabled.
    * SRFI-0 doesn't require `quasiquote`.
    * The following features are enabled automatically when a feature
      that requires them is enabled: `quasiquote` for SRFI-43, string
      procedures for SRFI-69 and SRFI-180, and internal definitions for
      SRFI-95 and SRFI-180.

### Notes for packagers and system integrators

  * Meson 1.1.0 or later is required to build with Meson.

  * The suppression of false positives of Valgrind is built only when
    `valgrind/memcheck.h` exists on build. Specify
    `-Dvalgrind=enabled` to require it with Meson. Valgrind isn't
    needed at run time.

  * SigScheme installs `COPYING` and `README.md` to the document
    directory (`share/doc/sigscheme/` by default). Meson also
    installs `depmf.json` to it.

  * The ABI of libsscm is compatible with 1.0.0. The soname is
    `libsscm.so.4`.

## 1.0.0 - 2026-11-12

This release supports R7RS small, inexact real numbers and Unicode
character properties and case mappings. It also removes SIOD
compatible features and some obsolete configurations and platforms.

### Incompatible changes

  * Removed SIOD compatible features.
    * `--enable-compat-siod` and `-Dcompat_siod` are removed. uim
      must remove `compat_siod=false` from its options for the
      SigScheme subproject.
    * Removed procedures: `symbol-value`, `set-symbol-value!`,
      `verbose`, `undefine`, `eof-val`, `%%closure-code`, `%%siod=`,
      `bit-and`, `bit-or`, `bit-xor`, `bit-not` and
      `the-environment`
    * Removed C API: `scm_get_verbose_level()`,
      `scm_set_verbose_level()` and `scm_p_siod_equal()`
    * `set-car!` and `set-cdr!` don't return the set value and
      `require` doesn't return `*FILE-loaded*`.

  * Removed `--enable-conf=siod` and `--enable-conf=small`.

  * Removed BREW and Symbian OS support.

  * Required C99.

  * Moved public headers to `include/sigscheme/`.

  * Moved the bundled libgcroots to `subprojects/libgcroots/`.
    * Existing clones need `git submodule sync` and
      `git submodule update --init`.

  * Enabled hygienic macros (`syntax-rules`) by default including
    `--enable-conf=uim`.
    * `define-syntax` not at the toplevel defined a global macro. It's
      an error now without R7RS. It's an internal definition with
      R7RS.

  * Reimplemented `define-record-type` of SRFI-9 by `syntax-rules`.
    * SRFI-9 requires hygienic macros.
    * `record?` is removed.
    * `vector?` returns `#f` for records.

  * Changed the error object to have its kind such as file error and
    read error as the 5th element. The reason is still the 2nd
    element.

  * Changed the ABI of libsscm. The soname is `libsscm.so.4`.

### Improvements

  * Added Meson build support. Meson is recommended. GNU Autotools is
    still supported for compatibility.

  * Added R7RS support (`--enable-r7rs`, `-Dr7rs=true` and
    `--enable-conf=r7rs`). See "R7RS conformance" in `doc/spec.txt`
    for details.
    * Libraries: `define-library`, `import`, the standard libraries
      such as `(scheme base)` and `environment`
    * Syntax: `case-lambda`, `parameterize`, `let-values`,
      `let*-values`, `define-values`, `letrec*`, `when`, `unless`,
      `delay-force`, `syntax-error`, `include`, `=>` in `case` and
      the R7RS extensions of `syntax-rules`
    * Lexical syntax: `#true`, `#false`, block comments, datum
      comments, datum labels, `|symbol|`, `#!fold-case` and so on
    * Bytevectors and binary ports
    * Procedures for lists, vectors, strings, characters, numbers,
      ports, error objects and system interface
    * `write` and `display` terminate for cyclic objects.
    * R7RS standard feature identifiers

  * Added inexact real numbers (`--enable-real` and `-Dreal=true`).
    * Mathematical functions such as `sqrt`, `exp` and `sin` are also
      added.

  * Added Unicode character properties and case mappings
    (`--enable-unicode` and `-Dunicode=true`).

  * Added SRFI-180 JSON.

  * Added R5RS number procedures for exact integers such as `exact?`,
    `floor` and `numerator`.

  * Added support for converting a source file by its coding
    declaration such as `;; -*- coding: euc-jp -*-` in `load`.

  * Added fallback encodings for `load` of a file without coding
    declaration: `with-load-fallback-encodings`

  * Added the port information to port errors.

  * Added `r6rs-chars` feature for `provided?`.

  * Added `sigscheme-combined` Meson dependency for uim.

  * `exit` accepts `#t` and `#f` like R7RS.

  * Made `#` notations such as `#T` and `#X1A` case-insensitive.

  * Made string procedures such as `string->list`, `string<?`,
    `string-upcase`, `write` and `format` accept a string that has an
    invalid sequence in the current character codec like
    `string-length` and `string-ref`.

  * Improved performance of variable lookup with hygienic macros,
    `write` for strings and output string ports.

  * Updated bundled libgcroots to 0.3.6.

### Fixes

  * Fixed a bug that integer arithmetic such as `*` and `expt` returned
    a wrapped value on overflow.

  * Fixed a bug that `(provided? "*FILE-loaded*")` always returned
    `#f` after `(require "FILE")`.

  * Fixed a bug that `list->string`, `string-set!` and `string-fill!`
    accepted NUL characters.

  * Fixed a bug that `quote` of circular data caused an infinite loop.

  * Fixed a bug that `else` and `=>` in `cond` and `case` didn't
    respect their bindings.

  * Fixed bugs that hygienic macros didn't work with definitions in
    macro expansions, identifiers inserted by macros in `define` and
    `set!` and pattern variables at deeper template levels.

  * Fixed a bug that `guard` clauses were evaluated in the dynamic
    environment of `raise`.

  * Fixed a bug that GC may collect elements of a vector being
    created.

  * Fixed a crash with relative `--system-load-path`.

  * Fixed `make check` in VPATH build with absolute `configure` path.

  * Fixed compiler warnings.

### Notes for packagers and system integrators

  * SigScheme can be built with Meson or GNU Autotools. Meson is
    recommended.

  * SigScheme installs system Scheme libraries. Please install them in
    addition to libsscm.

  * SigScheme uses system BDWGC (8.3.0 or later) or libgcroots to find
    GC roots. libgcroots is also bundled. Since it is installed as a
    separated library independent of libsscm, please use system BDWGC
    or create its own package, and make SigScheme package depending on
    it with `-Dgc=bdwgc` or `-Dgc=gcroots`
    (`--with-libgcroots=installed` for GNU Autotools).

  * The ABI of libsscm varies by configuration. So to make libsscm
    sharable, please specify `-Dconf=full` (`--enable-conf=full` for
    GNU Autotools) and keep other feature options untouched for
    system-installed library.

  * The ABI of libsscm isn't compatible with 0.9.6. The soname is
    `libsscm.so.4`.

  * The options `-Ddebug_mode=true` and/or `-Dbacktrace=true`
    (`--enable-debug` and/or `--enable-backtrace` for GNU Autotools)
    make SigScheme quite heavy. Please keep them unspecified for
    normal library.

## 0.9.6 - 2026-09-22

### Improvements

  * Updated bundled libgcroots to 0.3.3

## 0.9.5 - 2026-03-28

### Improvements

  * Added `expt`
    * GH-26
    * Patch by jpellegrini

  * Added `gcd` and `lcm`
    * GH-25
    * Patch by jpellegrini

  * Added support for system BDWGC
    * BDWGC 8.3.0 will have the feature that is provided by
      libgcroots. We'll deprecate libgcroots and migrate to BDWGC
      eventually.
    * GH-29
    * Patch by Ivan Maidanski

### Thanks

  * jpellegrini
  * Ivan Maidanski

## 0.9.4 - 2025-11-29

### Fixes

  * Fixed a bug that loaded symbol may have garbage at the end.
  * Fixed a bug that loaded symbol may have garbage filename.
    * GH-20
    * GH-21
    * Patch by mkotha

### Thanks

  * mkotha

## 0.9.3 - 2025-05-06

### Improvements

  * Cleaned up internal function call dispatch implementation.

## 0.9.2 - 2025-05-04

### Improvements

  * Added support for C23.
    * Reported by SteelDynamite

### Thanks

  * SteelDynamite

## 0.9.1 - 2020-08-25

### Improvements

  * Simplify getcontext() detection
    [GitHub#3][Patch by NIIBE Yutaka]

  * Add support for GNU Hurd
    [GitHub#5][Patch by NIIBE Yutaka]

  * Update the bundled libgcroots to 0.3.2

### Fixes

  * Fix test directory
    [Reported by OBATA Akio]

### Thanks

  * NIIBE Yutaka

  * OBATA Akio

## 0.9.0 - 2018-05-09

  * Just updating packaging system

## 0.8.6 - 2011-05-10

  * Just update configure script

## 0.8.5 - 2010-07-28

### Specification changes

  * Support colon separated multiple load paths with scm_set_lib_path().

## 0.8.4 - 2010-07-15

### Fixes

  * Fix alignment check on x86_64 when --enable-debug is set (bug #26950).
  * Fix test-storage.c

## 0.8.3 - 2008-04-26

### Fixes

  * Disable some GC protection tests that produce indifinite result on make
    check
  * Re-enable following unintentionally disabled tests
    * test-format.c
    * test-storage.c

## 0.8.2 - 2008-04-06

### Specification changes

  * test-report-result exits with error code 70 (EX_SOFTWARE) if some tests are
    failed

### Fixes

  * Fix bogus result of 'make check'. 0.8.1 and earlier passes all tests even
    if some tests are failed

## 0.8.1 - 2008-03-29

### Specification changes

  * [R6RS] Remove the escape sequence `"\|"` invalidated in final R6RS

### Fixes (also fixed in 0.7.6)

  * [CRITICAL] Fix memory alighnment issue in symbol name.
  * [CRITICAL] Fix possible bug in string buffer.
  * Plug possible memory leak.
  * Fix make test in test-string-cmp.
  * Fix compilation on Mac OS X 10.5
  * Support OpenBSD PowerPC and x86_64 in libgcroots

## 0.8.0 - 2007-09-13

### New features

  * SRFI-0 Feature-based conditional expansion construct

  * SRFI-1 List Library (full featured)

  * SRFI-9 Defining Record Types

  * SRFI-43 Vector library

  * SRFI-55 require-extension

  * SRFI-69 Basic hash tables

  * SRFI-95 Sorting and Merging

  * R5RS promises (delay and force)

  * Legacy define-macro with some limitations (see spec.txt)

  * New syntax let-optionals* compatible with Gauche, for optional argument
    processing

  * New C interface functions scm_array2list() and scm_list2array()

  * unittest.scm is now installed as a library. And some SRFI-64 compatible
    assertions are added. It is a temporary solution and will be replaced with
    full SRFI-64 implementation in future release

  * %%require-module and scm_require_module(). 'use' and scm_use() have been
    deprecated and will be removed in SigScheme 0.9.0

  * System-installed libraries written in Scheme are introduced. And to manage
    them, scm_set_system_load_path() and %%system-load-path have been added

  * New character codec related procedures %%current-char-codec,
    %%set-current-char-codec!, with-char-codec and %%string-reconstruct!

  * New port handling procedures %%current-error-port,
    %%set-current-input-port!, %%set-current-output-port!,
    %%set-current-error-port!

  * New debugging procedures %%pair-mutable?, %%string-mutable?,
    %%vector-mutable?

  * New procedure sscm-version for version information

### Specification changes

  * SRFI-75 characters have been turned into R6RS (R5.92RS) characters,
    including configuration names

  * Make Shift_JIS encoding name (CES) and Unicode CCS names of the codec API
    proper

  * Accept any non-ASCII singlebyte values on integer->char, make-string and
    string-fill! when !SCM_USE_MULTIBYTE_CHAR

  * Replace implicit filler value ' ' for make-string with '?' to avoid wrong
    assumption by user

  * make-string, string-fill! and vector-fill! now returns SCM_UNDEF instead of
    the modified object

  * Second argument argv is added to scm_initialize() and thus incompatible
    with 0.7.x.

  * [R5RS] R5RS hygienic macros is disabled by default in all configurations
    but 'dev' since it has a considerable bug (such as infinite loop on
    test-srfi1-another.scm)

  * call-with-input-file, call-with-output-file, with-input-from-file and
    with-output-to-file are re-implemented in lib/sigscheme-init.scm. The
    standard current ports handling on with-input-from-file and
    with-output-to-file are now continuation-safe by dynamic-wind

  * Continuation implementation now uses sigsetjmp(3) and siglongjmp(3) if
    available

### Fixes

  * [CRITICAL] Fix unterminated string generation on singlebyte character codec

  * [R5RS] Fix multiple values inacceptance of call-with-values continuation
    such as (receive (x y) (call/cc (lambda (k) (k 0 1))))

  * [SRFI-38] Fix broken execution by misinitialized internal hash table

  * Fix string-length on multibyte string invalidly counted based on current
    char codec. It is inconsistent with string length recorded in string object

  * [R5RS] Fix error on (integer->char 0) on non-Unicode codecs

  * [R6RS] Fix invalid Unicode character acception on integer->char

  * Fix unexpected memory exhaustion on negative length on make-string

  * [SRFI-2] Fix body-less forms rejection on and-let* such as (and-let* ())

  * [R5RS] Fix overflow error by a long number on string->number with #f

  * [R5RS] Fix invalid assertion on modifying optional arguments to a dotted or
    circular list (see test-misc.scm). This bug only appeared on --enable-debug

  * Fix reading unterminated quote as `(quote #<eof>)`

  * [SIOD] Fix defining '=' as SIOD-compatible version regardless of
    --enable-compat-siod-bugs

### Others

  * New document multibyte.txt about multibyte character processing has been
    added

  * Code validation for R5RS characters, all R5RS string procedures, R5RS
    vectors, SRFI-2, SRFI-8 and Multibyte character processing have been done
    and now can be used for production codes

  * SRFI-1 List Library is partially validated, but expected as usable quality.
    Though C part is fully validated, the Scheme part imported from the
    reference implementation of SRFI-1 is not fully validated. See
    test/test-srfi1-another.scm for validation status. The procedures that not
    validated only have header comment such as ";; delete-duplicates" in the
    file.

## 0.7.6 - 2008-02-20

### Fixes

  * [CRITICAL] Fix memory alighnment issue in symbol name.
  * [CRITICAL] Fix possible bug in string buffer.
  * Plug possible memory leak.
  * Fix make test in test-string-cmp.
  * Fix compilation on Mac OS X 10.5
  * Support OpenBSD PowerPC and x86_64 in libgcroots

## 0.7.5 - 2007-03-14

### New features

  * Add SIOD compatibility about syntax 'if'.
  * Revise the SRFI-75 support into R6RS (R5.92RS) characters.

## 0.7.4 - 2007-01-13

### New features

  * %%prealloc-heaps procedure for memory consumptive applications

## 0.7.3 - 2007-01-06

### Fixes

  * [CRITICAL] Fix broken libgcroots compilation on SPARC and IA-64 (NIIBE
    Yutaka)

  * Fix broken eval_state passing in call() on possible configurations that
    (sizeof(ScmObj) != sizeof(void *))

  * Fix some build problems

  * Suppress warnings

## 0.7.2 - 2006-12-29

### Fixes

  * [CRITICAL] Fix broken libgcroots (Etsushi)

  * Fix distribution making procedure

  * Fix '-no-cpp-precomp' warning on gcc

  * Change To: mail address of make-report.sh which does not have size
    limitation

## 0.7.1 - 2006-12-24

### New features

  * All particular language features and behaviors have become configurable via
    --enable and --disable options of the configure script, with automated
    feature dependencies resolution and conflict detection

  * The Cutter-based C testing framework has been replaced with the new
    framework developed by Jun Inoue. Simply type 'make check' to run the
    tests. All of old contents of test-c/ have been removed, and test-c2/ has
    been renamed to test-c/. Be careful to read old logs.

  * "internal definitions" and "strict toplevel definitions validation"
    features have been configurable

  * Add optional duplicate variable check to 'let', 'let*', 'letrec' and 'do'
    (it is not required by R5RS)

  * [R6RS] R6RS (R5.91RS) compatible 'fixnum-width' procedure

  * SSCM_VERSION_REQUIRE() macro

  * Add pkg-config support

### Specification changes

  * [R5RS] Remove 'delay' and 'force' (temporarily) since they completely
    violates R5RS definitions

  * [R5RS] Proper tail recursion conformance of 'eval' has been marked as
    'uncertain'

  * [SRFI-23] Display error message and optional objects as same as the
    reference implementation of SRFI-23

  * [SRFI-34] Add 'current handler' to error object to behave as same as the
    reference implementation of SRFI-34 'raise'

  * [SRFI-77, R6RS] The SRFI-77 procedures 'least-fixnum' and 'greatest-fixnum'
    have been upgraded to R6RS (R5.91RS) (nothing is actually changed)

  * The API for function call with GC-ready stack has been changed to resolve
    corrupted GC problem on SPARC and IA-64. It needs API change

  * Definition of dotted list length is changed to SRFI-1's from
    SigScheme-speciific one. SCM_LISTLEN_DOTTED(), SCM_DOTTED_LISTP() and other
    dotted list-related macros and functions have been changed so

  * Remove initial hyphen support for symbols (such as '-sym). Use
    (string->symbol "-sym") instead

  * Remove SIOD-compatible external representation of eof value '(eof)'

  * (scm_set_lib_path): Change to holding copied library path string

  * (scm_return_value): Removed

  * Change the low-level port API to fix the design error about error handling
    (get_byte() and peek_byte() were not able to detect read error)

  * Withdraw sigscheme-stdint.h. Use scmint.h instead

  * The --enable-configuration=CONF option of the configure is renamed to
    --enable-conf=CONF

  * The --enable-multibyte=ENCODING option of the configure is replaced with
    --enable-default-encoding=ENCODING, and --enable-ENCODING options are also
    added

### Fixes

  [R5RS] and [SRFI-n] tags indicate specification conformance fixes.

  * [CRITICAL] Fix crashes by broken va_list passing of format.c on x86_64
    platform

  * [CRITICAL] Fix corrupted GC on some architectures such as SPARC and IA-64
    with libgcroots

  * [CRITICAL] Fix crashes by corrupted GC mark on stack on specific platforms
    that have (alignof(ScmObj) < sizeof(ScmObj)), such as m68k

  * [CRITICAL] Fix potential SEGV on long string parsing

  * [CRITICAL] Fix possible crash on parsing R5RS-reserved chars |[]{}

  * [CRITICAL] Fix broken GC on systems that have 8-byte aligned malloc(3) such
    as Cygwin

  * [CRITICAL] Fix broken 64-bit data model capability of storage-compact

  * [CRITICAL] Fix broken ScmBaseCharPort inheritance of ScmSingleByteCharPort
    which may cause SEGV

  * [R5RS] Fix invalid acceptance of definition form on where neither toplevel
    nor internal definition is allowed

  * [R5RS] Fix invalid acceptance of 'begin' that contains definitions and
    expressions intermixed

  * [R5RS] Fix invalid acceptance of `<body>` that contains definitions and
    expressions intermixed on 'let', 'let*', 'letrec' and function form
    'define'

  * [R5RS] Fix syntactic keyword to value evaluation that only bound to syntax
    or macro (i.e. (eq? if and) has been invalidated). But binding syntactic
    keywords to first-class objects such as (define else 3) and (define do 4)
    are still allowed

  * [R5RS] Fix first-class binding objects acceptance of let-syntax,
    letrec-syntax and define-syntax

  * [R5RS] Fix invalid no-expressions `<body>` acceptance of 'let', 'let*',
    'letrec' and function form 'define'

  * [R5RS] Fix invalid acceptance of binding syntactic keyword as value on
    'define', 'let', 'let*', 'letrec' and 'do'

  * [R5RS] Fix broken per-iteration env isolation of 'do'

  * [R5RS] Fix proper tail recursion incapability of '=>' form of 'cond'

  * [R5RS] Fix invalid acceptance of cond-like '=>' form of 'case' which is not
    defined in R5RS

  * [R5RS] Fix broken result of 'modulo' on no-remainder cases

  * [R5RS] Fix improper list acceptance on single-arg map

  * [R5RS] Fix improper tail recursion of call-with-values on a corner case

  * [R5RS] Fix broken improper tail handling of 'list-ref'

  * [R5RS] Fix improper list acceptance of 'reverse'

  * [R5RS] Reject invalid number strings such as "0xa" and " 1" on
    'string->number'

  * [R5RS] Reject invalid number literals such as "#x0xa"

  * [SRFI-38] Fix inacceptance of optional 'optarg' argument of
    'write-with-shared-structure'

  * [SRFI-48] Fix optional port argument inacceptance of 'pretty-print'

  * [SRFI-48] Fix broken number prefix acceptance such as "~,f", "~1,f", "~,1f"

  * [SRFI-60] Fix invalid result of (logand). Now it returns -1 as same
    as the reference implementation

  * [MAJOR] Add lacking or incomplete error handlings for port operations

  * [MAJOR] Fix incomplete singlebyte character support

  * [MAJOR] Fix broken sign extention for 8-bit char on string port read

  * [MAJOR] Fix broken out of range error detection of string->number which
    fails every conversion once after the error has occurred

  * [MAJOR] Fix possible crash on parsing script prelude longer than 64 chars

  * [MAJOR] Fix possible crash on parsing script prelude that only has
    "#! /usr/bin/env"

  * [MAJOR] Fix a broken error handling on character encoding switching when
    !SCM_USE_MULTIBYTE_CHAR

  * [MAJOR] Fix infinite loop on raising error objects that contain circular
    list when SCM_USE_HYGIENIC_MACRO

  * [MAJOR] Fix compile error on environments that lacks stdint.h -compatible
    definitions

  * [MAJOR] Fix missized-cast of 'quotient' which results a broken value on
    64-bit configurations

  * [MAJOR] Fix broken evaluation of quasiquoted vectors splicing with improper
    list

  * [MAJOR] Fix 64-bit capability of quasiquoted vectors

  * [MAJOR] Fix passing circular list into error object when SRFI-38 is not
    enabled

  * Fix '0' prefix incapability on a maximum-length binary number literal. See
    "R5RS conformance: Numbers: Literals" subsection of doc/spec.txt for
    further details

  * Fix possible crash of the broken GC protection on initialization

  * Fix a broken type handling appeares on (equal? macro1 macro2) on
    storage-compact

  * Fix broken procedure invocation appears on a minor build configuration

  * Fix broken body result of %%closure-code when body-length == 1

  * Fix possible datum index overflow of SRFI-38 write/ss on 64-bit platforms

  * Fix acceptable pathname length of a script name of sscm command previously
    one char lesser than maximum

  * Fix broken aggregated global variables handling

  * Fix writable static data feature dependency

  * Fix broken max heap size configuration

  * Fix crashes on 'make check' in test-c2/ on x86_64-unknown-linux-gnu

  * Fix unwanted test-c2/*-coll.c removal on --disable-maintainer-mode

### Others

  * The maintainer of the software has been succeeded by YAMAMOTO Kengo a.k.a
    YamaKen

## 0.6.1 - 2006-06-14

Changes from 0.5.0 (r3097 + private modifications).

### New features

  * Support R5RS hygienic macros

  * Support format strings (covers SRFI-28 and SRFI-48)

  * Add global symbol exportation control method in portable way (see
    doc/global-obj.txt)

  * Add experimental support for embedded platforms that lack writable static
    data, such as BREW or Symbian OS (see doc/global-obj.txt)

### Fixes

  * Make installed libsscm and header files workable

## 0.5.0

Changes from 0.5.0-alpha (r2902 + private modifications).

### New features

  * Support 64-bit data models (storage-compact is not yet)

  * Add lacking character predicates and complete all R5RS character procedures

  * Add lacking string predicates and complete all R5RS string procedures

  * Support constant list (storage-compact does not)

  * Support constant vector (storage-compact is not yet)

  * Add quote-less vector literal check

### Fixes

  * Make behavior of internal definitions strictly conforming to R5RS

  * Make C99-dependent stdint.h unneeded
