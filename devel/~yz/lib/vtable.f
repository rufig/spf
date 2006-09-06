\ Реализация методов интерфейсов
\ Ю. Жиловец, 22.03.2002

REQUIRE == ~yz/lib/common.f

0
CELL -- :pointer
CELL -- :methods
== #vtable-header

: VTABLE ( ->bl; parent #newmethods -- vtable)
  CREATE HERE >R
  #vtable-header ALLOT
  SWAP ?DUP IF 
    DUP :methods @ CELLS ALLOT
    R@ HERE R@ - CMOVE
  ELSE 
    \ родителей нет
    R@ :methods 0!
  THEN
  R@ #vtable-header + R@ :pointer !
  CELLS ALLOT
  R> ;

: VTABLE; ( vtable -- ) DROP ;

: METHOD ( -- xt) :NONAME ;
: METHOD; ( vtable xt -- vtable)
  S" ;" EVALUATE TASK 
  OVER DUP :methods @ CELLS + #vtable-header + !
  DUP :methods 1+!
; IMMEDIATE

: lookup-inttable ( iid inttable -- intptr/0)
  BEGIN ( iid table ) DUP @ WHILE
    2DUP CELL+ @ guid= IF PRESS @ EXIT THEN 
    2 CELLS+
  REPEAT 2DROP 0
;

: INTTABLE ( -- a; ->bl) HERE ;
: INTTABLE; ( -- ) 0 , ;
: IMPLEMENTS ( int -- ; ->bl )
  , BL PARSE EVALUATE ,
;

: INSTANCE ( _>bl; vtable -- )
  CREATE @ ,
;