# Native tests of SigScheme
sscm_tests = [
  'test-apply.scm',
  'test-assoc.scm',
  'test-begin.scm',
  'test-bool.scm',
  'test-char-cmp.scm',
  'test-char-pred.scm',
  'test-continuation.scm',
  'test-define.scm',
  'test-define-internal.scm',
  'test-do.scm',
  'test-dyn-extent.scm',
  'test-eq.scm',
  'test-eqv.scm',
  'test-equal.scm',
  'test-eval.scm',
  'test-fail.scm',
  'test-formal-syntax.scm',
  'test-formatplus.scm',
  'test-lambda.scm',
  'test-legacy-macro.scm',
  'test-let.scm',
  'test-letstar.scm',
  'test-letrec.scm',
  'test-list.scm',
  'test-map.scm',
  'test-member.scm',
  'test-misc.scm',
  'test-named-let.scm',
  'test-number-arith.scm',
  'test-number-cmp.scm',
  'test-number-literal.scm',
  'test-number-io.scm',
  'test-number-pred.scm',
  'test-obsolete.scm',
  'test-pair.scm',
  'test-quote.scm',
  'test-srfi0.scm',
  'test-srfi1-another.scm',
  'test-srfi1-obsolete.scm',
  'test-srfi2.scm',
  'test-srfi6.scm',
  'test-srfi8.scm',
  'test-srfi9.scm',
  'test-srfi28.scm',
  'test-srfi34.scm',
  'test-srfi34-2.scm',
  'test-srfi38.scm',
  'test-srfi43.scm',
  'test-srfi48.scm',
  'test-srfi55.scm',
  'test-srfi60.scm',
  'test-sscm-ext.scm',
  'test-string-cmp.scm',
  'test-string-core.scm',
  'test-string-null.scm',
  'test-string-proc.scm',
  'test-string.scm',
  'test-symbol.scm',
  'test-syntax-rules.scm',
  'test-syntax.scm',
  'test-unittest.scm',
  'test-values.scm',
  'test-vector.scm',
]
sscm_xfail_tests = [
  'test-fail.scm',
]
if use['utf8']
  sscm_tests += ['test-enc-utf8.scm']
endif
if use['euccn']
  sscm_tests += ['test-enc-eucgeneric.scm']
endif
if use['eucjp']
  sscm_tests += ['test-enc-eucjp.scm', 'test-char.scm']
endif
if use['sjis']
  sscm_tests += ['test-enc-sjis.scm']
endif

if use['shell']
  foreach sscm_test : sscm_tests
    test(sscm_test,
         sscm,
         args: [
           '--system-load-path', meson.project_source_root() / 'lib',
           files(sscm_test),
         ],
         should_fail: sscm_xfail_tests.contains(sscm_test),
         suite: 'sscm',
         workdir: meson.project_source_root())
  endforeach
endif
