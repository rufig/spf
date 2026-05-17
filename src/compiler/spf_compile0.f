\ $Id$

( Компиляция чисел словарь.
  ОС-независимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999, март 2000
)

  USER CURRENT     \ дает wid текущего словаря компиляции

  VARIABLE (DP)    \ переменная, содержащая HERE сегмента данных
5 CONSTANT CFL     \ Code Field Length - the length of a "call" threaded code element
  USER     DOES>A  \ This variable used to be for `DOES>`, now it is left only for backward compatibility.


\ Instead of `GET-CURRENT` and `SET-CURRENT`,
\ the better names are `COMPLIST` and `SET-COMPLIST`
\ ("complist" is an abbreviation from "compilation-wordlist").
\ Rationale: The meaning of the English word "current" should not be narrowed down
\ to refer specifically to a term denoting the compliation word list in Forth.

VECT COMPLIST-MAYBE  ( -- wid|0 )
: [CORE]COMPLIST-MAYBE ( -- wid|0 )
  CURRENT @
;
' [CORE]COMPLIST-MAYBE  ' COMPLIST-MAYBE  TC-VECT!

: COMPLIST? ( -- wid true | false )
  COMPLIST-MAYBE DUP IF TRUE THEN
;
: COMPLIST ( -- wid )
  COMPLIST-MAYBE DUP IF EXIT THEN
  -2014 THROW \ "No compilation wordlist is set"  \ see-also: -47 "compilation word list deleted"
;


VECT SET-COMPLIST
: [CORE]SET-COMPLIST ( wid|0 -- ) CURRENT ! ;
' [CORE]SET-COMPLIST  ' SET-COMPLIST  TC-VECT!

: EXCHANGE-COMPLIST ( wid1|0 -- wid2|0 )
  COMPLIST-MAYBE  SWAP  SET-COMPLIST
;

: SET-CURRENT ( wid -- ) \ 94 SEARCH
\ Установить список компиляции на список, идентифицируемый wid.
  DUP IF SET-COMPLIST EXIT THEN
  -12 THROW \ "argument type mismatch"
;

: GET-CURRENT ( -- wid ) \ 94 SEARCH
\ Возвращает wid - идентификатор списка компиляции.
  COMPLIST
;

\ Maybe this name is better
\ : IS-WORDLIST-TEMPORARY ( wid -- flag )  CELL- @ -1 = ;

: IS-TEMP-WORDLIST ( wid -- flag )
\ проверяет, является ли словарь wid временным (внешним)
  CELL- @ -1 =
;
: IS-TEMP-WL ( -- flag )
\ проверяет, является ли текущий словарь компиляции временным (внешним)
  GET-CURRENT IS-TEMP-WORDLIST
  \ This implementation might not work as expected for temporary storage/dictionary,
  \ so it should be redefined for backward compatibility.
;

VECT DP \ ( -- a-addr[ addr.here ] )
\ Data Pointer - the address of a cell containing HERE
\ The vect is initialized in "./spf_wordlist.f"

: COMPLIST-STATIC ( -- flag ) \ or maybe "DICTIONARY-STATIC"
  \ Note: it is a forward compatibile definition
  DP @  IMAGE-BASE IMAGE-SIZE OVER +  WITHIN
;

: ALLOT ( n -- ) \ 94
\ Если n больше нуля, зарезервировать n байт пространства данных. Если n меньше
\ нуля - освободить |n| байт пространства данных. Если n ноль, оставить
\ указатель пространства данных неизменным.
\ Если перед выполнением ALLOT указатель пространства данных выровнен и n
\ кратно размеру ячейки, он остается выровненным и после ALLOT.
\ Если перед выполнением ALLOT указатель пространства данных выровнен на
\ границу символа и n кратно размеру символа, он остается выровненным на
\ границу символа и после ALLOT.
  DP +!
;

: , ( x -- ) \ 94
\ Зарезервировать одну ячейку в области данных и поместить x в эту ячейку.
  DP @ 4 ALLOT !
;

: C, ( char -- ) \ 94
\ Зарезервировать место для символа в области данных и поместить туда char.
  DP @ 1 CHARS ALLOT C!
;

: W, ( word -- )
\ Зарезервировать место для word в области данных и поместить туда char.
  DP @ 2 ALLOT W!
;
