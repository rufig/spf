# $Id$
# Makefile for documentation
# NB parameters on commandline override values in this file

# build system
# win - windows
# lin - linux (SF server)
host=win
# what kind of doc to generate
# local - local documentation
# web - online help
usage=local

ifeq ($(host),win)
output=type
delete=del
tools_path=..\\tools\\doc\\
parts_path=$(tools_path)parts\\
else
output=cat
delete=rm -f
tools_path=../tools/doc/
parts_path=$(tools_path)parts/
endif

ifeq ($(usage),local)
# this is default
html_vect_header=html_header_2
else
# this uses SF logo
html_vect_header=html_header_3
endif

docs = intro.ru.html intro.en.html readme.ru.html readme.en.html devel.ru.html devel.en.html src.ru.html

target: clean_mark $(docs)

clean_mark:
	$(delete) mark.new

%.html: css = intro.md.css

%.md: %.mdt
	spf ../tools/doc/std.f S" $<" REPLACE S" $@" OCCUPY BYE

devel.en.html: $(tools_path)devel.xsl devel.xml
	xsltproc --stringparam lang en --stringparam usage $(usage) $^ > $@
	echo $@ >> mark.new

devel.ru.html: $(tools_path)devel.xsl devel.xml
	xsltproc --stringparam lang ru --stringparam usage $(usage) $^ > $@
	echo $@ >> mark.new

%.html: %.md
	$(output) $(parts_path)html_header_1 > $@
	$(output) $(css) >> $@
	$(output) $(parts_path)$(html_vect_header) >> $@
	perl $(tools_path)Markdown.pl $(patsubst %.html,%.md,$@) >> $@
	$(output) $(parts_path)html_footer >> $@
	echo $@ >> mark.new

clean:
	$(delete) $(docs)
	$(delete) mark.new
