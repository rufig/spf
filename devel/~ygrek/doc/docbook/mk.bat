cmd/c libs.bat
rmdir /S /Q source
cmd/c libs2docbook.bat
rmdir /S /Q chunked
mkdir chunked
xsltproc --nonet --xinclude devel.html.chunked.xsl devel.docbook

