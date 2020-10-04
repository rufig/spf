# Generate/update the following files
#   forthml-core.auto.f
#   forthml.xsl

MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
.POSIX:
.DELETE_ON_ERROR:
.ONESHELL:

.PHONY: clean default all
.PHONY: step1 step2 step3

forthml: all  # the goal (default target)

xslt ?= saxonhe-xslt

define xslt-output
  $(xslt) -s:$< -xsl:$(word 2,$^)
endef
define xslt-default
  $(xslt-output) > $@
endef
define xslt-default2
  $(xslt-output) | $(xslt) -s:- -xsl:$(word 3,$^) > $@
endef

struct  := ../engine-xml/struct.xsl
sxsl    := ../engine-xml/sxsl.xsl


tmp/rules-common.sxsl.xml: src/rules-common.f.xml meta/rules2sxsl.xsl
	$(xslt-default)

tmp/forthml.sxsl.xml: meta/index-xslt.sxsl.xml $(struct)
	$(xslt-default)

forthml.xsl: tmp/forthml.sxsl.xml $(sxsl)
	$(xslt-default)


# ( r:* ) --> ( f:* r:m0 r:m )

tmp/trules-step1.xsl: meta/trules-step1.sxsl.xml $(struct) $(sxsl)
	$(xslt-default2)

tmp/rules-step1.xml: meta/core-forth.f.xml $(struct) tmp/trules-step1.xsl
	$(xslt-default2)

step1: tmp/rules-step1.xml


# ( f:* ) --> ( r:* )

tmp/trules-step2.xsl: meta/trules-step2.sxsl.xml $(sxsl)
	$(xslt-default)

tmp/rules-step2.xml: tmp/rules-step1.xml tmp/trules-step2.xsl
	$(xslt-default)

step2: tmp/rules-step2.xml


# ( r:* text() ) --> ( plainForth )

tmp/trules-step3.xsl: meta/trules-step3.sxsl.xml $(struct) $(sxsl)
	$(xslt-default2)

tmp/rules-step3.f: tmp/rules-step2.xml tmp/trules-step3.xsl
	$(xslt-default)

step3: tmp/rules-step3.f


forthml-core.auto.f: tmp/rules-step3.f
# In the case of Windows/Java platform, Saxon generates CRLF line endings
	tr -d '\r' < $< > $@


all: forthml.xsl forthml-core.auto.f

clean:
	rm forthml.xsl tmp/*
