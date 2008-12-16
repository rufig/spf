\ $Id$
\ Multithreaded queue
\ Not compatible with per-thread heaps (default on SPF/Win32)

REQUIRE ENTER-CRIT ~ygrek/lib/sys/critical.f
REQUIRE { lib/ext/locals.f
REQUIRE list ~ygrek/lib/list/core.f

\ multi-threaded queue
MODULE: mtq

MODULE: detail

0
CELL -- lock
CELL -- avail \ TODO: event
CELL -- data
CONSTANT /Q

: (put) { x q -- }
  x q data @ list::cons q data !
  TRUE q avail ! ;

{{ list
: (get) { q -- x -1 | 0 }
   q data @ list::empty? IF FALSE EXIT THEN
   q data @ DUP car SWAP FREE-NODE
   q data @ cdr q data !

   q data @ empty? 0= q avail ! 

   TRUE ;
}}

EXPORT

: new ( -- q )
  /Q ALLOCATE THROW { q }
  NEW-CRIT q lock !
  FALSE q avail !
  list::nil q data ! 
  q ;

: del { q -- }
  q DEL-CRIT
  data list::free \ !!
  q FREE THROW ;

: put ( x q -- )
  ['] (put) OVER lock @ WITH-CRIT ;

: get { q -- x }
  BEGIN
   BEGIN q avail @ 0 = WHILE 10 PAUSE REPEAT

   q ['] (get) q lock @ WITH-CRIT
  UNTIL ;

: get? { q -- x -1 | 0 } q ['] (get) q lock @ WITH-CRIT ;

\ : clear ;

;MODULE
;MODULE

\EOF

new-q VALUE q
100 q put
200 q put
300 q put

q get?
