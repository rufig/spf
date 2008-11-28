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
REQUIRE TYPE>STR ~ygrek/lib/typestr.f
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

\ todo windows
: uname ( ? -- s )
  S" /proc/sys/kernel/ostype" cat 
  S" /proc/sys/kernel/osrelease" cat OVER S+
  SWAP IF S" /proc/sys/kernel/version" cat OVER S+ THEN
  DUP " {EOLN}" "  " replace-str- ;

[DEFINED] WINAPI: [IF]

REQUIRE /OSVERSIONINFO lib/win/osver.f

: OSVER_INFO ( -- build minor major )
   /OSVERSIONINFO ALLOCATE THROW DUP >R
   /OSVERSIONINFO R@ !
   GetVersionExA DROP
   R@ dwBuildNumber @
   R@ dwMinorVersion @
   R@ dwMajorVersion @
   R> FREE THROW
;

: OS_NAME OSVER_INFO " Microsoft Windows {n}.{n}.{n}" ;
[ELSE]
: OS_NAME FALSE uname ;
[THEN]

\ todo interactive session when no environment present
\ todo problems with ABORT here (TYPE>STR doesn't catch it)
: get-params S" QUERY_STRING" ENVIRONMENT? 0= IF S" " THEN GetParamsFromString ;

: revision $Revision$ SLITERAL ;
: spf-version VERSION 1000 / 100 /MOD " {n}.{n}" ;

: EMPTY? NIP 0= ;

: tag: PARSE-NAME POSTPONE SLITERAL POSTPONE tag ; IMMEDIATE
: quote [CHAR] " EMIT ;
: enquote-> PRO quote BACK quote TRACKING CONT ;

: attributes ( l -- )
  LAMBDA{ SPACE DUP car STR@ TYPE [CHAR] = EMIT enquote-> cdar STR@ HTML::TYPE } OVER mapcar
  FREE-LIST ;

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
: /tag ( a u -- ) () -ROT /atag ;

: PARSE-SLIT PARSE-NAME POSTPONE SLITERAL ;

: atag: PARSE-SLIT POSTPONE atag ; IMMEDIATE
: /atag: PARSE-SLIT POSTPONE /atag ; IMMEDIATE

: $$ %[ >STR %s >STR %s ]% %l ;
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

   tag: form

   %[ 
      `q `name $$
      ( a u ) `value $$
      `text `type $$
      `30 `size $$
   ]% 
   /atag: input

   %[ `submit `type $$ `Search `value $$ ]% `input /atag
   HTML::CR
   \ HTML::CR
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
  DUP << words-each-> show-word >>
  FREE-LIST ;

: content
  get-params
  `q GetParam start-page
  `q GetParam EMPTY? IF EXIT THEN
  wordsfile words-load { l }
  `q GetParam l words-find ( l1 l2 ) 
  S" Exact matches : " block
  S" Case-insensitive matches : " block 
  l FREE-LIST
;

: footer
  hrule
  tag: small
  OS_NAME { os }
  os STR@ FINE-TAIL "  help.cgi r{revision} ({s})" STYPE CR
  os STRFREE
  spf-logo CR ;

PREVIOUS

: output
  tag: html
  <<
   tag: head
   %[ `some.css `href $$ `stylesheet `rel $$ `text/css `type $$ ]% /atag: link
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
