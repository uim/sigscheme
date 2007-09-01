dist_scmlib_DATA = sigscheme-init.scm unittest.scm
if USE_SRFI0
dist_scmlib_DATA += srfi-0.scm
endif
if USE_SRFI1
dist_scmlib_DATA += srfi-1.scm
endif
if USE_SRFI9
dist_scmlib_DATA += srfi-9.scm
endif
if USE_SRFI43
dist_scmlib_DATA += srfi-43.scm
endif
if USE_SRFI55
dist_scmlib_DATA += srfi-55.scm
endif
if USE_SRFI69
dist_scmlib_DATA += srfi-69.scm
endif
if USE_SRFI95
dist_scmlib_DATA += srfi-95.scm
endif

# Install into master package's pkgdatadir if --with-master-pkg is specified
# e.g.)
#   --without-master-pkg   ->  /usr/share/sigscheme/lib/srfi-1.scm
#   --with-master-pkg=uim  ->  /usr/share/uim/lib/srfi-1.scm
if WITH_MASTER_PKG
pkgdatadir = ${datadir}/${SSCM_MASTER_PKG}
endif
