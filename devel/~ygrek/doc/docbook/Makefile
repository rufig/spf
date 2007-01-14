
docbook-xsl=D:/WORK/docbook/docbook-xsl-1.71.1/

docs = devel.html devel.chm

target: all

all: $(docs)

force: clean-all all

devel.html: *.docbook devel.html.single.xsl devel.basic.xsl
	xsltproc --nonet devel.html.single.xsl $(patsubst %.html,%.docbook,$@) > $@

devel.chm: *.docbook devel.chm.xsl devel.basic.xsl
	xsltproc --nonet devel.chm.xsl devel.docbook
	hhc devel.hhp

clean:
	del *.hhp, *.hhc, *.hhk
	del ch*.html, index.html, pr01.html

clean-all: clean
	del $(docs)
