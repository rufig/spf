\ $Id$
\ 
\ sample CGI
\ see it in action at http://ygrek.org.ua/exec/help.cgi?q=*SWAP*

: wordsfile S" words" ;

REQUIRE FINE-TAIL ~pinka/samples/2005/lib/split-white.f
REQUIRE $Revision ~ygrek/lib/fun/kkv.f
REQUIRE { lib/ext/locals.f
REQUIRE DumpParams ~ac/lib/string/get_params.f
REQUIRE AsQName ~pinka/samples/2006/syntax/qname.f 
REQUIRE BOUNDS ~ygrek/lib/string.f
REQUIRE CEQUAL ~pinka/spf/string-equal.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f
REQUIRE OSNAME-STR ~ygrek/lib/sys/osname.f
REQUIRE xmltag ~ygrek/lib/xmltag.f
\ REQUIRE INTER ~ygrek/lib/debug/inter.f
REQUIRE list-all ~ygrek/lib/list/all.f
REQUIRE words-load ~ygrek/prog/web/help.cgi/load.f

: revision $Revision$ SLITERAL ;
: spf-version VERSION 1000 / 100 /MOD " {n}.{n}" ;

: text/html S" Content-type: text/html" TYPE CR ;
: content-length ( n -- ) " Content-Length: {n}" STYPE CR ;

\ local shortcuts to save typing
: << POSTPONE START{ ; IMMEDIATE
: >> POSTPONE }EMERGE ; IMMEDIATE

: get-params S" QUERY_STRING" ENVIRONMENT? 0= IF S" " THEN GetParamsFromString ;

: EMPTY? NIP 0= ;
: STARTS-WITH? { a1 u1 a2 u2 -- ? }
  u1 u2 < IF FALSE EXIT THEN
  a1 u2 a2 u2 CEQUAL ;

: span PRO %[ `class $$ ]% `span atag CONT ;
: span: PARSE-NAME PRO span CONT ;
: hrule `hr /tag ;

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

: link ( name u link u2 -- ) %[ `href $$ ]% `a atag XMLSAFE::TYPE ;

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

ALSO XMLSAFE

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
   %[ `content-type `http-equiv $$ `text/html;charset=cp1251 `content $$ ]% /atag: meta
   %[ `some.css `href $$ `stylesheet `rel $$ `text/css `type $$ ]% /atag: link
   tag: title S" SP-Forth words search" XMLSAFE::TYPE
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
