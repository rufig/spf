@if not exist tmp mkdir tmp
call saxonB8 -novw src/index-common-rules.struct.f.xml  ../engine-xml/struct.xsl        >tmp/index-common-rules.f.xml
call saxonB8 -novw tmp/index-common-rules.f.xml         meta/rules2sxsl.xsl             >tmp/index-common-rules.sxsl.xml
call saxonB8 -novw src/index-xslt.struct.sxsl.xml       ../engine-xml/struct-pre.xsl    >tmp/forthml.sxsl.xml
call saxonB8 -novw tmp/forthml.sxsl.xml                 ../engine-xml/sxsl.xsl          >forthml.xsl
