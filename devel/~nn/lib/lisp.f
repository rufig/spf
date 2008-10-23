\ LIST Processing
REQUIRE AddNode ~nn/lib/list.f
REQUIRE ICOMPARE ~nn/lib/wcmatch.f
REQUIRE S>ZALLOC ~nn/lib/az.f
REQUIRE [NONAME ~nn/lib/noname.f

: cons ( n1 n2 -- a)
    2 CELLS ALLOCATE THROW >R
    R@ CELL+ !
    R@ ! R> ;

: AddPair ( n1 n2 list -- ) >R cons R> AddNode ;
: AppendPair ( n1 n2 list -- ) >R cons R> AppendNode ;

: FindProp ( a u list -- node )
    BEGIN @ ?DUP WHILE
       >R 2DUP R@ NodeValue @AZ ICOMPARE 0=
       IF 2DROP R> EXIT THEN
       R>
    REPEAT
    2DROP 0
;

: SetProp ( a1 u1 a2 u2 list -- )
    >R
    2SWAP 2DUP R@ FindProp ?DUP
    IF NodeValue DUP CELL+ @ FREE DROP
       >R 2DROP S>ZALLOC R> CELL+ !
    ELSE
        S>ZALLOC >R S>ZALLOC R> SWAP R@ AppendPair
    THEN
    RDROP ;

: GetProp ( a1 u1 list -- a2 u2 ) 
    FindProp ?DUP
    IF NodeValue CELL+ @ ASCIIZ> ELSE S" " THEN
;

: DelProp ( a1 u1 list -- )
    DUP >R FindProp ?DUP
    IF R@ DelNode THEN
    RDROP
;

: FreePairList ( list -- )
    >R
    [NONAME 
        NodeValue FREE DROP
    NONAME] R@ DoList
    R> FreeList
;

\EOF 
VARIABLE l
\ REQUIRE [NONAME ~nn/lib/noname.f

: .l
    [NONAME
        NodeValue DUP @ ASCIIZ> TYPE ." ="
        CELL+ @ ASCIIZ> TYPE CR
    NONAME] l DoList
;
: test
    S" Вес" S" 70" l SetProp
    S" Рост" S" 176" l SetProp
    .l
    S" Вес" l GetProp TYPE CR CR
    S" Вес" S" 65" l SetProp
    S" Вес" l GetProp TYPE CR CR
    .l
    S" " l GetProp TYPE CR CR
;

test
