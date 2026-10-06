txts = [
  'design.txt',
  'global-obj.txt',
  'index.txt',
  'multibyte.txt',
  'release.txt',
  'spec.txt',
  'style.txt',
]

# Suppress installing documents on combined-source configuration
if use['libsscm']
  install_data(txts, install_dir: docdir)
  # Source archives include generated HTML files. We use them if they
  # exist. We generate them if AsciiDoc is available otherwise.
  asciidoc = find_program('asciidoc', required: false)
  foreach txt : txts
    html = txt.replace('.txt', '.html')
    if fs.exists(html)
      install_data(html, install_dir: docdir)
    elif asciidoc.found()
      # xhtml11 backend is supported from AsciiDoc 7.0.0
      custom_target(html,
                    input: txt,
                    output: html,
                    command: [
                      asciidoc,
                      '-b', 'xhtml11',
                      '-n',
                      '-o', '@OUTPUT@',
                      '@INPUT@',
                    ],
                    install: true,
                    install_dir: docdir)
    endif
  endforeach
endif
