\ Упрощение работы с xpath-функциями, выдающими float-результаты.

REQUIRE XML_XPATH      ~ac/lib/lin/xml/xml.f

\ WINAPI: sprintf MSVCRT.DLL 
\ : P.0> S" %.0f" DROP PAD sprintf DUP 0 < THROW NIP NIP  NIP NIP PAD SWAP ;

ALSO libcurl.dll
  : P.0> S" %.0f" DROP PAD 4 curl_msprintf DUP 0 < THROW PAD SWAP ;
PREVIOUS

:NONAME xpo.floatval ( 12 DUMP) CELL+ 2@ P.0> TYPE ; xpathTypes 2 CELLS + !
:NONAME xpo.floatval CELL+ 2@ P.0> ;                xpathTypes@ 2 CELLS + !

\EOF пример
S" xml-rpc.xml" S" count(//member)" XML_XPATH
S" xml-rpc.xml" S" string(count(//member))" XML_XPATH