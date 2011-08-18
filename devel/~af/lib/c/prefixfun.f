\ Andrey Filatkin, af@forth.org.ru
\ Либа предназначена для повышения читабельности форт-текстов.
\ Дает возможность записи вызова слов в более наглядном виде -
\ (( func arg1 , arg2 , arg3 )
\ (( foo ()
\ Особенно полезна при вызове API-функций.
\ Имеет встроеный счетчик аргументов.

REQUIRE [DEFINED]  lib/include/tools.f

[DEFINED] CASE-INS [IF] CASE-INS @ CASE-INS OFF [THEN]

VOCABULARY PFSupport
GET-CURRENT ALSO PFSupport DEFINITIONS

USER curfunc

\ возвращает имя текущего слова, если есть
: curname ( -- false | addr u true )
  curfunc @ DUP IF 2 CELLS + COUNT TRUE THEN
;

\ возвращает число аргументов
: count ( -- -1 | n )
  curfunc @ DUP IF CELL+ @ ELSE DROP -1 THEN
;

\ увеличивает счетчик аргументов на 1
: , ( -- )
  curfunc @ CELL+ 1+!
; IMMEDIATE

\ выполняет слово, освобождает память
: ) ( -- )
  POSTPONE ,
  curfunc @
  DUP >R 2 CELLS + COUNT EVALUATE
  R> DUP @ curfunc !
  FREE THROW
  PREVIOUS
; IMMEDIATE

\ чтобы не писать DROP после вызова каждой функции
: )) ( -- )
  POSTPONE )
  STATE @ IF POSTPONE DROP ELSE DROP THEN
; IMMEDIATE

\ для слов без аргументов
: () ( -- )
  -1 curfunc @ CELL+ ! POSTPONE )
; IMMEDIATE

: ()) ( -- )
  POSTPONE ()
  STATE @ IF POSTPONE DROP ELSE DROP THEN
; IMMEDIATE

SET-CURRENT

\ откладывает выполнение слова до достижения конца списка аргументов
: (( ( "func" -- )
  NextWord
  DUP 9 + CELL+ ALLOCATE THROW
  \ некоторые обработчики NOTFOUND пишут 0x0 за пределом обрабатываемого буфера
  \ поэтому, берем лишний CELL -- для исправления bug#1828051 и во избежании 
  \ ( ~ruv 2010.Oct.27 )
  curfunc @ OVER ! DUP curfunc !
  CELL+ DUP 0!
  CELL+ 2DUP C!
  1+ SWAP MOVE
  ALSO PFSupport
; IMMEDIATE
PREVIOUS

[DEFINED] CASE-INS [IF] CASE-INS ! [THEN]

\EOF
: foo1  . . ;
: foo2 DUP 1+ ;
: test11 (( foo1 1 , 2 ) CR ;
: test21 1 2 foo1 CR ;
: test12 (( foo1 (( foo2 5 ) , ) CR ;
: test22 5 foo2 foo1 CR ;
test11 test21
test12 test22
23 (( DUP () . .
