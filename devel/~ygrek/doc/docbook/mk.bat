
REM rmdir /S /Q source
REM rmdir /S /Q chunked

cmd/c libs.bat
cmd/c libs2docbook.bat

mkdir chunked
mkdir chm
xsltproc --nonet --xinclude devel.html.chunked.xsl devel.docbook
copy simple.css chunked\
xsltproc --nonet --xinclude devel.html.single.xsl devel.docbook > devel.html
xsltproc --nonet --xinclude devel.chm.xsl devel.docbook
C:\Program\hh\hhc devel.hhp