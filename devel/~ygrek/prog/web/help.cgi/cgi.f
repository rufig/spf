\ $Id$
\ 
\ sample CGI
\ see it in action at http://ygrek.org.ua/exec/help.cgi?q=*SWAP*

: wordsfile S" words" ;


REQUIRE FINE-TAIL ~pinka/samples/2005/lib/split-white.f
REQUIRE $Revision ~ygrek/lib/fun/kkv.f
REQUIRE cat ~ygrek/lib/cat.f
REQUIRE replace-str- ~pinka/samples/2005/lib/replace-str.f
REQUIRE DumpParams ~ac/lib/string/get_params.f
REQUIRE tag ~ygrek/lib/xmltag.f
REQUIRE AsQName ~pinka/samples/2006/syntax/qname.f 

S" ~ygrek/prog/web/help.cgi/load.f" INCLUDED

: text/html S" Content-type: text/html" TYPE CR CR ;

MODULE: CGI

: CR ." </br>" CR ;
: SPACE ." &nbsp;" ;
: SPACES 0 ?DO SPACE LOOP ;

: << POSTPONE START{ ; IMMEDIATE
: >> POSTPONE }EMERGE ; IMMEDIATE

;MODULE 

ALSO CGI

: uname ( ? -- s )
  S" /proc/sys/kernel/ostype" cat 
  S" /proc/sys/kernel/osrelease" cat OVER S+
  SWAP IF S" /proc/sys/kernel/version" cat OVER S+ THEN
  DUP " {EOLN}" "  " replace-str- ;

: get-params S" QUERY_STRING" ENVIRONMENT? 0= ABORT" Not a CGI" GetParamsFromString ;

: revision $Revision$ SLITERAL ;
: spf-version VERSION 1000 / 100 /MOD " SP-Forth {n}.{n} (http://spf.sf.net)" ;

: EMPTY? NIP 0= ;

: tag: PARSE-NAME POSTPONE SLITERAL POSTPONE tag ; IMMEDIATE

: start-page
   <<
    tag: h2
    ." Search SP-Forth words (src,lib,devel) :"
   >>
   tag: form
   " <input name={''}q{''} value={''}{''} type={''}text{''} size={''}30{''}/>" STYPE SPACE SPACE
   " <input value={''}Search{''} type={''}submit{''}/>" STYPE CR
   CR
   tag: small
   ." Usual shell wildcards should work : <b>?</b> (any symbol) and <b>*</b> (any number of any symbols)" CR
;


: span PRO ." <span class=" [CHAR] " EMIT TYPE [CHAR] " EMIT ." >" CONT ." </span>" ;
: span: PARSE-NAME PRO span CONT ;

: main
  get-params
  S" q" GetParam EMPTY? IF start-page EXIT THEN
  << tag: h2 ." Search results : " >>
  wordsfile load { l }
  S" q" GetParam l find 
  each->
  << `word span STR@ TYPE >>
  SPACE 
  << `stack span STR@ TYPE >>
  ."  \ "
  << `source span STR@ TYPE >>
  CR ;

: content
  tag: html
  <<
   tag: head
   " <link href={''}some.css{''} rel={''}stylesheet{''} type={''}text/css{''}/>" STYPE 
  >>
  tag: body
  main
  CR
  ." <hr/>"
  tag: small
  FALSE uname { os }
  os STR@ FINE-TAIL "  help.cgi r{revision} ({s})" STYPE CR
  os STRFREE
  "  Powered by " STYPE spf-version STYPE CR ;

PREVIOUS

:NONAME text/html content CR BYE ; MAINX !

S" help.cgi" SAVE BYE
