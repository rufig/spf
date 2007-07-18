\ $Id$
\ Обёртка к iconv
\ more to do

REQUIRE SO ~ac/lib/ns/so-xt.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE /TEST ~profit/lib/testing.f

ALSO SO NEW: iconv.dll
( libiconv_open libiconv libiconv_close)

: UTF8>CP1251 { a u | a2 u2 cd -- s } 
   S" UTF-8" DROP S" CP1251" DROP 2 libiconv_open DUP -1 = ABORT" No such conversion"
   -> cd
   u 1 * -> u2
   PAD -> a2
   ^ u2 ^ a2 ^ u ^ a cd 5 libiconv -1 = ABORT" Conversion failed"
   cd 1 libiconv_close ABORT" cd close failed"
   "" >R
   PAD a2 OVER - R@ STR!
   R> ;


PREVIOUS

\ -------------------------------------------------

/TEST

S" Привет" UTF8>CP1251 CR STYPE

