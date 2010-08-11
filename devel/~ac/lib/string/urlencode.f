\ URLENCODE - конвертаци€ строки в "Percent-encoding"-представление, прин€тое в HTTP
\ дл€ кодировани€ URL'ов, параметров QUERY_STRING и тел POST-запросов application/x-www-form-urlencoded.
\ ‘ункци€ симметрична URI-DECODE, котора€ (в версии acWEB/src/proto/http/uri-decode.f)
\ тоже понимает UTF-8.

( ƒл€ кодировани€ POST-запросов лучше не использовать, т.к. там нет причин
  передавать кодированные строки, можно слать открытым текстом.
  ≈сли все же используетс€, то надо заметить, что BL замен€етс€ на %20, как в URL,
  а не на "+", как раньше было прин€то в POST. Ќовым скриптерам без разницы.
)

REQUIRE >UTF8 ~ac/lib/lin/iconv/iconv.f 

: IsUrlUnreservedChar ( char -- flag ) \ в среднем быстрее, чем CharInSet из Eserv
  DUP 97 123 WITHIN IF DROP TRUE EXIT THEN \ a-z
  DUP 65  91 WITHIN IF DROP TRUE EXIT THEN \ A-Z
  DUP 48  58 WITHIN IF DROP TRUE EXIT THEN \ 0-9
  DUP [CHAR] - = IF DROP TRUE EXIT THEN
  DUP [CHAR] _ = IF DROP TRUE EXIT THEN
  DUP [CHAR] . = IF DROP TRUE EXIT THEN
  DUP [CHAR] ~ = IF DROP TRUE EXIT THEN
  DUP [CHAR] / = IF DROP TRUE EXIT THEN \ js не кодирует
  DROP FALSE
;
: UTF8URLENCODE { a u \ mem o b -- a2 u2 } \ исходна€ строка предполагаетс€ в UTF-8-кодировке
  \ результат в allocated-буфере; портитс€ область <# #>

  u 3 * 1 + ALLOCATE THROW -> mem
  BASE @ -> b HEX
  u 0 ?DO a I + C@
          DUP IsUrlUnreservedChar
          IF mem o + C! o 1+ -> o
          ELSE 0 <# # # [CHAR] % HOLD #> mem o + SWAP MOVE o 3 + -> o
          THEN
  LOOP
  b BASE !
  mem o
;
: URLENCODE ( a u -- a2 u2 ) \ исходна€ строка предполагаетс€ в Windows-1251-кодировке
  >UTF8
  UTF8URLENCODE
;
: IsUrlUnreservedChar2 ( char -- flag )
  \ в отличие от IsUrlUnreservedChar кодирует и "/"
  DUP 97 123 WITHIN IF DROP TRUE EXIT THEN \ a-z
  DUP 65  91 WITHIN IF DROP TRUE EXIT THEN \ A-Z
  DUP 48  58 WITHIN IF DROP TRUE EXIT THEN \ 0-9
  DUP [CHAR] - = IF DROP TRUE EXIT THEN
  DUP [CHAR] _ = IF DROP TRUE EXIT THEN
  DUP [CHAR] . = IF DROP TRUE EXIT THEN
  DUP [CHAR] ~ = IF DROP TRUE EXIT THEN
\  DUP [CHAR] / = IF DROP TRUE EXIT THEN \ js не кодирует
  DROP FALSE
;
: URLENCODE2 { a u \ mem o b -- a2 u2 } \ исходна€ строка предполагаетс€ в UTF-8-кодировке
  \ результат в allocated-буфере; портитс€ область <# #>

  u 3 * 1 + ALLOCATE THROW -> mem
  BASE @ -> b HEX
  u 0 ?DO a I + C@
          DUP IsUrlUnreservedChar2
          IF mem o + C! o 1+ -> o
          ELSE 0 <# # # [CHAR] % HOLD #> mem o + SWAP MOVE o 3 + -> o
          THEN
  LOOP
  b BASE !
  mem o
;
