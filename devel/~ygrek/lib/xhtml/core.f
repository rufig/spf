\ $Id$
\
\ Some common XHTML words

REQUIRE xmltag ~ygrek/lib/xmltag.f
REQUIRE AsQWord ~pinka/spf/quoted-word.f
REQUIRE XMLSAFE ~ygrek/lib/xmlsafe

MODULE: XHTML

\ shortcuts
: << POSTPONE START{ ; IMMEDIATE
: >> POSTPONE }EMERGE ; IMMEDIATE

: :span ( `class -- ) PRO %[ `class $$ ]% `span atag CONT ;
: span: ( "class" -- ) PARSE-NAME PRO :span CONT ;
: hrule `hr /tag ;

: th ( a u -- ) `th tag XMLSAFE::TYPE ;
: tr ( <--> ) PRO `tr tag CONT ;
: td PRO `td tag CONT ;

: :div ( `class -- ) PRO %[ `class $$ ]% `div atag CONT ;

: link-tag ( `link --> \ <-- ) PRO %[ `href $$ ]% `a atag CONT ;
: link-text ( name u link u2 -- ) link-tag XMLSAFE::TYPE ;

;MODULE
