# Native tests of SigScheme
sscm_tests = [
  'test-apply.scm',
  'test-assoc.scm',
  'test-begin.scm',
  'test-char-cmp.scm',
  'test-continuation.scm',
  'test-define.scm',
  'test-define-internal.scm',
  'test-do.scm',
  'test-dyn-extent.scm',
  'test-eval.scm',
  'test-fail.scm',
  'test-formatplus.scm',
  'test-lambda.scm',
  'test-legacy-macro.scm',
  'test-let.scm',
  'test-library.scm',
  'test-letstar.scm',
  'test-letrec.scm',
  'test-map.scm',
  'test-member.scm',
  'test-named-let.scm',
  'test-number-arith.scm',
  'test-number-cmp.scm',
  'test-number-literal.scm',
  'test-number-io.scm',
  'test-obsolete.scm',
  'test-quote.scm',
  'test-r7rs.scm',
  'test-real.scm',
  'test-srfi0.scm',
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
  'test-srfi55.scm',
  'test-srfi60.scm',
  'test-string-null.scm',
  'test-string.scm',
  'test-syntax-rules.scm',
  'test-syntax.scm',
  'test-unittest.scm',
  'test-values.scm',
]
sscm_xfail_tests = [
  'test-fail.scm',
]
if use['utf8']
  # They specify "-C UTF-8" in their script prelude.
  sscm_tests += [
    'test-bool.scm',
    'test-char-pred.scm',
    'test-enc-utf8.scm',
    'test-eq.scm',
    'test-equal.scm',
    'test-eqv.scm',
    'test-formal-syntax.scm',
    'test-list.scm',
    'test-misc.scm',
    'test-number-pred.scm',
    'test-pair.scm',
    'test-srfi1-another.scm',
    'test-srfi48.scm',
    'test-sscm-ext.scm',
    'test-string-cmp.scm',
    'test-string-core.scm',
    'test-string-proc.scm',
    'test-symbol.scm',
    'test-vector.scm',
  ]
endif
if use['utf8'] and use['srfi6'] and iconv_dependency.found()
  # It specifies "-C UTF-8" in its script prelude.
  sscm_tests += ['test-coding.scm']
endif
if use['srfi64']
  sscm_tests += ['test-srfi64.scm']
endif
if use['srfi180']
  sscm_tests += ['test-srfi180.scm']
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

# They don't use helper.scm. test-srfi64.scm tests SRFI-64 itself and
# the others use lib/unittest.scm. All other tests use SRFI-64 with
# helper.scm.
sscm_no_helper_tests = [
  'test-fail.scm',
  'test-srfi64.scm',
  'test-unittest.scm',
]

# lib/srfi-64.scm in the source tree can be used even if SRFI-64 is
# disabled when the features that SRFI-64 requires are enabled.
srfi64_available = true
foreach feature : feature_required_dependencies['srfi64']
  if not use[feature]
    srfi64_available = false
  endif
endforeach

if use['shell']
  foreach sscm_test : sscm_tests
    sscm_test_args = ['--system-load-path', meson.project_source_root() / 'lib']
    if not sscm_no_helper_tests.contains(sscm_test)
      if not srfi64_available
        continue
      endif
      # It makes the exit status non-zero on failure.
      sscm_test_args += ['--load', files('helper.scm')]
    endif
    test(sscm_test,
         sscm,
         args: sscm_test_args + [files(sscm_test)],
         should_fail: sscm_xfail_tests.contains(sscm_test),
         suite: 'sscm',
         workdir: meson.project_source_root())
  endforeach
endif

if use['shell'] and srfi64_available
  test('test-sscm-load.scm',
       sscm,
       args: [
         '--system-load-path', meson.project_source_root() / 'lib',
         '--load', files('sscm-load/first.scm'),
         '--load', files('sscm-load/second.scm'),
         '--load', files('helper.scm'),
         files('test-sscm-load.scm'),
         # This is an argument of the script.
         '--load', 'ignored',
       ],
       suite: 'sscm',
       workdir: meson.project_source_root())
endif

subdir('r7rs')
