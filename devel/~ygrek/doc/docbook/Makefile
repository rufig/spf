
docs = devel.html chunked/index.html devel.chm

DOC_PATH=source

docbooks = $(foreach forthfile,$(forthcode),$(DOC_PATH)/$(patsubst %.f,%.docbook,$(forthfile)))
xmlhelps = $(foreach docbook,$(docbooks),$(patsubst %.docbook,%.xml,$(docbook)))

# файл для подключения либы и генерации xmlhelp
# чтобы полностью моделировать реальные условия и исключить финты ушами a la /TEST
tempfile=.temporary.f
# шаблон для tempfile
temptemp=.template.f

target: all

.PRECIOUS: $(xmlhelps)

# manual debug
do: clean-all devel.chm
chunked: chunked/index.html
chm: devel.chm
html: devel.html

template:
	echo S" xmlhelp.f" INCLUDED > $(tempfile)
	echo S" $(DOC_PATH)/$(patsubst %.f,%.xml,$(source))" START-XMLHELP >> $(tempfile)
	echo S" $(source)" INCLUDED >> $(tempfile)
	echo FINISH-XMLHELP >> $(tempfile)
	spf $(tempfile) BYE
	xsltproc --param xmlhelp.allstack 1 xmlhelp2docbook.xsl $(DOC_PATH)/$(patsubst %.f,%.xml,$(source)) > $(DOC_PATH)/$(patsubst %.f,%.docbook,$(source))

all: $(docs)

force: cleanall all

devel.html: $(docbooks) devel.docbook devel.html.single.xsl devel.basic.xsl
	xsltproc --nonet devel.html.single.xsl devel.docbook > devel.html

chunked/index.html: $(docbooks) devel.docbook devel.html.chunked.xsl devel.basic.xsl
	-mkdir chunked
	xsltproc --nonet devel.html.chunked.xsl devel.docbook

devel.chm: $(docbooks) devel.docbook devel.chm.xsl devel.basic.xsl
	xsltproc --nonet devel.chm.xsl devel.docbook
	hhc devel.hhp

%.docbook: %.xml
	xsltproc --param xmlhelp.allstack 0 xmlhelp2docbook.xsl $< > $@

%.xml: $(patsubst $(DOC_PATH)/%.xml,$(DEVEL_PATH)/%,$@)
	cp $(temptemp) $(tempfile)
	sed -i 's|%XML%|$@|' $(tempfile) 
	sed -i 's|%LIB%|$(patsubst $(DOC_PATH)/%.xml,%,$@)|' $(tempfile)
	spf $(tempfile) BYE

# удалить промежуточные файлы
clean:
	-del *.hhp *.hhc *.hhk
	-del ch*.html index.html pr??.html
	-del $(tempfile)

# удалить все сгенерированные файлы
cleanall: clean
	-del $(docbooks) $(xmlhelps) $(docs) chunked/*.html
