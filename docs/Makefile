
host=win

ifeq ($(host),win)
output=type
delete=del
md_path="..\\tools\\markdown\\"
else
output=cat
delete=rm -f
md_path=../tools/markdown/
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
	$(output) $(md_path)html_header_2 >> $@
	python $(md_path)markdown-1-5.py $(patsubst %.html,%.md,$@) >> $@
	$(output) $(md_path)html_footer >> $@
	echo $@ >> mark.new

clean:
	$(delete) $(docs)
	$(delete) mark.new
