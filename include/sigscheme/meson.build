config_h = configure_file(output: 'config.h',
                          configuration: config_data,
                          install: use['libsscm'],
                          install_dir: pkgincludedir)

if use['libsscm']
  headers = files(
    'global.h',
    'scmint.h',
    'sigscheme.h',
  )
  if use['storage_compact']
    headers += files('storage-common.h', 'storage-compact.h')
  else
    headers += files('storage-common.h', 'storage-fatty.h')
  endif
  if use['multibyte_char']
    headers += files('encoding.h')
  else
    headers += files('encoding-dummy.h')
  endif
  install_headers(headers, subdir: meson.project_name())
endif
