\ $Id$

REQUIRE XHTML ~ygrek/lib/xhtml/core.f

MODULE: XHTML

: input ( `value `name `type -- ) %[ `type $$ `name $$ `value $$ ]% `input /atag ;

: form-post ( `url -- ) PRO %[ `post `method $$ `action $$ ]% `form atag CONT ;
: form ( `url -- ) PRO %[ `action $$ ]% `form atag CONT ;

: icon-valid ( -- )
  `http://validator.w3.org/check?uri=referer link-tag
   %[ 
    S" Valid XHTML 1.0 Strict" `alt $$
    `http://www.w3.org/Icons/valid-xhtml10 `src $$
    `31 `height $$
    `88 `width $$
   ]% /atag: img ;

;MODULE

0 CONSTANT XHTML-EXTRA

