REQUIRE EMBODY    ~pinka/spf/forthml/index.f

\ temporary, need a better name(?):

: StoN ( c-addr u -- x )
  forthml-hidden::I-LIT IF EXIT THEN 2DROP 0
;


\ experimetal words:

: CBACK ( a u cn -- a2 u2 )
  CHARS TUCK + >R - R>
;
: CFORW ( a u cn -- a2 u2 )
  CHARS +
;

\ load (from current directory):

`url.f.xml  EMBODY

\ test:

  `forth.org.ru/path/file/ assume-url dump-location CR

  `http://A:B@forth.org.ru:81/path/file?query-part#fragment-identifier HERE OVER 2SWAP S,
  assume-url dump-location
