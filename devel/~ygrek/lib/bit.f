\ $Id$

REQUIRE B@ ~pinka/lib/ext/basics.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE { lib/ext/locals.f

\ n addr -- адрес отдельного бита в памяти, то есть n-й бит отсчитывая от ячейки памяти addr 
\ n при этом может выходить за границу ячейки

\ this-bit приводит адрес бита к "нормализированному" виду, где координата бита n будет меньше 8-и,
\ и адрес addr выровнен до одного байта
: this-bit ( n addr -- n1 addr1 ) >R 8 /MOD R> + ;
\ : this-bit4 ( n addr -- n1 addr1 ) >R 32 /MOD 4 * R> + ;

\ CREATE _mask 1 B, 2 B, 4 B, 8 B, 16 B, 32 B, 64 B, 128 B,
\ : and-mask1 _mask + B@ ;
: and-mask ( n -- 2^n ) 1 SWAP LSHIFT ;

\ Установить бит с координатами n a в единицу
: :1 ( n a -- ) this-bit >R and-mask R@ @ OR R> ! ;
\ : :1-1 ( n a -- ) this-bit >R and-mask1 R@ @ OR R> ! ;

\ Установить бит с координатами n a в ноль
: :0 ( n a -- ) this-bit >R and-mask INVERT R@ @ AND R> ! ;

: BBIT@ ( n byte -- b ) SWAP RSHIFT 1 AND ;

\ Прочитать значение бита n addr 
: BIT@ ( n addr -- 0|1 ) this-bit @ BBIT@ ;

\ Записать значение бита n addr 
: BIT! ( 0|1 n a -- ) ROT IF :1 ELSE :0 THEN ;

\ ----------------

: (.) S>D (D.) TYPE ;
: ?01 ( ? -- 0|1 ) 0 SWAP - ;

: bits, 8 /MOD SWAP 0 <> ?01 + ALLOT ;

: b: ( "bits" -- num )
   PARSE-NAME
   0 -ROT
   OVER + 1- ?DO
    1 LSHIFT
    I C@ [CHAR] 1 = IF 1 OR THEN
   -1 +LOOP ;

: b- b: B, ;

: BITS. 
   0 DO
    I 8 /MOD SWAP 0= AND IF SPACE THEN
    I OVER BIT@ (.) 
   LOOP DROP ;

: BITS-APPEND { from bits to tbits -- }
   bits 0 DO
    I from BIT@ tbits to BIT!
    tbits 1+ -> tbits
   LOOP ;

: BITS-MOVE ( from to bits -- ) SWAP 0 BITS-APPEND ;

: BITS-EQUAL? { a1 a2 bits -- ? }
   bits 0 ?DO
    I a1 BIT@ I a2 BIT@ <> IF FALSE UNLOOP EXIT THEN
   LOOP TRUE ;

: BITS-CELLS ( n -- bits CELLS ) [ CELL 8 * ] LITERAL /MOD ;

: BITS-XOR { a1 a2 bits a3 -- }
   bits BITS-CELLS 0 DO
    a1 @ a2 @ XOR a3 !
    a1 CELL+ -> a1
    a2 CELL+ -> a2
    a3 CELL+ -> a3
   LOOP 
   ( bits ) 0 ?DO
    I a1 BIT@ I a2 BIT@ XOR I a3 BIT!
   LOOP ;

: BITS-XOR1 { a1 a2 bits a3 -- }
   bits 0 ?DO
    I a1 BIT@ I a2 BIT@ XOR I a3 BIT!
   LOOP ;

: BITS-1LROT { bits addr -- }
   0 addr BIT@
   bits 1 DO I addr BIT@ I 1- addr BIT! LOOP 
   bits 1- addr BIT! ;

: BITS-1RROT { bits addr -- }
   bits 1- addr BIT@
   1 bits 1- DO I 1- addr BIT@ I addr BIT! -1 +LOOP 
   0 addr BIT! ;

: BITS-RROT ( bits addr n -- ) 0 ?DO 2DUP BITS-1RROT LOOP 2DROP ;
: BITS-LROT ( bits addr n -- ) 0 ?DO 2DUP BITS-1LROT LOOP 2DROP ;

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES bits set/get

CREATE b 2 ALLOT

0 b :1
2 b :1
9 b :1

(( 0 b BIT@ -> 1 ))
(( 1 b BIT@ -> 0 ))
(( 2 b BIT@ -> 1 ))
(( 3 b BIT@ -> 0 ))
(( 4 b BIT@ -> 0 ))
(( 5 b BIT@ -> 0 ))
(( 6 b BIT@ -> 0 ))
(( 7 b BIT@ -> 0 ))
(( 8 b BIT@ -> 0 ))
(( 9 b BIT@ -> 1 ))

END-TESTCASES

TESTCASES bits operations
CREATE z b- 01011010
(( 8 z 2 BITS-LROT z B@ -> b: 01101001 ))
(( 8 z 1 BITS-LROT z B@ -> b: 11010010 ))
CREATE a1 b: 010101101001101111011 ,
CREATE a2 b: 010101101001101110011 , 
(( a1 a2 21 BITS-EQUAL? -> FALSE ))
(( a1 a2 18 BITS-EQUAL? -> FALSE ))
(( a1 a2 17 BITS-EQUAL? -> TRUE ))
(( a1 a2 10 BITS-EQUAL? -> TRUE ))
END-TESTCASES

\EOF \ some speed comparison

REQUIRE GENRAND ~ygrek/lib/neilbawd/mersenne.f

WINAPI: GetTickCount KERNEL32.DLL
GetTickCount SGENRAND

: measure 
   GetTickCount >R
   EXECUTE
   GetTickCount R> - ;

: RANDOM-FILL ( addr n -- ) 0 ?DO GENRAND OVER B! LOOP DROP ;

3000003 CONSTANT #N

#N ALLOCATE THROW VALUE in
in #N RANDOM-FILL
#N ALLOCATE THROW VALUE out
:NONAME in in #N 8 * out BITS-XOR1 ; measure CR .
:NONAME in in #N 8 * out BITS-XOR ; measure CR .

\ :NONAME #N 8 * 0 DO I out :1 LOOP ; measure CR .
\ :NONAME #N 8 * 0 DO I out :1-1 LOOP ; measure CR .

