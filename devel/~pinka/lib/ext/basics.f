\ $Id$

REQUIRE [UNDEFINED] lib/include/tools.f

[UNDEFINED] B@ [IF]

: B@ C@ ;
: B! C! ;
: B, C, ;

\ ������ ����, 'B' - byte ������������ �� �������� � 'B' - bit.
\ ����� ��� �����: BIT@ BIT! (?)

\ �����, ��� �������� �������� ���� ����������� '8': 8@ 8!
\ ��, �� �����, ���� ������� ����.

[THEN]

[UNDEFINED] L@ [IF] \ 'long' (double word) -- 4 bytes -- 32 bits
: L@ @ ;
: L! ! ;
: L, , ;
[THEN]

[UNDEFINED] Q@ [IF] \ 'quadro' (quadruple word) -- 8 bytes -- 64 bits
: Q@ 2@ SWAP ;      \ ������� ����� �� �������� ������
: Q! >R SWAP R> 2! ;
: Q, SWAP , , ;
[THEN] \ see also: http://en.wikipedia.org/wiki/Double_word#Dword_and_Qword


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


[UNDEFINED] ALLOCATED [IF]
: ALLOCATED ( u -- a u ) DUP ALLOCATE THROW SWAP ;
: FREE-FORCE ( a|0 -- ) DUP IF FREE THROW EXIT THEN DROP ;
[THEN]

[UNDEFINED] ALSO! [IF]
: ALSO! ( wid -- ) ALSO CONTEXT ! ; [THEN]


[UNDEFINED] DtoS [IF]
: DtoS ( d -- addr1 u1 )  (D.) ;
: NtoS ( n -- addr1 u1 )  S>D (D.) ;
: UtoS ( u -- addr1 u1 )  U>D (D.) ;
[THEN]

[UNDEFINED] 3DUP [IF]
: 3DUP ( x1 x2 x3 -- x1 x2 x3  x1 x2 x3 ) 2 PICK 2 PICK 2 PICK ;
[THEN]

[UNDEFINED] lexicon.basics-aligned [IF]
TRUE CONSTANT lexicon.basics-aligned [THEN]
