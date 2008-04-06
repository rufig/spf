REQUIRE EMBODY    ~pinka/spf/forthml/index.f

`envir.f.xml            FIND-FULLNAME2 EMBODY  xml-struct-hidden::start
`import-words.f.xml     FIND-FULLNAME2 EMBODY
`tc-host.f.xml          FIND-FULLNAME2 EMBODY

\ TC-WL NLIST
\ TC-WL ALSO!

\ 50 TO TRACE-HEAD-SIZE

`index.f.xml FIND-FULLNAME2 EMBODY

  TC-WL ALSO!
  .( >>>>> Welcome to the target system ) CR ORDER quit
