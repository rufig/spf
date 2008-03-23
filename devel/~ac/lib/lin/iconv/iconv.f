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

: ICONV { a u cpfa cpfu cpta cptu \ ico oa ou aa -- oa ou }
\ преобразовать строку a u из кодировки cpfa cpfu в cpta cptu,
\ например: S" тест" S" CP1251" S" UTF-8" ICONV
\ возвращает результат oa ou; oa освобождать вызывающему по FREE
  u 3 * DUP -> ou ALLOCATE THROW DUP -> oa -> aa
  cpfa cpta 2 libiconv_open -> ico
  ^ ou ^ oa ^ u ^ a ico 5 libiconv THROW
  aa oa OVER -
  ico 1 libiconv_close THROW
;
: >UNICODE ( addr u -- addr2 u2 )
  S" CP1251" S" UTF-16" ICONV
;
: UNICODE> ( addr u -- addr2 u2 )
  S" UTF-16" S" CP1251" ICONV
;
: UTF8>UNICODE ( addr u -- addr2 u2 )
  S" UTF-8" S" UTF-16" ICONV
;
: UNICODE>UTF8 ( addr u -- addr2 u2 )
  S" UTF-16" S" UTF-8" ICONV
;
: >UTF8  ( addr u -- addr2 u2 )
  S" CP1251" S" UTF-8" ICONV
;
: UTF8> ( addr u -- addr2 u2 )
  S" UTF-8" S" CP1251" ICONV
;
PREVIOUS

\EOF
S" тест-123-abc" S" CP1251" S" UTF-8" ICONV 2DUP TYPE CR DROP FREE THROW
S" тест-123-abc" >UNICODE 2DUP DUMP CR UNICODE> ANSI>OEM TYPE CR
S" тест-123-abc" >UTF8 UTF8>UNICODE UNICODE> ANSI>OEM TYPE CR
