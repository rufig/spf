
docs = devel.html chunked/index.html devel.chm

DOC_PATH=source

forthcode = ~ac/lib/lin/curl/curl.f \
						~ac/lib/win/winsock/sockets.f \
						~pinka/lib/queue_pr.f \
						~day/lib/staticlist.f \
						~pinka/lib/hash-table.f \
						~mlg/SrcLib/bitfield.f \
						~day/lib/memreport.f


docbooks = $(foreach forthfile,$(forthcode),$(DOC_PATH)/$(patsubst %.f,%.docbook,$(forthfile)))

xmlhelps = $(foreach docbook,$(docbooks),$(patsubst %.docbook,%.xml,$(docbook)))

target: all

.PRECIOUS: $(xmlhelps)

# manual debug
do: clean-all devel.chm
chunked: chunked/index.html
chm: devel.chm
html: devel.html

template:
	spf xmlhelp.f S" $(DOC_PATH)/$(patsubst %.f,%.xml,$(source))" START-XMLHELP S" $(source)" INCLUDED FINISH-XMLHELP BYE
	xsltproc --param xmlhelp.allstack 1 xmlhelp2docbook.xsl $(DOC_PATH)/$(patsubst %.f,%.xml,$(source)) > $(DOC_PATH)/$(patsubst %.f,%.docbook,$(source))

all: $(docs)

force: cleanall all

devel.html: $(docbooks) devel.docbook devel.html.single.xsl devel.basic.xsl
	xsltproc --nonet devel.html.single.xsl devel.docbook > devel.html

chunked/index.html: $(docbooks) devel.docbook devel.html.chunked.xsl devel.basic.xsl
	xsltproc --nonet devel.html.chunked.xsl devel.docbook

devel.chm: $(docbooks) devel.docbook devel.chm.xsl devel.basic.xsl
	xsltproc --nonet devel.chm.xsl devel.docbook
	hhc devel.hhp

%.docbook: %.xml
	xsltproc --param xmlhelp.allstack 0 xmlhelp2docbook.xsl $< > $@

%.xml: $(patsubst $(DOC_PATH)/%.xml,$(DEVEL_PATH)/%.f,$@)
	spf xmlhelp.f S" $@" START-XMLHELP S" $(patsubst $(DOC_PATH)/%.xml,%.f,$@)" INCLUDED FINISH-XMLHELP BYE

# удалить промежуточные файлы
clean:
	-rm *.hhp *.hhc *.hhk
	-rm ch*.html index.html pr??.html

# удалить все сгенерированные файлы
cleanall: clean
	-rm $(docbooks) $(xmlhelps) $(docs) chunked/*.html
