# Suppress installing headers on combined-source configuration
if USE_LIBSSCM
nodist_pkginclude_HEADERS = config.h
pkginclude_HEADERS = config-old.h scmint.h global.h sigscheme.h
if USE_STORAGE_COMPACT
pkginclude_HEADERS += storage-common.h storage-compact.h
else
pkginclude_HEADERS += storage-common.h storage-fatty.h
endif
if USE_MULTIBYTE_CHAR
pkginclude_HEADERS += encoding.h
else
pkginclude_HEADERS += encoding-dummy.h
endif
endif
