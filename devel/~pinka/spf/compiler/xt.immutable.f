\ Oct.2006, Feb.2007

\ “ребует слов GERM и GERM!

: CONCEIVE ( -- )
  ?CSP GERM >CS
  ALIGN HERE GERM!
;
: BIRTH ( -- xt )
  RET, GERM  CS> GERM!
  \ AT-BIRTH ( xt -- xt ) \ is event
;
: NAMING ( c-addr u xt -- ) \ NAMED GIVE-NAME ?
\ дает им€ и зачисл€ет его в текущую книгу имен :)
\ сразу после этого им€ находимо.

  HERE SWAP ,  LAST-CFA !
  0 C,     \ flags
  \ +SWORD was here
  HERE >R S",  R@ GET-CURRENT DUP @ , !
  R> LAST !
;

[DEFINED] QuickSWL-Support  [IF]
WARNING @  WARNING 0!
: NAMING NAMING LAST @ GET-CURRENT QuickSWL-Support::update1-wlhash ;
WARNING !                   [THEN]

: NAMING- ( xt c-addr u -- ) ROT NAMING ;

: ALIAS ( xt c-addr u -- ) NAMING- ;

\ : DEFER-NAMING ( c-addr u -- entry ) 0 , 0 C, HERE -ROT S", 0 , ;
\ ~ BIND-NAME ( xt entry -- ) TUCK 5 - ! .....  ;


\EOF
\ дополнительные (в процессе поиска формы), пока не используютс€:

: MAKE-LIT ( x -- xt ) \ xt ( -- x )
  CONCEIVE LIT, BIRTH
;
: MAKE-SLIT ( c-addr u -- xt ) \ xt ( -- c-addr2 u )
  CONCEIVE SLIT, BIRTH
;
: MAKE-SLOT ( -- xt )  \ xt ( -- addr )
  ALIGN HERE 0 , MAKE-LIT
;

: DEVELOP ( wid -- ) ( CS: -- wid-prev )
  GET-CURRENT >CS
  ALSO CONTEXT ! DEFINITIONS
;
: FURL ( -- ) ( CS: wid-prev -- )
  PREVIOUS CS> SET-CURRENT
;
