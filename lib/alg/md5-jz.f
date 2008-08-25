REQUIRE [DEFINED]  lib/include/tools.f
REQUIRE ms@ lib/include/facil.f

HERE 

MODULE: MD5-MODULE

0 [IF]

OK, I'll get into this .. :-)

This is my VERY 1ST CUT, which just refactors the original code.
I keep the basic concept intact, but code it more efficiently.
I do this by eliminating the FF()..II() words, which primarily
do stack management, and then create M[]+. Then I perform each
sub-round as the algorithm literally describes. I also made two
versions: one that compiles F()..I(), M[]+ as standard colon
defined words, and a second version which compiles them as
MACROS, which SwiftForth will inline compile directly.

The colon word compiled version runs about 17% faster than the
original code, and the MACRO version is about 27% faster on my
machine (600 MHz K-7 w/PC100 SDRAM) and SwiftForth V 2.00.3.
But since this is ANS FORTH code, which I also verifed runs on
Win32Forth, it will run on any ANS FORTH system.

The really nice aspect of the origal design model, which I tried
to impove on, is that I think (at this point) that it is the
"best approach" to structure the problem, by using the stack to
hold the hash values A - D.  The modified refactoring I've done
makes a Pentium optimized version a breeze to do as it is modeled
right now, but I think I can get even better modeling efficiences
by taking the approach I did for SHA-1 optimization.  Stay tuned..

If someone (Marcel ??) could post the test suite you are using to
get the times I see being posted I will run it with those tests,
and/or people (Marcel) can take my code and just run a version of
the test with it. Everthing in the original code has remained the
same (except I did change the name of 'lroll' to 'rol') so it
should be an easy mod.


Jabar1 Zakiya

[THEN]

\ MD5 routine in ANS FORTH
\ Original code posted by Frederick W. Warren 02Nov2000
\ in comp.lang.forth.
\ Modified by Jabari Zakiya 14Dec2000 (jzakiya@mail.com)
\ Verifed in Win32Forth and SwiftForth (speed tested also).

VARIABLE A   VARIABLE B   VARIABLE C   VARIABLE D
1 A !  \  FOR ENDIAN TESTING

VARIABLE MD5LEN

CREATE BUF[] 64 ALLOT
CREATE PART[] 64 ALLOT
CREATE MD5PAD 64 ALLOT  MD5PAD 64 0 FILL  128 MD5PAD C!

4096 ALLOT

: ROL ( N1 S1 -- RES ) \ ROLL LEFT WITH C/O TO BIT 0
  2DUP 32 SWAP - RSHIFT  ROT ROT LSHIFT OR ;

A C@ [IF] \ IF LITTLE ENDIAN CPU
: ENDIAN@  ( A1 - N1 )  S" @" EVALUATE ; IMMEDIATE
: ENDIAN!  ( N A1 -- )  S" !" EVALUATE ; IMMEDIATE

[ELSE] \ BIG ENDIAN CPUS (E.G. MACS)
: ENDIAN  ( A1 -- N1 )
  >R  R@  3  +  C@  8 LSHIFT R@  2  +  C@  +  8 LSHIFT
  R@  1+  C@  +  8 LSHIFT  R>  C@  +
;

: ENDIAN!  ( N1 A1 - )
  >R  256 /MOD  SWAP  R@  C!  256 /MOD  SWAP  R@  1+  C!
  256 /MOD  SWAP  R@  2  +  C!  3  +  C!
;
[THEN]

1 [IF]  \ COMPILE COLON DEFINED WORDS

: F() ( N1 N2 N3 -- N4 )
 ROT DUP INVERT ROT AND ROT ROT AND OR ;

: G() ( N1 N2 N3 -- N4 )
  SWAP OVER INVERT AND ROT ROT AND OR ;

: H() ( N1 N2 N3 -- N4 )  XOR XOR ;

: I() ( N1 N2 N3 -- N4 )  INVERT ROT OR XOR ;

: M[]+ ( X I -- N )  CELLS BUF[] + ENDIAN@ + ;

[ELSE]  \ COMPILE FUNCTIONS AS MACROS

: F() ( N1 N2 N3 -- N4 )
  S" ROT DUP INVERT ROT AND ROT ROT AND OR " EVALUATE ; IMMEDIATE

: G() ( N1 N2 N3 -- N4 )
  S" SWAP OVER INVERT AND ROT ROT AND OR "  EVALUATE  ; IMMEDIATE

: H() ( N1 N2 N3 -- N4 )  S" XOR XOR" EVALUATE ; IMMEDIATE

: I() ( N1 N2 N3 -- N4 )  S" INVERT ROT OR XOR" EVALUATE ; IMMEDIATE

: M[]+ ( X I -- N )  S" CELLS BUF[] + ENDIAN@ + " EVALUATE ; IMMEDIATE
[THEN]

HEX

: ROUND1 ( -- )
  B @ A @ OVER C @ D @ F() + 0D76AA478 + 00 M[]+ 07 ROL + A ! \ 1
  A @ D @ OVER B @ C @ F() + 0E8C7B756 + 01 M[]+ 0C ROL + D ! \ 2
  D @ C @ OVER A @ B @ F() + 0242070DB + 02 M[]+ 11 ROL + C ! \ 3
  C @ B @ OVER D @ A @ F() + 0C1BDCEEE + 03 M[]+ 16 ROL + B ! \ 4
  B @ A @ OVER C @ D @ F() + 0F57C0FAF + 04 M[]+ 07 ROL + A ! \ 5
  A @ D @ OVER B @ C @ F() + 04787C62A + 05 M[]+ 0C ROL + D ! \ 6
  D @ C @ OVER A @ B @ F() + 0A8304613 + 06 M[]+ 11 ROL + C ! \ 7
  C @ B @ OVER D @ A @ F() + 0FD469501 + 07 M[]+ 16 ROL + B ! \ 8
  B @ A @ OVER C @ D @ F() + 0698098D8 + 08 M[]+ 07 ROL + A ! \ 9
  A @ D @ OVER B @ C @ F() + 08B44F7AF + 09 M[]+ 0C ROL + D ! \ 10
  D @ C @ OVER A @ B @ F() + 0FFFF5BB1 + 0A M[]+ 11 ROL + C ! \ 11
  C @ B @ OVER D @ A @ F() + 0895CD7BE + 0B M[]+ 16 ROL + B ! \ 12
  B @ A @ OVER C @ D @ F() + 06B901122 + 0C M[]+ 07 ROL + A ! \ 13
  A @ D @ OVER B @ C @ F() + 0FD987193 + 0D M[]+ 0C ROL + D ! \ 14
  D @ C @ OVER A @ B @ F() + 0A679438E + 0E M[]+ 11 ROL + C ! \ 15
  C @ B @ OVER D @ A @ F() + 049B40821 + 0F M[]+ 16 ROL + B ! \ 16
;

: ROUND2 ( -- )
  B @ A @ OVER C @ D @ G() + 0F61E2562 + 01 M[]+ 05 ROL + A ! \ 1
  A @ D @ OVER B @ C @ G() + 0C040B340 + 06 M[]+ 09 ROL + D ! \ 2
  D @ C @ OVER A @ B @ G() + 0265E5A51 + 0B M[]+ 0E ROL + C ! \ 3
  C @ B @ OVER D @ A @ G() + 0E9B6C7AA + 00 M[]+ 14 ROL + B ! \ 4
  B @ A @ OVER C @ D @ G() + 0D62F105D + 05 M[]+ 05 ROL + A ! \ 5
  A @ D @ OVER B @ C @ G() +  02441453 + 0A M[]+ 09 ROL + D ! \ 6
  D @ C @ OVER A @ B @ G() + 0D8A1E681 + 0F M[]+ 0E ROL + C ! \ 7
  C @ B @ OVER D @ A @ G() + 0E7D3FBC8 + 04 M[]+ 14 ROL + B ! \ 8
  B @ A @ OVER C @ D @ G() + 021E1CDE6 + 09 M[]+ 05 ROL + A ! \ 9
  A @ D @ OVER B @ C @ G() + 0C33707D6 + 0E M[]+ 09 ROL + D ! \ 10
  D @ C @ OVER A @ B @ G() + 0F4D50D87 + 03 M[]+ 0E ROL + C ! \ 11
  C @ B @ OVER D @ A @ G() + 0455A14ED + 08 M[]+ 14 ROL + B ! \ 12
  B @ A @ OVER C @ D @ G() + 0A9E3E905 + 0D M[]+ 05 ROL + A ! \ 13
  A @ D @ OVER B @ C @ G() + 0FCEFA3F8 + 02 M[]+ 09 ROL + D ! \ 14
  D @ C @ OVER A @ B @ G() + 0676F02D9 + 07 M[]+ 0E ROL + C ! \ 15
  C @ B @ OVER D @ A @ G() + 08D2A4C8A + 0C M[]+ 14 ROL + B ! \ 16
;

: ROUND3 ( -- )
  B @ A @ OVER C @ D @ H() + 0FFFA3942 + 05 M[]+ 04 ROL + A ! \ 1
  A @ D @ OVER B @ C @ H() + 08771F681 + 08 M[]+ 0B ROL + D ! \ 2
  D @ C @ OVER A @ B @ H() + 06D9D6122 + 0B M[]+ 10 ROL + C ! \ 3
  C @ B @ OVER D @ A @ H() + 0FDE5380C + 0E M[]+ 17 ROL + B ! \ 4
  B @ A @ OVER C @ D @ H() + 0A4BEEA44 + 01 M[]+ 04 ROL + A ! \ 5
  A @ D @ OVER B @ C @ H() + 04BDECFA9 + 04 M[]+ 0B ROL + D ! \ 6
  D @ C @ OVER A @ B @ H() + 0F6BB4B60 + 07 M[]+ 10 ROL + C ! \ 7
  C @ B @ OVER D @ A @ H() + 0BEBFBC70 + 0A M[]+ 17 ROL + B ! \ 8
  B @ A @ OVER C @ D @ H() + 0289B7EC6 + 0D M[]+ 04 ROL + A ! \ 9
  A @ D @ OVER B @ C @ H() + 0EAA127FA + 00 M[]+ 0B ROL + D ! \ 10
  D @ C @ OVER A @ B @ H() + 0D4EF3085 + 03 M[]+ 10 ROL + C ! \ 11
  C @ B @ OVER D @ A @ H() +  04881D05 + 06 M[]+ 17 ROL + B ! \ 12
  B @ A @ OVER C @ D @ H() + 0D9D4D039 + 09 M[]+ 04 ROL + A ! \ 13
  A @ D @ OVER B @ C @ H() + 0E6DB99E5 + 0C M[]+ 0B ROL + D ! \ 14
  D @ C @ OVER A @ B @ H() + 01FA27CF8 + 0F M[]+ 10 ROL + C ! \ 15
  C @ B @ OVER D @ A @ H() + 0C4AC5665 + 02 M[]+ 17 ROL + B ! \ 16
;

: ROUND4 ( -- )
  B @ A @ OVER C @ D @ I() + 0F4292244 + 00 M[]+ 06 ROL + A ! \ 1
  A @ D @ OVER B @ C @ I() + 0432AFF97 + 07 M[]+ 0A ROL + D ! \ 2
  D @ C @ OVER A @ B @ I() + 0AB9423A7 + 0E M[]+ 0F ROL + C ! \ 3
  C @ B @ OVER D @ A @ I() + 0FC93A039 + 05 M[]+ 15 ROL + B ! \ 4
  B @ A @ OVER C @ D @ I() + 0655B59C3 + 0C M[]+ 06 ROL + A ! \ 5
  A @ D @ OVER B @ C @ I() + 08F0CCC92 + 03 M[]+ 0A ROL + D ! \ 6
  D @ C @ OVER A @ B @ I() + 0FFEFF47D + 0A M[]+ 0F ROL + C ! \ 7
  C @ B @ OVER D @ A @ I() + 085845DD1 + 01 M[]+ 15 ROL + B ! \ 8
  B @ A @ OVER C @ D @ I() + 06FA87E4F + 08 M[]+ 06 ROL + A ! \ 9
  A @ D @ OVER B @ C @ I() + 0FE2CE6E0 + 0F M[]+ 0A ROL + D ! \ 10
  D @ C @ OVER A @ B @ I() + 0A3014314 + 06 M[]+ 0F ROL + C ! \ 11
  C @ B @ OVER D @ A @ I() + 04E0811A1 + 0D M[]+ 15 ROL + B ! \ 12
  B @ A @ OVER C @ D @ I() + 0F7537E82 + 04 M[]+ 06 ROL + A ! \ 13
  A @ D @ OVER B @ C @ I() + 0BD3AF235 + 0B M[]+ 0A ROL + D ! \ 14
  D @ C @ OVER A @ B @ I() + 02AD7D2BB + 02 M[]+ 0F ROL + C ! \ 15
  C @ B @ OVER D @ A @ I() + 0EB86D391 + 09 M[]+ 15 ROL + B ! \ 16
;

DECIMAL
: TRANSFORM ( -- )
  A @ B @  C @ D @  ROUND1 ROUND2 ROUND3 ROUND4
  D @ + D !   C @ + C !   B @ + B !   A @ + A !
;
 HEX
: MD5INT ( -- )
  067452301 A !  0EFCDAB89 B !
  098BADCFE C !  010325476 D !
  0 MD5LEN !  ;
DECIMAL

-1 VALUE MD5INT?

: SETLEN ( COUNT -- )
  MD5LEN @ 8 M*  BUF[] 60 + ! BUF[] 56 + ! ;

\ DO ALL 64 BYTE BLOCKS LEAVING REMAINDER BLOCK
: DOFULLBLOCKS ( ADR1 COUNT1 --  ADR2 COUNT2 )
  BEGIN  DUP 63 >
  WHILE  64 - SWAP DUP BUF[] 64 CMOVE
         64 + SWAP TRANSFORM
  REPEAT ;

: MOVEPARTIAL ( ADDR COUNT -- )
  SWAP OVER BUF[] SWAP CMOVE
  MD5PAD OVER BUF[] + ROT 64 SWAP - CMOVE ;

: DOFINAL ( ADDR COUNT -- )
  2DUP MOVEPARTIAL DUP 55 >
  IF  TRANSFORM  BUF[] 64 0 FILL THEN
  2DROP SETLEN TRANSFORM  ;

\ COMPUTE MD5 FROM A COUNTED BUFFER OF TEXT
: MD5FULL ( ADDR COUNT -- )
  MD5INT DUP MD5LEN +!  DOFULLBLOCKS DOFINAL ;

: SAVEPART ( ADR COUNT -- )
  MD5LEN @ 64 MOD IF  PART[] SWAP CMOVE  ELSE  2DROP  THEN  ;

: MOVEPART ( ADR1 COUNT1 PARTINDEX -- ADR2 COUNT2 ) \ ADD TO PART[]
  2DUP 64 SWAP - MIN >R  PART[] + >R OVER R> R@ CMOVE
  SWAP R@ + SWAP R> - ;

: MD5UPDATE ( ADR COUNT -- )
  MD5INT? IF MD5INT FALSE TO MD5INT? THEN
  MD5LEN @ 64 MOD OVER MD5LEN +! ( ADR COUNT PARTINDEX -- )
  DUP IF    2DUP + 63 >
            IF    MOVEPART PART[] 64 DOFULLBLOCKS  DOFULLBLOCKS
                  SAVEPART CR
            ELSE  MOVEPART 2DROP THEN
      ELSE  DROP DOFULLBLOCKS SAVEPART THEN ;

: MD5FINAL ( ADR COUNT -- )
  MD5INT? IF MD5INT FALSE TO MD5INT? THEN
  MD5LEN @ 64 MOD OVER MD5LEN +! ( ADR COUNT PARTINDEX -- )
  DUP IF    2DUP + 63 >

            IF    MOVEPART PART[] 64 DOFULLBLOCKS  DOFULLBLOCKS
                  DOFINAL
            ELSE  MOVEPART 2DROP PART[] MD5LEN @ 64 MOD DOFINAL THEN
      ELSE  DROP
  DOFULLBLOCKS DOFINAL THEN ;

 \ FUNCTIONS FOR CREATING OUTPUT STRING
CREATE DIGIT$
  48 C, 49 C, 50 C, 51 C, 52 C, 53 C, 54 C, 55 C, 56 C, 57 C,
  97 C, 98 C, 99 C, 100 C, 101 C, 102 C,

: INTDIGITS ( -- )  0 PAD ! ;

\ OUTPUT DIGIT AT PAD
: SAVEDIGIT ( N -- )  PAD C@ 1+ DUP PAD C! PAD + C! ;

: BYTEDIGITS ( N1 -- )
  DUP 4 RSHIFT DIGIT$ + C@ SAVEDIGIT  15 AND DIGIT$ + C@ SAVEDIGIT ;

A C@ [IF] \ LITTLE ENDIAN
: CELLDIGITS ( A1 -- )  DUP 4 + SWAP DO I C@ BYTEDIGITS LOOP ;
[ELSE]
: CELLDIGITS ( A1 -- )  DUP 3 + DO I C@ BYTEDIGITS -1  +LOOP ;
[THEN]

: MD5STRING ( -- ADR COUNT ) \ RETURN ADDRESS OF COUNTED MD5 STRING
  INTDIGITS A CELLDIGITS B CELLDIGITS C CELLDIGITS D CELLDIGITS PAD
  COUNT TRUE TO MD5INT? ;


EXPORT

: MD5 ( a u -- a1 u2 ) MD5FULL MD5STRING ;

1024 VALUE MD5BUFSIZE

: MD5FILE ( a u -- a1 u2 )
  MD5BUFSIZE ALLOCATE THROW >R
  R/O OPEN-FILE-SHARED 0=
  IF  BEGIN  DUP R@ MD5BUFSIZE ROT READ-FILE DROP DUP MD5BUFSIZE =
      WHILE  R@ SWAP MD5UPDATE
      REPEAT R@ SWAP MD5FINAL
      CLOSE-FILE DROP MD5STRING
  ELSE S" "
  THEN 
  R> FREE THROW
;

;MODULE

.( Size of MD5-JZ is ) HERE SWAP - . CR

\ \EOF

\ TEST SUITE
ALSO MD5-MODULE
: QUOTESTRING ( ADR COUNT -- )
  34 EMIT TYPE  34 EMIT ;

: .MD5 ( ADR COUNT -- )
  CR CR 2DUP MD5 TYPE SPACE QUOTESTRING ;

: md5-jz.f ( -- )
  S" md5-jz.f" R/O OPEN-FILE 0=
  IF  BEGIN  DUP PAD 1024 ROT READ-FILE DROP DUP 1024 =
      WHILE  PAD SWAP MD5UPDATE
      REPEAT PAD SWAP MD5FINAL
      CLOSE-FILE DROP CR CR MD5STRING TYPE ."  md5-jz.f"
  ELSE DROP
  THEN ;

: MD5TEST ( -- )
  ." MD5 TEST SUITE RESULTS:"
  S" "  .MD5
  S" A" .MD5
  S" ABC" .MD5
  S" ABCDEFGHIJKLMNOPQRSTUVWXYZ" .MD5
  S" ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
.MD5
  S" 12345678901234567890123456789012345678901234567890123456789012345678901234567890"
  .MD5
  md5-jz.f CR CR ;

\ SPF SPECIFIC PERFORMANCE TEST
 
100000 VALUE N#

: UTIMER
  ms@ SWAP - .
;

: [TEST]  S" ABCDEFGHIJKLMNOPQRSTUVWXYZ" MD5FULL ;
: TEST  [ DECIMAL ]
  CR ." md5 test for " N# . ." loops in milliseconds is "
  ms@  N# 0 DO [TEST] LOOP  UTIMER
;

PREVIOUS

