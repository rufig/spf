\ ~day 20.Feb.2001
\ Run Length Encoding, PalmOS format
\ DragonFly project
\ (0x80 + n)   b_0 ... b_n n+1 bytes of literal data (n <= 127) 
\ (0x40 + n)   n+1 repetitions of 0x00 (n <= 63) 
\ (0x20 + n)   b n+2 repetitions of b (n <= 31) 
\ (0x10 + n)   n+1 repetitions of 0xFF (n <= 15) 
\  0x00        end compressed data 

USER rle.pbData
USER rle.pbComp
USER rle.cbData
USER DbPtr

: DBC! ( c offs )
    C!
\   SWAP tmpw C! DbPtr @ SWAP
\   tmpw >abs 1 DmWrite THROW
;

: Next@
   rle.pbData @ C@
;

: Next+@
   rle.pbData @ + C@
;

: IncCounts
   DUP rle.pbData +!
   NEGATE rle.cbData +!
;

: Pack10
   0
   BEGIN
     DUP Next+@ 0xFF =
     OVER 16 < AND
     OVER rle.cbData @ < AND
   WHILE
     1+ 
   REPEAT DUP 1- 0x10 +
   rle.pbComp @ DBC!
   rle.pbComp 1+!
   IncCounts
;

: Pack20
   Next@ >R \ данный символ
   0
   BEGIN
     DUP Next+@ R@ =
     OVER 32 < AND
     OVER rle.cbData @ < AND
   WHILE
     1+
   REPEAT DUP 2- 0x20 +
   rle.pbComp @ DBC!
   R> rle.pbComp @ 1+ DBC!
   2 rle.pbComp +!
   IncCounts
;

: Pack40 ( -- )
   0
   BEGIN
     DUP Next+@ 0=
     OVER 64 < AND
     OVER rle.cbData @ < AND
   WHILE
     1+ 
   REPEAT DUP 1- 0x40 +
   rle.pbComp @ DBC!
   rle.pbComp 1+!
   IncCounts
;

: Pack00orFF ( -- f )
   Next@
   DUP 0= IF DROP 0x40
             rle.pbComp @ DBC!
             1 IncCounts 
             rle.pbComp 1+!
             -1 EXIT
          ELSE
             0xFF = IF 0x10
             rle.pbComp @ DBC!
             1 IncCounts 
             rle.pbComp 1+!
             -1 EXIT
                    THEN
          THEN 0
;

: Pack80
   1 Next+@ DUP 0= SWAP 0xFF = OR
   IF 0x80 rle.pbComp @ DBC!
      Next@ rle.pbComp @ 1+ DBC!
      1 IncCounts 
      2 rle.pbComp +!
      EXIT
   THEN
   Next@ DUP >R
   rle.pbComp @ TUCK 1+ DBC!
   1 \ первый байт уже отправили
   BEGIN           
     DUP Next+@  
     R> OVER >R <>
     R@ 0 <> AND
     R@ 0xFF <> AND
     OVER 128 < AND
     OVER rle.cbData @ < AND
   WHILE
     1+ DUP
     rle.pbComp @ +
     R@ SWAP DBC! 
   REPEAT DUP 2- 0x80 +
   ROT DBC! RDROP
   DUP rle.pbComp +!
   1- IncCounts
;

: PackLast
   Pack00orFF IF EXIT THEN
   rle.pbComp @ DUP
   0x80 SWAP DBC! 1+
   Next@ SWAP DBC!
    2 rle.pbComp +!
   -1 rle.cbData +!
;

: PackRep ( -- )
   rle.cbData @ 1 = IF PackLast EXIT THEN
   Next@ 
   DUP 0= IF DROP Pack40 EXIT THEN
   DUP 0xFF = IF DROP Pack10 EXIT THEN
   1 Next+@
   = IF Pack20 
     ELSE Pack80
     THEN
;

: CompressRle ( addr addr1 u -- u1 )
   rle.cbData !
   DUP >R
   rle.pbComp !
   rle.pbData !
   BEGIN
     rle.cbData @
   WHILE
     PackRep
   REPEAT rle.pbComp @ R> - 1+
   0 rle.pbComp @ DBC!
;

\EOF
(
STARTLOG
HEX 

\ 80 71 40 10
CREATE from 1C C, 8A C, 71 C, FF C, 0D C, 00 C, 36 C, 2A C,
CREATE to 10 ALLOT

from to 8 CompressRle DUP . to SWAP DUMP



\EOF        )

lib\ext\locals.f

: test { \ b h s outb outf }
  S" data.rnd" R/O OPEN-FILE THROW
  DUP TO h FILE-SIZE THROW DROP TO s
  s ALLOCATE THROW TO b
  b s h READ-FILE THROW DROP
  s DUP 6 / + ALLOCATE THROW TO outb
  b outb s CompressRle
  S" packed.rnd" W/O CREATE-FILE THROW TO outf
  outb SWAP outf WRITE-FILE THROW
  h CLOSE-FILE THROW
  outf CLOSE-FILE THROW
  b FREE THROW outb FREE THROW
;

STARTLOG
test