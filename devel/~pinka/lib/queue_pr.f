\ 07.Jul.2001 Sat 21:27 Ruv

\ ќчередь с приоритетом  Low Value First

( module export:
     .queue  LeaveLow        Enterly New-Queue       
     VocPrioritySupport      Del-Queue 
)

REQUIRE {  ~ac\lib\locals.f

MODULE:  VocPrioritySupport

\ priority: LowValueFirst

0  \ list element
1 CELLS  -- ^next       
1 CELLS  -- ^prev 
1 CELLS  -- ^priority
1 CELLS  -- ^value
CONSTANT /elist

: insert { newel elem -- }
\ elem1 before ( at left) elem
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
  \ ¬сегда есть линк слева и справа (изначально)
;

EXPORT

: New-Queue ( -- queue )
  { \ a z }
  /elist ALLOCATE THROW  -> a  a /elist ERASE
  /elist ALLOCATE THROW  -> z  z /elist ERASE
  z a ^next !
  a z ^prev !
  -1 a ^priority !
  a  z ^value !
  z
;

DEFINITIONS

: first ( q -- elem )
  ^value @  ^next @
;

EXPORT

: Enterly { x pr  queue  \ newel  -- }
\ включить элемент x в очередь queue с приоритетом pr
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
\ или false в случае не успеха (пуста€ очередь).
  { \ elem }
  DUP ^prev @ -> elem
  ^value @ elem = IF FALSE EXIT THEN
  elem remove
  elem ^value @  -1
  elem FREE THROW 
;

: Del-Queue ( queue -- )
  BEGIN DUP WHILE DUP ^prev @ SWAP FREE THROW REPEAT  DROP
;

\ Include ( x pr  queue -- )
\ ExcludeLow ( queue -- x true | false )

: .queue { q -- }
  q first BEGIN DUP q <> WHILE
    DUP .  DUP ^priority @ . DUP ^value @ . CR
    ^next @
  REPEAT DROP
;

;MODULE

 ( Example:
New-Queue VALUE q
10 5 q Enterly
11 7 q Enterly
12 3 q Enterly
q .queue
q LeaveLow . . CR
q LeaveLow . . CR
q LeaveLow . . CR
q Del-Queue
\ )