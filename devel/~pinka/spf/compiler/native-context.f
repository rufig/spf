\ 01.2008
\ Управление контекстом трансляции,
\ постфиксный и прозрачный по стеку данных аналог MODULE: ... EXPORT ... ;MODULE


REQUIRE >CS ~pinka/spf/compiler/control-stack.f \ управляющий стек


: (NODE-PRECEDING-FROM) ( node1 node9 -- node2|0 ) \ node9--> ... -->node2-->node1
  SWAP >R
  BEGIN DUP WHILE \ ( node4 )
  DUP CDR DUP R@ = IF ( node4 node3 ) DROP RDROP EXIT THEN
  NIP REPEAT RDROP
;
: (CONCAT-WORDLIST) ( node1 node9 wid -- )
  DUP @ >R ! NAME>L R> SWAP !
;
: DISPLACE-SUBWORDLIST ( wid-src node-boundary wid-dst -- )
  >R SWAP
  2DUP @ (NODE-PRECEDING-FROM) DUP 0= IF DROP 2DROP RDROP EXIT THEN
  ( node-boundary wid-src pnode )
  >R DUP @ >R ! \ node-boundary wid-src !  ( R: wid-dst pnode last-node )
  2R> R> (CONCAT-WORDLIST)
;
\ see also: model/data/list-plain.f.xml # DISPLACE-SUBLIST

: PUSH-CURRENT ( wid -- ) 
  GET-CURRENT >CS SET-CURRENT
;
: DROP-CURRENT ( -- ) 
  CS> SET-CURRENT
;
: POP-CURRENT ( -- wid ) 
  CURRENT @ DROP-CURRENT
;
: SCOPE-DEPTH ( -- u )
  CONTEXT S-O - >CELLS
  \ не может быть отрицательным (by design),
  \ поэтому допустимо использовать >CELLS напрямую
;
: PUSH-SCOPE ( wid -- )
  ALSO! \ == ALSO CONTEXT !
;
: POP-SCOPE ( -- wid )
  CONTEXT @ PREVIOUS
;
: DROP-SCOPE ( -- )
  POP-SCOPE DROP
;
: PUSH-DEVELOP ( wid -- )
  GET-CURRENT >CS DUP SET-CURRENT PUSH-SCOPE
;
: POP-DEVELOP ( -- wid )
  POP-SCOPE CS> SET-CURRENT
;
: DROP-DEVELOP ( -- )
  POP-DEVELOP DROP
;
: BEGIN-EXPORT ( -- )
  GET-CURRENT @ >CS
;
: END-EXPORT ( -- )
  GET-CURRENT CS> CS@  DISPLACE-SUBWORDLIST
  [DEFINED] QuickSWL-Support    [IF]
    GET-CURRENT REFRESH-WLCACHE
    CS@         REFRESH-WLCACHE
  [THEN]
;


: PUSH-WARNING ( u -- )
  WARNING @ >CS WARNING !
;
: DROP-WARNING ( -- )
  CS> WARNING !
;
: PUSH-BASE ( u -- )
  BASE @ >CS BASE !
;
: DROP-BASE ( -- )
  CS> BASE !
;


: &  ( c-addr u -- xt )  \ see also ' (tick)
  SFIND IF EXIT THEN -321 THROW
;
: DEFINED ( c-addr u -- xt|0 )
  SFIND IF EXIT THEN 2DROP 0
;


\EOF

\ old ideas:
: DEVELOP ( wid -- ) ( CS: -- wid-prev )
  GET-CURRENT >CS
  ALSO CONTEXT ! DEFINITIONS
;
: FURL ( -- ) ( CS: wid-prev -- )
  PREVIOUS CS> SET-CURRENT
;
