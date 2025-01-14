( 28.Mar.2000 Andrey Cherezov  Copyright [C] RU FIG

  ������������ ���� ��������� �������:
  Ruvim Pinka; Dmitry Yakimov; Oleg Shalyopa; Yuriy Zhilovets;
  Konstantin Tarasov; Michail Maximov.

  !! �������� ������ � SPF4.
)

( ������� ���������� ��-����� ���������� �����������.
  ����������� ��� ������������� LOCALS ��������� 94.

  ���������� ��������� ����������, ������� ������ ������
  �������� ����� � ������������ �������� ������ �������
  ����� ����������� � ������� ����� "{". ������ ����������� 
  ����� ������������ �����������, �������� �������� ������� �����
  { ������_������������������_������� \ ��.������.������� -- ��� ������ }
  ��������:

  { a b c d \ e f -- i j }

  ��� { a b c d \ e f[ EVALUATE_��������� ] -- i j }
  ��� ������ ��� ��� ���������� f[ ����� ������� �� ����� ��������� �������
  ������ ������ n ����. ������������� ���������� f[ ���� ����� ������ �����
  �������. \� ����� MPE\

  ��� { a b c d \ e [ 12 ] f -- i j }
  ��� ������ ��� ��� ���������� f ����� ������� �� ����� ��������� �������
  ������ ������ 12 ����. ������������� ���������� f ���� ����� ������ �����
  �������. 

  ����� "\ ��.������.�������" ����� �������������, ��������:

  { item1 item2 -- }

  ��� ���������� ��-���� ������������� �������� ����� �
  ����� ��������� ��� ���� ���������� � ������ ������ �����
  � ������������� ����������� ����� ��� ������ �� ����.

  ��������� � ����� ��������� ���������� - ��� � VALUE-����������
  �� �����. ���� ����� ����� ����������, �� ������������ "^ ���"
  ��� "AT ���".


  ������ \ ����� ������������ |
  ������ -> ����� ������������ TO

  �������:

  : TEST { a b c d \ e f -- } a . b . c .  b c + -> e  e .  f .  ^ a @ . ;
   Ok
  1 2 3 4 TEST
  1 2 3 5 0 1  Ok

  : TEST { a b -- } a . b . CR 5 0 DO I . a . b . CR LOOP ;
   Ok
  12 34 TEST
  12 34
  0 12 34
  1 12 34
  2 12 34
  3 12 34
  4 12 34
   Ok

  : TEST { a b } a . b . ;
   Ok
  1 2 TEST
  1 2  Ok

  : TEST { a b \ c } a . b . c . ;
   Ok
  1 2 TEST
  1 2 0  Ok

  : TEST { a b -- } a . b . ;
   Ok
  1 2 TEST
  1 2  Ok

  : TEST { a b \ c -- d } a . b . c . ;
   Ok
  1 2 TEST
  1 2 0  Ok

  : TEST { \ a b } a . b .  1 -> a  2 -> b  a . b . ;
   Ok
  TEST
  0 0 1 2  Ok

  ����� ��������� ���������� ���������� � ������������
  ��������� ������� ������ � ������ ���������� �����, �
  ����� ����� ���������� � ����� ����������.

  ������������ ����������� "{ ... }" ������ ������ ����������� �����
  ������ ���� ���.

  ���������� ���� ���������� ��������� � ������� ������� ����������
  ������ ��� �����:
  ������� "vocLocalsSupport" � "{"
  ��� ��������� ������ "��������" � �������, ������������ ��
  �� �������������.
)

MODULE: vocLocalsSupport

USER widLocals
USER uLocalsCnt
USER uLocalsUCnt
USER uPrevCurrent
USER uAddDepth

: (Local^) ( N -- ADDR )
  RP@ +
;
: LocalOffs ( n -- offs )
  uLocalsCnt @ SWAP - CELLS CELL+ uAddDepth @ +
;

BASE @ HEX
: CompileLocalsInit
  uPrevCurrent @ SET-CURRENT
  uLocalsCnt  @ uLocalsUCnt @ - ?DUP IF CELLS LIT, POSTPONE DRMOVE THEN
  uLocalsUCnt @ ?DUP
  IF 
     LIT, POSTPONE (RALLOT)
  THEN
  uLocalsCnt  @ ?DUP 
  IF CELLS RLIT, ['] (LocalsExit) RLIT, THEN
;

: CompileLocal@ ( n -- )
  ['] DUP MACRO,
  LocalOffs DUP  SHORT?
  OPT_INIT SetOP
  IF    8B B, 44 B, 24 B, B, \ mov eax, offset [esp]
  ELSE  8B B, 84 B, 24 B,  , \ mov eax, offset [esp]
  THEN  OPT
  OPT_CLOSE
;

\ : CompileLocal@ ( n -- )
\   LocalOffs LIT, POSTPONE RP+@
\ ;

: CompileLocal! ( n -- )
  LocalOffs DUP  SHORT?
  OPT_INIT SetOP
  IF    89 B, 44 B, 24 B, B, \ mov  offset [esp], eax
  ELSE  89 B, 84 B, 24 B,  , \ mov  offset [esp], eax
  THEN  OPT
  OPT_CLOSE
  ['] DROP MACRO,
;

: CompileLocalRec ( u -- )
  LocalOffs DUP
  ['] DUP MACRO,
  SHORT?
  OPT_INIT SetOP
  IF    8D B, 44 B, 24 B, B, \ lea eax, offset [esp]
  ELSE  8D B, 84 B, 24 B,  , \ lea eax, offset [esp]
  THEN  OPT
  OPT_CLOSE
;

BASE !

: LocalsStartup
  TEMP-WORDLIST widLocals !
  GET-CURRENT uPrevCurrent !
  ALSO vocLocalsSupport
  widLocals @ PUSH-ORDER DEFINITIONS
  uLocalsCnt 0!
  uLocalsUCnt 0!
  uAddDepth 0!
;
: LocalsCleanup
  PREVIOUS PREVIOUS
  widLocals @ FREE-WORDLIST
;

: ProcessLocRec ( "name" -- u )
  [CHAR] ] PARSE
  STATE 0!
  EVALUATE CELL 1- + CELL / \ ������ ������� 4
  -1 STATE !
  DUP uLocalsCnt +!
  uLocalsCnt @ 1-
;

: CreateLocArray
  ProcessLocRec
  CREATE ,
;

: LocalsRecDoes@ ( -- u )
  DOES> @ CompileLocalRec
;

: LocalsRecDoes@2 ( -- u )
  ProcessLocRec ,
  DOES> @ CompileLocalRec
;

: LocalsDoes@
  uLocalsCnt @ ,
  uLocalsCnt 1+!
  DOES> @ CompileLocal@
;

: ;; POSTPONE ; ; IMMEDIATE


: ^ 
  ' >BODY @ 
  CompileLocalRec
; IMMEDIATE


: -> ' >BODY @ CompileLocal!  ; IMMEDIATE

WARNING DUP @ SWAP 0!

: AT
  [COMPILE] ^
; IMMEDIATE

: TO ( "name" -- )
  >IN @ NextWord widLocals @ SEARCH-WORDLIST 1 =
  IF >BODY @ CompileLocal! DROP
  ELSE >IN ! [COMPILE] TO
  THEN
; IMMEDIATE

WARNING !

: � POSTPONE -> ; IMMEDIATE

WARNING @ WARNING 0!
\ ===
\ ��������������� ��������������� ���� ��� ����������� ������������
\ ��������� ���������� ������  ����� DO LOOP  � ���������� �� ���������
\ ����������� ����� ���������  �������   >R   R>

: DO    POSTPONE DO     [  3 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
: ?DO   POSTPONE ?DO    [  3 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
: LOOP  POSTPONE LOOP   [ -3 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
: +LOOP POSTPONE +LOOP  [ -3 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
: >R    POSTPONE >R     [  1 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
: R>    POSTPONE R>     [ -1 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
: RDROP POSTPONE RDROP  [ -1 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
: 2>R   POSTPONE 2>R    [  2 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
: 2R>   POSTPONE 2R>    [ -2 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE

\ ===

\ { ... | ... -- _____ }
: ParseLocals3
  BEGIN
   PARSE-NAME
   DUP 0= ABORT" Locals bad syntax (3)"
   2DUP S" }" COMPARE 0= IF 2DROP EXIT THEN
   2DROP
  AGAIN
;

\ { ... | _____ -- ... }
: ParseLocals2
  BEGIN
   PARSE-NAME
   DUP 0= ABORT" Locals bad syntax (2)"
   2DUP S" --" COMPARE 0= IF 2DROP ParseLocals3 EXIT THEN
   2DUP S" }" COMPARE 0= IF 2DROP EXIT THEN
   2DUP S" [" COMPARE 0= 
   IF 
     2DROP CreateLocArray LocalsRecDoes@
   ELSE 
     CREATED
     LATEST-NAME NAME>STRING CHARS + CHAR- C@
     [CHAR] [ =
     IF
       LocalsRecDoes@2
     ELSE
       LocalsDoes@ 1 
     THEN
   THEN
   uLocalsUCnt +! IMMEDIATE
  AGAIN
;

\ { _____ | ... -- ... }
: ParseLocals1
  BEGIN
    PARSE-NAME
    DUP 0= ABORT" Locals bad syntax (1)"
    2DUP S" |" COMPARE 0= IF 2DROP ParseLocals2 EXIT THEN
    2DUP S" \" COMPARE 0= IF 2DROP ParseLocals2 EXIT THEN
    2DUP S" --" COMPARE 0= IF 2DROP ParseLocals3 EXIT THEN
    2DUP S" }" COMPARE 0= IF 2DROP EXIT THEN

    CREATED LocalsDoes@ IMMEDIATE
  AGAIN
;

\  uLocalsCnt  @ ?DUP 
\  IF CELLS RLIT, ['] (LocalsExit) RLIT, THEN

: ;  LocalsCleanup
     S" ;" EVAL-WORD
; IMMEDIATE

WARNING !

\ =====================================================================

EXPORT

: {
  LAST @ >R
  LocalsStartup
  ParseLocals1
  CompileLocalsInit
  R> LAST !
;; IMMEDIATE

;MODULE
