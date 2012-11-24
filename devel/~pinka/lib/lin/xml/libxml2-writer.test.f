REQUIRE createWriterFilename libxml2-writer.f

S" libxml2-writer.test.xml" createWriterFilename VALUE w
  \ the file will be overwritten if exists

2 w setWriterIndentNumber

0. w writeStartDocument
\ content shoud be in UTF-8 by default

`root w writeStartElement
  `test `tag w writeAttribute

  `passed-1 `test w writeElement

  `<passed-2> `test w writeElement

  `test w writeStartElement
    `passed-3 w writeText

w writeEndDocument \ closes all opened tags

w freeWriter  0 TO w
