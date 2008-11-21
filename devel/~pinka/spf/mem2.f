\ $Id$
\ 03.Oct.2003  Ruv
\ 02.Aug.2004 код перенесен из mem.f в mem2.f

( –асширение SPF4
  измен€ет поведение слов ALLOCATE FREE RESIZE
  на предмет учета HEAP-ID
  - если он возвращает не 0, работать с ним как с хипом,
  иначе с хипом потока THREAD-HEAP -- старое поведение.
)

REQUIRE [UNDEFINED] lib/include/tools.f

USER-VALUE HEAP-ID

: HEAP-ID! ( heap -- ) TO HEAP-ID ;

\ 8 = HEAP_ZERO_MEMORY 
\ 1 = HEAP_NO_SERIALIZE
\ 9 = HEAP_ZERO_MEMORY HEAP_NO_SERIALIZE OR
\ “аким образом, синхронизаци€ при доступе к общему хипу
\  на совести вызывающей программы..

: ALLOCATE2 ( u -- a-addr ior ) \ 94 MEMORY
  CELL+ 9 ( HEAP_ZERO_MEMORY HEAP_NO_SERIALIZE OR )
  HEAP-ID ?DUP 0= IF THREAD-HEAP @ THEN
  HeapAlloc
  DUP IF R@ OVER ! CELL+ 0 ELSE -300 THEN
;
: FREE2 ( a-addr -- ior ) \ 94 MEMORY
  CELL- 1 ( HEAP_NO_SERIALIZE )
  HEAP-ID ?DUP 0= IF THREAD-HEAP @ THEN
  HeapFree ERR
;
: RESIZE2 ( a-addr1 u -- a-addr2 ior ) \ 94 MEMORY
  CELL+ SWAP CELL- 9 ( HEAP_ZERO_MEMORY HEAP_NO_SERIALIZE OR )
  HEAP-ID ?DUP 0= IF THREAD-HEAP @ THEN
  HeapReAlloc
  DUP IF CELL+ 0 ELSE -300 THEN
;

WARNING @ WARNING 0!
[UNDEFINED] ALLOCATE1 [IF] ( создание векторов, если их не было )

' ALLOCATE  VECT ALLOCATE
' FREE      VECT FREE    
' RESIZE    VECT RESIZE  
( xt-orig-ALLOCATE xt-orig-FREE xt-orig-RESIZE )

[THEN]

' ALLOCATE2 TO ALLOCATE
' FREE2     TO FREE
' RESIZE2   TO RESIZE

[UNDEFINED] ALLOCATE1 [IF] ( перехват оригинальных слов, если не было векторов)
REQUIRE REPLACE-WORD lib/ext/patch.f

' RESIZE    SWAP REPLACE-WORD
' FREE      SWAP REPLACE-WORD
' ALLOCATE  SWAP REPLACE-WORD

[THEN]
WARNING !

\ ===

: HEAP-GLOBAL ( -- )
  GetProcessHeap HEAP-ID!
;
: HEAP-DEFAULT ( -- ) \ or HEAP-LOCAL  or HEAP-USER
  0 HEAP-ID!
;
