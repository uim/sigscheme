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
UIM_REPOSITORY = http://uim.googlecode.com/git/
#RELEASE_BRANCH     = master
RELEASE_BRANCH     = $(DIST_NAME)
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

DISTCLEANFILES = sigscheme.pc tools/gnuify-changelog.pl $(DIST_SUM_LIST)

.PHONY: FORCE sum
FORCE:

# We use `wget' instead of `git archive' here
# because `git archive' doesn't work with Google Code Git repository.
ChangeLog: FORCE
	wget $(UIM_REPOSITORY)/tools/gnuify-changelog.pl
	git log --date-order --date=short $(RELEASE_BRANCH) \
	    | perl ./gnuify-changelog.pl > $@
	rm gnuify-changelog.pl
	@test -s $@ && echo 'ChangeLog updated successfully.'

sum: FORCE
	$(MD5) $(DIST_ARCHIVES) >$(DIST_SUM_LIST)
	$(SHA1) $(DIST_ARCHIVES) >>$(DIST_SUM_LIST)

distclean-local:
	if test '$(top_srcdir)' != '$(top_builddir)'; then  \
	    rm -f ChangeLog;                                    \
	fi
