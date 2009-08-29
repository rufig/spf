\ $Id$
\ 
\ Simple CGI
\ See it in action at http://ygrek.org.ua/p/spf/words?q=swap

: wordsfile S" words.txt" ;

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
REQUIRE XHTML-EXTRA ~ygrek/lib/xhtml/extra.f

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
ALSO XMLSAFE

: start-page ( -- )
   <<
    tag: h2
    ." Search SP-Forth words (src,lib,devel) :"
   >>

   S" " form
   <<
   tag: div

   %[ 
      `q `name $$
      `q GetParam `value $$
      `text `type $$
      `30 `size $$
   ]% 
   /atag: input

   %[
      `exact `name $$
      `1 `value $$
      `exact GetParam EMPTY? NOT IF `checked 2DUP $$ THEN
      `exact `id $$
      `checkbox `type $$
   ]%
   /atag: input

   << %[ `exact `for $$ ]% `label atag S" whole word" TYPE >>

   %[ `submit `type $$ `Search `value $$ ]% `input /atag
   >>
   `div tag
   `small tag
   ." Usual shell wildcards should work : <b>?</b> (any symbol) and <b>*</b> (any number of any symbols)" CR
   S" All words" wordsfile link-text
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
  start-page
  `q GetParam EMPTY? IF EXIT THEN
  { | l s }
  wordsfile words-load -> l
  `q GetParam `exact GetParam EMPTY? IF " *{s}*" ELSE >STR THEN -> s
  s STR@ l words-find ( l1 l2 ) 
  S" Exact matches : " block
  S" Case-insensitive matches : " block 
  l words-free
  s STRFREE
;

: footer
  hrule
  tag: div
  <<
   %[ S" float:left;margin-right:1%" `style $$ ]%
   atag: div
   tag: small
   OSNAME-STR { os }
   `help.cgi `http://forth.org.ru/~ygrek/prog/web/help.cgi/cgi.f link-text
   os STR@ FINE-TAIL "  r{revision} ({s})" STYPE CR
   os STRFREE
   spf-logo 
  >>
  icon-valid
  ;

: output
  xml-declaration
  doctype-strict

  xhtml
  <<
   tag: head
   %[ `content-type `http-equiv $$ `text/html;charset=utf-8 `content $$ ]% /atag: meta
   `some.css link-stylesheet
   tag: title S" SP-Forth words search" TYPE
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
  `help.cgi SAVE BYE ;

