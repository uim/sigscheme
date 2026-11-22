# SigScheme

SigScheme is a R5RS and R7RS small Scheme interpreter for embedded use.

It features low memory consumption (2-words per cons cell), multibyte
characters handling (UTF-8, EUCs and Shift_JIS) and more.

It is mainly developed to be the Scheme interpreter of uim.

  * Homepage: https://github.com/uim/sigscheme
  * Git repository: `git clone https://github.com/uim/sigscheme.git`

See following files for further information.

  * `doc/spec.txt`: specifications of SigScheme

Please report us if you find a problem.

  * Issues: https://github.com/uim/sigscheme/issues

## Features

  * Conforms to R5RS basically (not fully)
  * Conforms to R7RS small basically (not fully) with the `r7rs` feature
    * Libraries: `define-library`, `import` and the standard libraries
    * Bytevectors and binary ports
  * R5RS hygienic macros with R7RS extensions
  * Inexact real numbers (flonums) with the `real` feature
  * Unicode character properties and case mappings with the `unicode`
    feature
  * Supports Following SRFIs
    * SRFI-0: Feature-based conditional expansion construct
    * SRFI-1: List Library
    * SRFI-2: `AND-LET*`: an AND with local bindings, a guarded `LET*`
      special form
    * SRFI-6: Basic String Ports
    * SRFI-8: receive: Binding to multiple values
    * SRFI-9: Defining Record Types
    * SRFI-22: Running Scheme Scripts on Unix (partial)
    * SRFI-23: Error Reporting Mechanism
    * SRFI-28: Basic Format Strings
    * SRFI-34: Exception Handling for Programs
    * SRFI-38: External Representation for Data with Shared Structure
      (partial)
    * SRFI-43: Vector library
    * SRFI-48: Intermediate Format Strings
    * SRFI-55: require-extension
    * SRFI-60: Integer as Bits (partial)
    * SRFI-64: A Scheme API for test suites
    * SRFI-69: Basic hash tables
    * SRFI-95: Sorting and Merging
    * SRFI-180: JSON
  * R6RS: R6RS characters (partial and preliminary)
  * Multibyte character encodings support
  * `define-macro`
  * `let-optionals*` for optional argument processing

See `doc/spec.txt` and `doc/design.txt` for further information.

## How to build

SigScheme can be built with Meson or GNU Autotools. Meson is
recommended. GNU Autotools is still supported for compatibility but
it will be removed in the future.

### With Meson

Meson 1.1.0 or later and Ninja are required to build with Meson.

Run `meson setup` with some options at the top directory.

```bash
meson setup [-Dconf=CONF] [-Ddefault_encoding=ENCODING] build
```

#### `-Dconf=CONF`

This specifies a base configuration set. Select one from the list
below suitable for your purpose.

  * `full`: compile with full features but broken ones
  * `regular`: (default) compile with typically needed features
  * `r5rs`: compile with strict R5RS conformances
  * `r7rs`: compile with R7RS features
  * `dev`: developer-friendly configuration
  * `uim`: configure for uim

#### `-Ddefault_encoding=ENCODING`

SigScheme normally selects UTF-8 as default encoding. You can change
it by this option as follows.

```bash
meson setup -Ddefault_encoding=eucjp build
```

Following encodings can be specified.

  * `utf8`
  * `euccn`
  * `eucjp`
  * `euckr`
  * `sjis`

#### `-DENCODING=true`

In addition to `-Ddefault_encoding=ENCODING`, you can enable other
optional and switchable character encodings.

```bash
meson setup -Ddefault_encoding=eucjp -Deucjp=true -Dsjis=true build
```

#### `-Dgc=GC`

SigScheme uses BDWGC (8.3.0 or later) or libgcroots to find GC
roots. By default (`-Dgc=auto`), system BDWGC is used if it
exists. Otherwise system libgcroots is used if it exists. Otherwise
the bundled libgcroots is used. You can choose one explicitly as
follows.

  * `bdwgc`: use system BDWGC
  * `gcroots`: use system libgcroots or the bundled libgcroots
  * `tiny-subst`: use tiny substitution in `src/gcroots`

Use `--force-fallback-for=gcroots` to always use the bundled
libgcroots.

```bash
meson setup -Dgc=gcroots --force-fallback-for=gcroots build
```

#### Other options

Meson's built-in options are also available. For example, use
`--buildtype=release` for an optimized build and `-Db_ndebug=true` to
disable assertions.

See `meson_options.txt` or `meson configure build` for all
options. Each `--enable-FEATURE`/`--disable-FEATURE` option of
`configure` is available as `-DFEATURE=true`/`-DFEATURE=false`. Note
that `-` in `FEATURE` is replaced with `_` and `--enable-debug` is
`-Ddebug_mode=true`.

#### Build

Then run `meson compile`.

```bash
meson compile -C build
```

### With GNU Autotools

GNU make is required to build.

Run `./configure` with some options at the top directory.

```bash
./configure [--enable-conf=CONF] [--enable-default-encoding=ENCODING]
```

Options are the same as Meson's ones: `--enable-conf=CONF`,
`--enable-default-encoding=ENCODING`, `--enable-ENCODING` and so on.

Then type `make` at the top directory.

```bash
make
```

## Test

```bash
meson test -C build
```

or

```bash
make check
```

### AddressSanitizer

SigScheme can be built and tested with AddressSanitizer.

```bash
meson setup -Db_sanitize=address build
meson test -C build
```

`-Db_lundef=false` is also needed with Clang.

libgcroots 0.3.8 or later is required when system libgcroots is
used. The bundled libgcroots and `-Dgc=tiny-subst` can also be used.

### Valgrind

The GC scans the stack that has uninitialized locations. Valgrind
reports it as a use of an uninitialized value. The reports are
suppressed when SigScheme is built with `valgrind/memcheck.h`. It's
used by default if it exists. `-Dvalgrind=true` requires it.

```bash
meson setup -Dvalgrind=true build
```

## Installation

```bash
meson install -C build
```

or

```bash
make install
```

## How to use

To run SigScheme in interactive mode, type as follows.

```bash
sscm
```

To execute a Scheme script, specify it as argument.

```bash
sscm <filename>
```

To load files before the script or the interactive mode, specify them
with `--load`. They are loaded in the specified order.

```bash
sscm --load <filename> [--load <filename> ...] [<filename>]
```

## How to build unreleased version

```bash
git clone --recursive https://github.com/uim/sigscheme.git
cd sigscheme
./setup.sh
meson setup <YOUR_BUILD_OPTIONS> build
meson compile -C build
```

or

```bash
git clone --recursive https://github.com/uim/sigscheme.git
cd sigscheme
./setup.sh
./autogen.sh
./configure --enable-maintainer-mode <YOUR_BUILD_OPTIONS>
make -j$(nproc)
```

## Acknowledgements

Some parts of this software had been funded by IPA
(http://www.ipa.go.jp/)
