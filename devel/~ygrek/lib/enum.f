\ yGREK
\ 08.May.2005

\ Развивая идею ~micro/lib/const.f
\ Перечисление переменных в виде
\ floats a b c d e ;

\ Пример в конце

: GetWordPosition ( -- f )
  BEGIN
   >IN @ 
   NextWord
    DUP 0=
  WHILE
   2DROP
   DROP
   REFILL 0= ABORT" Need semicolon as the delimiter!"
  REPEAT
  S" ;" COMPARE 
  DUP IF SWAP >IN ! ELSE NIP THEN
;

: ENUM
  CREATE ,
  DOES> @ ( xt )
  BEGIN
    GetWordPosition
  WHILE
   DUP EXECUTE 
  REPEAT
  DROP
;

 
\EOF
\ Пример
REQUIRE F. lib/include/float2.f

:NONAME 2e FVALUE ; ENUM floats                          
:NONAME 23 CONSTANT ; ENUM consts
:NONAME CREATE DOES> DROP S" Hello,world" TYPE ; ENUM hellos

consts a1
a2 a3 
    a4 
;
hellos h1 h2 h3 ; 
floats f1 f2 f3 ;
