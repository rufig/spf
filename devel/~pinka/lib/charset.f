\ <INTRODUCTION>
\ множество символов
\ ver 0.2 ( 27.04.2000)

\ (c) 1999-2000 Ruvim Pinka
\ </INTRODUCTION>

\ <HISTORY>
\ 09.04.99г. 04:36:16 - создано.
\   ... кое что добавлено
\ 03.01.2000
\   добавлен постфикс.
\ 27.04.2000
\   дурной синтаксис был ( addr value )
\   исправил, сделав работу по аналогии со словами !  +!  ( value addr )
\ </HISTORY>

\ <BODY>

REQUIRE CREATED  ~pinka\lib\EXT_my.f 


\ 256 бит = 8 бит * 32  = 32 байта
\    = 32 bit * 8 = 8 cells
32 CONSTANT /set


: created-set  ( a u  -- )
    CREATED    HERE  /set ALLOT  /set ERASE
;

: create-set ( -- )  \ name
\ создать пустое множество в словаре
    NextWord  created-set
;

\ динамически создать пустое множество. освобождение по FREE
: new-set ( -- a-set )
    /set ALLOCATE THROW  DUP /set ERASE
;


\  /MOD ( делимое делитель -- остаток частное )

: getmask ( char a-set -- a-byte byte-mask )
    >R  8 /MOD R> +  SWAP ( a-byte bits-offs )
    1 SWAP LSHIFT
;

\ проверить элемент
: belong ( char a-set -- f )
    getmask  >R  C@ R@ AND  R> =
;
\ включить элемент
: set+   ( char a-set -- )
    getmask  SWAP DUP >R C@  OR  R> C!
;
\ исключить элемент
: set-   ( char a-set -- )
    getmask 255 XOR    SWAP DUP >R C@ AND R> C!
;

\ включить все символы из заданной строки во множество
: set-str+  ( addr u  a-set -- )
    >R
    OVER +  SWAP ( a2 a1 )
    BEGIN
        2DUP <> 
    WHILE
        DUP C@ R@ set+  1+
    REPEAT 2DROP RDROP
;

: set. ( a-set -- )
    256 0 DO  I OVER belong IF  I EMIT THEN LOOP DROP
;

\ </BODY>
