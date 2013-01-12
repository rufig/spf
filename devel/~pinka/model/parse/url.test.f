REQUIRE EMBODY    ~pinka/spf/forthml/index.f

\ extension
`http://forth.org.ru/~pinka/model/trans/rules-slot.f.xml EMBODY


\ load object to the current wordlist:
`url.f.xml  EMBODY \ from the current directory

\ test:

  `forth.org.ru/path/file/ assume-url dump-location CR

  `http://A:B@forth.org.ru:81/path/file?query-part#fragment-identifier HERE OVER 2SWAP S,
  assume-url dump-location

  .( local-ref -- ) local-ref TYPE CR
