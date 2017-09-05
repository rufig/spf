REQUIRE DLL          ~ac/lib/ns/so-xt.f
REQUIRE FILE         ~ac/lib/str5.f
REQUIRE UTF8>UNICODE ~ac/lib/lin/iconv/iconv.f 

ALSO SO NEW: libhunspell.dll

: TEST { \ h }
\ S" ru_RU.dic" DROP S" ru_RU.aff" DROP 2 Hunspell_create работать не будет, т.к.
\ используется модифицированная (гуглом и немножко мной :) библиотека,
\ принимающая на вход бинарный utf8-словарь в памяти, а не koi8-словарь на диске
  S" ru-RU-3-0.bdic" FILE SWAP 2 Hunspell_create -> h
  h 0= IF EXIT THEN
  S" тест" DROP h 2 Hunspell_spell . CR
  S" тестp" DROP h 2 Hunspell_spell . CR

  S" апечатка" DROP PAD h 3 Hunspell_suggest 0 ?DO
	PAD @ I CELLS + @ \ DUP 20 DUMP CR
        ASCIIZ> UTF8>UNICODE UNICODE> ANSI>OEM TYPE CR
  LOOP
;

PREVIOUS

TEST

\EOF
В норме будет напечатано:
1
0
печатка
а печатка
перчатка
печатника
лапчатка
