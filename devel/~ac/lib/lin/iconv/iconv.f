(  онвертаци€ строк между разными кодовыми таблицами

  ƒл€ компил€ции нужны следующие dll:
  iconv.dll - либо GNU libiconv [800Kb],
              либо win_iconv [32Kb] by Yukihiro Nakadaira
  —м. http://www.gtk.org/download-windows.html
)  
  
WARNING @ WARNING 0!
REQUIRE SO            ~ac/lib/ns/so-xt.f
REQUIRE STR@          ~ac/lib/str5.f
WARNING !

REQUIRE [IF]          lib/include/tools.f

OS_WINDOWS [IF]
  ALSO SO NEW: iconv.dll
[ELSE]
  ALSO SO NEW: libc.so.6
  : libiconv_open iconv_open ; : libiconv iconv ; : libiconv_close iconv_close ;
[THEN]

: 0x98>BL ( addr u -- )
  \ libiconv - борец за чистоту русского €зыка :)
  \ в кодировке cp1251 на месте 0x98 - дырка
  0 ?DO DUP C@ 0x98 = IF BL OVER C! THEN 1+ LOOP DROP
;
: ICONV { a u cpfa cpfu cpta cptu \ ico oa ou aa su sa -- oa ou }
\ преобразовать строку a u из кодировки cpfa cpfu в cpta cptu,
\ например: S" тест" S" CP1251" S" UTF-8" ICONV
\ возвращает результат oa ou; oa освобождать вызывающему по FREE
  u -> su  a -> sa \ при невозможности конвертации libiconv портит a u
  u 4 * CELL+ DUP -> ou ALLOCATE THROW DUP -> oa -> aa  
  cpfa cpta 2 libiconv_open -> ico
  ^ ou ^ oa ^ u ^ a ico 5 libiconv
  IF ( ошибка перекодировани€, оставл€ем исходную строку )
    sa aa su 1+ MOVE aa su
  ELSE
    aa oa OVER -
    2DUP + 0 SWAP W!
  THEN
  ico 1 libiconv_close THROW
;
: BUNICODE> ( addr u -- addr2 u2 )
  S" UTF-16BE" S" CP1251" ICONV
;
: >BUNICODE ( addr u -- addr2 u2 )
  S" CP1251" S" UTF-16BE" ICONV
;

[UNDEFINED] >UNICODE [IF]

: >UNICODE ( addr u -- addr2 u2 )
  S" CP1251" S" UTF-16LE" ICONV
;
: UNICODE> ( addr u -- addr2 u2 )
  S" UTF-16LE" S" CP1251" ICONV
;
: UTF8>UNICODE ( addr u -- addr2 u2 )
  S" UTF-8" S" UTF-16LE" ICONV
;
: UNICODE>UTF8 ( addr u -- addr2 u2 )
  S" UTF-16LE" S" UTF-8" ICONV
;
: >UTF8  ( addr u -- addr2 u2 )
  2DUP 0x98>BL
  S" CP1251" S" UTF-8" ICONV
;
: UTF8> ( addr u -- addr2 u2 )
  S" UTF-8" S" CP1251" ICONV
;
[THEN]

: iso-8859-5>UNICODE ( addr u -- addr2 u2 )
\ специально дл€ чтени€ писем ~yz :)
  S" ISO-8859-5" S" UTF-16LE" ICONV
;
: UCS4> ( addr u -- addr2 u2 ) \ используетс€ в IDNA
  S" UTF-32LE" S" CP1251" ICONV
;
: >UCS4 ( addr u -- addr2 u2 )
  S" CP1251" S" UTF-32LE" ICONV
;
PREVIOUS

[UNDEFINED] UASCIIZ> [IF]
: UASCIIZ> ( addr -- addr u ) \ вариант ASCIIZ> дл€ Unicode
  0 OVER
  BEGIN
    DUP W@ 0<>
  WHILE
    2+ SWAP 1+ SWAP
  REPEAT DROP 2*
;
[THEN]

: 4ASCIIZ> ( addr -- addr u ) \ вариант ASCIIZ> дл€ UCS-4
  0 OVER
  BEGIN
    DUP @ 0<>
  WHILE
    4 + SWAP 1+ SWAP
  REPEAT DROP 4 *
;

\EOF
S" тест-123-abc" S" CP1251" S" UTF-8" ICONV 2DUP TYPE CR DROP FREE THROW
S" тест-123-abc" >UNICODE 2DUP DUMP CR UNICODE> ANSI>OEM TYPE CR
S" тест-123-abc" >UTF8 UTF8>UNICODE UNICODE> ANSI>OEM TYPE CR
