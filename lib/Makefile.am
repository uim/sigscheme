EXTRA_DIST = slib.scm

dist_scmlib_DATA = sigscheme-init.scm srfi-1.scm srfi-55.scm srfi-95.scm

# Install into master package's pkgdatadir if --with-master-pkg is specified
# e.g.)
#   --without-master-pkg   ->  /usr/share/sigscheme/lib/srfi-1.scm
#   --with-master-pkg=uim  ->  /usr/share/uim/lib/srfi-1.scm
if WITH_MASTER_PKG
pkgdatadir = ${datadir}/${SSCM_MASTER_PKG}
endif
