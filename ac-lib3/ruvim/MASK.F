
\ сравнение строки и маски, содержащей метасимволы (wildcards)  * ?

\ ver 0.4
\ 18.03.2000
\ исправлена некорректная обработка случая  S" aaa" S" aaa*"
\ ver 0.5
\ переход к locals,  небольшое улучшение алгоритма. (  для Eserv2* - temps.f оставлены)
\ ver 0.6  13.05.2000  добавлена возможность квотить метасимволы:  \* \? \\

\ for SPF
\ ver 0.1 - 11.06.1999    
\ (c) Ruvim Pinka


REQUIRE ||  temps.f 

CHAR \ VALUE quote-char

: WITHIN ( n1|u1 n2|u2 n3|u3 -- flag ) \ 93 CORE EXT
  OVER - >R - R> U<
;

\ возвращает верхний регистр символа ( только для основного набора)
: UpCase ( c1 -- c2 )
  DUP  [CHAR] a   [ CHAR z 1+ ] LITERAL  WITHIN
  IF   32 -  THEN
;


\ макросы   ( тут бы временный словарь заюзать... :)
: wc+
    S" wc  1+  -> wc   wclen  1-  -> wclen  " EVALUATE
; IMMEDIATE
: str+
    S" str 1+  -> str  strlen 1-  -> strlen " EVALUATE
; IMMEDIATE


: WildCMP-U   (  addr1 u1  addr2 u2 -- n )   \ case sensitive - non
\  addr1 u1  - строка
\  addr2 u2  - маска ( шаблон)
\  n =  0,  если строка подходит под шаблон,
\  n = -1,  - если несовпадающий символ НЕ найден, но строки разной длины.
\           - если он найден, причем первый несовпадающий символ
\           строки имеет меньшее числовое значение, чем соответсвующий
\           символ маски
\  n =  1   в остальных случаях, т.е.  если первый несовпадающий символ
\           строки имеет не большее числовое значение, чем соответсвующий
\           символ маски.
\  Маска :
\           *  - любое количество любых символов
\           ?  - любой символ
\
    || str strlen wc wclen ||  (( str strlen wc wclen ))

    BEGIN
        wclen  1 < IF   
            strlen 0= IF  0 EXIT THEN  -1  EXIT  
        THEN

        strlen 0= IF
            wc C@ [CHAR] * =  IF 
                wc+  wclen 0= IF 0  EXIT THEN \ если * - последний.
            THEN  -1  EXIT
        THEN

        wc C@  wc+
        DUP  [CHAR] *  = IF DROP

                wclen 0= IF  0 EXIT  THEN \ выход, если * - последний в шаблоне

                BEGIN  \ попробуем сравнить оставшиеся части
                    str strlen  wc wclen  RECURSE  0=
                    IF   0 EXIT  THEN  \ нашли совпадение
                    \ пропустим символ в строке, если не успешно ( обрабатывается * )
                    strlen 0= IF -1  EXIT THEN   str+
                AGAIN
        ELSE
        DUP  [CHAR] ?  = IF DROP    str+  ELSE
        DUP  quote-char = IF DROP  wc C@  wc+ THEN
            UpCase  str C@
            UpCase  2DUP  <> IF
               > IF  -1 EXIT    ELSE   1 EXIT   THEN  
            THEN 2DROP
            str+
        THEN THEN
    AGAIN
;


( example
  S" Zbaabbb777778" S" ?b*7*8" WildCMP-U .
  S" 012WebMaster" S" ???w??mas*" WildCMP-U .
  S" INBOX" S" INBOX*" WildCMP-U .
  S" http://blablabla.html?.newshub.eserv.ru/" S" http://*\?.*/"  WildCMP-U .
)
