# r7rs-tests.scm is tests/r7rs-tests.scm of chibi-scheme
# (https://github.com/ashinn/chibi-scheme) at
# 4ef2f51c2c885923153821ecd097b2918b7827bc. See COPYING at the top
# directory for its license.
#
# Reports how many tests in r7rs-tests.scm of chibi-scheme pass:
#   meson compile -C build r7rs-tests
#
# Use run.py directly with --verbose to see failures.
if (use['shell'] and use['legacy_macro'] and use['quasiquote'] and
    use['srfi6'] and use['srfi34'])
  run_target('r7rs-tests',
             command: [
               find_program('run.py'),
               sscm,
               meson.project_source_root() / 'lib',
               files('r7rs-tests.scm'),
             ])
endif
