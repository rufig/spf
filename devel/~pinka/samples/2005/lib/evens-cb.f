\ 21.Dec.2005 Wed 11:44 -- events callback management
\ $Id$

REQUIRE HEAP-ID! ~pinka\spf\mem.f
REQUIRE WITH-HEAP ~pinka\samples\2005\ext\mem.f 

REQUIRE HASH@ ~pinka\lib\hash-table.f
REQUIRE /CELL ~pinka\samples\2005\ext\size.f

MODULE: EventsCbSupport

0 VALUE events-table
0 VALUE heap

512 VALUE spread-cells

: 0events
  HEAP-ID DUP 0= IF DROP GetProcessHeap THEN TO heap
  spread-cells new-hash TO events-table
;
\ : 9events ;

..: AT-PROCESS-STARTING  0events ;..
0events

: xt-key ( xt -- xt a u )
  SP@ /CELL
;
: event-h ( a u -- h true | false )
  events-table HASH@N
;
: _new-event ( a u -- h )
  small-hash DUP >R -ROT events-table HASH!N R>
;
: new-event ( a u -- h )
  ['] _new-event heap WITH-HEAP
;
: event-h-force ( a u -- h )
  2DUP event-h IF NIP NIP EXIT THEN new-event
;
: _attachEvent ( xt id-a id-u -- )
  event-h-force >R xt-key R> HASH!N
;
: _detachEvent ( xt id-a id-u -- )
  event-h IF >R xt-key R> -HASH DROP THEN
;
: (fireEvent) ( a|value  akey ukey -- )
  2DROP EXECUTE
;

EXPORT

: attachEvent ( xt id-a id-u -- )
  ['] _attachEvent heap WITH-HEAP
;
: detachEvent ( xt id-a id-u -- )
  ['] _detachEvent heap WITH-HEAP
;
: callEvent ( id-a id-u -- true|false )
  events-table HASH@N IF ['] (fireEvent) for-hash TRUE EXIT THEN FALSE
;
: fireEvent ( id-a id-u -- )
  callEvent DROP
;

\ ' MyCallBack  S" onLoad" AttachEvent

;MODULE
