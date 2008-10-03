\ Oct.2006, Feb.2007

\ Требует слов GERM и GERM!

: CONCEIVE ( -- )
  ?CSP GERM >CS
  ALIGN HERE GERM!
;
: BIRTH ( -- xt )
  RET, GERM  CS> GERM!
  ClearJpBuff \ for OPT
  \ AT-BIRTH ( xt -- xt ) \ is event
  [DEFINED] UNUSED [IF] \ в ядре нет слова UNUSED
  UNUSED 250 < IF -8 THROW  THEN \ dictionary overflow
  \ сравнение с учетом знака,
  \ т.к. "свободное место" может стать и отрицательной величиной.
  [THEN]
;
: MAKE-CONST ( x -- xt ) \ xt ( -- x )
  CONCEIVE LIT, BIRTH
;

\EOF
\ дополнительные (в процессе поиска формы), пока не используются:

: MAKE-LIT ( x -- xt ) \ xt ( -- x )
  CONCEIVE LIT, BIRTH
;
: MAKE-SLIT ( c-addr u -- xt ) \ xt ( -- c-addr2 u )
  CONCEIVE SLIT, BIRTH
;
: MAKE-SLOT ( -- xt )  \ xt ( -- addr )
  ALIGN HERE 0 , MAKE-LIT
;
