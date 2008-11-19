#!/bin/sh

SPF_ROOT=$(spf ModuleDirName TYPE BYE)
xsltproc devel_libs.xsl $SPF_ROOT/docs/devel.xml > devel.docbook
xsltproc devel_libs2.xsl $SPF_ROOT/docs/devel.xml > libs2docbook.sh
chmod a+x libs2docbook.sh
