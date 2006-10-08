
host=win

output=type
delete=del

ifneq ($(host),win)
output=cat
delete=rm -f
endif

target: intro.html

%.html: %.md intro.md.css
	$(output) ..\..\tools\markdown\html_header_1 > $@
	$(output) intro.md.css >> $@
	$(output) ..\..\tools\markdown\html_header_2 >> $@
	markdown $< >> $@
	$(output) ..\..\tools\markdown\html_footer >> $@

clean:
	$(delete) intro.html