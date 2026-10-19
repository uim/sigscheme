# Libraries
EXTRA_DIST = unittest-bigloo.scm unittest-gauche.scm \
             run-singletest.sh.in meson.build

sscm_xfail_tests = test-fail.scm
sscm_optional_tests =
# Native tests of SigScheme
sscm_tests = \
        test-apply.scm \
        test-assoc.scm \
        test-begin.scm \
        test-char-cmp.scm \
        test-continuation.scm \
        test-define.scm \
        test-define-internal.scm \
        test-do.scm \
        test-dyn-extent.scm \
        test-eval.scm \
        test-fail.scm \
        test-formatplus.scm \
        test-lambda.scm \
        test-legacy-macro.scm \
        test-let.scm \
        test-library.scm \
        test-letstar.scm \
        test-letrec.scm \
        test-map.scm \
        test-member.scm \
        test-named-let.scm \
        test-number-arith.scm \
        test-number-cmp.scm \
        test-number-literal.scm \
        test-number-io.scm \
        test-obsolete.scm \
        test-quote.scm \
        test-r7rs.scm \
        test-real.scm \
        test-srfi0.scm \
        test-srfi1-obsolete.scm \
        test-srfi2.scm \
        test-srfi6.scm \
        test-srfi8.scm \
        test-srfi9.scm \
        test-srfi28.scm \
        test-srfi34.scm \
        test-srfi34-2.scm \
        test-srfi38.scm \
        test-srfi43.scm \
        test-srfi55.scm \
        test-srfi60.scm \
        test-string-null.scm \
        test-string.scm \
        test-syntax-rules.scm \
        test-syntax.scm \
        test-unittest.scm \
        test-values.scm

# They specify "-C UTF-8" in their script prelude.
sscm_utf8_tests = \
        test-bool.scm \
        test-char-pred.scm \
        test-enc-utf8.scm \
        test-eq.scm \
        test-equal.scm \
        test-eqv.scm \
        test-formal-syntax.scm \
        test-list.scm \
        test-misc.scm \
        test-number-pred.scm \
        test-pair.scm \
        test-srfi1-another.scm \
        test-srfi48.scm \
        test-sscm-ext.scm \
        test-string-cmp.scm \
        test-string-core.scm \
        test-string-proc.scm \
        test-symbol.scm \
        test-vector.scm

if USE_UTF8
sscm_optional_tests += $(sscm_utf8_tests)
else
sscm_xfail_tests += $(sscm_utf8_tests)
endif
EXTRA_DIST += $(sscm_utf8_tests)

if USE_EUCCN
sscm_optional_tests += test-enc-eucgeneric.scm
else
sscm_xfail_tests += test-enc-eucgeneric.scm
endif
EXTRA_DIST += test-enc-eucgeneric.scm

if USE_EUCJP
sscm_optional_tests += test-enc-eucjp.scm test-char.scm
else
sscm_xfail_tests += test-enc-eucjp.scm test-char.scm
endif
EXTRA_DIST += test-enc-eucjp.scm test-char.scm

if USE_SJIS
sscm_optional_tests += test-enc-sjis.scm
else
sscm_xfail_tests += test-enc-sjis.scm
endif
EXTRA_DIST += test-enc-sjis.scm

EXTRA_DIST += test-tail-rec.scm
EXTRA_DIST += \
	library/broken.sld \
	library/circular.sld \
	library/greeting-ci.scm \
	library/greeting-declarations.scm \
	library/greeting.scm \
	library/greeting.sld

# Imported foreign tests
imported_tests = \
        scm-r4rstest.scm \
        bigloo-apply.scm \
        bigloo-bchar.scm \
        bigloo-bool.scm \
        bigloo-case.scm \
        bigloo-letrec.scm \
        bigloo-list.scm \
        bigloo-quote.scm \
        bigloo-vector.scm \
        gauche-euc-jp.scm \
        gauche-let-optionals.scm \
        gauche-primsyn.scm \
        oleg-srfi2.scm

# Not included to the distribution since their original license is unknown.
#imported_tests += stone-srfi1.scm
#imported_tests += panu-srfi69.scm

EXTRA_DIST += $(sscm_tests) $(imported_tests)

# R7RS tests from chibi-scheme. Run them with Meson:
#   meson compile -C build r7rs-tests
EXTRA_DIST += r7rs/chibi-test.scm r7rs/meson.build r7rs/run.py \
              r7rs/r7rs-tests.scm

LOG_COMPILER = $(SH)
AM_LOG_FLAGS = $(top_builddir)/test/run-singletest.sh
if USE_SHELL
TESTS = $(sscm_tests) $(sscm_optional_tests)
XFAIL_TESTS = $(sscm_xfail_tests)
else
TESTS =
XFAIL_TESTS = $(sscm_tests) $(sscm_xfail_tests)
endif

DISTCLEANFILES = run-singletest.sh
