
# build system - Windows or linux (SF server)
host=win
# whether to generate local documentation or web documents
usage=local

ifeq ($(host),win)
output=type
delete=del
md_path="..\\tools\\markdown\\"
else
output=cat
delete=rm -f
md_path=../tools/markdown/
endif

ifeq ($(usage),local)
# this is default
html_vect_header=html_header_2
else
# this uses SF logo
html_vect_header=html_header_3
endif

docs = intro.ru.html intro.en.html readme.ru.html readme.en.html devel.ru.html devel.en.html

target: clean_mark $(docs)

clean_mark:
	$(delete) mark.new

#devel.ru.html: css = devel.md.css
%.html: css = intro.md.css

%.html: %.md
	$(output) $(md_path)html_header_1 > $@
	$(output) $(css) >> $@
	$(output) $(md_path)$(html_vect_header) >> $@
#	python $(md_path)markdown-1-5.py $(patsubst %.html,%.md,$@) >> $@
	perl $(md_path)Markdown.pl $(patsubst %.html,%.md,$@) >> $@
	$(output) $(md_path)html_footer >> $@
	echo $@ >> mark.new

clean:
	$(delete) $(docs)
	$(delete) mark.new
