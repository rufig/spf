\ mask.f производства RP с замененными temps на locals

\ сравнение строки и маски, содержащей метасимволы (wildcards)  * ?

\ ver 0.4
\ 18.03.2000
\ исправлена некорректна€ обработка случа€  S" aaa" S" aaa*"

\ for SPF
\ ver 0.1 - 11.06.1999    
\ (c) Ruvim Pinka


REQUIRE { ~ac/lib/locals.f

: WITHIN ( n1|u1 n2|u2 n3|u3 -- flag ) \ 93 CORE EXT
  OVER - >R - R> U<
;

\ возвращает верхний регистр символа ( только дл€ основного набора)
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


: WildCMP-U   (  addr1 u1  addr2 u2 -- n )  \ case sensitive - non
\  addr1 u1  - строка
\  addr2 u2  - маска ( шаблон)
\  n =  0,  если строка подходит под шаблон,
\  n = -1,  - если несовпадающий символ Ќ≈ найден, но строки разной длины.
\           - если он найден, причем первый несовпадающий символ
\           строки имеет меньшее числовое значение, чем соответсвующий
\           символ маски
\  n =  1   в остальных случа€х, т.е.  если первый несовпадающий символ
\           строки имеет не большее числовое значение, чем соответсвующий
\           символ маски.
\  ћаска :
\           *  - любое количество любых символов
\           ?  - любой символ
\
\ —лучай   *ссс - где ссс - любое количество любых ће“а—ићвќлќв, обрабатываетс€
\ также, как  если бы этих метасимволов не было.(така€ маска сверхдостаточна)


    { str strlen wc wclen }

    BEGIN

        wclen  0= IF   
            strlen 0= IF  0 EXIT THEN  -1 EXIT  
        THEN

        strlen 0= IF
            wc C@ [CHAR] * =  IF 
                wc+  wclen 0= IF 0 EXIT THEN \ если * - последний.
            THEN  -1 EXIT
        THEN

        wc C@
        DUP  [CHAR] ?  = IF DROP    str+ wc+   ELSE
        DUP  [CHAR] *  = IF DROP    wc+
                \ пропустим все метасимволы после *
                BEGIN   wclen IF  
                        wc C@ [CHAR] * =  wc C@ [CHAR] ? =  OR
                    ELSE  0 EXIT  THEN \ выход, если * - последний в шаблоне
                WHILE wc+ REPEAT
                BEGIN  \ попробуем сравнить оставшиес€ части
                    str strlen  wc wclen  RECURSE  0<>
                WHILE  \ пропустим символ в строке, если не успешно ( обрабатываетс€ * )
                    strlen 0= IF -1  EXIT THEN   str+
                REPEAT
        ELSE
            UpCase  str C@
            UpCase  2DUP  <> IF
               > IF  -1 EXIT    ELSE   1 EXIT   THEN  THEN 2DROP
            str+ wc+
        THEN THEN
    AGAIN
;
