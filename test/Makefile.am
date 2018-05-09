# Libraries
EXTRA_DIST = unittest-bigloo.scm unittest-gauche.scm \
             run-singletest.sh.in

sscm_xfail_tests = test-fail.scm
sscm_optional_tests =
# Native tests of SigScheme
sscm_tests = \
        test-apply.scm \
        test-assoc.scm \
        test-begin.scm \
        test-bool.scm \
        test-char-cmp.scm \
        test-char-pred.scm \
        test-continuation.scm \
        test-define.scm \
        test-define-internal.scm \
        test-do.scm \
        test-dyn-extent.scm \
        test-eq.scm \
        test-eqv.scm \
        test-equal.scm \
        test-eval.scm \
        test-fail.scm \
        test-formal-syntax.scm \
        test-formatplus.scm \
        test-lambda.scm \
        test-legacy-macro.scm \
        test-let.scm \
        test-letstar.scm \
        test-letrec.scm \
        test-list.scm \
        test-map.scm \
        test-member.scm \
        test-misc.scm \
        test-named-let.scm \
        test-number-arith.scm \
        test-number-cmp.scm \
        test-number-literal.scm \
        test-number-io.scm \
        test-number-pred.scm \
        test-obsolete.scm \
        test-pair.scm \
        test-quote.scm \
        test-srfi0.scm \
        test-srfi1-another.scm \
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
        test-srfi48.scm \
        test-srfi55.scm \
        test-srfi60.scm \
        test-sscm-ext.scm \
        test-string-cmp.scm \
        test-string-core.scm \
        test-string-null.scm \
        test-string-proc.scm \
        test-string.scm \
        test-symbol.scm \
        test-syntax-rules.scm \
        test-syntax.scm \
        test-unittest.scm \
        test-values.scm \
        test-vector.scm

if USE_UTF8
sscm_optional_tests += test-enc-utf8.scm
else
sscm_xfail_tests += test-enc-utf8.scm
endif
EXTRA_DIST += test-enc-utf8.scm

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
