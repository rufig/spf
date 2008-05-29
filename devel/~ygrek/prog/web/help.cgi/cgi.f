\ $Id$
\ 
\ sample CGI
\ see it in action at http://ygrek.org.ua/exec/help.cgi?q=*SWAP*

: wordsfile S" words" ;

S" ~ygrek/prog/web/help.cgi/load.f" INCLUDED

REQUIRE FINE-TAIL ~pinka/samples/2005/lib/split-white.f
REQUIRE $Revision ~ygrek/lib/fun/kkv.f
REQUIRE cat ~ygrek/lib/cat.f
REQUIRE replace-str- ~pinka/samples/2005/lib/replace-str.f
REQUIRE DumpParams ~ac/lib/string/get_params.f

: uname ( ? -- s )
  S" /proc/sys/kernel/ostype" cat 
  S" /proc/sys/kernel/osrelease" cat OVER S+
  SWAP IF S" /proc/sys/kernel/version" cat OVER S+ THEN
  DUP " {EOLN}" "  " replace-str- ;

: get-params S" QUERY_STRING" ENVIRONMENT? 0= ABORT" Not a CGI" GetParamsFromString ;

: revision $Revision$ SLITERAL ;
: spf-version VERSION 1000 / 100 /MOD " SP-Forth {n}.{n} (http://spf.sf.net)" ;

: EMPTY? NIP 0= ;

: text/plain S" Content-type: text/plain" TYPE CR CR ;

: main
  get-params
  S" q" GetParam EMPTY? IF S" set 'q' param" TYPE CR EXIT THEN
  wordsfile load { l }
  S" q" GetParam l find show ;

:NONAME
  text/plain
  main
  CR
  FALSE uname { os }
  os STR@ FINE-TAIL "  help.cgi r{revision} ({s})" STYPE CR
  os STRFREE
  "  Powered by " STYPE spf-version STYPE CR
  BYE 
; 
MAINX !

S" help.cgi" SAVE BYE
