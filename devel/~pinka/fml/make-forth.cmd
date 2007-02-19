@if not exist forthml.xsl call make-xslt.cmd
call saxonB8 -novw src/index-forth-rules.struct.f.xml   ../engine-xml/struct-pre.xsl    >tmp/index-forth-rules.f.xml
call saxonB8 -novw tmp/index-forth-rules.f.xml          meta/rules2fml.xsl              >tmp/forthml-rules.f.xml
call saxonB8 -novw tmp/forthml-rules.f.xml              forthml.xsl                     >forthml-rules.f
