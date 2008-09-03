\ 01.2008
\ ”правление контекстом трансл€ции,
\ постфиксный и прозрачный по стеку данных аналог MODULE: ... EXPORT ... ;MODULE

REQUIRE Require   ~pinka/lib/ext/requ.f

Require >CS control-stack.f \ управл€ющий стек


: PARENT-NODE-FROM ( node1 node9 -- node2|0 ) \ node2-->node1
  SWAP >R
  BEGIN DUP WHILE \ ( node4 )
  DUP CDR DUP R@ = IF ( node4 node3 ) DROP RDROP EXIT THEN
  NIP REPEAT RDROP
;
: FIND-PARENT-NODE ( node1 node9 -- node2 true | node1 falst ) \ node2-->node1
  OVER >R PARENT-NODE-FROM DUP IF RDROP TRUE EXIT THEN
  DROP R> FALSE
;
: (CONCAT-WORDLIST) ( node1 node9 wid -- )
  DUP @ >R ! NAME>L R> SWAP !
;

: PUSH-CURRENT ( wid -- ) 
  GET-CURRENT >CS SET-CURRENT
;
: DROP-CURRENT ( -- ) 
  CS> SET-CURRENT
;
: POP-CURRENT ( -- wid ) 
  CURRENT @ DROP-CURRENT
;

: PUSH-SCOPE ( wid -- )
  ALSO CONTEXT !
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
  CS> GET-CURRENT 2DUP @ FIND-PARENT-NODE 0= IF DROP 2DROP EXIT THEN
  ( node wid-current  pnode )
  GET-CURRENT @ CS@ (CONCAT-WORDLIST)
  ( node wid-current ) !
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

\EOF

\ old ideas:
: DEVELOP ( wid -- ) ( CS: -- wid-prev )
  GET-CURRENT >CS
  ALSO CONTEXT ! DEFINITIONS
;
: FURL ( -- ) ( CS: wid-prev -- )
  PREVIOUS CS> SET-CURRENT
;
