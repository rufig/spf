\ сравнение строки и маски, содержащей метасимволы (wildcards)  * ?
\ for SPF
\ (c) Ruvim Pinka -- исходная версия: ~pinka/lib/mask.f
\ переписано: 04.07.2026 ~ac

\ НЕСОВМЕСТИМОСТИ с ~pinka/lib/mask.f:
\ * WildCMP-U возвращает только 0 (совпало) или 1 (не совпало);
\   знака направления сравнения символов (-1/1) больше нет --
\   для сортировки/двоичного поиска не годится
\ * несколько * в хвосте маски совпадают с исчерпанной строкой:
\   S" abc" S" abc**" WildCMP-U -> 0 (у исходной было -1)
\ * символ квотирования жёстко \ , VALUE quote-char удалён
\ * вспомогательное слово _WildCMP-U? остаётся видимым
\   (исходная прятала внутренности во временный словарь)

REQUIRE {              ~ac\lib\locals.f
REQUIRE [UNDEFINED]    lib\include\tools.f

[UNDEFINED] WITHIN [IF]
: WITHIN ( n1|u1 n2|u2 n3|u3 -- flag ) \ 93 CORE EXT
  OVER - >R - R> U<
;
[THEN]

[UNDEFINED] UpCase [IF]
: UpCase ( c1 -- c2 )
  DUP  [CHAR] a   [ CHAR z 1+ ] LITERAL  WITHIN
  IF   32 -  THEN
;
[THEN]

: _WildCMP-U? { str strlen wc wclen -- flag }
  BEGIN
    wclen 0= IF strlen 0= EXIT THEN
    wc C@ [CHAR] * =
    IF
      wc 1+ -> wc  wclen 1- -> wclen
      wclen 0= IF TRUE EXIT THEN
      BEGIN
        str strlen wc wclen RECURSE IF TRUE EXIT THEN
        strlen 0= IF FALSE EXIT THEN
        str 1+ -> str  strlen 1- -> strlen
      AGAIN
    THEN
    strlen 0= IF FALSE EXIT THEN
    wc C@ [CHAR] ? =
    IF
      wc 1+ -> wc  wclen 1- -> wclen
      str 1+ -> str  strlen 1- -> strlen
    ELSE
      wc C@ [CHAR] \ =
      IF
        wc 1+ -> wc  wclen 1- -> wclen
        wclen 0= IF FALSE EXIT THEN
      THEN
      wc C@ UpCase str C@ UpCase <> IF FALSE EXIT THEN
      wc 1+ -> wc  wclen 1- -> wclen
      str 1+ -> str  strlen 1- -> strlen
    THEN
  AGAIN ;
: WildCMP-U ( addr1 u1 addr2 u2 -- n ) _WildCMP-U? IF 0 ELSE 1 THEN ;

( example
  S" Zbaabbb777778" S" ?b*7*8" WildCMP-U .
  S" 012WebMaster" S" ???w??mas*" WildCMP-U .
  S" INBOX" S" INBOX*" WildCMP-U .
  S" http://blablabla.html?.newshub.eserv.ru/" S" http://*\?.*/"  WildCMP-U .
)
