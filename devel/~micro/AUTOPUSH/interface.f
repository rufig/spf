\ Слова интерфейса

REQUIRE WindowSearch ~micro/autopush/core.f
\ слова ядра

: GetLastChar ( addr u -- c )
\ вернуть последний символ строки addr u
  + 1- C@
;

: WindowSearcher
\ WindowSearcher <name>
\ создать слово-искатель окна
\ <name> caption<разделитель строки>
\ где <разделитель строки> является последним символом <name>
  CREATE
  IMMEDIATE
  LATEST-NAME NAME>STRING GetLastChar
  ,
  DOES>
  @ PARSE
  POSTPONE SLITERAL
  POSTPONE WindowSearch
;

WindowSearcher ->"
