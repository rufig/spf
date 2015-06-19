\ $Id$

REQUIRE [UNDEFINED] lib/include/tools.f

[UNDEFINED] B@ [IF]

: B@ C@ ;
: B! C! ;
: B, C, ;

\ Должно быть, 'B' - byte пересекается по значению с 'B' - bit.
\ Тогда для битов: BIT@ BIT! (?)

\ Также, для байтовых операций было предложенно '8': 8@ 8!
\ но, по моему, этот вариант хуже (и конфликтует с 2@ и 2! )

[THEN]

[UNDEFINED] T@ [IF] \ 'twice word' (double word) -- 32 bits
: T@ @ ;
: T! ! ;
: T, , ;
[THEN]

[UNDEFINED] Q@ [IF] \ 'quadro' (quadruple word) -- 64 bits
: Q@ 2@ SWAP ;      \ старшая часть по старшему адресу
: Q! >R SWAP R> 2! ;
: Q, SWAP , , ;
[THEN] \ see also: http://en.wikipedia.org/wiki/Double_word#Dword_and_Qword

\ O@ O! O, -- octuple word -- 128 bits

REQUIRE NDROP   ~pinka/lib/ext/common.f

[UNDEFINED] /CELL [IF]
1 CELLS CONSTANT /CELL [THEN]

[UNDEFINED] /CHAR [IF]
1 CHARS CONSTANT /CHAR [THEN]


REQUIRE EQUAL   ~pinka/spf/string-equal.f


[UNDEFINED] CELL-! [IF]
: CELL-! ( a -- ) -1 CELLS SWAP +! ; [THEN]

[UNDEFINED] CELL+! [IF]
: CELL+! ( a -- ) 1 CELLS SWAP +! ; [THEN]

[UNDEFINED] 1+! [IF]
: 1+! ( a -- )  1 SWAP +! ; [THEN]

[UNDEFINED] 1-! [IF]
: 1-! ( a -- ) -1 SWAP +! ; [THEN]

[UNDEFINED] -! [IF]
: -! ( x a -- ) >R NEGATE R> +! ; [THEN]

[UNDEFINED] UM+ [IF]
: UM+ ( u1 u2 -- u3 c3 ) 0 SWAP 0 D+ ; [THEN]


[UNDEFINED] ALLOCATED [IF]
: ALLOCATED ( u -- a u ) DUP ALLOCATE THROW (FIX-MEMTAG) SWAP ;
: RESIZED ( addr1 u -- addr2 u ) DUP >R RESIZE THROW R> ;
: FREE-SURE ( a|0 -- ) DUP IF FREE THROW EXIT THEN DROP ;
[THEN]

[UNDEFINED] ALSO! [IF]
: ALSO! ( wid -- ) ALSO CONTEXT ! ; [THEN]


[UNDEFINED] DtoS [IF]
: DtoS ( d -- addr1 u1 )  (D.) ;
: NtoS ( n -- addr1 u1 )  S>D (D.) ;
: UtoS ( u -- addr1 u1 )  U>D (D.) ;
[THEN]

[UNDEFINED] 2NIP [IF]
: 2NIP ( d-x2 d-x1 -- d-x1 ) 2SWAP 2DROP ;
[THEN]

[UNDEFINED] 3DUP [IF]
: 3DUP ( x1 x2 x3 -- x1 x2 x3  x1 x2 x3 ) 2 PICK 2 PICK 2 PICK ;
[THEN]

[UNDEFINED] lexicon.basics-aligned [IF]
TRUE CONSTANT lexicon.basics-aligned [THEN]
