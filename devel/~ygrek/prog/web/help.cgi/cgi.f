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
REQUIRE BOUNDS ~ygrek/lib/string.f
REQUIRE CEQUAL ~pinka/spf/string-equal.f

: STARTS-WITH? { a1 u1 a2 u2 -- ? }
  u1 u2 < IF FALSE EXIT THEN
  a1 u2 a2 u2 CEQUAL ;

S" ~ygrek/prog/web/help.cgi/load.f" INCLUDED

: text/html S" Content-type: text/html" TYPE CR CR ;

\ what is better?
\ - introduce new words for HTML output, or
\ - overload (as done below)

MODULE: HTML

: CR ." </br>" CR ;
: SPACE ." &nbsp;" ;
: SPACES 0 ?DO SPACE LOOP ;
: EMIT
   DUP BL < IF DROP BL EMIT EXIT THEN
   DUP [CHAR] < = IF DROP ." &lt;" EXIT THEN
   DUP [CHAR] > = IF DROP ." &gt;" EXIT THEN
   DUP [CHAR] " = IF DROP ." &quot;" EXIT THEN
   DUP [CHAR] & = IF DROP ." &amp;" EXIT THEN
   EMIT ;
: TYPE BOUNDS ?DO I C@ EMIT LOOP ;
: STYPE DUP STR@ TYPE STRFREE ;

;MODULE 

: << POSTPONE START{ ; IMMEDIATE
: >> POSTPONE }EMERGE ; IMMEDIATE

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

: span PRO ." <span class=" [CHAR] " EMIT TYPE [CHAR] " EMIT ." >" CONT ." </span>" ;
: span: PARSE-NAME PRO span CONT ;

: start-page ( a u -- )
   <<
    tag: h2
    ." Search SP-Forth words (src,lib,devel) :"
   >>
   tag: form
   " <input name={''}q{''} value={''}{s}{''} type={''}text{''} size={''}30{''}/>" STYPE SPACE SPACE
   " <input value={''}Search{''} type={''}submit{''}/>" STYPE CR
   HTML::CR
   tag: small
   ." Usual shell wildcards should work : <b>?</b> (any symbol) and <b>*</b> (any number of any symbols)" CR
;

: link ( name u link u2 -- )
  " <a href={''}{s}{''}>" STYPE
  HTML::TYPE
  ." </a>" ;

: spf-link ( a u -- )
  " http://forth.org.ru/" >R
  2DUP R@ STR+
  R@ " \" " /" replace-str- \ "
  R@ STR@ link
  R> STRFREE ;

: source-from-spf ( a u -- )
  2DUP S" lib" STARTS-WITH? IF spf-link EXIT THEN
  2DUP S" ~" STARTS-WITH? IF spf-link EXIT THEN
  HTML::TYPE ;

ALSO HTML

: main
  get-params
  S" q" GetParam start-page
  S" q" GetParam EMPTY? IF EXIT THEN
  ." <hr/>"
  wordsfile load { l }
  S" q" GetParam l find 
  each->
  << `word span STR@ TYPE >>
  SPACE
  << `stack span STR@ TYPE >>
  << `source span ."  \ " STR@ source-from-spf >>
  CR ;

: footer
  CR
  ." <hr/>"
  tag: small
  FALSE uname { os }
  os STR@ FINE-TAIL "  help.cgi r{revision} ({s})" STYPE CR
  os STRFREE
  "  Powered by " STYPE spf-version STYPE CR ;

PREVIOUS

: output
  tag: html
  <<
   tag: head
   " <link href={''}some.css{''} rel={''}stylesheet{''} type={''}text/css{''}/>" STYPE 
  >>
  tag: body
  main
  footer ;

:NONAME text/html output CR BYE ; MAINX !

S" help.cgi" SAVE BYE

