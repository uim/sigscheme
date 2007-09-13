include $(top_builddir)/libgcroots.mk

# To take precedence over installed gcroots.h by the bundled
# libgcroots/include/gcroots.h, @GCROOTS_CFLAGS@ must be placed here.
AM_CPPFLAGS = -I$(top_builddir)/include -I$(top_srcdir)/src @GCROOTS_CFLAGS@ \
	      -DTST_SCM_SYSTEM_LOAD_PATH=\"@abs_top_srcdir@/lib\"
AM_CFLAGS   =
AM_LDFLAGS  = -rpath $(libdir)
LIBS        = $(top_builddir)/src/libsscm.la @GCROOTS_LIBS@

EXTRA_DIST= sscm-test.h utils.c \
            test-alignment.c \
            test-global.c \
            test-gc.c test-gc-protect.c test-gc-protect-stack.c \
            test-storage.c test-storage-compact.c \
            test-strcasecmp.c test-length.c test-format.c test-array2list.c

SUFFIXES= -coll.o -coll.c

if MAINTAINER_MODE
CLEANFILES= *-coll.c

# FIXME: how do I make this rule depend on collect.sh (is it
# possible)?
.c-coll.c:
	$(SH) ./collect.sh $< > $@ || { rm -f $@; false; }
endif


# Name your test suite with a -coll suffix if you want it processed
# with collect.sh.  Leave the suffix out if you don't want some script
# messing around with your masterpiece.
if USE_LIBSSCM
TESTS= test-alignment-coll \
       test-global-coll \
       test-gc-coll test-gc-protect-coll test-gc-protect-stack-coll \
       test-storage-coll test-storage-compact-coll \
       test-strcasecmp-coll test-length-coll test-format-coll \
       test-array2list-coll
XFAIL_TESTS =
check_PROGRAMS= $(TESTS) test-minishell
else
TESTS=
XFAIL_TESTS =
check_PROGRAMS=
endif

# GNU version of sed is required to run collect.sh
dist-hook:
	@(test -n "$(SED)"                                              \
	  && $(SED) --version 2>/dev/null                               \
	  && $(SED) --version 2>/dev/null | grep GNU)                   \
	 || (echo 'GNU sed(1) is not found: install it'; exit 1)
