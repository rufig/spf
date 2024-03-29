\ Work in spf3, spf4
( 28.Mar.2000 Andrey Cherezov  Copyright [C] RU FIG

  ������������ ���� ��������� �������:
  Ruvim Pinka; Dmitry Yakimov; Oleg Shalyopa; Yuriy Zhilovets;
  Konstantin Tarasov; Michail Maximov.
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
  ��������� ���.
  : test { this } { a b } a this 4 + ! b this 8 + ! ;
  CREATE th 20 ALLOT
  12 5 th test 

  ���������� ���� ���������� ��������� � ������� ������� ����������
  ������ ��� �����:
  ������� "vocLocalsSupport" � "{"
  ��� ��������� ������ "��������" � �������, ������������ ��
  �� �������������.
)
( 23.03.2002 Andrey Filatkin
  ��������� ��������� ���������� ��� �������� ������ �� ���������� COM.
  ���� ������ ������������� ����� ������ ������.������� � 
  ���������� ����� �������� - \v.
  ��� ���� ����������, �� ������ ����, ��� ������� ������� ���������� release.

: test { \v excel }
  Z" Excel.Application" create-object THROW TO excel
  TRUE _bool excel ::! Visible
;
)

REQUIRE [IF] lib/include/tools.f

VOCABULARY vocLocalsSupport
GET-CURRENT ALSO vocLocalsSupport DEFINITIONS

USER widLocals
USER uLocalsCnt
USER uLocalsUCnt
USER uLocalsCOMCnt
USER uPrevCurrent
USER uAddDepth
USER lLocalsCnt
USER lLocalsUCnt
USER lLocalsCOMCnt

: LocalOffs ( n -- offs )
  uLocalsCnt @ SWAP - 1- CELLS uAddDepth @ +
;

: ClearObj ( R: n --)
  R> R>
  RP@ SWAP 0
  DO
    DUP @ ?DUP IF 2 CELLS OVER @ + @ API-CALL DROP THEN \ ����� ������ release
    CELL+
  LOOP
  DROP
  >R
;

\ ����� ������� � � spf3 � � spf4
VERSION 400000 < [IF]
\ spf3
  : CompileLocalsInit
    uPrevCurrent @ SET-CURRENT
    uLocalsCnt  @ uLocalsUCnt @ - uLocalsCOMCnt @ -
    ?DUP IF CELLS LIT, POSTPONE DRMOVE THEN
    uLocalsUCnt @ uLocalsCOMCnt @ + ?DUP
    IF LIT, POSTPONE (RALLOT) THEN
  ;
  : CompileLocal@ ( n -- )
    LocalOffs LIT, POSTPONE RP+@
  ;
  : CompileLocal! ( n -- )
    LocalOffs LIT, POSTPONE RP+!
  ;
  : CompileLocalRec ( u -- )
    LocalOffs LIT, POSTPONE RP+
  ;
[ELSE]
\ spf4
  : CompileLocalsInit
    uPrevCurrent @ SET-CURRENT
    uLocalsCnt @ lLocalsCnt @ -
    uLocalsUCnt @ lLocalsUCnt @ - -
    uLocalsCOMCnt @ lLocalsCOMCnt @ - -
    ?DUP IF
      DUP
      1- DUP CELLS SWAP 0 ?DO
        0xFF C, 0x75 C, CELL- DUP C, \ PUSH XX [EBP]
      LOOP
      DROP
      0x50 C, \ PUSH EAX 
      0 DO S" DROP" EVALUATE LOOP
    THEN
    uLocalsUCnt @ lLocalsUCnt @ -
    uLocalsCOMCnt @ lLocalsCOMCnt @ -
    + ?DUP IF
      DUP 9 < IF \ ���� �������������������� �������� �������, �� ������� �����
        0 LIT,
        0 DO 0x50 C, ( PUSH EAX) LOOP
        S" DROP" EVALUATE
      ELSE
        LIT, POSTPONE (RALLOT)
      THEN
    THEN
  ;

  : CompileLocal@ ( n -- )
    ['] DUP MACRO,
    LocalOffs DUP  SHORT?
    OPT_INIT SetOP
    IF
      ?DUP IF 0x8B C, 0x44 C, 0x24 C, C, \ mov eax, offset [esp]
      ELSE 0x8B C, 0x04 C, 0x24 C, \ mov eax, [esp]
      THEN
    ELSE  0x8B C, 0x84 C, 0x24 C,  , \ mov eax, offset [esp]
    THEN  OPT
    OPT_CLOSE
  ;

  : CompileLocal! ( n -- )
    LocalOffs DUP  SHORT?
    OPT_INIT SetOP
    IF    0x89 C, 0x44 C, 0x24 C, C, \ mov  offset [esp], eax
    ELSE  0x89 C, 0x84 C, 0x24 C,  , \ mov  offset [esp], eax
    THEN  OPT
    OPT_CLOSE
    ['] DROP MACRO,
  ;

  : CompileLocalRec ( u -- )
    LocalOffs DUP
    ['] DUP MACRO,
    SHORT?
    OPT_INIT SetOP
    IF    0x8D C, 0x44 C, 0x24 C, C, \ lea eax, offset [esp]
    ELSE  0x8D C, 0x84 C, 0x24 C,  , \ lea eax, offset [esp]
    THEN  OPT
    OPT_CLOSE
  ;
[THEN]

: LocalsStartup
  widLocals @ 0= IF
    ALSO vocLocalsSupport
    TEMP-WORDLIST widLocals !
    GET-CURRENT uPrevCurrent !
    ALSO widLocals @ CONTEXT ! DEFINITIONS
    uLocalsCnt 0!
    uLocalsUCnt 0!
    uLocalsCOMCnt 0!
    lLocalsCnt 0!
    lLocalsUCnt 0!
    lLocalsCOMCnt 0!
    uAddDepth 0!
  ELSE
    widLocals @ SET-CURRENT
    uLocalsCnt @ lLocalsCnt !
    uLocalsUCnt @ lLocalsUCnt !
    uLocalsCOMCnt @ lLocalsCOMCnt !
  THEN
;
: LocalsCleanup
  PREVIOUS PREVIOUS
  widLocals @ ?DUP IF FREE-WORDLIST widLocals 0! THEN
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
  [CHAR] [ SKIP
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

: COMLocalsDoes@
  uLocalsCnt @ ,
  uLocalsCnt 1+!
  uLocalsCOMCnt 1+!
  DOES> @ CompileLocal@
;

: ;; POSTPONE ; ; IMMEDIATE

: ^  ' >BODY @ CompileLocalRec ; IMMEDIATE

: -> ' >BODY @ CompileLocal!  ; IMMEDIATE

WARNING DUP @ SWAP 0!

[DEFINED] AT [IF]
  : AT
    >IN @ NextWord ROT >IN ! widLocals @ SEARCH-WORDLIST
    IF DROP POSTPONE ^ ELSE POSTPONE AT THEN
  ; IMMEDIATE
[ELSE]
  : AT
    POSTPONE ^
  ; IMMEDIATE
[THEN]

: TO ( "name" -- )
  >IN @ NextWord ROT >IN ! widLocals @ SEARCH-WORDLIST
  IF DROP POSTPONE -> ELSE POSTPONE TO THEN
; IMMEDIATE

WARNING !

: NoLimit? ( -- f )
  BL SKIP PeekChar
  DUP [CHAR] \ <>
  OVER [CHAR] | <> AND
  OVER [CHAR] - <> AND
  OVER [CHAR] } <> AND
  SWAP [CHAR] ) <> AND
;

: ParseLocals
  BEGIN
    NoLimit?
  WHILE
    CREATE LocalsDoes@ IMMEDIATE
  REPEAT
;
: ParseULocals
  BEGIN
    NoLimit?
  WHILE
    PeekChar [CHAR] [ =
    IF CreateLocArray LocalsRecDoes@
    ELSE
      CREATE LATEST-NAME NAME>CSTRING DUP C@ + C@
      [CHAR] [ = IF  LocalsRecDoes@2  ELSE  LocalsDoes@ 1  THEN
    THEN
    uLocalsUCnt +!
    IMMEDIATE
  REPEAT
;
: ParseCOMLocals
  BEGIN
    NoLimit?
  WHILE
    CREATE COMLocalsDoes@ IMMEDIATE
  REPEAT
;

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

VERSION 400000 < [IF]
: (EXIT)
  uLocalsCnt  @ ?DUP 
  IF
    uLocalsCOMCnt @ ?DUP
    IF LIT, POSTPONE >R POSTPONE ClearObj THEN
    CELLS LIT, POSTPONE >R ['] (LocalsExit) LIT, POSTPONE >R
  THEN
;
[ELSE]
: (EXIT)
  uLocalsCnt  @ ?DUP 
  IF
    uLocalsCOMCnt @ ?DUP
    IF RLIT, POSTPONE ClearObj THEN
    CELLS DUP SHORT?
    IF 0x83 C, 0xC4 C, C, \ ADD ESP, # 127
    ELSE 0x81 C, 0xC4 C, , \ ADD ESP, # 128
    THEN
  THEN
;
[THEN]

: EXIT  (EXIT) POSTPONE EXIT ; IMMEDIATE

: ;  (EXIT)  LocalsCleanup  S" ;" EVALUATE ; IMMEDIATE

WARNING !

\ =====================================================================
SET-CURRENT

: {
  LocalsStartup
  ParseLocals
  PeekChar DUP [CHAR] \ =  SWAP [CHAR] | = OR
  IF
    >IN 1+!  PeekChar [CHAR] v =
    IF >IN 1+! ParseCOMLocals
    ELSE
      ParseULocals
      PeekChar DUP [CHAR] \ =  SWAP [CHAR] | = OR
      IF
        >IN 1+!  PeekChar [CHAR] v = IF >IN 1+! ParseCOMLocals THEN
      THEN
    THEN
  THEN
  [CHAR] } PARSE 2DROP
  CompileLocalsInit
;; IMMEDIATE

PREVIOUS
