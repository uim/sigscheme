scm_files = files('sigscheme-init.scm', 'unittest.scm')
foreach srfi : ['0', '1', '9', '43', '55', '69', '95']
  if use['srfi' + srfi]
    scm_files += files('srfi-@0@.scm'.format(srfi))
  endif
endforeach
install_data(scm_files, install_dir: scmlibdir)
