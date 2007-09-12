TXTS = index.txt design.txt spec.txt multibyte.txt style.txt \
        global-obj.txt release.txt
ASCIIDOC_HTMLS = \
        index.html design.html spec.html multibyte.html style.html \
        global-obj.html release.html

# Obsolete
#TXTS += gc-protection.txt test-c.txt
#ASCIIDOC_HTMLS += gc-protection.html test-c.html

EXTRA_DIST =

# Suppress installing documents on combined-source configuration
if USE_LIBSSCM
dist_doc_DATA  = $(TXTS)
dist_html_DATA = $(ASCIIDOC_HTMLS)
endif

MAINTAINERCLEANFILES = $(ASCIIDOC_HTMLS)

.PHONY: clean-html

if MAINTAINER_MODE
# xhtml11 backend is supported from AsciiDoc 7.0.0
.txt.html:
	if test -n "$(ASCIIDOC)"; then          \
	    $(ASCIIDOC) -b xhtml11 -n -o $@ $<; \
	fi
endif

html: $(ASCIIDOC_HTMLS)
clean-html:
	rm -f $(ASCIIDOC_HTMLS)

dist-hook:
	@test -n "$(ASCIIDOC)"                                          \
	    || (echo 'asciidoc(1) not found: install AsciiDoc'; exit 1)
