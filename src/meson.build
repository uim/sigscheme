# libtool's -version-info CURRENT:REVISION:AGE is shared with
# Makefile.am via libtool-version.mk.
libtool_version = ''
foreach line : fs.read('libtool-version.mk').split('\n')
  if line.startswith('libsscm_version')
    libtool_version = line.split('=')[1].strip()
  endif
endforeach
if libtool_version == ''
  error('libsscm_version is missing in src/libtool-version.mk')
endif
libtool_version_components = libtool_version.split(':')
lt_current = libtool_version_components[0].to_int()
lt_revision = libtool_version_components[1].to_int()
lt_age = libtool_version_components[2].to_int()
so_version = lt_current - lt_age
library_version = '@0@.@1@.@2@'.format(so_version, lt_age, lt_revision)
darwin_versions = [
  lt_current + 1,
  '@0@.@1@'.format(lt_current + 1, lt_revision),
]

# Built-in function tables. They are #include-d from source files.
#
# [output, table name, sources]
func_tables = [
  # Core
  ['functable-sscm-core.c', 'scm_functable_sscm_core',
   ['error.c', 'module.c']],
  ['functable-r5rs-core.c', 'scm_functable_r5rs_core',
   ['eval.c', 'list.c', 'procedure.c']],
  # R5RS syntaxes
  ['functable-r5rs-syntax.c', 'scm_functable_r5rs_syntax', ['syntax.c']],
  ['functable-r5rs-qquote.c', 'scm_functable_r5rs_qquote', ['qquote.c']],
  ['functable-r5rs-macro.c', 'scm_functable_r5rs_macro', ['macro.c']],
  ['functable-r5rs-promise.c', 'scm_functable_r5rs_promise', ['promise.c']],
  # R5RS procedures
  ['functable-r5rs-number.c', 'scm_functable_r5rs_number', ['number.c']],
  ['functable-r5rs-number-io.c', 'scm_functable_r5rs_number_io',
   ['number-io.c']],
  ['functable-r5rs-char.c', 'scm_functable_r5rs_char', ['char.c']],
  ['functable-r5rs-string.c', 'scm_functable_r5rs_string', ['string.c']],
  ['functable-r5rs-string-procedure.c',
   'scm_functable_r5rs_string_procedure',
   ['string-procedure.c']],
  ['functable-r5rs-vector.c', 'scm_functable_r5rs_vector', ['vector.c']],
  ['functable-r5rs-port.c', 'scm_functable_r5rs_port', ['port.c']],
  ['functable-r5rs-read.c', 'scm_functable_r5rs_read', ['read.c']],
  ['functable-r5rs-write.c', 'scm_functable_r5rs_write', ['write.c']],
  ['functable-r5rs-load.c', 'scm_functable_r5rs_load', ['load.c']],
  ['functable-r5rs-deep-cadrs.c', 'scm_functable_r5rs_deep_cadrs',
   ['deep-cadrs.c']],
  # Optional modules
  ['functable-legacy-macro.c', 'scm_functable_legacy_macro',
   ['legacy-macro.c']],
  ['functable-sscm-ext.c', 'scm_functable_sscm_ext', ['module-sscm-ext.c']],
  ['functable-siod.c', 'scm_functable_siod', ['module-siod.c']],
  ['functable-srfi1.c', 'scm_functable_srfi1', ['module-srfi1.c']],
  ['functable-srfi2.c', 'scm_functable_srfi2', ['module-srfi2.c']],
  ['functable-srfi6.c', 'scm_functable_srfi6', ['module-srfi6.c']],
  ['functable-srfi8.c', 'scm_functable_srfi8', ['module-srfi8.c']],
  ['functable-srfi9.c', 'scm_functable_srfi9', ['module-srfi9.c']],
  ['functable-srfi23.c', 'scm_functable_srfi23', ['module-srfi23.c']],
  ['functable-srfi28.c', 'scm_functable_srfi28', ['module-srfi28.c']],
  ['functable-srfi34.c', 'scm_functable_srfi34', ['module-srfi34.c']],
  ['functable-srfi38.c', 'scm_functable_srfi38', ['module-srfi38.c']],
  ['functable-srfi43.c', 'scm_functable_srfi43', ['module-srfi43.c']],
  ['functable-srfi48.c', 'scm_functable_srfi48', ['module-srfi48.c']],
  ['functable-srfi55.c', 'scm_functable_srfi55', ['module-srfi55.c']],
  ['functable-srfi60.c', 'scm_functable_srfi60', ['module-srfi60.c']],
]
# Source archives include generated function tables. We use them if
# they exist. We need Ruby to generate them otherwise.
func_tables_stamp = []
if not fs.exists(func_tables[0][0])
  ruby = find_program('ruby')
  build_func_table = files('../tools/build_func_table.rb')
  build_func_table_depends = files(
    '../tools/functable-footer.txt',
    '../tools/functable-header.txt',
    '../tools/scm_decl.rb',
  )
  func_table_targets = []
  foreach func_table : func_tables
    func_table_targets += [
      custom_target(func_table[0],
                    input: func_table[2],
                    output: func_table[0],
                    command: [
                      ruby,
                      '-I', meson.project_source_root() / 'tools',
                      build_func_table,
                      '@OUTPUT@',
                      func_table[1],
                      '@INPUT@',
                    ],
                    depend_files: build_func_table_depends),
    ]
  endforeach
  # We can't use func_table_targets as sources directly because Meson
  # compiles *.c in sources. We use a header file that depends on
  # func_table_targets to build them before we build sources that
  # #include them.
  func_tables_stamp += [
    custom_target('functables-stamp.h',
                  output: 'functables-stamp.h',
                  command: [
                    ruby,
                    '-e', 'File.write(ARGV[0], "")',
                    '@OUTPUT@',
                  ],
                  depends: func_table_targets),
  ]
endif

libsscm_sources = files(
  'alloc.c',
  'env.c',
  'error.c',
  'eval.c',
  'list.c',
  'module.c',
  'procedure.c',
  'sigscheme.c',
  'storage-gc.c',
  'storage.c',
  'symbol.c',
  'syntax.c',
)
if use['continuation']
  libsscm_sources += files('continuation.c')
endif
if use['port']
  libsscm_sources += files('scmport-basechar.c', 'scmport-file.c')
  if use['multibyte_char']
    libsscm_sources += files('encoding.c', 'scmport-mbchar.c')
  else
    libsscm_sources += files('scmport-sbchar.c')
  endif
endif
# [feature, sources]
foreach optional_sources : [
  ['format', ['format.c']],
  ['quasiquote', ['qquote.c']],
  # FIXME: support SCM_USE_SYNTAX_CASE
  ['hygienic_macro', ['macro.c']],
  ['legacy_macro', ['legacy-macro.c']],
  ['promise', ['promise.c']],
  ['number', ['number.c']],
  ['number_io', ['number-io.c']],
  ['char', ['char.c']],
  ['string', ['string.c']],
  ['string_procedure', ['string-procedure.c']],
  ['vector', ['vector.c']],
  ['port', ['port.c']],
  ['reader', ['read.c']],
  ['writer', ['write.c']],
  ['load', ['load.c']],
  ['deep_cadrs', ['deep-cadrs.c']],
  # optional modules
  ['sscm_extensions', ['module-sscm-ext.c']],
  ['compat_siod', ['module-siod.c', 'scmport-null.c']],
  ['srfi1', ['module-srfi1.c']],
  ['srfi2', ['module-srfi2.c']],
  ['srfi6', ['module-srfi6.c', 'scmport-str.c']],
  ['srfi8', ['module-srfi8.c']],
  ['srfi9', ['module-srfi9.c']],
  ['srfi23', ['module-srfi23.c']],
  ['srfi28', ['module-srfi28.c']],
  ['srfi34', ['module-srfi34.c']],
  ['srfi38', ['module-srfi38.c']],
  ['srfi43', ['module-srfi43.c']],
  ['srfi48', ['module-srfi48.c']],
  ['srfi55', ['module-srfi55.c']],
  ['srfi60', ['module-srfi60.c']],
]
  if use[optional_sources[0]]
    libsscm_sources += files(optional_sources[1])
  endif
endforeach
if strcasecmp_replacement
  libsscm_sources += files('strcasecmp.c')
endif
libsscm_sources += gcroots_sources

sscm_c_args = [
  '-DPKGDATADIR="@0@"'.format(prefix / pkgdatadir),
  '-DSCMLIBDIR="@0@"'.format(prefix / scmlibdir),
]
sigscheme_internal_include_directories = [
  sigscheme_include_directories,
  sigscheme_config_include_directories,
  include_directories('.'),
] + gcroots_include_directories

if use['libsscm']
  # To take precedence over installed gcroots.h by the bundled
  # subprojects/libgcroots/include/gcroots.h, gcroots_include_directories must be
  # placed here.
  libsscm = library('sscm',
                    libsscm_sources,
                    func_tables_stamp,
                    c_args: (sscm_c_args +
                            libsscm_c_args +
                            ['-DSCM_COMPILING_LIBSSCM=1']),
                    darwin_versions: darwin_versions,
                    dependencies: gcroots_dependencies,
                    include_directories: sigscheme_internal_include_directories,
                    install: true,
                    soversion: so_version,
                    version: library_version)
  sigscheme_dep = declare_dependency(dependencies: gcroots_dependencies,
                                     include_directories: sigscheme_include_directories,
                                     link_with: libsscm)
  meson.override_dependency('sigscheme', sigscheme_dep)
endif

if use['shell']
  sscm = executable('sscm',
                    'main.c',
                    c_args: sscm_c_args,
                    dependencies: gcroots_dependencies,
                    include_directories: sigscheme_internal_include_directories,
                    install: true,
                    link_with: libsscm)
endif
