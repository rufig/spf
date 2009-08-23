# $Id$

DOC_PATH:=source
ifeq ($(OS),Windows_NT)
SPF_ROOT:=..\..\..\..\\
else
SPF_ROOT:=../../../../
endif

$(DOC_PATH)/%.docbook: $(SPF_ROOT)/devel/$(patsubst $(DOC_PATH)/%.docbook,%,%)
	$(SPF_ROOT)spf4 xmlhelp-helper.f make: $(@:.docbook=.xml) $(patsubst $(DOC_PATH)/%.docbook,%,$@) BYE > .temporary.f
	$(SPF_ROOT)spf4 .temporary.f BYE
	xsltproc --param xmlhelp.allstack 0 xmlhelp2docbook.xsl $(@:.docbook=.xml) > $@
