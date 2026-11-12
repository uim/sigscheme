# NEWS

## 1.0.0 - 2026-11-12

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
