\ $Id$
\ Multithreaded queue
\ Not compatible with per-thread heaps (default on SPF/Win32)

REQUIRE ENTER-CRIT ~ygrek/lib/sys/critical.f
REQUIRE { lib/ext/locals.f
REQUIRE list ~ygrek/lib/list/core.f
REQUIRE /TEST ~profit/lib/testing.f

\ multi-threaded queue
MODULE: mtq

MODULE: detail

0
CELL -- lock
CELL -- avail \ TODO: event
CELL -- data
CELL -- last \ last node in data
CONSTANT /Q

{{ list
: (put) { x q -- }
  x () cons ( l )
  q data @ empty?
  IF
    DUP q data ! q last !
  ELSE
    q last @ OVER LINK-NODE ( l ) q last !
  THEN
  TRUE q avail ! 
  ;

: (get) ( q -- x -1 | 0 ) 
   { q | l }
   q data @ -> l
   l list::empty? IF FALSE EXIT THEN
   l car
   l cdr l FREE-NODE -> l
   l q data !
   l empty? 0= q avail !

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
   BEGIN q avail @ 0 = WHILE 10 PAUSE REPEAT \ TODO: wait on event here

   q ['] (get) q lock @ WITH-CRIT
  UNTIL ;

: get? { q -- x -1 | 0 } q ['] (get) q lock @ WITH-CRIT ;

\ ~pinka/lib/lambda.f
\ : size ( q -- n ) LAMBDA{ data @ list::length } OVER lock @ WITH-CRIT ;

\ : clear ;

;MODULE
;MODULE

/TEST

REQUIRE HEAP-GLOBAL ~pinka/spf/mem.f
HEAP-ID
HEAP-GLOBAL \ need global heap for this lib to work correctly

ALSO mtq

new VALUE q

:NONAME HEAP-GLOBAL 10 0 ?DO DUP I + q put 1 PAUSE LOOP DROP ; TASK: producer
:NONAME HEAP-GLOBAL DROP BEGIN q get . AGAIN ; TASK: consumer

100 producer START DROP
200 producer START DROP
300 producer START DROP
\ q size .

0 consumer START DROP

HEAP-ID! \ restore THREAD-HEAP (or crash in RECEIVE-WITH-XT on SPF/Win32)
