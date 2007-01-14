
# Stupid hhc.exe generates exit code 1 even if everything is ok.
# So put chm generation as the last target

docs = devel.html chunked\\index.html devel.chm

target: all

all: $(docs)

force: clean-all all

devel.html: *.docbook source/*.docbook devel.html.single.xsl devel.basic.xsl
	xsltproc --nonet devel.html.single.xsl devel.docbook > devel.html

chunked\\index.html: *.docbook source/*.docbook devel.html.chunked.xsl devel.basic.xsl
	xsltproc --nonet devel.html.chunked.xsl devel.docbook

devel.chm: *.docbook source/*.docbook devel.chm.xsl devel.basic.xsl
	xsltproc --nonet devel.chm.xsl devel.docbook
	hhc devel.hhp

clean:
	del *.hhp, *.hhc, *.hhk
	del ch*.html, index.html, pr??.html, ix??.html

clean-all: clean
	del $(docs)
	del chunked\\*.html
