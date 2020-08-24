ACLOCAL_AMFLAGS = -I m4

SUBDIRS = doc m4 tools
if USE_LIBGCROOTS_BUNDLED
SUBDIRS += libgcroots
endif
SUBDIRS += include src lib test test-c bench

# To make 'make distclean' workable on --with-libgcroots=tiny-subdir,
# libgcroots must be eliminated from $DIST_SUBDIRS.
DIST_SUBDIRS = $(SUBDIRS)

# $(distdir) does work as a part of $(RELEASE_URL) when configured as a
# subpackage.
DIST_NAME = $(PACKAGE)-$(VERSION)
#RELEASE_TAG     = master
RELEASE_TAG     = $(DIST_NAME)
DIST_SUM_LIST = $(DIST_NAME).sum

EXTRA_DIST = \
        sigscheme.pc.in libgcroots.mk.in sigscheme.mk.in autogen.sh \
        RELNOTE TODO QALog \
        compare-scm.sh runbench.sh runtest.sh runtest-tail-rec.sh \
        make-report.sh make-dist.sh

if USE_LIBSSCM
pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = sigscheme.pc
endif

$(pkgconfig_DATA): config.status

DISTCLEANFILES = sigscheme.pc $(DIST_SUM_LIST)

.PHONY: FORCE sum
FORCE:

sum: FORCE
	$(MD5) $(DIST_ARCHIVES) >$(DIST_SUM_LIST)
	$(SHA1) $(DIST_ARCHIVES) >>$(DIST_SUM_LIST)
	$(SHA256) $(DIST_ARCHIVES) >>$(DIST_SUM_LIST)

tag:
	cd "$(srcdir)" && git tag -a -m "$(VERSION) has been released!!!" $(VERSION)
	cd "$(srcdir)" && git push --tags
