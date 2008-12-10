\ $Id$
\ 
\ sample CGI
\ see it in action at http://ygrek.org.ua/exec/help.cgi?q=*SWAP*

: wordsfile S" words" ;

REQUIRE FINE-TAIL ~pinka/samples/2005/lib/split-white.f
REQUIRE $Revision ~ygrek/lib/fun/kkv.f
REQUIRE DumpParams ~ac/lib/string/get_params.f
REQUIRE tag ~ygrek/lib/xmltag.f
REQUIRE AsQName ~pinka/samples/2006/syntax/qname.f 
REQUIRE BOUNDS ~ygrek/lib/string.f
REQUIRE CEQUAL ~pinka/spf/string-equal.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f
REQUIRE OSNAME-STR ~ygrek/lib/sys/osname.f
\ REQUIRE INTER ~ygrek/lib/debug/inter.f
S" ~ygrek/lib/list/all.f" INCLUDED

: STARTS-WITH? { a1 u1 a2 u2 -- ? }
  u1 u2 < IF FALSE EXIT THEN
  a1 u2 a2 u2 CEQUAL ;

S" ~ygrek/prog/web/help.cgi/load.f" INCLUDED

: text/html S" Content-type: text/html" TYPE CR ;
: content-length ( n -- ) " Content-Length: {n}" STYPE CR ;

\ what is better?
\ - introduce new words for HTML output, or
\ - overload (as done below)

MODULE: HTML

: EMIT
   DUP BL < IF DROP BL EMIT EXIT THEN
   DUP [CHAR] < = IF DROP ." &lt;" EXIT THEN
   DUP [CHAR] > = IF DROP ." &gt;" EXIT THEN
   DUP [CHAR] " = IF DROP ." &quot;" EXIT THEN
   DUP [CHAR] & = IF DROP ." &amp;" EXIT THEN
   DUP [CHAR] ' = IF DROP ." &apos;" EXIT THEN
   EMIT ;
: TYPE BOUNDS ?DO I C@ EMIT LOOP ;
: STYPE DUP STR@ TYPE STRFREE ;

;MODULE 

: << POSTPONE START{ ; IMMEDIATE
: >> POSTPONE }EMERGE ; IMMEDIATE

\ todo interactive session when no environment present
\ todo problems with ABORT here (TYPE>STR doesn't catch it)
: get-params S" QUERY_STRING" ENVIRONMENT? 0= IF S" " THEN GetParamsFromString ;

: revision $Revision$ SLITERAL ;
: spf-version VERSION 1000 / 100 /MOD " {n}.{n}" ;

: EMPTY? NIP 0= ;

: tag: PARSE-NAME POSTPONE SLITERAL POSTPONE tag ; IMMEDIATE
: quote [CHAR] " EMIT ;
: enquote-> PRO quote BACK quote TRACKING CONT ;

{{ list
: attributes ( l -- )
  DUP LAMBDA{ SPACE DUP car STR@ TYPE [CHAR] = EMIT enquote-> cdar STR@ HTML::TYPE } iter
  LAMBDA{ ['] STRFREE free-with } free-with ;
}}

: prepare-tag ( attr-l a u -- ) CR xmltag.indent# SPACES [CHAR] < EMIT TYPE attributes ;

\ с отступами
: atag ( attr-l a u -- )
   PRO
   BACK xmltag.indent# 1- TO xmltag.indent# " </{s}>" STYPE TRACKING
   2RESTB
   prepare-tag [CHAR] > EMIT
   xmltag.indent# 1+ TO xmltag.indent#
   CONT ;

: /atag ( attr-l a u -- ) prepare-tag ." />" ;
: /tag ( a u -- ) list::nil -ROT /atag ;

: PARSE-SLIT PARSE-NAME POSTPONE SLITERAL ;

: atag: PARSE-SLIT POSTPONE atag ; IMMEDIATE
: /atag: PARSE-SLIT POSTPONE /atag ; IMMEDIATE

: $$ %[ >STR % >STR % ]% % ;
: $$: PARSE-SLIT PARSE-SLIT POSTPONE $$ ; IMMEDIATE

MODULE: HTML
: CR `br /tag ;
: SPACE ." &nbsp;" ;
: SPACES 0 ?DO SPACE LOOP ;
;MODULE

: span PRO %[ `class $$ ]% `span atag CONT ;
: span: PARSE-NAME PRO span CONT ;

: start-page ( a u -- )
   <<
    tag: h2
    ." Search SP-Forth words (src,lib,devel) :"
   >>

   %[ S" " `action $$ ]%
   atag: form
   <<
   tag: div

   %[ 
      `q `name $$
      ( a u ) `value $$
      `text `type $$
      `30 `size $$
   ]% 
   /atag: input

   %[ `submit `type $$ `Search `value $$ ]% `input /atag
   >>
   `div tag
   `small tag
   ." Usual shell wildcards should work : <b>?</b> (any symbol) and <b>*</b> (any number of any symbols)" CR
;

: link ( name u link u2 -- ) %[ `href $$ ]% `a atag HTML::TYPE ;

: spf-logo ."  Powered by " `SP-Forth `http://spf.sf.net link SPACE spf-version STYPE ;

\ link to source
: source-from-spf ( a u -- )
\  " http://spf.cvs.sourceforge.net/*checkout*/spf/" 
  " http://forth.org.ru/"
  >R
  2DUP S" ~" STARTS-WITH? IF S" devel/" R@ STR+ THEN
  2DUP R@ STR+
  R@ " \" " /" replace-str- \ "
  ( a u ) R@ STR@ link
  R> STRFREE ;

: hrule `hr /tag ;

ALSO HTML

: show-word ( s1 s2 s3 -- )
  << `word span STR@ TYPE >>
  SPACE
  << `stack span STR@ TYPE >>
  << `source span ."  \ " STR@ source-from-spf >>
  CR ;

: block ( l a u -- )
  hrule
  << tag: h3 TYPE >>
  tag: div
  DUP << words-each-> show-word >>
  list::free ;

: content
  get-params
  `q GetParam start-page
  `q GetParam EMPTY? IF EXIT THEN
  wordsfile words-load { l }
  `q GetParam l words-find ( l1 l2 ) 
  S" Exact matches : " block
  S" Case-insensitive matches : " block 
  l words-free
;

: footer
  hrule
  tag: div
  <<
   %[ S" float:left;margin-right:1%" `style $$ ]%
   atag: div
   tag: small
   OSNAME-STR { os }
   os STR@ FINE-TAIL "  help.cgi r{revision} ({s})" STYPE CR
   os STRFREE
   spf-logo 
  >>
  %[ S" float:left" `style $$ ]%
  atag: div
   %[ `http://validator.w3.org/check?uri=referer `href $$ ]% atag: a
   %[ 
    S" Valid XHTML 1.0 Strict" `alt $$
    `http://www.w3.org/Icons/valid-xhtml10 `src $$
    `31 `height $$
    `88 `width $$
   ]% /atag: img
  ;

PREVIOUS

: output
  " <?xml version={''}1.0{''}?>{EOLN}" STYPE
  " <!DOCTYPE html PUBLIC {''}-//W3C//DTD XHTML 1.0 Strict//EN{''} 
 {''}http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd{''}>{EOLN}" STYPE

  %[ `http://www.w3.org/1999/xhtml `xmlns $$ ]%
  atag: html
  <<
   tag: head
   %[ `some.css `href $$ `stylesheet `rel $$ `text/css `type $$ ]% /atag: link
   tag: title S" SP-Forth words search" HTML::TYPE
  >>
  tag: body
  content
  footer ;

\ buffer all output so that we can set Content-Length and server won't use
\ chunked transfer-encoding (thx to ~pinka for pointing this out)
: output-s LAMBDA{ output CR } TYPE>STR ;

: main text/html output-s DUP STRLEN content-length CR STYPE ; 

: save
  LAMBDA{ main BYE } MAINX !
  S" help.cgi" SAVE BYE ;
