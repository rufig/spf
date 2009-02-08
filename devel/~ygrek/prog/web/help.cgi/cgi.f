\ $Id$
\ 
\ sample CGI
\ see it in action at http://ygrek.org.ua/exec/help.cgi?q=*SWAP*

: wordsfile S" words" ;

REQUIRE FINE-TAIL ~pinka/samples/2005/lib/split-white.f
REQUIRE $Revision ~ygrek/lib/fun/kkv.f
REQUIRE { lib/ext/locals.f
REQUIRE DumpParams ~ac/lib/string/get_params.f
REQUIRE BOUNDS ~ygrek/lib/string.f
REQUIRE CEQUAL ~pinka/spf/string-equal.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f
REQUIRE OSNAME-STR ~ygrek/lib/sys/osname.f
\ REQUIRE INTER ~ygrek/lib/debug/inter.f
REQUIRE list-all ~ygrek/lib/list/all.f
REQUIRE words-load ~ygrek/prog/web/help.cgi/load.f
REQUIRE XHTML ~ygrek/lib/xhtml/core.f

: revision $Revision$ SLITERAL ;
: spf-version VERSION 1000 / 100 /MOD " {n}.{n}" ;

: text/html S" Content-type: text/html" TYPE CR ;
: content-length ( n -- ) " Content-Length: {n}" STYPE CR ;

: get-params S" QUERY_STRING" ENVIRONMENT? 0= IF S" " THEN GetParamsFromString ;

: EMPTY? NIP 0= ;
: STARTS-WITH? { a1 u1 a2 u2 -- ? }
  u1 u2 < IF FALSE EXIT THEN
  a1 u2 a2 u2 CEQUAL ;

ALSO XHTML

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

\ link to source
: source-from-spf ( a u -- )
\  " http://spf.cvs.sourceforge.net/*checkout*/spf/" 
  " http://forth.org.ru/"
  >R
  2DUP S" ~" STARTS-WITH? IF S" devel/" R@ STR+ THEN
  2DUP R@ STR+
  R@ " \" " /" replace-str- \ "
  ( a u ) R@ STR@ link-text
  R> STRFREE ;

ALSO XMLSAFE

: spf-logo ."  Powered by " `SP-Forth `http://spf.sf.net link-text SPACE spf-version STYPE ;

: show-word ( s1 s2 s3 -- )
  << `word :span STR@ TYPE >>
  SPACE
  << `stack :span STR@ TYPE >>
  << `source :span ."  \ " STR@ source-from-spf >>
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

: output
  xml-declaration
  doctype-strict

  xhtml
  <<
   tag: head
   %[ `content-type `http-equiv $$ `text/html;charset=cp1251 `content $$ ]% /atag: meta
   `some.css link-stylesheet
   tag: title S" SP-Forth words search" XMLSAFE::TYPE
  >>
  tag: body
  content
  footer ;

PREVIOUS
PREVIOUS

\ buffer all output so that we can set Content-Length and server won't use
\ chunked transfer-encoding (thx to ~pinka for pointing this out)
: output-s LAMBDA{ output CR } TYPE>STR ;

: main text/html output-s DUP STRLEN content-length CR STYPE ; 

: save
  LAMBDA{ main BYE } MAINX !
  S" help.cgi" SAVE BYE ;
