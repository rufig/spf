\ FCP.F, version 1.0  Copyright 2001-2002 Ian Osgood  iano@quirkster.com
\ A simple chess program written in ANS Forth.

\ Uses Core Extension words:
\   .( .R U.R <> U> ?DO ERASE FALSE NIP TO TRUE TUCK VALUE WITHIN \
\ Uses Exception words: CATCH THROW ABORT"
\ Uses Tools Extension words: [IF] [ELSE] [THEN]
\ Uses String word:           TOLOWER
\ Uses Win32Forth utilities:  ms@ CELL CELL- DEFER IS [DEFINED] [UNDEFINED]
\ Will use DEFER and IS if available for board iterator and vectors.
\ Uses defacto-standard HEX constant specifier: $FF
\  (I would use decimal #99, but it isn't supported by Win32Forth.
\   Thus, BASE 10 is assumed.  Use the next line if this is not the case.)
\ BASE @ DECIMAL
\ UNUSED

\ Assumes 32-bit cells
\ Recursive: assumes a data stack larger than MAX_PLY
\  and a return stack larger than 3*MAX_PLY.
\ Uses about 32K bytes of data space.  Some structures (eval boards etc.)
\  could use signed chars instead of cells for some space savings.

\ For further commentary on the basic chess data structures and algorithms,
\  please refer to the C source of the original TSCP program (v1.73),
\  written by Tom Kerrigan.
\  http://home.attbi.com/~tckerrigan/tscp173.zip

\ Change log:
\ (Initial port from TSCP C program)
\ 1* 0x88 vs. mailbox edge detection
\  * different piece & color values
\  * fine-grain factoring
\  * different command set, UI
\ 2* track king positions for inCheck?
\  * [reps implemented]
\ 3* material and pawn files updated incrementally for eval
\  * narrow starting a-b window with fail-high/low for more cutoffs
\  * setup EPD command
\ 4* style improvements based on c.l.f commentary
\  * fixed bugs in time display, reps
\  * use $ for hex constants instead of using DECIMAL & HEX
\  * .board options: showCoords, rotateBoard
\  * .epd command for recording a position, .moveList to list moves
\ (hiatus)
\ 5* more factoring and commentary
\  * inLine? optimized (thanks to Bruce Moreland's excellent web site)
\    http://www.seanet.com/~brucemo/topics/0x88.htm
\  * bd@ inlined and made into CELLS for a large speedup!
\  * fixed bug in genPush to bring node counts in line with TSCP.EXE
\  * st command to set thinking time (seconds per move)
\  * replaced most VARIABLEs with VALUEs (faster and more concise)
\ 6* inline and tweak hottest words for 25% speed boost
\  * fix bugs in epd, reps
\  * more factoring: move generation greatly simplified
\  * use new DEFER-based board iterators for move gen and eval
\ 7* inner loop unrolling
\  * optimize PV handling, eval, genPush
\  * remove forEachPiece/forEachOfMyPieces abstraction layer
\  * clarify word and variable names
\ 8* elegant stack machine alpha-beta search uses half the data stack
\  * fix some search and eval bugs (fixes node count diffs)
\  * more search debugging words (uses FILE wordset)
\  * fcp-help command
\ 9* further optimized attacks?, eval, moveGen
\  * use CATCH/THROW to abort a search more simply
\ A* use wbMACRO from Wil Baden for inline words
\  * smaller, more effective history table
\  * killer moves, new sorting mechanism
\  * fix some MAX_PLY limit bugs, thanks to running test suites (setup2)
\  * move debug code to separate file (available upon request)
\  * check for king errors in setup, use ABORT" for input
\ (Sufficiently enhanced to rename to FCP.)
\ 1.0 * null-move heuristic (major tactical speedup!)
\     * better check search extension (ditto!)

\ Possible future enhancements:
\ + experiment with other search extensions:
    \ single response, null-move mated, recapture, passed pawn advance
\ + add a transposition table
\ + further optimize eval routines
\ + clean up input routines
\ + add an opening book
\ + update squares attacked incrementally
\ + enhance evaluation routines

S" lib\include\core-ext.f" INCLUDED
S" lib\include\float.f" INCLUDED
S" lib\include\tools.f" INCLUDED

: NOTFOUND ( addr u -- )
  2DUP 2>R ['] NOTFOUND CATCH ?DUP
  IF                    
    NIP NIP 2R>
    OVER C@ [CHAR] $ =
    IF
       BASE @ >R HEX
       SKIP1 ?SLITERAL1
       STATE @ 0=
       IF NIP
       ELSE DROP
       THEN
       R> BASE !
    ELSE
       THROW
    THEN
  ELSE RDROP RDROP
  THEN
;

: DEFER VECT ;
: IS POSTPONE TO ; IMMEDIATE

WINAPI: GetTickCount KERNEL32.DLL

: ms@
   GetTickCount
;

UNUSED

S" [UNDEFINED]" PAD C! PAD CHAR+ PAD C@ CMOVE
PAD FIND NIP 0= [IF]
: [UNDEFINED] ( "word" -- tf ) BL WORD FIND NIP 0= ; IMMEDIATE
[THEN]
[UNDEFINED] [DEFINED] [IF]
: [DEFINED] ( "word" -- tf ) BL WORD FIND NIP ; IMMEDIATE
[THEN]

[UNDEFINED] CELL [IF]
1 CELLS CONSTANT CELL
[THEN]
[UNDEFINED] CELL- [IF]
: CELL- POSTPONE CELL POSTPONE - ; IMMEDIATE
[THEN]

\ Wil Baden implements wbMACRO for portably inlining code
: wbMACRO  ( "name <char> ccc<char>" -- )
  : CHAR PARSE  POSTPONE SLITERAL  POSTPONE EVALUATE
  POSTPONE ; IMMEDIATE
;
\ ' MACRO ALIAS wbMACRO \ if line-profiling on Win32Forth

1120 CONSTANT GEN_STACK
  32 CONSTANT MAX_PLY
 400 CONSTANT HIST_STACK

 : MAX_PLY* 5 LSHIFT ;

\ *** Square (piece + color) ***

\ 0 CONSTANT EMPTY      \ and BLANK are taken; just use 0
1 CONSTANT PAWN
2 CONSTANT KNIGHT
3 CONSTANT BISHOP
4 CONSTANT ROOK
5 CONSTANT QUEEN
6 CONSTANT KING
\ 7 CONSTANT PIECEMASK

wbMACRO piece " 7 AND" ( [sq] -- piece )

\ 0 CONSTANT EMPTY
0x10 CONSTANT LIGHT
0x20 CONSTANT DARK
0x30 CONSTANT COLORMASK

\ : color ( [sq] -- color ) COLORMASK AND ;
wbMACRO otherSide " COLORMASK XOR" ( color -- ~color )

wbMACRO light? " LIGHT AND" ( [sq] -- nz )
wbMACRO dark? " DARK AND" ( [sq] -- nz )

\ : mine? ( [sq] color+piece -- tf ) XOR COLORMASK AND 0= ;
  \ if input is just a color, simply use AND
\ : enemy? ( [sq] color -- tf ) XOR COLORMASK AND COLORMASK = ;
  \ mine? and enemy? are symmetric ( color [sq] -- tf )
  \ color can also be a piece+color

DARK PAWN + CONSTANT DARKPAWN
LIGHT PAWN + CONSTANT LIGHTPAWN

\ *** Board ***

\ The board structure is changed from the original TSCP to this Forth
\  version.  This representation has the advantages of:
\  1. One board index is used both for the main board and the eval boards
\     The original TSCP had a 120 element board for the pieces and edge
\     detection, and 64 element boards for eval piece-square tables, requiring
\     extra tables for translating between the two indices.  This
\     design uses one half of a 128 element board for both functions.
\  2. Edge detection testing on board index vs. board contents
\  3. One board element contains both piece and color data.  The original
\     TSCP had two separate boards, one for color and one for piece type.
\  4. Easy to translate between rank/file and board index.
\  5. Efficient test for whether a piece on one square can attack a piece
\     on another square (heavily used by inCheck?)

CREATE board 0x80 CELLS ALLOT

0x70 CONSTANT sqA1
0x72 CONSTANT sqC1
0x74 CONSTANT sqE1
0x76 CONSTANT sqG1
0x77 CONSTANT sqH1
0x00 CONSTANT sqA8
0x02 CONSTANT sqC8
0x04 CONSTANT sqE8
0x06 CONSTANT sqG8
0x07 CONSTANT sqH8

wbMACRO edge? " 0x88 AND" ( sq+dir -- nz )

: eraseBoard   board 0x80 CELLS ERASE ;
wbMACRO bd! " CELLS board + !" ( piece+color sq -- )
wbMACRO bd@ " CELLS board + @" ( sq -- piece+color )
\ $F CONSTANT EDGE        \ not empty, but no color
\ NOTE: EDGE and 0 are neither mine? nor enemy?, light? nor dark?
wbMACRO ?bd@ " DUP edge? IF DROP $F ELSE bd@ THEN" ( sq+dir -- piece|EDGE )
wbMACRO piece@ " bd@ piece" ( sq -- piece )

wbMACRO bd@mine? " bd@ AND" ( color sq -- nz )

: bdMove ( from to -- ) OVER bd@ SWAP bd! 0 SWAP bd! ;

wbMACRO rank " 4 RSHIFT" ( sq -- rank )
wbMACRO file " 0xF AND" ( sq -- file )
: fileRank>sq ( file rank -- sq ) 4 LSHIFT OR ;

wbMACRO rank8? " rank 0=" ( sq -- tf )
wbMACRO rank7? " rank 1 =" ( sq -- tf )
wbMACRO rank2? " rank 6 =" ( sq -- tf )
wbMACRO rank1? " rank 7 =" ( sq -- tf )

wbMACRO rotate " NEGATE $77 +" ( sq -- sq' )

: cRank ( sq -- c ) rank NEGATE [CHAR] 8 + ;
: cFile ( sq -- c ) file [CHAR] a + ;
: .sq ( sq -- ) DUP cFile EMIT cRank EMIT ;

\ *** Globals ***

0 VALUE nodes       \ must be 32-bit (or higher for long searches)
0 VALUE ep          \ destination square of possible en-passant capture
0 VALUE fifty       \ fifty move draw count

1 CONSTANT wkCastleBit
2 CONSTANT wqCastleBit
4 CONSTANT bkCastleBit
8 CONSTANT bqCastleBit
1 2 OR CONSTANT wCastleBits
4 8 OR CONSTANT bCastleBits
$F CONSTANT allCastleBits

allCastleBits VALUE castle  \ flags for castling capability

LIGHT VALUE side        \ color to move during search
TRUE  VALUE wtm?        \ : wtm? ( -- tf ) side light? ;
: setWtm  TRUE TO wtm?  LIGHT TO side ;
: setBtm  FALSE TO wtm?  DARK TO side ;
: switchColors  wtm? 0= TO wtm?  side otherSide TO side ;

\ *** Board Iterator ***

[DEFINED] DEFER [IF]    \ this is fastest (less stack fiddling)

DEFER doSq \ use of global DEFER means this iterator is not reentrant!!!

: forEveryRow ( sq -- sq+7 )
  doSq 1+ doSq 1+ doSq 1+ doSq 1+ doSq 1+ doSq 1+ doSq 1+ doSq ;

: forEverySq ( [st] 'word -- )  \ doSq ( [st] sq -- [st] sq )
  IS doSq
  0   forEveryRow 9 + forEveryRow 9 + forEveryRow 9 + forEveryRow
  9 + forEveryRow 9 + forEveryRow 9 + forEveryRow 9 + forEveryRow DROP ;

[ELSE] TRUE [IF]  \ unroll loops for speed and simplicity
: forEveryRow ( 'word sq -- 'word sq+7 )
     OVER EXECUTE 1+ OVER EXECUTE 1+ OVER EXECUTE 1+ OVER EXECUTE
  1+ OVER EXECUTE 1+ OVER EXECUTE 1+ OVER EXECUTE 1+ OVER EXECUTE ;

: forEverySq ( [st] 'word -- )  \ word ( [st] sq -- [st] sq )
  0   forEveryRow 9 + forEveryRow 9 + forEveryRow 9 + forEveryRow
  9 + forEveryRow 9 + forEveryRow 9 + forEveryRow 9 + forEveryRow  2DROP ;
[ELSE] TRUE [IF]
: forEverySq ( [st] 'word -- ) \ word ( [st] sq -- [st] sq )
  $80 0 DO
    I 8 + I DO
      I SWAP DUP >R EXECUTE DROP R>
    LOOP
  $10 +LOOP DROP ;
[ELSE]
: forEverySq    \ this was slower
  >R 0 BEGIN
    R@ EXECUTE
    1+ DUP 8 AND +             \ next square
  DUP edge? UNTIL R> 2DROP ;
[THEN] [THEN] [THEN]

\ *** Board Display ***

CREATE symbols
  CHAR . , CHAR P , CHAR N , CHAR B ,
  CHAR R , CHAR Q , CHAR K , CHAR # ,

[UNDEFINED] tolower [IF]
: tolower ( C -- c ) $20 OR ;
[THEN]

: .piece ( piece[+color] -- )
  DUP piece CELLS symbols + @       \ symbol for piece
  SWAP dark? IF tolower THEN EMIT ; \ dark is lowercase

FALSE VALUE showCoords?
FALSE VALUE blackAtBottom?
: ?rotate ( sq -- sq' ) blackAtBottom? IF rotate THEN ;

: .aSq ( sq -- sq )
  showCoords? OVER 1- edge? AND IF
    DUP ?rotate cRank EMIT 2 SPACES
  THEN
  DUP ?rotate bd@ .piece
  DUP 1+ edge? IF CR ELSE SPACE THEN ;

( >>> )  DEFER .board

: .board_ascii
  CR ['] .aSq forEverySq
  showCoords? IF CR 3 SPACES
    blackAtBottom? IF ." h g f e d c b a"
    ELSE ." a b c d e f g h" THEN CR
  THEN ;

( >>> )  ' .board_ascii IS .board   \ To use it as it was
( >>> )  ' NOOP IS .board           \ Switch it off for graphical reasons

\ Display board as an Extended Position Definition (EPD) string

VARIABLE epdBlCount

: ?.epdBl
  epdBlCount @ ?DUP IF
    [CHAR] 0 + EMIT
    0 epdBlCount !
  THEN ;

: .epdSq ( sq -- sq )
  DUP bd@ ?DUP IF
    ?.epdBl  .piece
  ELSE
    1 epdBlCount +!
  THEN
  DUP 1+ edge? IF
    ?.epdBl  DUP rank1? 0= IF [CHAR] / EMIT THEN
  THEN ;

: .epd   CR  0 epdBlCount !
  ['] .epdSq forEverySq SPACE
  wtm? IF [CHAR] w ELSE [CHAR] b THEN EMIT CR ;
  \ !!! show castling rights and ep square?

\ *** Attack and check detection ***

 $10 CONSTANT So        \ rank
 -16 CONSTANT No
   1 CONSTANT Ea        \ file
  -1 CONSTANT We

So Ea + CONSTANT SE     \ diagonals
So We + CONSTANT SW
No Ea + CONSTANT NE
No We + CONSTANT NW

No NE + CONSTANT Kn1   Ea NE + CONSTANT Kn2     \ knight moves
Ea SE + CONSTANT Kn3   So SE + CONSTANT Kn4
So SW + CONSTANT Kn5   We SW + CONSTANT Kn6
We NW + CONSTANT Kn7   No NW + CONSTANT Kn8

: Northerly? ( dir -- tf ) POSTPONE 0< ; IMMEDIATE   \ a1 to a8 direction?

\ This table relies on pieces being an enumeration of small integers (1..6)
\ This table exploits a property of the 0x88 board representation: the
\ spacial relationship between two squares is uniquely specified by
\ (the absolute value of) the difference of their indicies.  See Bruce
\ Moreland's website for a clear explanation.

1 ROOK LSHIFT 1 QUEEN LSHIFT + CONSTANT RQ
1 BISHOP LSHIFT 1 QUEEN LSHIFT + CONSTANT BQ
1 KNIGHT LSHIFT CONSTANT Kn
1 PAWN LSHIFT CONSTANT pawnMask
: +K   1 KING LSHIFT + ;
: +KP  pawnMask + +K ;

CREATE inLineTable              0 , RQ +K , RQ , RQ , RQ , RQ , RQ , RQ , 0 ,
0 , 0 , 0 , 0 , 0 , Kn , BQ +KP , RQ +K , BQ +KP , Kn , 0 , 0 , 0 , 0 , 0 , 0 ,
    0 , 0 , 0 , 0 , 0 , BQ , Kn , RQ , Kn , BQ , 0 , 0 , 0 , 0 , 0 , 0 ,
    0 , 0 , 0 , 0 , BQ , 0 , 0 ,  RQ ,  0 , 0 , BQ , 0 , 0 , 0 , 0 , 0 ,
    0 , 0 , 0 , BQ , 0 , 0 , 0 ,  RQ ,  0 , 0 , 0 , BQ , 0 , 0 , 0 , 0 ,
    0 , 0 , BQ , 0 , 0 , 0 , 0 ,  RQ ,  0 , 0 , 0 , 0 , BQ , 0 , 0 , 0 ,
    0 , BQ , 0 , 0 , 0 , 0 , 0 ,  RQ ,  0 , 0 , 0 , 0 , 0 , BQ , 0 , 0 ,
    BQ , 0 , 0 , 0 , 0 , 0 , 0 ,  RQ ,  0 , 0 , 0 , 0 , 0 , 0 , BQ ,

\ example: ROOK sqE8 sqE1 - inLine ( -- [1 ROOK LSHIFT] )

: inLine? ( sq diff -- mask )
  ABS CELLS inLineTable + @ DUP IF
    1 ROT piece@ LSHIFT AND EXIT ELSE
    NIP ( FALSE ) THEN ;

: diff>dir ( diff -- dir )              \ could also be a table
  DUP ABS 8 U< IF
    0< IF We ELSE Ea THEN EXIT THEN
  \ dir = diff / number of ranks spanned
  DUP ABS 8 + 4 RSHIFT / ;              \ expensive division

\ assumes dir sq sqSrc - inLine?  (so no need to check for edge)
: sqSliderAttacks? ( sq sqSrc dir -- sq tf )
  >R BEGIN                      \ R: dir
    R@ + 2DUP = IF              \ clear line
      R> 2DROP TRUE EXIT
    THEN
  DUP bd@ UNTIL
  R> 2DROP FALSE ;

Kn +KP CONSTANT adjacentMask

: sqAttacks? ( sq sqSrc -- sq sqSrc tf )
  2DUP -          ( sq sqSrc diff )
  2DUP inLine? DUP IF
    adjacentMask AND ?DUP IF
      pawnMask AND IF Northerly? OVER bd@ LIGHTPAWN = = EXIT THEN
      DROP TRUE EXIT
    THEN
    OVER >R diff>dir sqSliderAttacks? R> SWAP EXIT
  THEN
  NIP ( FALSE ) ;

TRUE [IF]
\ unrolling doesn't seem to help with attacks?,
\  perhaps because it defeats branch prediction

: attacks? ( color sq -- tf )
  $80 0 DO
    I 8 OR I DO
      OVER I bd@mine? IF                 \ hot spot
        I sqAttacks? IF
          DROP 2DROP TRUE
          UNLOOP UNLOOP EXIT
        THEN DROP
      THEN
    LOOP
  So +LOOP
  2DROP FALSE ;

[ELSE]
: sqAtt? ( color sq sqSrc  -- color sq sqSrc )
  2 PICK OVER bd@mine? IF sqAttacks? IF 1 THROW THEN THEN ;
: att?  ['] sqAtt? forEverySq ;
: attacks?  ( color sq -- tf ) ['] att? CATCH 1 = NIP NIP ;
[THEN]

VARIABLE lkSq  VARIABLE dkSq

: inCheck? ( wtm? -- tf )
  IF DARK lkSq ELSE LIGHT dkSq THEN @ attacks? ;

\ *** Move Type ***

\ A stored move is a cell containing four byte fields:
\  F from square, T to square, B bit flags, P promotion piece
\  cell layout: MSB [xxxxxPPP xxBBBBBB xTTTTTTT xFFFFFFF] LSB

4 CONSTANT moveSize

 0x10000 CONSTANT captureBit
 0x20000 CONSTANT castleBit
 0x40000 CONSTANT pawnBit
 0x80000 CONSTANT  2sqBit
0x100000 CONSTANT  epBit
0x200000 CONSTANT  promoteBit

$3F0000 castleBit XOR CONSTANT reset50Bits

: mvPromote! ( mv piece -- mv )
  $18 LSHIFT OR [ pawnBit promoteBit OR ] LITERAL OR ;

wbMACRO mvFrom " $FF AND" ( mv -- sqFrom )
wbMACRO mvTo " 8 RSHIFT $FF AND" ( mv -- sqTo )
: mvPromote ( mv -- piece ) $18 RSHIFT piece ;

wbMACRO fromTo>mv " 8 LSHIFT OR" ( from to -- mv :)
wbMACRO fromTo>fromMv " 8 LSHIFT OVER OR" ( from to -- from mv :)

: epSq ( mv -- mv ep ) DUP mvFrom OVER mvTo + 2/ ;
: epCapSq ( mv -- mv epCap ) DUP mvFrom $F0 AND OVER mvTo file OR ;

: .move ( mv -- )
  DUP 0= IF ." (null)" EXIT THEN
  DUP mvFrom .sq
  DUP captureBit AND IF [CHAR] x ELSE [CHAR] - THEN EMIT
  DUP mvTo .sq
  DUP promoteBit AND IF
    [CHAR] = EMIT  DUP mvPromote .piece
  THEN
  epBit AND IF ." ep" THEN ;

\ *** History (for improved move ordering) ***

\ Smaller table indexed by destination, piece, and color should work as well
\ as the original table, indexed by source and destination

\ CREATE history $80 6 * CELLS ALLOT    \ smallest, but harder to index
CREATE history $80 $16 * CELLS ALLOT
: historyErase history $80 $16 * CELLS ERASE ;

\ experiment: age off history instead of clearing between moves
8 VALUE historyAgeFactor \ proportional to last depth? nodes? max? mean?
: historyAge
  history $80 $16 * CELLS + history DO
    I @ historyAgeFactor RSHIFT I !
  CELL +LOOP ;
: xMaxHistory 0 history $80 $16 * CELLS + history DO
    I @ MAX
  CELL +LOOP . ;
: xMeanHistory 0 0 history $80 $16 * CELLS + history DO
    I @ ?DUP IF + >R 1+ R> THEN
  CELL +LOOP 2DUP . ." / " . ." = " SWAP / . ;

: mvHistory ( mv -- mv ^hist )
\   DUP mvFrom bd@  DUP piece 1- 7 LSHIFT  SWAP color 2/ 8 -  +
  DUP mvFrom bd@ $11 - 7 LSHIFT
  OVER mvTo +  CELLS history + ;

\ *** Killer Moves (improves move ordering) ***

\ Killer moves serve the same function as the history table above.  Whereas
\ the history table is used to value a move made anywhere in the tree at
\ any time, the killer move table values moves which made a cutoff at the
\ same depth in the tree recently in the search.

0 VALUE ply            \ current depth of search

CREATE killers MAX_PLY 2* CELLS ALLOT
: killersErase killers MAX_PLY 2* CELLS ERASE ;
\ NOTE: more efficient to not erase between moves

: getKillers ( -- ^k ) ply 2* CELLS killers + ;

: killer1 ( -- mv ) getKillers @ ;
: killer2 ( -- mv ) ply 2 U< IF 0 EXIT THEN  getKillers 4 CELLS - @ ;
: killer3 ( -- mv ) getKillers CELL+ @ ;
: killer4 ( -- mv ) ply 2 U< IF 0 EXIT THEN  getKillers 3 CELLS - @ ;

: setKiller ( mv -- )
  DUP captureBit AND IF DROP EXIT THEN  \ captures already sorted high
  getKillers  2DUP @ = IF 2DROP EXIT THEN
  DUP @  OVER CELL+ !  ! ;        \ swap and replace

\ *** Move Generation ***

moveSize CELL+ CONSTANT genSize
: genSize*   3 LSHIFT ;

CREATE genStack GEN_STACK genSize* ALLOT

CREATE firstMove MAX_PLY 1+ CELLS ALLOT  \ stores addresses within gen_dat

genStack firstMove !

wbMACRO ^firstMovePly " firstMove ply CELLS +" ( -- ^first )
: firstMovePly ( -- ^gen ) ^firstMovePly @ ;
: lastMovePly ( -- ^gen ) ^firstMovePly CELL+ @ ;

: forMovesAtPly ( -- lastMovePly firstMovePly )  \ init ?DO LOOP
  ^firstMovePly DUP CELL+ @ SWAP @ ;

: genPutMove ( score mv -- ) \ genStack[firstMove[ply+1]++] = mv+score
  ^firstMovePly CELL+ DUP @ DUP genSize + ROT ! 2! ;

: genInitPly   ^firstMovePly DUP @ SWAP CELL+ ! ;

$100000 CONSTANT mvSortFirst

: genPushPromotions ( mv -- )
  KING KNIGHT DO
    mvSortFirst I 4 LSHIFT +    \ score: sort promotions first
    OVER I mvPromote!   \ move
    genPutMove          \ push it
  LOOP DROP ;

: genPushCapture ( mv -- )    \ most-valuable-victim least-valuable-attacker
  DUP mvFrom piece@           \ piece moved
  OVER mvTo piece@ 4 LSHIFT   \ piece captured * 16
  + mvSortFirst +             \ sort captures first
  SWAP genPutMove ;

: genPush ( mv -- ) mvHistory @ SWAP genPutMove ;

pawnBit captureBit OR CONSTANT pawnCaptureBits

: ?pushEP ( dir piece -- )
  OVER ep + ?bd@ = IF
    ep + ep fromTo>mv [ pawnCaptureBits epBit OR ] LITERAL OR
    [ PAWN DUP 4 LSHIFT + mvSortFirst + ] LITERAL SWAP genPutMove
  ELSE
    DROP THEN ;

: genEP
  ep IF
    wtm? IF
      SW LIGHTPAWN ?pushEP
      SE LIGHTPAWN ?pushEP
    ELSE
      NW DARKPAWN ?pushEP
      NE DARKPAWN ?pushEP
    THEN
  THEN ;

: genCastle
  castle DUP
  wtm? IF
    wkCastleBit AND IF
      sqE1 sqG1 fromTo>mv castleBit OR genPush THEN
    wqCastleBit AND IF
      sqE1 sqC1 fromTo>mv castleBit OR genPush THEN
  ELSE
    bkCastleBit AND IF
      sqE8 sqG8 fromTo>mv castleBit OR genPush THEN
    bqCastleBit AND IF
      sqE8 sqC8 fromTo>mv castleBit OR genPush THEN
  THEN ;

: ?genCapture ( sq dest piece -- sq )
  side AND IF DROP EXIT THEN       \ mine?
  fromTo>fromMv captureBit OR genPushCapture ;

[DEFINED] DEFER [IF]
DEFER ?genEmpty   ' DROP IS ?genEmpty  ( sq dest -- sq )
[ELSE]
: ?genEmpty POSTPONE DROP ; IMMEDIATE
[THEN]

: genCapAdjacent ( sq dir -- sq )
  OVER +  DUP edge? IF DROP EXIT THEN
  DUP bd@ ?DUP IF ?genCapture EXIT ELSE ?genEmpty THEN ;

: genCapSlider ( sq dir -- sq )         \ slide to edge or other piece
  OVER BEGIN
    OVER +  DUP edge? IF 2DROP EXIT THEN
  DUP bd@ ?DUP UNTIL ROT DROP ?genCapture ;

: genSlider ( sq dir -- sq dest )       \ gen moves until edge or other piece
  >R DUP BEGIN
    R@ +  DUP edge? IF R> 2DROP EXIT THEN
    DUP bd@ ?DUP 0= WHILE
    2DUP fromTo>mv genPush
  REPEAT  ( sq dest )
  R> DROP ?genCapture ;

: genLPCaptures ( sq -- sq )
  DUP NW + ?bd@ dark? IF
    DUP DUP NW + fromTo>mv pawnCaptureBits OR
    OVER rank7? IF
      genPushPromotions ELSE
      genPushCapture THEN
  THEN
  DUP NE + ?bd@ dark? IF
    DUP DUP NE + fromTo>mv pawnCaptureBits OR
    OVER rank7? IF
      genPushPromotions ELSE
      genPushCapture THEN
  THEN ;

: genDPCaptures ( sq -- sq )
  DUP SW + ?bd@ light? IF
    DUP DUP SW + fromTo>mv pawnCaptureBits OR
    OVER rank2? IF
      genPushPromotions ELSE
      genPushCapture THEN
  THEN
  DUP SE + ?bd@ light? IF
    DUP DUP SE + fromTo>mv pawnCaptureBits OR
    OVER rank2? IF
      genPushPromotions ELSE
      genPushCapture THEN
  THEN ;

: genCapsLP  ( sq -- sq )
  genLPCaptures
  DUP rank7? IF
    DUP No + bd@ IF EXIT THEN
    DUP DUP No + fromTo>mv genPushPromotions
  THEN ;

: genCapsDP
  genDPCaptures
  DUP rank2? IF
    DUP So + bd@ IF EXIT THEN
    DUP DUP So + fromTo>mv genPushPromotions
  THEN ;

: genCapsN
  Kn1 genCapAdjacent Kn2 genCapAdjacent Kn3 genCapAdjacent Kn4 genCapAdjacent
  Kn5 genCapAdjacent Kn6 genCapAdjacent Kn7 genCapAdjacent Kn8 genCapAdjacent ;

: genCapsK
  No genCapAdjacent Ea genCapAdjacent So genCapAdjacent We genCapAdjacent
  NE genCapAdjacent SE genCapAdjacent SW genCapAdjacent NW genCapAdjacent ;

: genCapsB
  NE genCapSlider SE genCapSlider SW genCapSlider NW genCapSlider ;

: genCapsR
  No genCapSlider Ea genCapSlider So genCapSlider We genCapSlider ;

: genCapsQ
  genCapsR genCapsB ;

pawnBit 2sqBit OR CONSTANT pawn2sqBits

: genLP  ( sq -- sq )
  genLPCaptures
  DUP No + bd@ IF EXIT THEN
  DUP DUP No + fromTo>mv
  OVER rank7? IF
    genPushPromotions ELSE
    pawnBit OR genPush THEN
  DUP rank2? IF
    DUP No 2* + bd@ IF EXIT THEN
    DUP DUP No 2* + fromTo>mv pawn2sqBits OR genPush
  THEN ;

: genDP
  genDPCaptures
  DUP So + bd@ IF EXIT THEN
  DUP DUP So + fromTo>mv
  OVER rank2? IF
    genPushPromotions ELSE
    pawnBit OR genPush THEN
  DUP rank7? IF
    DUP So 2* + bd@ IF EXIT THEN
    DUP DUP So 2* + fromTo>mv pawn2sqBits OR genPush
  THEN ;

[DEFINED] DEFER [IF]

: genPushEmpty ( from to -- from ) fromTo>fromMv genPush ;

: genN
  ['] genPushEmpty IS ?genEmpty  genCapsN  ['] DROP IS ?genEmpty ;

: genK
  ['] genPushEmpty IS ?genEmpty  genCapsK  ['] DROP IS ?genEmpty ;

[ELSE]
: genAdjacent ( sq dir -- sq )  \ almost identical to genCapAdjacent
  OVER +  DUP edge? IF DROP EXIT THEN
  DUP bd@ ?DUP IF ?genCapture EXIT ELSE fromTo>fromMv genPush THEN ;

: genN
  Kn1 genAdjacent Kn2 genAdjacent Kn3 genAdjacent Kn4 genAdjacent
  Kn5 genAdjacent Kn6 genAdjacent Kn7 genAdjacent Kn8 genAdjacent ;

: genK
  No genAdjacent Ea genAdjacent So genAdjacent We genAdjacent
  NE genAdjacent SE genAdjacent SW genAdjacent NW genAdjacent ;
[THEN]

: genB
  NE genSlider SE genSlider SW genSlider NW genSlider ;

: genR
  No genSlider Ea genSlider So genSlider We genSlider ;

: genQ
  genR genB ;

: genNil ." Illegal piece on square " DUP .sq CR ;

\ genVector is an interleaved table,
\  genSq indexes by [sq]-8 (piece + color: $11..$16, $21..$26)
\  genCapsSq indexes by [sq]

CREATE genVector
  ' genNil , ' genNil , ' genNil , ' genNil ,
  ' genNil , ' genNil , ' genNil , ' genNil ,
  ' genNil , ' genLP ,  ' genN ,   ' genB ,
  ' genR ,   ' genQ ,   ' genK ,   ' genNil ,
  ' genNil ,   ' genCapsLP , ' genCapsN , ' genCapsB ,
  ' genCapsR , ' genCapsQ ,  ' genCapsK , ' genNil ,
  ' genNil , ' genDP ,  ' genN ,   ' genB ,
  ' genR ,   ' genQ ,   ' genK ,   ' genNil ,
  ' genNil ,   ' genCapsDP , ' genCapsN , ' genCapsB ,
  ' genCapsR , ' genCapsQ ,  ' genCapsK , ' genNil ,

: genCapsSq ( sq -- sq )
  side OVER bd@mine? IF
    DUP bd@ CELLS genVector + @ EXECUTE  \ all vectors are ( sq -- sq )
  THEN ;

: genCaps
  genInitPly
  ['] genCapsSq forEverySq
  genEP ;

: genSq ( sq -- sq )
  side OVER bd@mine? IF
    DUP bd@ 8 - CELLS genVector + @ EXECUTE
  THEN ;

: gen
  genInitPly
  ['] genSq forEverySq
  genCastle
  genEP ;

\ *** Move History Stack ***

2 CELLS CONSTANT histSize
: histSize* 3 LSHIFT ;

CREATE histStack HIST_STACK histSize* ALLOT

histStack VALUE histTop

: initHist  histStack TO histTop ;

: .moveList
  CR 5 SPACES ." White  Black" 0   ( halfmoveNumber )
  histTop histStack ?DO
    DUP 1 AND 0= IF
      CR DUP 2/ 1+ 3 .R SPACE
    THEN
    SPACE I @ .move SPACE
    1+
  histSize +LOOP DROP CR ;

: histPush ( mv -- )
  histTop                     \ move (32 bits)
  2DUP ! CELL+ SWAP
  mvTo bd@                      \ captured piece (w/color 6 bits)
  castle 8 LSHIFT OR          \ castle (4 bits)
  ep $10 LSHIFT OR            \ ep square (7 bits)
  fifty $18 LSHIFT OR         \ fifty move count (7 bits)
  OVER ! CELL+ TO histTop ;

: histPop ( -- capt mv )
  histTop
  CELL- DUP @
  DUP $18 RSHIFT TO fifty
  DUP $10 RSHIFT $FF AND TO ep
  DUP 8 RSHIFT $FF AND TO castle
  $FF AND SWAP
  CELL- DUP TO histTop @ ;

\ *** Move and Undo ***

\ these items are updated incrementally to save time in eval
\ pawnRank[c][f] is the rank of the least advanced pawn of color c
\  on file f - 1.  If no pawn, set to promotion rank.

CREATE darkPawnRank 10 CELLS ALLOT
CREATE lightPawnRank 10 CELLS ALLOT

: openFile? ( f+1 -- tf )
  CELLS DUP lightPawnRank + @ 0=
  SWAP darkPawnRank + @ 7 = AND ;

\ pawn moved, captured, or promoted: update the file (both sides)

: updatePawnFile ( file -- )
  DUP 1+ CELLS
  0 OVER lightPawnRank + !
  7 OVER darkPawnRank + !
  SWAP $70 + DUP $60 - DO
    I bd@ DUP LIGHTPAWN = IF DROP
      DUP lightPawnRank + DUP @ I rank MAX SWAP !
    ELSE DARKPAWN = IF
      DUP darkPawnRank + DUP @ I rank MIN SWAP !
    THEN THEN
  So +LOOP DROP ;

: updatePawnFiles ( mv -- )
  DUP mvFrom file SWAP mvTo file
  DUP updatePawnFile  OVER = IF DROP EXIT THEN
  updatePawnFile ;

VARIABLE lightPieceMat   VARIABLE darkPieceMat
VARIABLE lightPawnMat    VARIABLE darkPawnMat

100 CONSTANT pawnValue
CREATE pieceValues 0 , pawnValue , 300 , 300 , 500 , 900 , 0 ,

\ Update material and pawn files incrementally during move and takeback:
\ 1. captures 1a. pawn captured 2. promotions 3. en passant 4. pawn moves

: updatePieceMaterial ( value -- )
  wtm? IF darkPieceMat ELSE lightPieceMat THEN +! ;
: updatePawnMaterial ( value -- )
  wtm? IF darkPawnMat ELSE lightPawnMat THEN +! ;
: updatePromotionMaterial ( pawnValue pieceValue -- )
  wtm? IF lightPieceMat +! lightPawnMat ELSE
          darkPieceMat +! darkPawnMat THEN +! ;

\ Update king positions during move and takeback for inCheck?

: ?updateKingPosition ( sq -- )
  DUP piece@ KING = IF
    wtm? IF lkSq ELSE dkSq THEN !
  ELSE DROP THEN ;

: takeBack ( -- )
  switchColors
  ply 1- TO ply
  histPop       ( capt mv )
  DUP 0= IF 2DROP EXIT THEN     \ null-move abort

  DUP promoteBit AND IF
    PAWN side OR OVER mvFrom bd!
    \ update material
    pawnValue OVER mvPromote CELLS pieceValues + @ NEGATE
    updatePromotionMaterial
  ELSE
    DUP mvTo bd@ OVER mvFrom DUP >R bd!
    R> ?updateKingPosition
  THEN
  SWAP DUP IF  ( mv capt )
    \ capture: update material
    DUP piece DUP PAWN = IF DROP
      pawnValue updatePawnMaterial
      OVER pawnBit AND 0= IF
        OVER mvTo 2DUP bd!   file updatePawnFile
      THEN
    ELSE
      CELLS pieceValues + @ updatePieceMaterial
    THEN
  THEN
  OVER mvTo bd!    ( mv )

  DUP castleBit AND IF
    DUP mvTo DUP sqG1 = OVER sqG8 = OR IF           \ O-O
      DUP 1- SWAP 1+ bdMove      \ undo the rook
    ELSE DUP sqC1 = OVER sqC8 = OR IF               \ O-O-O
      DUP 1+ SWAP 1- 1- bdMove   \ undo the rook
    THEN THEN
  THEN

  DUP pawnBit AND IF
    DUP epBit AND IF
      \ update material
      pawnValue updatePawnMaterial
      epCapSq PAWN side otherSide OR SWAP bd!
    THEN
    updatePawnFiles EXIT
  THEN DROP ;

: sqCastleMask ( sq -- mask )
  allCastleBits SWAP DUP rank8? IF
    DUP sqA8 = IF DROP bqCastleBit XOR EXIT THEN
    DUP sqE8 = IF DROP bCastleBits XOR EXIT THEN
    sqH8 = IF bkCastleBit XOR THEN EXIT
  ELSE DUP rank1? IF
    DUP sqA1 = IF DROP wqCastleBit XOR EXIT THEN
    DUP sqE1 = IF DROP wCastleBits XOR EXIT THEN
    sqH1 = IF wkCastleBit XOR THEN EXIT
  ELSE
    DROP THEN THEN  ;

FALSE VALUE lastMoveCheck?

: makeMove ( mv -- legal? )

  DUP castleBit AND IF
    DUP mvTo DUP sqG1 = OVER sqG8 = OR IF           \ O-O
      DUP bd@ OVER 1- bd@ OR IF 2DROP FALSE EXIT THEN
      wtm? inCheck? IF 2DROP FALSE EXIT THEN
      side otherSide OVER attacks? IF 2DROP FALSE EXIT THEN
      \ side otherSide OVER 1- attacks? IF 2DROP FALSE EXIT THEN
      DUP 1+ SWAP 1- bdMove      \ OK: move the rook
    ELSE DUP sqC1 = OVER sqC8 = OR IF               \ O-O-O
      DUP bd@ OVER 1- bd@ OR OVER 1+ bd@ OR IF
        2DROP FALSE EXIT THEN
      wtm? inCheck? IF 2DROP FALSE EXIT THEN
      side otherSide OVER attacks? IF 2DROP FALSE EXIT THEN
      \ side otherSide OVER 1+ attacks? IF 2DROP FALSE EXIT THEN
      DUP 1- 1- SWAP 1+ bdMove      \ OK: move the rook
    ELSE
      DROP .move ." : bad castle" FALSE EXIT
    THEN THEN
  THEN
  DUP histPush
  ply 1+ TO ply

  castle IF
    castle OVER mvTo sqCastleMask AND OVER mvFrom sqCastleMask AND TO castle
  THEN

  DUP 2sqBit AND IF
    epSq ELSE
    0 THEN TO ep

  DUP reset50Bits AND IF
    0 ELSE
    fifty 1+ THEN TO fifty

  DUP mvTo
  DUP bd@ ?DUP IF
    \ capture: update material
    piece DUP PAWN = IF DROP
      pawnValue NEGATE updatePawnMaterial
      OVER pawnBit AND 0= IF
        0 OVER bd!  DUP file updatePawnFile THEN
    ELSE
      CELLS pieceValues + @ NEGATE updatePieceMaterial
    THEN
  THEN
  OVER mvFrom OVER bdMove
  ?updateKingPosition

  DUP pawnBit AND IF
    DUP promoteBit AND IF
      DUP mvPromote side OR OVER mvTo bd!
      \ update material
      pawnValue NEGATE OVER mvPromote CELLS pieceValues + @
      updatePromotionMaterial
    ELSE DUP epBit AND IF
      \ update material
      pawnValue NEGATE updatePawnMaterial
      epCapSq 0 SWAP bd!
    THEN THEN
    updatePawnFiles
  ELSE
    DROP THEN

  wtm?     switchColors
  inCheck? IF
    takeBack FALSE ELSE
    wtm? inCheck? TO lastMoveCheck? TRUE THEN ;

\ *** Evaluation ***

\ Eval should return the same value as the original TSCP.
\ It is only modified for the different board type, use of a vector
\ instead of a switch to evaluate pieces, and some terms updated
\ incrementally by makemove/takeback instead of recalculated every time.
\ Evaluation is much better commented in the original TSCP source.

: evalSetupSq ( sq -- sq )
  DUP bd@ DUP LIGHTPAWN = IF
    DROP pawnValue lightPawnMat +!
    DUP file 1+ CELLS lightPawnRank + ( sq ^lpr )
    OVER rank OVER @ MAX SWAP !
  ELSE DUP DARKPAWN = IF
    DROP pawnValue darkPawnMat +!
    DUP file 1+ CELLS darkPawnRank +
    OVER rank OVER @ MIN SWAP !
  ELSE ?DUP IF
    DUP piece CELLS pieceValues + @
    SWAP light? IF lightPieceMat ELSE darkPieceMat THEN +!
  THEN THEN THEN ;

: evalSetup ( -- )      \ call after setting up a position or new game
  10 0 DO
    0 lightPawnRank I CELLS + !
    7 darkPawnRank I CELLS + !
  LOOP
  0 lightPieceMat ! 0 darkPieceMat !
  0 lightPawnMat ! 0 darkPawnMat !
  ['] evalSetupSq forEverySq ;

-10 CONSTANT DOUBLED_PAWN_PENALTY
-20 CONSTANT ISOLATED_PAWN_PENALTY
 -8 CONSTANT BACKWARD_PAWN_PENALTY
 20 CONSTANT PASSED_PAWN_BONUS
 10 CONSTANT ROOK_SEMI_OPEN_FILE_BONUS
 15 CONSTANT ROOK_OPEN_FILE_BONUS
 20 CONSTANT ROOK_ON_SEVENTH_BONUS

\ The following tables are 128 * 64 piece square tables.
\ Each table has two "entry points" so that sq values
\ can act directly as indices and we save space.

\ The tables are flipped vertically if used for black.
\ Since they are all symetrical horizontally, we can rotate them instead.
\  exception: king table has light and dark versions
\  exception: king endgame table is 8-fold symmetric, can be used unrotated

CREATE pawnPcSq
 0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,
   -10 , -10 , -10 , -10 , -10 , -10 , -10 , -10 ,
 5 ,  10 ,  15 ,  20 ,  20 ,  15 ,  10 ,   5 ,
   -10 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 , -10 ,
 4 ,   8 ,  12 ,  16 ,  16 ,  12 ,   8 ,   4 ,
   -10 ,   0 ,   5 ,   5 ,   5 ,   5 ,   0 , -10 ,
 3 ,   6 ,   9 ,  12 ,  12 ,   9 ,   6 ,   3 ,
   -10 ,   0 ,   5 ,  10 ,  10 ,   5 ,   0 , -10 ,
 2 ,   4 ,   6 ,   8 ,   8 ,   6 ,   4 ,   2 ,
   -10 ,   0 ,   5 ,  10 ,  10 ,   5 ,   0 , -10 ,
 1 ,   2 ,   3 , -10 , -10 ,   3 ,   2 ,   1 ,
   -10 ,   0 ,   5 ,   5 ,   5 ,   5 ,   0 , -10 ,
 0 ,   0 ,   0 , -40 , -40 ,   0 ,   0 ,   0 ,
   -10 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 , -10 ,
 0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,
   -10 , -30 , -10 , -10 , -10 , -10 , -30 , -10 ,

pawnPcSq 8 CELLS + CONSTANT knightPcSq

CREATE bishopPcSq
-10 , -10 , -10 , -10 , -10 , -10 , -10 , -10 ,
    0 ,  10 ,  20 ,  30 ,  30 ,  20 ,  10 ,   0 ,
-10 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 , -10 ,
   10 ,  20 ,  30 ,  40 ,  40 ,  30 ,  20 ,  10 ,
-10 ,   0 ,   5 ,   5 ,   5 ,   5 ,   0 , -10 ,
   20 ,  30 ,  40 ,  50 ,  50 ,  40 ,  30 ,  20 ,
-10 ,   0 ,   5 ,  10 ,  10 ,   5 ,   0 , -10 ,
   30 ,  40 ,  50 ,  60 ,  60 ,  50 ,  40 ,  30 ,
-10 ,   0 ,   5 ,  10 ,  10 ,   5 ,   0 , -10 ,
   30 ,  40 ,  50 ,  60 ,  60 ,  50 ,  40 ,  30 ,
-10 ,   0 ,   5 ,   5 ,   5 ,   5 ,   0 , -10 ,
   20 ,  30 ,  40 ,  50 ,  50 ,  40 ,  30 ,  20 ,
-10 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 , -10 ,
   10 ,  20 ,  30 ,  40 ,  40 ,  30 ,  20 ,  10 ,
-10 , -10 , -20 , -10 , -10 , -20 , -10 , -10 ,
    0 ,  10 ,  20 ,  30 ,  30 ,  20 ,  10 ,   0 ,

bishopPcSq 8 CELLS + CONSTANT kingEndgamePcSq

CREATE kingLtPcSq
-40 , -40 , -40 , -40 , -40 , -40 , -40 , -40 ,
    0 ,  20 ,  40 , -20 ,   0 , -20 ,  40 ,  20 ,
-40 , -40 , -40 , -40 , -40 , -40 , -40 , -40 ,
  -20 , -20 , -20 , -20 , -20 , -20 , -20 , -20 ,
-40 , -40 , -40 , -40 , -40 , -40 , -40 , -40 ,
  -40 , -40 , -40 , -40 , -40 , -40 , -40 , -40 ,
-40 , -40 , -40 , -40 , -40 , -40 , -40 , -40 ,
  -40 , -40 , -40 , -40 , -40 , -40 , -40 , -40 ,
-40 , -40 , -40 , -40 , -40 , -40 , -40 , -40 ,
  -40 , -40 , -40 , -40 , -40 , -40 , -40 , -40 ,
-40 , -40 , -40 , -40 , -40 , -40 , -40 , -40 ,
  -40 , -40 , -40 , -40 , -40 , -40 , -40 , -40 ,
-20 , -20 , -20 , -20 , -20 , -20 , -20 , -20 ,
  -40 , -40 , -40 , -40 , -40 , -40 , -40 , -40 ,
  0 ,  20 ,  40 , -20 ,   0 , -20 ,  40 ,  20 ,
  -40 , -40 , -40 , -40 , -40 , -40 , -40 , -40 ,

kingLtPcSq 8 CELLS + CONSTANT kingDkPcSq

VARIABLE lightScore      VARIABLE darkScore

CREATE myCastledPawnRankPenalties
  -20 ,   0 , -10 , -20 , -20 , -20 , -20 , -25 ,
CREATE enemyCastledPawnRankPenalties
    0 ,   0 ,   0 ,   0 ,  -5 , -10 ,   0 , -15 ,

: evalLightKP ( file+1 -- value )
  DUP CELLS lightPawnRank + @ NEGATE 7 +
  CELLS myCastledPawnRankPenalties + @
  SWAP CELLS darkPawnRank + @
  CELLS enemyCastledPawnRankPenalties + @
  + ;

: evalDarkKP ( file+1 -- value )
  DUP CELLS darkPawnRank + @
  CELLS myCastledPawnRankPenalties + @
  SWAP CELLS lightPawnRank + @ NEGATE 7 +
  CELLS enemyCastledPawnRankPenalties + @
  + ;

: evalCenterKPs ( val file -- val )
  TUCK openFile? IF -10 + THEN
  OVER 1+ openFile? IF -10 + THEN
  SWAP 1+ 1+ openFile? IF -10 + THEN ;

1200 CONSTANT endgameThreshold
3100 CONSTANT maxPieceMat  \ $C1C    * 1.32129 = $1000 ( 12 RSHIFT )

: evalLK ( sq -- sq )
  darkPieceMat @ endgameThreshold U< IF
    DUP CELLS kingEndgamePcSq + @ lightScore +! EXIT
  THEN
    DUP CELLS kingLtPcSq + @              ( sq value )
    OVER file DUP 3 U< IF DROP
      1 evalLightKP +
      2 evalLightKP +
      3 evalLightKP 2/ +
    ELSE 4 OVER U< IF DROP
      8 evalLightKP +
      7 evalLightKP +
      6 evalLightKP 2/ +
    ELSE
      evalCenterKPs
    THEN THEN
    darkPieceMat @ M* maxPieceMat SM/REM NIP  \ expensive?
  lightScore +! ;

: evalDK ( sq -- sq )
  lightPieceMat @ endgameThreshold U< IF
    DUP CELLS kingEndgamePcSq + @ darkScore +! EXIT
  THEN
    DUP CELLS kingDkPcSq + @              ( sq value )
    OVER file
    DUP 3 U< IF DROP
      1 evalDarkKP +
      2 evalDarkKP +
      3 evalDarkKP 2/ +
    ELSE 4 OVER U< IF DROP
      8 evalDarkKP +
      7 evalDarkKP +
      6 evalDarkKP 2/ +
    ELSE
      evalCenterKPs
    THEN THEN
    lightPieceMat @ M* maxPieceMat SM/REM NIP \ expensive?
  darkScore +! ;

: evalLP ( sq -- sq )
  DUP DUP CELLS pawnPcSq + @ >R                      ( R: value )
  DUP file 1+ CELLS    ( sq f+1 )
  DUP lightPawnRank +  ( sq f+1 ^lpr )
  ROT rank             ( f+1 ^lpr r )
  OVER @ OVER U> IF
    R> DOUBLED_PAWN_PENALTY + >R THEN
  SWAP  DUP CELL+ @  SWAP CELL- @  MAX ( f+1 r max[lpr[f+2],lpr[f]] )
  DUP 0= IF
    R> ISOLATED_PAWN_PENALTY + >R  DROP ELSE      ( f+1 r )
    OVER U< IF
      R> BACKWARD_PAWN_PENALTY + >R  THEN THEN    ( f+1 r )
  SWAP darkPawnRank +  ( r ^dpr )
  DUP CELL+ @  OVER CELL- @ MIN  SWAP @ MIN  OVER U< IF  ( r )
    DROP R> lightScore +! EXIT ELSE
    NEGATE 7 + PASSED_PAWN_BONUS * R> + lightScore +! THEN ;

: evalDP ( sq -- sq )
  DUP DUP rotate CELLS pawnPcSq + @ >R       ( R: value )
  DUP file 1+ CELLS
  DUP darkPawnRank +
  ROT rank               ( f+1 ^lpr r )
  OVER @ OVER U< IF
    R> DOUBLED_PAWN_PENALTY + >R THEN
  SWAP  DUP CELL+ @  SWAP CELL- @  MIN
  DUP 7 = IF
    R> ISOLATED_PAWN_PENALTY + >R  DROP ELSE      ( f+1 r )
    OVER U> IF
      R> BACKWARD_PAWN_PENALTY + >R  THEN THEN    ( f+1 r )
  SWAP lightPawnRank +
  DUP CELL+ @  OVER CELL- @ MAX  SWAP @ MAX  OVER U> IF  ( r )
    DROP R> darkScore +! EXIT ELSE
    PASSED_PAWN_BONUS * R> + darkScore +! THEN ;

: evalLR ( sq -- sq )
  DUP file 1+ CELLS DUP lightPawnRank + @ 0= IF
    darkPawnRank + @ 7 = IF
      ROOK_OPEN_FILE_BONUS ELSE
      ROOK_SEMI_OPEN_FILE_BONUS THEN
    lightScore +!
  ELSE
    DROP THEN
  DUP rank7? IF
    ROOK_ON_SEVENTH_BONUS lightScore +! THEN ;

: evalDR ( sq -- sq )
  DUP file 1+ CELLS DUP darkPawnRank + @ 7 = IF
    lightPawnRank + @ 0= IF
      ROOK_OPEN_FILE_BONUS ELSE
      ROOK_SEMI_OPEN_FILE_BONUS THEN
    darkScore +!
  ELSE
    DROP THEN
  DUP rank2? IF
    ROOK_ON_SEVENTH_BONUS darkScore +! THEN ;

\ all the evalVector words are ( sq -- sq )

: evalLN   DUP CELLS knightPcSq + @ lightScore +! ;
: evalLB   DUP CELLS bishopPcSq + @ lightScore +! ;
: evalDN   DUP rotate CELLS knightPcSq + @ darkScore +! ;
: evalDB   DUP rotate CELLS bishopPcSq + @ darkScore +! ;
: evalQ    ;
: evalNil  ." Illegal piece on square " DUP .sq CR ;
[UNDEFINED] NOOP [IF]
: NOOP ;
[THEN]

CREATE evalVector            \ indexed by [sq] (piece + color: $11..$26)
  ' NOOP    , ' evalNil , ' evalNil , ' evalNil ,
  ' evalNil , ' evalNil , ' evalNil , ' evalNil ,
  ' evalNil , ' evalNil , ' evalNil , ' evalNil ,
  ' evalNil , ' evalNil , ' evalNil , ' evalNil ,
  ' evalNil , ' evalLP ,  ' evalLN ,  ' evalLB ,
  ' evalLR ,  ' evalQ ,   ' evalLK ,  ' evalNil ,
  ' evalNil , ' evalNil , ' evalNil , ' evalNil ,
  ' evalNil , ' evalNil , ' evalNil , ' evalNil ,
  ' evalNil , ' evalDP ,  ' evalDN ,  ' evalDB ,
  ' evalDR ,  ' evalQ ,   ' evalDK ,  ' evalNil ,

: evalSq ( sq -- sq )   \ the conditional is faster if NOOP is not native
  DUP bd@ ( ?DUP IF ) CELLS evalVector + @ EXECUTE ( THEN ) ;

: eval ( -- value )
  lightPieceMat @ lightPawnMat @ + lightScore !
   darkPieceMat @  darkPawnMat @ +  darkScore !
  ['] evalSq forEverySq
  wtm? IF
    lightScore @ darkScore @ - EXIT ELSE
    darkScore @ lightScore @ - THEN ;

\ *** Search ***

\ Principal Variation tracking
\ ( can be made 2* smaller with more expensive indexing )

CREATE pv MAX_PLY ( 1+ ) MAX_PLY* ( 2/ ) CELLS ALLOT
CREATE pvLen MAX_PLY 1+ CELLS ALLOT

: pvErase   pv MAX_PLY ( 1+ ) MAX_PLY* ( 2/ ) CELLS ERASE ;

: getPV ( ply -- ^mv ) CELLS DUP MAX_PLY* + pv + ;
\ : getPV ( ply -- ^mv ) DUP NEGATE 1+ MAX_PLY 2* + * 2/ CELLS pv + ;
: getPVlen ( ply -- len ) CELLS pvLen + @ ;
: setPVlen ( len ply -- ) CELLS pvLen + ! ;

: resetPVlen  0 ply setPVlen ;

: updatePV ( mv -- )            \ copy mv + pv[ply+1] to pv[ply]
  ply getPV TUCK ! CELL+
  ply 1+ getPVlen ?DUP IF
    >R  ply 1+ getPV SWAP  R@ CELLS MOVE  R> 1+
  ELSE DROP 1 THEN ply setPVlen ;

: .pv   pvLen @ 0 ?DO I CELLS pv + @ .move SPACE LOOP ;

\ *** Move sorting ***

\ Instead of using mvSortFirst shifted to order the high priority moves (PV, killers)
\  use a "vector iterator".  Avoids iterating once to find the move and
\  set its value highest, then iterating again later to find that highest value.
\  The sort word invoked by curSort changes as higher priority moves are exhausted.

CREATE pSort MAX_PLY CELLS ALLOT        \ points into sorts or sortsQ below
: pSortForPly ( -- ^pSort ) ply CELLS pSort + ;
: setFirstSort ( ^pSort -- ) pSortForPly ! ;
: nextSort   CELL pSortForPly +! ;
: curSort ( ^from -- ) pSortForPly @ @ EXECUTE ;

: findMove ( ^from mv -- ^from ^mv|0 )
  DUP 0= IF
    ( FALSE ) EXIT THEN
  OVER lastMovePly SWAP ?DO
    DUP I @ = IF
      DROP I UNLOOP EXIT
    THEN
  genSize +LOOP
  DROP FALSE ;

: swapMoves ( ^m1 ^m2 -- )      \ swap two moves on genStack
  DUP 2@ 2>R  OVER 2@ ROT 2!  2R> ROT 2! ;

\ all sort words are ( ^from -- )   \ from points into genStack
: sortNoop     DROP ;

: sort ( ^from -- )    \ sort by move score
  DUP DUP CELL+ @               ( ^from ^best bestScore )
  OVER CELL+ lastMovePly CELL+ SWAP ?DO
    DUP  I @ U< IF
      2DROP  I CELL-  I @
    THEN
  genSize +LOOP
  0= IF
    2DROP nextSort EXIT THEN    \ sortNoop
  2DUP = IF
    2DROP EXIT THEN             \ already have best move in position
  swapMoves ;

: sortKiller ( ^from mv -- ) nextSort
  findMove ?DUP IF
    swapMoves EXIT THEN
  curSort ;                \ killer isn't valid: try next move
: sortKiller4   killer4 sortKiller ;
: sortKiller3   killer3 sortKiller ;
: sortKiller2   killer2 sortKiller ;
: sortKiller1   killer1 sortKiller ;

: sortCaptures ( ^from -- )
  DUP sort
  CELL+ @ mvSortFirst U< IF  \ no more captures
    nextSort THEN ;          \ sortKiller1

VARIABLE 'firstSort        \ points to sortPV or sortCaptures
VARIABLE 'firstSortQ       \ points to sortPV or sort

\ iterative deepening search is optimal if we first follow the previous PV

: sortPV ( ^from -- ) nextSort
  ply CELLS pv + @ findMove ?DUP IF
    swapMoves EXIT THEN
  CELL 'firstSortQ +!                   \ sort
  CELL 'firstSort  +!  curSort ;        \ sortCaptures

CREATE sorts    \ sort order for main search
  ' sortPV , ( ' sortHash , ) ' sortCaptures , ' sortKiller1 ,
  ' sortKiller2 , ' sortKiller3 , ' sortKiller4 , ' sort , ' sortNoop ,
CREATE sortsQ   \ sort order for quiescence search
  ' sortPV , ( ' sortHash , ) ' sort , ' sortNoop ,

: followPV   sorts 'firstSort !  sortsQ 'firstSortQ ! ;
: initSortQ  'firstSortQ @ setFirstSort ;
: initSort   'firstSort  @ setFirstSort ;

\ Win32Forth word ms@ returns number of milliseconds since system start.
\ Define as appropriate for your Forth dialect

1000 CONSTANT msPerS
3600000 VALUE msMaxThinkTime

[UNDEFINED] ms@ [IF]
  [DEFINED] ?MS [IF] ( -- ms )
  : ms@ ?MS ;           \ iForth
  [ELSE] [DEFINED] cputime [IF] ( -- Dusec )
  : ms@ cputime d+ msPerS um/mod nip ;    \ gforth: Anton Ertl
  [ELSE] [DEFINED] utime [IF] ( -- Dusec )
  : ms@ utime D>S msPerS / ;              \ gforth
  [ELSE] [DEFINED] timer@ [IF] ( -- Dusec )
  : ms@ timer@ >us msPerS um/mod nip ;    \ bigForth
  [ELSE] [DEFINED] gettimeofday [IF] ( -- usec sec )
  : ms@ gettimeofday msPerS MOD msPerS * SWAP msPerS / + ;  \ PFE
  [ELSE]
  CR .( Warning! need definition for a millisecond timer ms@ )
  10 CONSTANT npms
  : ms@ ( -- n ) nodes npms / ;         \ bogus
  [THEN] [THEN] [THEN] [THEN] [THEN]
[THEN]

: .ms ( ms -- ) S>D msPerS UM/MOD 5 U.R ." ." 0 <# # # # #> TYPE ;

0 VALUE msStart
: startTimer   ms@ TO msStart ;
: readTimer ( -- ms ) ms@ msStart - ;

0 VALUE keyHit
: keyHitQ?   keyHit tolower [CHAR] q =  0 TO keyHit ;

: checkTime ( -- )
  readTimer msMaxThinkTime >
  KEY? DUP IF KEY TO keyHit THEN
  OR 1 AND THROW ; \ caught by think

0 CONSTANT drawScore
100 CONSTANT 50moveCount        \ ply 2*
-10000 CONSTANT mateScore

: incNodes ( -- nodes ) nodes 1+ DUP TO nodes ;
: ?checkTime ( nodes -- ) $3FF AND IF EXIT ELSE checkTime THEN ;

: maxSearch? ( -- exit? )
  [ MAX_PLY 1- ] LITERAL ply U<
  [ histStack HIST_STACK histSize* + 1- ] LITERAL histTop U< OR ;

: quiesce ( -b a -- -b value )   ( adds -b -- when recursing )
  incNodes ?checkTime
  resetPVlen
  maxSearch? IF DROP eval EXIT THEN
  eval MAX                      \ a < e:  a = e
  OVER NEGATE OVER > 0= IF
    DROP DUP NEGATE EXIT THEN   \ e >= b: return beta
  genCaps
  initSortQ
  forMovesAtPly ?DO          \ foreach move
    I curSort
    I @ makeMove IF
      OVER RECURSE NEGATE  ( -b a value )   \ negamax
      takeBack
      2DUP < IF                         \ value > a: new best move
        NIP                             \ a = value
        OVER NEGATE OVER > 0= IF                \ value >= b: cutoff
          DROP DUP NEGATE UNLOOP EXIT THEN      \ return beta
        I @ updatePV
      ELSE
        DROP THEN
    THEN
  genSize +LOOP ;            \ return alpha

: asIndex ( sq -- 0-63 ) DUP file SWAP $F0 AND 2/ OR ;

CREATE repsBd 64 CELLS ALLOT
: reps ( -- n )
  fifty 4 U< IF 0 EXIT THEN
  repsBd 64 CELLS ERASE 0 0  ( reps count )
  histTop histSize - DUP fifty 1- histSize* - SWAP DO
    I @ mvFrom asIndex CELLS  repsBd +  DUP @ 1+  DUP ROT !
    IF 1+ ELSE 1- THEN
    I @ mvTo asIndex CELLS  repsBd +  DUP @ 1-  DUP ROT !
    IF 1+ ELSE 1- THEN
    ?DUP 0= IF 1+ 0 THEN
  histSize NEGATE +LOOP DROP ;

\ these things would normally be on the call frame

1 VALUE _depth

CREATE searchFlags MAX_PLY CELLS ALLOT

: sfPly ( -- ^flags ) ply CELLS searchFlags + ;
: sfClear   _depth sfPly ! ;            \ saves depth and clears flags
: sfDepth   sfPly @ $3F AND ;
: sfCheck!  $40 sfPly +! ;
: sfCheck?  sfPly @ $40 AND ;
: sfMoves!  $100 sfPly +! ;
: sfMoves?  sfPly @ $FF00 AND ;

: sfRestoreDepth  sfDepth TO _depth ;   \ undo depth extensions

: .searchHeader ." ply     nodes     time score  pv" CR ;

\ code char: BL depth complete, '&' new best move, '-' '+' fail low/high

: .score ( value -- )
  mateScore ABS OVER ABS 100 + U< IF
    ."  Mat" DUP 0< IF [CHAR] - ELSE [CHAR] + THEN EMIT
    ABS mateScore + ABS 1+ 2/ .
  ELSE 6 .R SPACE THEN ;

[DEFINED] DEFER [IF]
\ support for test suites
DEFER onSearchStatus    ' NOOP IS onSearchStatus ( value code )
[ELSE]
: onSearchStatus ; IMMEDIATE  \ noop
[THEN]

: .searchStatus ( value codeChar -- ) onSearchStatus \ BASE @ >R DECIMAL
   EMIT readTimer  sfDepth 2 .R  nodes 10 U.R
  .ms ( value ) .score SPACE .pv CR ; \ R> BASE ! ;

0 VALUE moveCount
: .curMove ( ^move -- )
  moveCount 1+ DUP U. TO moveCount
  DUP @ .move SPACE  CELL+ @ U.  8 SPACES 13 EMIT ;

\ null move heuristic, R=2
\ Don't search at a position if we are doing fine even if we make no move.

: makeNullMove   _depth -2 + TO _depth
  0 TO ep  0 histPush  switchColors  ply 1+ TO ply ; \ !!! fifty 1+

: undoNullMove   _depth 2 + TO _depth
  histPop ABORT" Not a null move!" DROP  switchColors  ply 1- TO ply ;

: tryNullMove? ( -- tf )
  \ _depth 0> 0= IF FALSE EXIT THEN     \ not at leaf
  lastMoveCheck? IF FALSE EXIT THEN     \ not in check
  ply 0= IF FALSE EXIT THEN             \ and not at root
  histTop histSize - @ 0= IF FALSE EXIT THEN \ and last move not null
  darkPieceMat @ lightPieceMat @ + ( MIN) endgameThreshold < IF FALSE EXIT THEN
  genInitPly makeNullMove TRUE ;        \ and not endgame [zugzwang]

: _search ( -b a -- -b value )     \ recursive
  incNodes ?checkTime
  resetPVlen
  ply IF reps IF DROP drawScore EXIT THEN ELSE 0 TO moveCount THEN   \ draw: repeated pos
  maxSearch? IF DROP eval EXIT THEN
  sfClear
  lastMoveCheck? IF
    sfCheck! ELSE            \ extend search a ply
    _depth 1- TO _depth THEN \ undo before exit with sfRestoreDepth
  tryNullMove? IF  \ _depth 2-
    OVER DUP NEGATE 1- SWAP ( b-1 -b )
    _depth 0> IF RECURSE ELSE quiesce THEN NEGATE ( b-1 value )
    undoNullMove \ _depth 2+
    < IF
      DROP DUP NEGATE sfRestoreDepth EXIT THEN
  THEN
  gen
  initSort
  forMovesAtPly ?DO          \ foreach move
    I curSort
    ply 0= IF 5 sfDepth U< IF I .curMove THEN THEN  ( optional)
    I @ makeMove IF          \ ply++
      OVER _depth lastMoveCheck? OR IF RECURSE ELSE quiesce THEN NEGATE
      takeBack               \ ply--
      sfMoves!
      ( -b a value ) 2DUP < IF  \ value > a: new best move
        NIP ( or MAX )          \ a = value
        _depth 1+ I @ mvHistory NIP +!
        OVER NEGATE OVER > 0= IF        \ value >= b: cutoff
          ply 0= IF I @ updatePV THEN   \ save fail-high move for re-search
          I @ setKiller
          DROP DUP NEGATE sfRestoreDepth UNLOOP EXIT   \ return beta
        THEN
        I @ updatePV
        ply 0= IF 3 sfDepth U< IF DUP [CHAR] & .searchStatus THEN THEN
      ELSE
        DROP THEN
    THEN
  genSize +LOOP
  ply getPVlen IF ply getPV @ setKiller THEN
  sfRestoreDepth
  sfMoves? IF
    fifty 50moveCount U< 0= IF
      DROP drawScore THEN EXIT  \ draw, 50-move rule (else return alpha)
  ELSE
    DROP sfCheck? IF
      mateScore ply + ELSE      \ checkmate
      drawScore THEN            \ stalemate
  THEN ;

MAX_PLY 2/ VALUE maxDepth

: startDepth ( -- n ) pvErase 1 ;

: ?research ( alpha -beta value -- value )
  OVER NEGATE OVER > 0= IF  \ fail high: re-search
    wtm? inCheck? TO lastMoveCheck?
    followPV
    3 sfDepth U< IF DUP [CHAR] + .searchStatus THEN 2DROP
    mateScore DUP _search NIP
  ELSE NIP
  2DUP < 0= IF  \ fail low: re-search
    wtm? inCheck? TO lastMoveCheck?
    followPV  1 pvLen !
    3 sfDepth U< IF DUP [CHAR] - .searchStatus THEN DROP
    mateScore DUP _search NIP
  THEN THEN NIP ;

: thinker
  0 TO ply
  historyAge
  CR .searchHeader
  startTimer
  mateScore DUP ( alpha -beta )
  0 TO nodes
  maxDepth startDepth DO  \ iterative deepening
    I TO _depth
    wtm? inCheck? TO lastMoveCheck?
    followPV
    OVER _search  ( alpha -beta value )
    ?research     ( value )
    DUP BL .searchStatus
    mateScore 100 + ABS OVER ABS U< IF DUP LEAVE THEN   \ mate
    pawnValue 2/ - DUP pawnValue + NEGATE   \ restrict a-b window for more cutoffs
  LOOP 2DROP ;

: ?thinkAbort ( err -- )
  DUP 1 <> IF THROW EXIT THEN DROP
  ." Time's up! " nodes . ." nodes" readTimer .ms ."  seconds" CR
  ply 0 DO takeBack LOOP
  0 TO ply sfRestoreDepth ;

: .thinkResult
  readTimer ?DUP IF
\    nodes msPerS ROT */  ELSE
\ >>>  Jos: Oct. 20th, 2003 The following line prevents a divide by 0
     msPerS DS>F nodes DS>F F* DS>F F/ F>DS ELSE
    ." at least " nodes THEN
  U. ." nps  " ;

: think ( -- err ) ['] thinker CATCH DUP ?thinkAbort .thinkResult ;

\ *** high level (validated) ***

: initVars   0 TO ply  0 TO ep  0 TO fifty
  evalSetup initHist historyErase killersErase ;

: initBoard
  eraseBoard
  ROOK KNIGHT BISHOP KING QUEEN BISHOP KNIGHT ROOK   8 0 DO
    DUP DARK + I       bd!   \ top row of pieces
    DARKPAWN   I $10 + bd!   \ pawns
    LIGHTPAWN  I $60 + bd!   \ pawns
    LIGHT +    I $70 + bd!   \ bottom row of pieces
  LOOP
  sqE1 lkSq !  sqE8 dkSq !
  allCastleBits TO castle
  setWtm
  initVars ;

: str>sq ( c-addr -- sq T | x F )
  DUP C@ tolower [CHAR] a - ( ^c file )
  SWAP CHAR+ C@ [CHAR] 8 SWAP - ( file rank )
  2DUP OR 0 8 WITHIN IF
    fileRank>sq TRUE ELSE
    DROP FALSE THEN ;

: char>piece ( c -- piece | 0 )
  0 SWAP
  KING 1+ PAWN DO
    I CELLS symbols + @
    2DUP = IF 2DROP
      LIGHT I OR SWAP LEAVE
    ELSE tolower OVER = IF DROP
      DARK I OR SWAP LEAVE
    THEN THEN
  LOOP DROP ;

: str>mv ( str count -- mv )
  4 < ABORT" Malformed move."
  DUP str>sq 0= ABORT" Malformed move."
  OVER 2 CHARS + str>sq 0= ABORT" Malformed move."
  fromTo>mv  0 TO ply  gen  ( str mv )
  forMovesAtPly ?DO
    DUP I @ $FFFF AND = IF
      DROP I        \ found! its legal
      DUP @ promoteBit AND IF   \ get promotion piece
        SWAP 4 CHARS + C@ char>piece piece
        DUP KNIGHT KING WITHIN 0= IF DROP QUEEN THEN
        KNIGHT - genSize* +
      ELSE NIP THEN
      @ UNLOOP EXIT
    THEN
  genSize +LOOP
  ABORT" Illegal move." ;

: inmv ( "e2e4" -- mv )          \ usage: inmv e2e4
  BASE @ >R DECIMAL              \ important! e2e4 is a hex number!
  BL WORD COUNT
  R> BASE !  str>mv ;

: epdstr>board ( str count -- )
  OVER + SWAP   ( ^end ^cur )
  0 >R                             \ R: current sq
  eraseBoard   -1 lkSq !  -1 dkSq !
  DUP C@ [CHAR] / = IF CHAR+ THEN
  BEGIN
    DUP C@
    DUP [CHAR] 0 -
    DUP 1 9 WITHIN IF
      R> + >R                   \ 1-8 empty squares
    ELSE DROP DUP [CHAR] / = IF
      R> $F0 AND So + >R    \ next rank, 1st file
    ELSE DUP char>piece ?DUP IF
      DUP piece KING = IF
        DUP light? IF lkSq ELSE dkSq THEN
        DUP @ 0< 0= ABORT" Can't have multiple kings of the same color!"
        R@ SWAP !
      THEN
      R> TUCK bd! 1+ >R         \ piece
    ELSE
      CR ." Bad EPD character: " EMIT ."  at " R> .sq ABORT
    THEN THEN THEN
  DROP CHAR+ 2DUP = UNTIL
  lkSq @ 0< ABORT" Missing a white king!"
  dkSq @ 0< ABORT" Missing a black king!"
  R> DROP 2DROP ;

: epd ( "epd" "w|b" -- )
  BL WORD COUNT epdstr>board
  BL WORD COUNT 1 <> ABORT" Bad color!"
  C@ tolower DUP [CHAR] w = IF DROP setWtm
  ELSE [CHAR] b = IF setBtm
  ELSE TRUE ABORT" Bad color!" THEN THEN
  0 TO castle
  initVars
  wtm? 0= inCheck? ABORT" Side to move can capture king!" ;

: ?epdCB ( "KQkq" testChar bit -- "Qkq" )
  >R OVER C@ = IF R> castle OR TO castle  CHAR+ ELSE R> DROP THEN ;
: epdFlags ( "KQkq|-" "ep|-" -- )
  BL WORD COUNT  2DUP + 0 SWAP C!  IF  0 TO castle
    [CHAR] K wkCastleBit ?epdCB
    [CHAR] Q wqCastleBit ?epdCB
    [CHAR] k bkCastleBit ?epdCB
    [CHAR] q bqCastleBit ?epdCB DROP
  THEN
  BL WORD COUNT IF
    str>sq 0= IF DROP 0 THEN TO ep
  THEN ;

: .result? ( -- tf )
  FALSE 0 TO ply gen
  TRUE forMovesAtPly ?DO
    I @ makeMove IF takeBack DROP FALSE LEAVE THEN
  genSize +LOOP
  IF CR
    wtm? inCheck? IF
      wtm? IF ." White" ELSE ." Black" THEN ."  is checkmated"
    ELSE
      ." Stalemate"
    THEN
    DROP TRUE
  ELSE reps 3 = IF
    CR ." Draw by repetition" DROP TRUE
  ELSE fifty 50moveCount = IF
    CR ." Draw by fifty-move rule" DROP TRUE
  THEN THEN THEN CR ;

: retract   histTop histStack - IF takeBack THEN ;

\ *** User Commands ***

\ other words usable as commands: .board .epd .moveList

: new   initBoard .board ;            \ setup a new game

: sd ( depth -- ) 1 MAX 1+ MAX_PLY 1- MIN TO maxDepth ; \ Set Depth

: st ( seconds -- ) msPerS * TO msMaxThinkTime ;        \ Set Time

: go                  \ ask the computer to choose move
  think DROP    \ press any key to stop thinking and make a move
  pv @ ?DUP IF
    ." Move found: " DUP .move CR
    makeMove DROP .board
  THEN .result? DROP ;

: mv ( "e2e4" -- )    \ for alternating turns with the computer
  inmv makeMove 0= ABORT" Can't move there."
  .board .result? 0= IF go THEN ;

: domove ( "e2e4" -- )  \ for forcing a sequence of moves
  inmv makeMove 0= ABORT" Can't move there."
  .board .result? DROP ;

: undo   retract .board ;   \ take back one ply (switches sides)

: undo2   retract retract .board ;   \ take back one full move


( >>> )  DEFER  .whoseTurn-ogl    ' NOOP IS .whoseTurn-ogl

: .whoseTurn ( - )
    wtm? .whoseTurn-ogl  ( >>> )
    IF ." White to move" ELSE ." Black to move" THEN CR ;

: rotateBoard   blackAtBottom? 0= TO blackAtBottom? .board ;
: showCoords    showCoords? 0= TO showCoords? .board ;

: autoDepth ( depth1 depth2 -- )
  BEGIN
    SWAP DUP sd go
  .result? keyHitQ? OR UNTIL 2DROP ;

: autoTime ( time1 time2 -- )
  BEGIN
    SWAP DUP st go
  .result? keyHitQ? OR UNTIL 2DROP ;

\ EPD position setup (great for testing)
\ examples:  setup2 rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR W KQkq -
\ setup 2r2rk1/1bqnbpp1/1p1ppn1p/pP6/N1P1P3/P2B1N1P/1B2QPP1/R2R2K1 b

: setup ( "epd" "w|b" -- ) epd .board .whoseTurn ;
: setup2 ( epd w|b KQkq|- ep|- -- ) epd epdFlags .board .whoseTurn ;

: fcp-help  CR
." go           Make the computer move (hit any key to stop thinking)" CR
." domove e2e4  Move a piece from square e2 to square e4" CR
." undo         Take back the last move" CR
." mv h7h8Q     domove h7h8Q go (promote to a queen)" CR
." mv e1g1      castle kingside" CR
." undo2        undo undo" CR
." 5 sd         Set maximum depth for computer search" CR
." 10 st        Set maximum thinking time in seconds" CR
." new          Start a new game" CR
." rotateBoard  Display black at the bottom of the board" CR
." showCoords   Display algebraic coordinates" CR
." .board       Display the board" CR
." .moveList    Display the list of moves played so far" CR
." .epd         Display the EPD description of the board" CR
." .whoseTurn   Display which color moves next" CR
." setup EPD    Setup an EPD position" CR
." setup2 EPD   Full EPD, with castling and en-passant square" CR ;

\ *** EXECUTE WHEN LOADING ***

CR .( FCP 1.0 loaded. )
UNUSED - . .( bytes used. )
.( Type "fcp-help" for instructions. )

new

\ BASE !

