# GNU sed is required to run collect.sh
sed = find_program('gsed', 'sed', required: false)
gnu_sed = false
if sed.found()
  sed_version = run_command(sed, '--version', check: false)
  gnu_sed = (sed_version.returncode() == 0 and
             sed_version.stdout().contains('GNU'))
endif
if not use['libsscm']
  subdir_done()
endif
if not gnu_sed
  warning('GNU sed is not found: C tests are disabled')
  subdir_done()
endif

collect_sh_conf = configuration_data()
collect_sh_conf.set('SED', sed.full_path())
collect_sh = configure_file(input: 'collect.sh.in',
                            output: 'collect.sh',
                            configuration: collect_sh_conf)
sh = find_program('sh')

test_c_args = [
  '-DTST_SCM_SYSTEM_LOAD_PATH="@0@"'.format(meson.project_source_root() / 'lib'),
]
# To take precedence over installed gcroots.h by the bundled
# subprojects/libgcroots/include/gcroots.h, gcroots_include_directories must be
# placed here.
test_include_directories = [
  sigscheme_include_directories,
  sigscheme_config_include_directories,
  include_directories('../src'),
] + gcroots_include_directories

# Name your test suite with a -coll suffix if you want it processed
# with collect.sh.  Leave the suffix out if you don't want some script
# messing around with your masterpiece.
foreach test_name : [
  'test-alignment',
  'test-global',
  'test-gc',
  'test-gc-protect',
  'test-gc-protect-stack',
  'test-storage',
  'test-storage-compact',
  'test-strcasecmp',
  'test-length',
  'test-format',
  'test-array2list',
]
  test_coll_c = custom_target(test_name + '-coll.c',
                              input: test_name + '.c',
                              output: test_name + '-coll.c',
                              build_by_default: false,
                              command: [sh, collect_sh, '@INPUT@'],
                              capture: true)
  test_executable = executable(test_name + '-coll',
                               test_coll_c,
                               build_by_default: false,
                               c_args: test_c_args,
                               dependencies: gcroots_dependencies,
                               include_directories: test_include_directories,
                               link_with: libsscm)
  test(test_name, test_executable, suite: 'c')
endforeach

executable('test-minishell',
           'test-minishell.c',
           build_by_default: false,
           c_args: test_c_args,
           dependencies: gcroots_dependencies,
           include_directories: test_include_directories,
           link_with: libsscm)
