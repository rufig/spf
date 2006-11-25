
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

docs = intro.ru.html intro.en.html readme.ru.html readme.en.html

target: $(docs)

%.html: %.md intro.md.css
	$(output) $(md_path)html_header_1 > $@
	$(output) intro.md.css >> $@
	$(output) $(md_path)html_header_2 >> $@
	python $(md_path)markdown-1-5.py $< >> $@
	$(output) $(md_path)html_footer >> $@

clean:
	$(delete) $(docs)