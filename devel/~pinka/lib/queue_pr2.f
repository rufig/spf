\ 07.Jul.2001 Sat 21:27 Ruv

\ Очередь с приоритетом  Low Value First

( module export:
     queue.  LeaveLow        Enterly NewQueue       
     VocPrioritySupport      DelQueue 
)
\ 05.Jul.2002 Fri 23:47 + Queue-Count + ^cnt
\ 14.Sep.2003 Sun  + mapQueue * Исправлена серьезная ошибка насчет ^cnt
\ 06.Oct.2003 + QueueLow,   rename: Queue-Count -> QueueLen, Aa-Bb -> AaBb

REQUIRE {  ~ac\lib\locals.f

MODULE:  VocPrioritySupport

\ priority: LowValueFirst

( двунаправленный упорядоченный по priority список. )
0  \ list element
1 CELLS  -- ^next
1 CELLS  -- ^prev
1 CELLS  -- ^priority
      0  -- ^cnt  \ т.к. используется только у первого псевдо-элемента ( a )
1 CELLS  -- ^value
CONSTANT /elist

: insert { newel elem -- }
\ newelem before ( at left) elem
  elem ^prev @  DUP 
    newel ^prev  !
    newel SWAP ^next !
  elem newel ^next !
  newel elem ^prev !
;
: remove { elem -- }
  elem ^next @  elem ^prev @  ^next !
  elem ^prev @  elem ^next @  ^prev !
  \ правлю только ссылки на elem 
  \ сам elem  не правлю.
  \ Всегда есть линк слева и справа (изначально)
;

EXPORT

: NewQueue ( -- queue )
  { \ a z }
  /elist ALLOCATE THROW  -> a  a /elist ERASE
  /elist ALLOCATE THROW  -> z  z /elist ERASE
  z a ^next !
  a z ^prev !
  -1 a ^priority !
   0 z ^priority ! \ must be so !
   ( граница - по граничному priority )
  a  z ^value !
  z
; \ queue = elem_z

DEFINITIONS

: first ( q -- elem )
  ^value @  ^next @
;

EXPORT

: Enterly { x pr  queue  \ newel  -- }
\ включить элемент x в очередь queue с приоритетом pr
  queue ^value @ ^cnt 1+!
  queue first ( elem )
  BEGIN pr OVER ^priority @ U< WHILE ^next @ REPEAT ( elem ) 
  /elist ALLOCATE THROW -> newel
  x   newel ^value    !
  pr  newel ^priority !
  newel SWAP insert
;

: LeaveLow  ( queue -- x true | false )
\ исключить из очереди первый элемент (c наименьшим численным значением pr),
\ оставить элемент на стеке и true, в случае успеха
\ или false в случае не успеха (пустая очередь).
  { q \ elem }
  q ^value @ ^cnt @ IF
    -1 q ^value @ ^cnt +!
    q ^prev @ -> elem
    \ q ^value @ elem = IF FALSE EXIT THEN
    elem remove
    elem ^value @  -1
    elem FREE THROW 
    EXIT     
  THEN  FALSE
;

: DelQueue ( queue -- )
  BEGIN DUP WHILE DUP ^prev @ SWAP FREE THROW REPEAT  DROP
;

\ Include ( x pr  queue -- )
\ ExcludeLow ( queue -- x true | false )

: queue. { q -- }
  q first BEGIN DUP q <> WHILE
    DUP .  DUP ^priority @ . DUP ^value @ . CR
    ^next @
  REPEAT DROP
;
: QueueLen ( q -- len )
  ^value @  ^cnt @
;
: QueueLow { q -- priority-low }
  q ^value @ ^cnt @         IF
  q ^prev @  ^priority @    ELSE
  0                         THEN
;
: mapQueue { q xt \ e -- }  
\ xt ( value pr -- )
  q first BEGIN DUP q <> WHILE -> e
    e ^value @ e ^priority  @ xt  EXECUTE
    e ^next @
  REPEAT DROP
;

;MODULE

 ( Example:
NewQueue VALUE q
10 5 q Enterly  \ value pr queue -- 
11 7 q Enterly
12 3 q Enterly
13 7 q Enterly
q queue.
q :NONAME DROP . ; mapQueue CR
q QueueLen . CR
q LeaveLow . . CR
q LeaveLow . . CR
q LeaveLow . . CR
q LeaveLow . . CR
q LeaveLow . CR
q DelQueue
\ )