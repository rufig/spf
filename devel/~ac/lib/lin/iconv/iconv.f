( Конвертация строк между разными кодовыми таблицами

  Для компиляции нужны следующие dll:
  iconv.dll
)  
  
WARNING @ WARNING 0!
REQUIRE SO            ~ac/lib/ns/so-xt.f
REQUIRE STR@          ~ac/lib/str5.f
WARNING !

REQUIRE [IF]          lib/include/tools.f

[DEFINED] WINAPI: [IF]
  ALSO SO NEW: iconv.dll
[ELSE]
  ALSO SO NEW: libc.so.6
  : libiconv_open iconv_open ; : libiconv iconv ; : libiconv_close iconv_close ;
[THEN]

: 0x98>BL ( addr u -- )
  \ libiconv - борец за чистоту русского языка :)
  \ в кодировке cp1251 на месте 0x98 - дырка
  0 ?DO DUP C@ 0x98 = IF BL OVER C! THEN 1+ LOOP DROP
;
: ICONV { a u cpfa cpfu cpta cptu \ ico oa ou aa su sa -- oa ou }
\ преобразовать строку a u из кодировки cpfa cpfu в cpta cptu,
\ например: S" тест" S" CP1251" S" UTF-8" ICONV
\ возвращает результат oa ou; oa освобождать вызывающему по FREE
  u -> su  a -> sa \ при невозможности конвертации libiconv портит a u
  u 3 * CELL+ DUP -> ou ALLOCATE THROW DUP -> oa -> aa  
  cpfa cpta 2 libiconv_open -> ico
  ^ ou ^ oa ^ u ^ a ico 5 libiconv
  IF ( ошибка перекодирования, оставляем исходную строку )
    sa aa su 1+ MOVE aa su
  ELSE
    aa oa OVER -
    2DUP + 0 SWAP W!
  THEN
  ico 1 libiconv_close THROW
;
: >UNICODE ( addr u -- addr2 u2 )
  S" CP1251" S" UTF-16LE" ICONV
;
: UNICODE> ( addr u -- addr2 u2 )
  S" UTF-16LE" S" CP1251" ICONV
;
: BUNICODE> ( addr u -- addr2 u2 )
  S" UTF-16BE" S" CP1251" ICONV
;
: >BUNICODE ( addr u -- addr2 u2 )
  S" CP1251" S" UTF-16BE" ICONV
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
: iso-8859-5>UNICODE ( addr u -- addr2 u2 )
\ специально для чтения писем ~yz :)
  S" ISO-8859-5" S" UTF-16LE" ICONV
;

PREVIOUS

: UASCIIZ> ( addr -- addr u ) \ вариант ASCIIZ> для Unicode
  0 OVER
  BEGIN
    DUP W@ 0<>
  WHILE
    2+ SWAP 1+ SWAP
  REPEAT DROP 2*
;

\EOF
S" тест-123-abc" S" CP1251" S" UTF-8" ICONV 2DUP TYPE CR DROP FREE THROW
S" тест-123-abc" >UNICODE 2DUP DUMP CR UNICODE> ANSI>OEM TYPE CR
S" тест-123-abc" >UTF8 UTF8>UNICODE UNICODE> ANSI>OEM TYPE CR
