
docs = devel.html chunked/index.html devel.chm

DOC_PATH=source

forthcode = ~ac/lib/lin/curl/curl.f \
						~ac/lib/win/winsock/sockets.f \
						~pinka/lib/queue_pr.f \
						~day/lib/staticlist.f \
						~pinka/lib/hash-table.f \
						~mlg/SrcLib/bitfield.f \
						~day/lib/memreport.f \
						~profit/lib/bac4th.f \
						~ygrek/lib/spec/rss.f \
						~pinka/lib/like.f \
						~pinka/samples/2005/lib/append-file.f \
						~ygrek/lib/wid.f \
						~ygrek/lib/enum.f \
						~ygrek/lib/parse.f \
						~pinka/samples/2005/lib/lay-path.f \
						~pinka/samples/2005/lib/replace-str.f \
						~pinka/samples/2005/lib/split.f \
						~pinka/samples/2005/lib/split-white.f \
						~pinka/samples/2006/lib/save-bak.f \
						~pinka/lib/multi/critical.f \
						~ac/lib/str5.f \
						~ac/lib/string/compare-u.f \
						~ac/lib/string/conv.f \
						~ac/lib/string/uppercase.f \
						~ac/lib/win/file/findfile.f \
						~ac/lib/win/file/findfile-r.f \
						~ac/lib/lin/sql/sqlite3.f \
						~ac/lib/lin/xml/xml.f \
						~ac/lib/lin/xml/expat.f \
						~ac/lib/lin/xml/xslt.f \
						~ac/lib/win/date/date.f \
						~ac/lib/win/date/date-int.f \
						~ac/lib/win/date/timezone.f \
						~ac/lib/win/date/unixdate.f \
						~ygrek/lib/spec/sdate.f \
						~ygrek/lib/spec/sdate2.f \
						~ygrek/lib/spec/unixdate.f \
						lib/ext/locals.f \
						lib/include/float2.f \
						lib/include/string.f \
						lib/include/tools.f \
						lib/include/facil.f \
						lib/include/double.f \
						lib/include/core-ext.f \
						lib/win/api-call/capi2.f \
						lib/win/mutex.f \
						~ygrek/lib/neilbawd/mersenne.f


docbooks = $(foreach forthfile,$(forthcode),$(DOC_PATH)/$(patsubst %.f,%.docbook,$(forthfile)))
xmlhelps = $(foreach docbook,$(docbooks),$(patsubst %.docbook,%.xml,$(docbook)))

# файл для подкюлчения либы и генерации xmlhelp
# чтобы полностью моделировать реальные условия и исключить финты ушами a la /TEST
tempfile=.temporary.f

target: all

.PRECIOUS: $(xmlhelps)

# manual debug
do: clean-all devel.chm
chunked: chunked/index.html
chm: devel.chm
html: devel.html

template:
	echo.> $(tempfile)
	echo S" xmlhelp.f" INCLUDED >> $(tempfile)
	echo S" $(DOC_PATH)/$(patsubst %.f,%.xml,$(source))" START-XMLHELP >> $(tempfile)
	echo S" $(source)" INCLUDED >> $(tempfile)
	echo FINISH-XMLHELP >> $(tempfile)
	spf S" $(tempfile)" INCLUDED BYE
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
	echo.> $(tempfile)
	echo S" xmlhelp.f" INCLUDED >> $(tempfile)
	echo S" $@" START-XMLHELP >> $(tempfile)
	echo S" $(patsubst $(DOC_PATH)/%.xml,%.f,$@)" INCLUDED >> $(tempfile)
	echo FINISH-XMLHELP >> $(tempfile)
	spf S" $(tempfile)" INCLUDED BYE

# удалить промежуточные файлы
clean:
	-rm *.hhp *.hhc *.hhk
	-rm ch*.html index.html pr??.html
	-rm $(tempfile)

# удалить все сгенерированные файлы
cleanall: clean
	-rm $(docbooks) $(xmlhelps) $(docs) chunked/*.html
