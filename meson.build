project('sigscheme',
        'c',
        version: '0.9.7',
        # 0.63.0 or later is needed to build test programs that aren't
        # built by default on 'meson test'.
        meson_version: '>=0.63.0')

fs = import('fs')

cc = meson.get_compiler('c')

package_name = 'SigScheme'
package_string = '@0@ @1@'.format(package_name, meson.project_version())
package_bugreport = 'sigscheme-ja@googlegroups.com'

prefix = get_option('prefix')
datadir = get_option('datadir')
includedir = get_option('includedir')
libdir = get_option('libdir')

# Install into master package's pkgdatadir if master_pkg is specified
# e.g.)
#   -Dmaster_pkg=     ->  /usr/share/sigscheme/lib/srfi-1.scm
#   -Dmaster_pkg=uim  ->  /usr/share/uim/lib/srfi-1.scm
master_pkg = get_option('master_pkg')
if master_pkg == ''
  master_pkg = meson.project_name()
endif
pkgdatadir = datadir / master_pkg
scmlibdir = pkgdatadir / 'lib'
pkgincludedir = includedir / meson.project_name()
docdir = datadir / 'doc' / meson.project_name()


#
# Checks for header files, types, compiler characteristics and functions
#

config_data = configuration_data()
config_data.set_quoted('PACKAGE', meson.project_name())
config_data.set_quoted('PACKAGE_BUGREPORT', package_bugreport)
config_data.set_quoted('PACKAGE_NAME', package_name)
config_data.set_quoted('PACKAGE_STRING', package_string)
config_data.set_quoted('PACKAGE_TARNAME', meson.project_name())
config_data.set_quoted('PACKAGE_URL', '')
config_data.set_quoted('PACKAGE_VERSION', meson.project_version())
config_data.set_quoted('VERSION', meson.project_version())

foreach header : [
  'malloc.h',
  'strings.h',
  'sys/types.h',
]
  if cc.has_header(header)
    config_data.set('HAVE_' + header.underscorify().to_upper(), 1)
  endif
endforeach

type_prefix = '''
#include <stddef.h>
#include <stdint.h>
'''
# Do not assume (sizeof(int32_t) == 4) and so on (i.e. do not (CHAR_BIT == 8)).
foreach type : [
  'char',
  'int',
  'long',
  'void *',
  'size_t',
  'int16_t',
  'int32_t',
  'int64_t',
  'intmax_t',
  'intptr_t',
]
  type_id = type.replace('*', 'p').underscorify().to_upper()
  config_data.set('SIZEOF_' + type_id,
                  cc.sizeof(type, prefix: type_prefix))
endforeach
foreach type : [
  'char',
  'int',
  'long',
  'void *',
  'int16_t',
  'int32_t',
  'int64_t',
  'intptr_t',
]
  type_id = type.replace('*', 'p').underscorify().to_upper()
  config_data.set('ALIGNOF_' + type_id,
                  cc.alignment(type, prefix: type_prefix))
endforeach

sigsetjmp_code = '''
#include <setjmp.h>

int
main(void)
{
  sigjmp_buf env;
  while (!sigsetjmp(env, 1))
    siglongjmp(env, 1);
  return 0;
}
'''
if cc.links(sigsetjmp_code, name: 'sigsetjmp')
  config_data.set('HAVE_SIGSETJMP', 1)
endif

foreach function : [
  'fileno',
  'getcontext',
  'memalign',
]
  if cc.has_function(function)
    config_data.set('HAVE_' + function.to_upper(), 1)
  endif
endforeach

# Macros that are enabled only when we build libsscm. configure
# defines them in config.h with '#if SCM_COMPILING_LIBSSCM' but we
# pass them only to libsscm.
libsscm_c_args = []
if cc.has_function('posix_memalign')
  config_data.set('HAVE_POSIX_MEMALIGN', 1)
  # For posix_memalign(3). although this value is overridden by _GNU_SOURCE
  # on glibc, keep this for other environments.
  libsscm_c_args += ['-D_POSIX_C_SOURCE=200112L']
endif
if cc.has_function('strdup')
  config_data.set('HAVE_STRDUP', 1)
  # Overrides _POSIX_C_SOURCE
  libsscm_c_args += ['-D_XOPEN_SOURCE=500']
endif
strcasecmp_replacement = false
if cc.has_function('strcasecmp')
  config_data.set('HAVE_STRCASECMP', 1)
else
  strcasecmp_replacement = true
endif


#
# libgcroots
#

# We prefer system BDWGC/libgcroots and use the bundled libgcroots as a
# fallback. Use --force-fallback-for=gcroots to use the bundled
# libgcroots even if system libgcroots exists.
gc = get_option('gc')
gcroots_dependencies = []
gcroots_include_directories = []
use_libgcroots = ''
if gc in ['auto', 'bdwgc']
  bdwgc = dependency('bdw-gc', version: '>= 8.3.0', required: gc == 'bdwgc')
  if bdwgc.found()
    gcroots_dependencies += [bdwgc]
    config_data.set('SCM_WITH_BDWGC', 1)
    use_libgcroots = 'installed BDWGC'
  endif
endif
if use_libgcroots == '' and gc in ['auto', 'gcroots']
  gcroots = dependency('gcroots', version: '>= 0.2.3', fallback: 'libgcroots')
  gcroots_dependencies += [gcroots]
  if gcroots.type_name() == 'internal'
    use_libgcroots = 'bundled one'
  else
    use_libgcroots = 'installed one'
  endif
endif
if gc == 'tiny-subst'
  # use src/gcroots/gcroots.[hc]
  gcroots_include_directories += [include_directories('src/gcroots')]
  use_libgcroots = 'tiny substitution in src/gcroots'
endif


########################################
# Configure features with dependencies #
########################################

# This is a port of AX_FEATURE_CONFIGURATOR in
# m4/ax_feature_configurator.m4. Values of features are 'yes', 'no'
# or other value such as 'compact' for 'storage'.

# Specify a set of default variable settings for each 'conf'.
conf_r5rs_features_all = {
  'continuation': 'yes',
  'quasiquote': 'yes',
  'promise': 'yes',
  'int': 'yes',
  'numeric_io': 'yes',
  'char': 'yes',
  'string': 'yes',
  'string_procedures': 'yes',
  'deep_cadrs': 'yes',
  'vector': 'yes',
  'port': 'yes',
  'reader': 'yes',
  'writer': 'yes',
  'load': 'yes',
}
conf_srfis_all = {
  'srfi0': 'yes',
  'srfi1': 'yes',
  'srfi2': 'yes',
  'srfi6': 'yes',
  'srfi8': 'yes',
  'srfi9': 'yes',
  'srfi22': 'yes',
  'srfi23': 'yes',
  'srfi28': 'yes',
  'srfi34': 'yes',
  'srfi38': 'yes',
  'srfi43': 'yes',
  'srfi48': 'yes',
  'srfi55': 'yes',
  'srfi60': 'yes',
  'srfi69': 'yes',
  'srfi95': 'yes',
}
conf_presets = {
  'regular': {
    'hygienic_macro': 'no',
  },
  'full': {
    # multibyte char handlings
    'utf8': 'yes',
    'euccn': 'yes',
    'eucjp': 'yes',
    'euckr': 'yes',
    'sjis': 'yes',
    # R5RS behaviors
    'strict_r5rs': 'no',
    'const_vector_literal': 'yes',
    'strict_vector_form': 'yes',
    'strict_argcheck': 'yes',
    'strict_toplevel_definitions': 'yes',
    'internal_definitions': 'yes',
    # experimental features
    'hygienic_macro': 'no',
    # SigScheme-specific extensions
    'legacy_macro': 'yes',
    'sscm_extensions': 'yes',
    'sscm_format_extension': 'yes',
    'compat_siod': 'no',
    'eval_c_string': 'yes',
    # R6RS features
    'r6rs_named_chars': 'yes',
    'r6rs_chars': 'yes',
  } + conf_r5rs_features_all + conf_srfis_all,
  'r5rs': {
    # R5RS behaviors
    'strict_r5rs': 'yes',
    # experimental features
    'hygienic_macro': 'no',
    # SigScheme-specific extensions
    'legacy_macro': 'yes',
    'sscm_extensions': 'yes',
    'sscm_format_extension': 'yes',
    'compat_siod': 'no',
    'eval_c_string': 'yes',
    # R6RS features
    'r6rs_named_chars': 'no',
    'r6rs_chars': 'no',
  } + conf_r5rs_features_all + conf_srfis_all,
  'dev': {
    # multibyte char handlings
    'utf8': 'yes',
    'euccn': 'yes',
    'eucjp': 'yes',
    'euckr': 'yes',
    'sjis': 'yes',
    # R5RS behaviors
    'strict_r5rs': 'no',
    'const_vector_literal': 'yes',
    'strict_vector_form': 'yes',
    'strict_argcheck': 'yes',
    'strict_toplevel_definitions': 'yes',
    'internal_definitions': 'yes',
    # experimental features
    'hygienic_macro': 'yes',
    # SigScheme-specific extensions
    'legacy_macro': 'yes',
    'sscm_extensions': 'yes',
    'sscm_format_extension': 'yes',
    'compat_siod': 'no',
    'eval_c_string': 'yes',
    # R6RS features
    'r6rs_named_chars': 'yes',
    'r6rs_chars': 'yes',
    # Debugging features
    'backtrace': 'yes',
    'debug': 'yes',
    'warning_suppressor': 'yes',
  } + conf_r5rs_features_all + conf_srfis_all,
  'uim': {
    # multibyte char handlings
    'default_encoding': 'singlebyte',
    'utf8': 'yes',
    'euccn': 'no',
    'eucjp': 'yes',
    'euckr': 'no',
    'sjis': 'no',
    'strict_encoding_check': 'no',
    # R5RS behaviors
    'strict_r5rs': 'no',
    'const_vector_literal': 'yes',
    'strict_null_form': 'no',
    'strict_vector_form': 'yes',
    'strict_argcheck': 'yes',
    'strict_toplevel_definitions': 'yes',
    'internal_definitions': 'yes',
    # R5RS features
    'continuation': 'yes',
    'quasiquote': 'yes',
    'promise': 'yes',
    'int': 'yes',
    'numeric_io': 'yes',
    'char': 'yes',
    'string': 'yes',
    'string_procedures': 'yes',
    'deep_cadrs': 'no',
    'vector': 'yes',
    'port': 'yes',
    'reader': 'yes',
    'writer': 'yes',
    'load': 'yes',
    # experimental features
    'hygienic_macro': 'no',
    # SigScheme-specific extensions
    'legacy_macro': 'yes',
    'sscm_extensions': 'yes',
    'sscm_format_extension': 'yes',
    'compat_siod': 'yes',
    'eval_c_string': 'yes',
    # R6RS features
    'r6rs_named_chars': 'yes',
    'r6rs_chars': 'yes',
  } + conf_srfis_all,
}

# [feature, default value]
#
# The order is the same as configure.ac.
feature_declarations = [
  # Pseudo feature as base dependency: Features that required to run
  # current SigScheme implementation depends on this.
  ['sigscheme', 'yes'],
  ['conf', 'regular'],

  # Storage configuration
  ['storage', 'compact'],
  ['fixnum', 'long'],
  ['scmref', 'intptr_t'],
  ['valuecons', 'no'],
  ['dump', 'no'],

  # String configuration
  ['null_capable_string', 'no'],

  # Character encodings
  ['multibyte', 'no'],
  ['default_encoding', 'utf8'],
  ['utf8', 'yes'],
  ['euccn', 'no'],
  ['eucjp', 'no'],
  ['euckr', 'no'],
  ['sjis', 'no'],
  ['strict_encoding_check', 'yes'],

  # Other internal SigScheme features
  ['format', 'no'],
  ['raw_c_format', 'no'],

  # R5RS behaviors
  ['strict_r5rs', 'no'],
  ['const_list_literal', 'no'],
  ['const_vector_literal', 'yes'],
  ['strict_null_form', 'no'],
  ['strict_vector_form', 'yes'],
  ['strict_argcheck', 'yes'],
  ['strict_toplevel_definitions', 'yes'],
  ['internal_definitions', 'yes'],

  # R5RS features
  ['continuation', 'yes'],
  ['quasiquote', 'yes'],
  ['hygienic_macro', 'no'],
  ['promise', 'yes'],
  ['number', 'no'],
  ['int', 'yes'],
  ['rational', 'no'],
  ['real', 'no'],
  ['complex', 'no'],
  ['numeric_io', 'yes'],
  ['char', 'yes'],
  ['string', 'yes'],
  ['string_procedures', 'yes'],
  ['deep_cadrs', 'yes'],
  ['vector', 'yes'],
  ['port', 'yes'],
  ['reader', 'yes'],
  ['writer', 'yes'],
  ['load', 'yes'],

  # SRFIs
  ['srfi0', 'yes'],
  ['srfi1', 'yes'],
  ['srfi2', 'yes'],
  ['srfi6', 'yes'],
  ['srfi8', 'yes'],
  ['srfi9', 'yes'],
  ['srfi22', 'yes'],
  ['srfi23', 'yes'],
  ['srfi28', 'yes'],
  ['srfi34', 'yes'],
  ['srfi38', 'yes'],
  ['srfi43', 'yes'],
  ['srfi48', 'yes'],
  ['srfi55', 'yes'],
  ['srfi60', 'yes'],
  ['srfi69', 'yes'],
  ['srfi95', 'yes'],

  # R6RS features (preliminary)
  ['r6rs_named_chars', 'yes'],
  ['r6rs_chars', 'yes'],

  # Common Scheme features
  ['syntax_case', 'no'],
  ['unhygienic_macro', 'no'],
  ['legacy_macro', 'yes'],

  # SigScheme-specific features
  ['sscm_extensions', 'yes'],
  ['sscm_format_extension', 'yes'],
  ['compat_siod', 'no'],
  ['eval_c_string', 'yes'],
  ['backtrace', 'no'],
  ['libsscm', 'yes'],
  ['shell', 'yes'],

  # Developer-only debugging features
  ['debug', 'no'],
  ['debug_port', 'no'],
  ['debug_parser', 'no'],
  ['debug_macro', 'no'],
  ['debug_encoding', 'no'],
  ['debug_backtrace_sep', 'no'],
  ['debug_backtrace_val', 'no'],
  ['soft_assert', 'no'],
  ['accessor_assert', 'no'],
  ['warning_suppressor', 'yes'],
]

# Features that can't be specified by users
internal_features = [
  'sigscheme',
  'scmref',
  'valuecons',
  'dump',
  'null_capable_string',
  'multibyte',
  'format',
  'raw_c_format',
  'number',
  'rational',
  'real',
  'complex',
  'syntax_case',
  'unhygienic_macro',
]
# Meson option names that differ from feature names. We can't use
# 'debug' because it's a Meson's built-in option.
feature_option_names = {
  'debug': 'debug_mode',
}

# Required dependencies
feature_required_dependencies = {
  'sigscheme': ['raw_c_format'],
  'backtrace': ['continuation', 'port', 'writer'],
  'debug': ['raw_c_format'],
  'debug_backtrace_val': ['debug', 'backtrace', 'raw_c_format'],

  'format': ['writer', 'port', 'string'],
  'srfi28': ['format'],
  'srfi48': ['format', 'srfi28'],
  'sscm_format_extension': ['format', 'srfi48'],
  'raw_c_format': ['format'],

  'syntax_case': ['unhygienic_macro'],
  'string_procedures': ['string_procedure'],
  'string_procedure': ['string', 'char'],
  'reader': ['port'],
  'writer': ['port', 'raw_c_format'],
  'load': ['port', 'reader', 'string'],
  'sscm_extensions': ['load'],
  'eval_c_string': ['reader', 'srfi6'],
  'srfi0': ['load', 'srfi55', 'legacy_macro', 'srfi1', 'srfi23'],
  'srfi1': ['continuation', 'deep_cadrs', 'load', 'sscm_extensions', 'srfi8',
            'srfi23'],
  'srfi6': ['port', 'string'],
  'srfi9': ['load', 'vector', 'srfi23'],
  'srfi34': ['continuation', 'srfi23'],
  'srfi38': ['writer'],
  'srfi43': ['load', 'vector', 'srfi8', 'srfi23', 'sscm_extensions'],
  'srfi55': ['load', 'sscm_extensions'],
  'srfi60': ['int'],
  'srfi69': ['load', 'int', 'string', 'vector', 'srfi9', 'srfi23'],
  'srfi95': ['load', 'int'],
  'r6rs_named_chars': ['char'],
  'r6rs_chars': ['char', 'utf8', 'reader', 'r6rs_named_chars'],

  'compat_siod': ['sscm_extensions', 'srfi60', 'eval_c_string'],
  'strict_r5rs': ['strict_null_form', 'strict_vector_form', 'strict_argcheck',
                  'internal_definitions', 'strict_toplevel_definitions',
                  'const_vector_literal'],

  'int': ['number'],
  'rational': ['number'],
  'real': ['number'],
  'complex': ['number'],
  'numeric_io': ['number_io'],
  'number_io': ['number', 'string'],

  'fixnum_long': ['long_fixnum'],
  'fixnum_int': ['int_fixnum'],
  'fixnum_int32_t': ['32bit_fixnum'],
  'fixnum_int64_t': ['64bit_fixnum'],
  'scmref_intptr_t': ['intptr_scmref'],
  'scmref_int32_t': ['32bit_scmref'],
  'scmref_int64_t': ['64bit_scmref'],

  'multibyte': ['multibyte_char'],
  'utf8': ['multibyte_char'],
  'eucjp': ['multibyte_char'],
  'euckr': ['multibyte_char'],
  'euccn': ['multibyte_char'],
  'sjis': ['multibyte_char'],
  'default_encoding_utf8': ['utf8', 'utf8_as_default'],
  'default_encoding_singlebyte': ['singlebyte_as_default'],
  'default_encoding_euccn': ['euccn', 'euccn_as_default'],
  'default_encoding_eucjp': ['eucjp', 'eucjp_as_default'],
  'default_encoding_euckr': ['euckr', 'euckr_as_default'],
  'default_encoding_sjis': ['sjis', 'sjis_as_default'],

  'shell': ['libsscm'],
}

# Recommended dependencies (not required)
feature_recommended_dependencies = {
  'conf_dev': ['warning_suppressor'],
  'storage_fatty': ['valuecons', 'const_list_literal', 'const_vector_literal'],
  'debug': ['accessor_assert', 'strict_argcheck', 'strict_encoding_check'],
  'backtrace': ['srfi38'],
  'srfi69': ['srfi38'],
}

# Conflicts between the features
feature_conflicts = [
  ['storage_fatty', 'storage_compact'],
  ['storage_compact', 'valuecons'],
  ['storage_compact', 'const_list_literal'],
  ['debug_no', 'null_capable_string'],
  ['strict_r5rs', 'strict_vector_form_no'],
  ['strict_r5rs', 'strict_null_form_no'],
  ['strict_r5rs', 'strict_toplevel_definitions_no'],
  ['strict_r5rs', 'internal_definitions_no'],
  ['long_fixnum', 'int_fixnum', '32bit_fixnum', '64bit_fixnum'],
  ['intptr_scmref', '32bit_scmref', '64bit_scmref'],
  ['singlebyte_as_default', 'utf8_as_default', 'eucjp_as_default',
   'euckr_as_default', 'euccn_as_default', 'sjis_as_default'],
]

#
# Acquire the feature configuration variables from user
#

conf = get_option('conf')
conf_preset = conf_presets[conf]
feature_values = {}
feature_list_all = []
feature_list_explicit = []
foreach declaration : feature_declarations
  feature = declaration[0]
  default_value = declaration[1]
  value = 'auto'
  if feature not in internal_features
    value = get_option(feature_option_names.get(feature, feature))
    if value == 'true'
      value = 'yes'
    elif value == 'false'
      value = 'no'
    endif
  endif
  if value == 'auto'
    # If the value is provided by 'conf', it's used as default value.
    # Explicit option value can override it.
    value = conf_preset.get(feature, default_value)
  endif
  feature_values += {
    feature: value,
    '@0@_@1@'.format(feature, value): 'yes',
  }
  feature_list_all += [feature]
  if value != 'no'
    feature_list_explicit += [feature]
    if value != 'yes'
      feature_list_explicit += ['@0@_@1@'.format(feature, value)]
    endif
  endif
endforeach

#
# Resolve dependency of the features
#

foreach dependencies : [
  feature_required_dependencies,
  feature_recommended_dependencies,
]
  # Compute the transitive closure of the explicitly specified
  # features.
  resolved_features = feature_list_explicit
  foreach _ : range(feature_declarations.length() * 2)
    new_features = []
    foreach feature : resolved_features
      foreach dependency : dependencies.get(feature, [])
        if dependency not in resolved_features and \
           dependency not in new_features
          new_features += [dependency]
        endif
      endforeach
    endforeach
    if new_features.length() == 0
      break
    endif
    resolved_features += new_features
  endforeach
  # Override values: Features that are required by other features are
  # enabled even if they are disabled explicitly.
  foreach feature : resolved_features
    value = feature_values.get(feature, '')
    if value == ''
      feature_list_all += [feature]
    endif
    if value in ['', 'no']
      feature_values += {
        feature: 'yes',
        feature + '_yes': 'yes',
      }
    endif
  endforeach
endforeach

# Check conflicts between the features
feature_list_expanded = []
foreach feature : feature_list_all
  value = feature_values.get(feature)
  if value != 'no'
    feature_list_expanded += [feature]
  endif
  feature_list_expanded += ['@0@_@1@'.format(feature, value)]
endforeach
feature_conflict_messages = []
foreach mutexes : feature_conflicts
  conflicts = []
  foreach feature : feature_list_expanded
    if feature in mutexes
      conflicts += [feature]
    endif
  endforeach
  if conflicts.length() > 1
    feature_conflict_messages += [
      'these features must exclusively be chosen from @0@: @1@'.format(
        '|'.join(mutexes),
        ' '.join(conflicts)),
    ]
  endif
endforeach
if feature_conflict_messages.length() > 0
  foreach message : feature_conflict_messages
    warning(message)
  endforeach
  error('feature conflict(s) between mutually exclusive ones have been detected')
endif

#
# Define configured results
#

# Features that are defined as SCM_USE_FEATURE in config.h
feature_definitions = [
  # Storage configuration
  'storage_compact',
  'storage_fatty',
  'long_fixnum',
  'int_fixnum',
  '32bit_fixnum',
  '64bit_fixnum',
  'intptr_scmref',
  '32bit_scmref',
  '64bit_scmref',
  'valuecons',
  'dump',

  # String configuration
  'null_capable_string',

  # Character encodings
  'multibyte_char',
  'utf8',
  'euccn',
  'eucjp',
  'euckr',
  'sjis',
  'utf8_as_default',
  'singlebyte_as_default',
  'euccn_as_default',
  'eucjp_as_default',
  'euckr_as_default',
  'sjis_as_default',
  'strict_encoding_check',

  # Other internal SigScheme features
  'format',
  'raw_c_format',

  # R5RS behaviors
  'strict_r5rs',
  'const_list_literal',
  'const_vector_literal',
  'strict_null_form',
  'strict_vector_form',
  'strict_argcheck',
  'strict_toplevel_definitions',
  'internal_definitions',

  # R5RS features
  'continuation',
  'quasiquote',
  'hygienic_macro',
  'promise',
  'number',
  'int',
  'rational',
  'real',
  'complex',
  'number_io',
  'char',
  'string',
  'string_procedure',
  'deep_cadrs',
  'vector',
  'port',
  'reader',
  'writer',
  'load',

  # SRFIs
  'srfi0',
  'srfi1',
  'srfi2',
  'srfi6',
  'srfi8',
  'srfi9',
  'srfi22',
  'srfi23',
  'srfi28',
  'srfi34',
  'srfi38',
  'srfi43',
  'srfi48',
  'srfi55',
  'srfi60',
  'srfi69',
  'srfi95',

  # R6RS features (preliminary)
  'r6rs_named_chars',
  'r6rs_chars',

  # Common Scheme features
  'syntax_case',
  'unhygienic_macro',
  'legacy_macro',

  # SigScheme-specific features
  'sscm_extensions',
  'sscm_format_extension',
  'compat_siod',
  'eval_c_string',
  'backtrace',
  'libsscm',
  'shell',

  # Developer-only debugging features
  'debug',
  'debug_port',
  'debug_parser',
  'debug_macro',
  'debug_encoding',
  'debug_backtrace_sep',
  'debug_backtrace_val',
  'soft_assert',
  'accessor_assert',
  'warning_suppressor',
]
# Macro names that aren't SCM_USE_FEATURE
feature_macros = {
  'strict_encoding_check': 'SCM_STRICT_ENCODING_CHECK',
  'strict_r5rs': 'SCM_STRICT_R5RS',
  'const_list_literal': 'SCM_CONST_LIST_LITERAL',
  'const_vector_literal': 'SCM_CONST_VECTOR_LITERAL',
  'strict_null_form': 'SCM_STRICT_NULL_FORM',
  'strict_vector_form': 'SCM_STRICT_VECTOR_FORM',
  'strict_argcheck': 'SCM_STRICT_ARGCHECK',
  'strict_toplevel_definitions': 'SCM_STRICT_TOPLEVEL_DEFINITIONS',
  'compat_siod': 'SCM_COMPAT_SIOD',
  'debug': 'SCM_DEBUG',
  'debug_port': 'SCM_DEBUG_PORT',
  'debug_parser': 'SCM_DEBUG_PARSER',
  'debug_macro': 'SCM_DEBUG_MACRO',
  'debug_encoding': 'SCM_DEBUG_ENCODING',
  'debug_backtrace_sep': 'SCM_DEBUG_BACKTRACE_SEP',
  'debug_backtrace_val': 'SCM_DEBUG_BACKTRACE_VAL',
  'soft_assert': 'SCM_SOFT_ASSERT',
  'accessor_assert': 'SCM_ACCESSOR_ASSERT',
}

# feature -> true/false. This is used like AM_CONDITIONAL().
use = {}
foreach feature : feature_definitions
  macro = feature_macros.get(feature, 'SCM_USE_' + feature.to_upper())
  value = feature_values.get(feature, 'no')
  if value == ''
    value = 'no'
  endif
  feature_values += {feature: value}
  enabled = (value != 'no')
  if enabled
    config_data.set(macro, 1)
  endif
  use += {feature: enabled}
endforeach


#########
# Fixup #
#########

#
# Hardwired configurations
#

config_data.set('SCM_ENCODING_USE_WITH_SIGSCHEME', 1)
config_data.set('SCM_SCMPORT_USE_WITH_SIGSCHEME', 1)

#
# Compiler options
#

# configure adds -g3 for --enable-debug and -DNDEBUG for
# --disable-debug. We don't do it. Use Meson's built-in options such as
# -Dbuildtype=debug and -Db_ndebug=true instead.

# For <sigscheme/*.h>
sigscheme_include_directories = include_directories('include')
# For <config.h> in internal sources
sigscheme_config_include_directories = include_directories('include/sigscheme')

subdir('include/sigscheme')
subdir('src')
subdir('lib')
subdir('doc')
subdir('test')
subdir('test-c')

if use['libsscm']
  # Clients such as uim use these variables to detect features.
  pc_variables = ['scmlibdir=' + ('${prefix}' / scmlibdir)]
  foreach feature : [
    'storage',
    'fixnum',
    'multibyte_char',
    'default_encoding',
    'utf8',
    'euccn',
    'eucjp',
    'euckr',
    'sjis',
    'strict_r5rs',
    'const_list_literal',
    'const_vector_literal',
    'strict_null_form',
    'strict_vector_form',
    'strict_argcheck',
    'strict_toplevel_definitions',
    'internal_definitions',
    'continuation',
    'quasiquote',
    'hygienic_macro',
    'promise',
    'int',
    'number_io',
    'char',
    'string',
    'string_procedure',
    'deep_cadrs',
    'vector',
    'port',
    'reader',
    'writer',
    'load',
    'srfi0',
    'srfi1',
    'srfi2',
    'srfi6',
    'srfi8',
    'srfi9',
    'srfi22',
    'srfi23',
    'srfi28',
    'srfi34',
    'srfi38',
    'srfi43',
    'srfi48',
    'srfi55',
    'srfi60',
    'srfi69',
    'srfi95',
    'r6rs_chars',
    'r6rs_named_chars',
    'legacy_macro',
    'sscm_extensions',
    'sscm_format_extension',
    'compat_siod',
    'eval_c_string',
    'backtrace',
    'debug',
  ]
    if feature == 'number_io'
      variable = 'sscm_numeric_io'
    elif feature.startswith('sscm_')
      variable = feature
    else
      variable = 'sscm_' + feature
    endif
    pc_variables += ['@0@=@1@'.format(variable, feature_values[feature])]
  endforeach
  pkgconfig = import('pkgconfig')
  pkgconfig.generate(libsscm,
                     name: package_name,
                     filebase: meson.project_name(),
                     description: 'Scheme interpreter for embedded use',
                     variables: pc_variables)
endif

summary({
          'base config': conf,
        },
        section: 'SigScheme')
summary({
          'Storage impl': feature_values['storage'],
          'Fixnum size': feature_values['fixnum'],
          'getcontext': config_data.has('HAVE_GETCONTEXT'),
          'libgcroots': use_libgcroots,
        },
        section: 'Storage configuration')
summary({
          'Multibyte chars': use['multibyte_char'],
          'Default encoding': feature_values['default_encoding'],
          'UTF-8 codec': use['utf8'],
          'EUC-CN codec': use['euccn'],
          'EUC-JP codec': use['eucjp'],
          'EUC-KR codec': use['euckr'],
          'Shift_JIS codec': use['sjis'],
        },
        section: 'Multibyte character handlings')
summary({
          'Strict R5RS': use['strict_r5rs'],
          'Const list literal': use['const_list_literal'],
          'Const vector literal': use['const_vector_literal'],
          'Strict null form': use['strict_null_form'],
          'Strict vector form': use['strict_vector_form'],
          'Strict argcheck': use['strict_argcheck'],
          'Strict top-level defs': use['strict_toplevel_definitions'],
          'Internal definitions': use['internal_definitions'],
        },
        section: 'R5RS behaviors')
summary({
          'Continuation': use['continuation'],
          'Quasiquote': use['quasiquote'],
          'Hygienic macros': use['hygienic_macro'],
          'Promise': use['promise'],
          'Integer': use['int'],
          'Numeric I/O': use['number_io'],
          'Charcters': use['char'],
          'Strings': use['string'],
          'String procedures': use['string_procedure'],
          'Deep c[ad]+r procs': use['deep_cadrs'],
          'Vectors': use['vector'],
          'Ports': use['port'],
          'Reader': use['reader'],
          'Writer': use['writer'],
          'Load': use['load'],
        },
        section: 'R5RS features')
summary({
          'SRFI-0': use['srfi0'],
          'SRFI-1': use['srfi1'],
          'SRFI-2': use['srfi2'],
          'SRFI-6': use['srfi6'],
          'SRFI-8': use['srfi8'],
          'SRFI-9': use['srfi9'],
          'SRFI-22': use['srfi22'],
          'SRFI-23': use['srfi23'],
          'SRFI-28': use['srfi28'],
          'SRFI-34': use['srfi34'],
          'SRFI-38': use['srfi38'],
          'SRFI-43': use['srfi43'],
          'SRFI-48': use['srfi48'],
          'SRFI-55': use['srfi55'],
          'SRFI-60': use['srfi60'],
          'SRFI-69': use['srfi69'],
          'SRFI-95': use['srfi95'],
        },
        section: 'SRFIs')
summary({
          'R6RS characters': use['r6rs_chars'],
          'R6RS named chars': use['r6rs_named_chars'],
        },
        section: 'R6RS features (preliminary)')
summary({
          'define-macro': use['legacy_macro'],
          'SigScheme extensions': use['sscm_extensions'],
          'format+ procedure': use['sscm_format_extension'],
          'SIOD compatibilities': use['compat_siod'],
          'eval_c_string()': use['eval_c_string'],
          'Backtrace': use['backtrace'],
          'Library': use['libsscm'],
          'Interactive shell': use['shell'],
        },
        section: 'SigScheme-specific extensions')
debugging_summary = {
  'Debug': use['debug'],
}
if use['debug']
  debugging_summary += {
    'Debug port': use['debug_port'],
    'Debug parser': use['debug_parser'],
    'Debug macro': use['debug_macro'],
    'Debug encoding': use['debug_encoding'],
    'Soft assert': use['soft_assert'],
    'Accessor assert': use['accessor_assert'],
    'Warning suppressor': use['warning_suppressor'],
  }
endif
summary(debugging_summary,
        section: 'Developer-only debugging features')
summary({
          'Package': package_string,
          'build (compile on)': '@0@-@1@'.format(build_machine.cpu(),
                                                 build_machine.system()),
          'host (compile for)': '@0@-@1@'.format(host_machine.cpu(),
                                                 host_machine.system()),
          'host align (C/I/L/P)': '@0@/@1@/@2@/@3@'.format(
            config_data.get('ALIGNOF_CHAR'),
            config_data.get('ALIGNOF_INT'),
            config_data.get('ALIGNOF_LONG'),
            config_data.get('ALIGNOF_VOID_P')),
          'Compiler': cc.get_id(),
          'Compiler version': cc.version(),
        },
        section: 'Build information (provide this on bug reports)')
