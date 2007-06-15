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
UIM_REPOSITORY = http://anonsvn.freedesktop.org/svn/uim
SSCM_REPOSITORY = $(UIM_REPOSITORY)/sigscheme-trunk
TAGS_REPOSITORY = $(UIM_REPOSITORY)/tags
#RELEASE_URL     = $(SSCM_REPOSITORY)
RELEASE_URL     = $(TAGS_REPOSITORY)/$(DIST_NAME)
DIST_SUM_LIST = $(DIST_NAME).sum

EXTRA_DIST = \
        sigscheme.pc.in libgcroots.mk.in sigscheme.mk.in autogen.sh \
        RELNOTE TODO QALog \
        compare-scm.sh runbench.sh runtest.sh runtest-tail-rec.sh \
        make-report.sh make-dist.sh

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = sigscheme.pc

$(pkgconfig_DATA): config.status

DISTCLEANFILES = sigscheme.pc tools/gnuify-changelog.pl $(DIST_SUM_LIST)

.PHONY: FORCE sum
FORCE:

ChangeLog: FORCE
	svn export $(UIM_REPOSITORY)/trunk/tools/gnuify-changelog.pl \
	    tools/gnuify-changelog.pl
	svn log $(RELEASE_URL) | tools/gnuify-changelog.pl > $@
	@test -s $@ && echo 'ChangeLog updated successfully.'

sum: FORCE
	$(MD5) $(DIST_ARCHIVES) >$(DIST_SUM_LIST)
	$(SHA1) $(DIST_ARCHIVES) >>$(DIST_SUM_LIST)

distclean-local:
	if test '$(top_srcdir)' != '$(top_builddir)'; then  \
	    rm -f ChangeLog;                                    \
	fi
