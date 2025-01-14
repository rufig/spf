\ (c) 2006 Dmitry Yakimov, support@activekitten.com

: PARSE-NAME NextWord ;

: S, ( addr u -- )
\ ��������������� u ���� ������������ ������ 
\ � ��������� ���� ���������� u ���� �� addr.
  CHARS DP @ SWAP DUP ALLOT MOVE
;

: S", ( addr u -- ) 
\ ���������� � ������������ ������ ������, �������� addr u, 
\ � ���� ������ �� ���������.
  DUP C, S,
;


(

���������������� : � ;

TODO:

+ ���� ���� ����� ���� �� ��������� � help, ����� �� ?

)

0 VALUE docHandle
VARIABLE xmlIndent
0 VALUE moduleComment?
0 VALUE includeBody?
0 VALUE generateHelp?
0 VALUE comment?
0x1FFFFFFF VALUE TC-IMAGE-BASE

: XMLHELP-ON
    TRUE TO generateHelp?
;

: XMLHELP-OFF
    FALSE TO generateHelp?
;

: +indent 1 xmlIndent +! ;
: -indent -1 xmlIndent +! ;

: (HELP-OUT) ( addr u )
   docHandle
   IF
     docHandle WRITE-FILE THROW
   ELSE TYPE
   THEN
;

: HELP-EMIT ( c )
   >R RP@ 1 (HELP-OUT) R> DROP
;

: HELP-SPACES ( n )
   0 ?DO BL HELP-EMIT LOOP
;

: HELP-OUT ( addr u )
    xmlIndent @ 2* HELP-SPACES (HELP-OUT)
;

: "h [CHAR] " HELP-EMIT ;
: crh LT 2 (HELP-OUT) ;

: HELP-OUT()  S" ( " (HELP-OUT) (HELP-OUT) [CHAR] ) HELP-EMIT ;

: OPEN-TAG ( addr u )
    xmlIndent @ 2* HELP-SPACES
    [CHAR] < HELP-EMIT
    (HELP-OUT) BL HELP-EMIT
;

: CLOSE-TAG
    [CHAR] > HELP-EMIT crh
;

: LINK,     ( list -- )    \ �������������� ����� � ���������� �����
         HERE  OVER @ ,  SWAP !  ;

VARIABLE CHAINS

\ �������������� ���������� CHAINS � 4 + � DOES> ��� ����, �����
\ ��� CHAINS ���� ����� �� ������� ���������, ��� � ��� ������
\ �������

: CHAIN ( "name" -- )
   CREATE
       CHAINS LINK,    
       0 ,
   DOES> CELL+
;

\ ���������� �������� ���� xt �������� ��������� �� ������
: ITERATE-LIST2 ( list xt -- f )
    >R
    BEGIN @ ?DUP
    WHILE DUP CELL+ R@ 
          ROT >R
          EXECUTE IF 2R> 2DROP TRUE EXIT 
                  ELSE R>
                  THEN
    REPEAT RDROP 0
;


CHAIN SPECIAL-CHARS

: SPECIAL ( "c" "name" -- )
    SPECIAL-CHARS LINK,
    CHAR , PARSE-NAME S",
;

SPECIAL & &amp;
SPECIAL ' &apos;
SPECIAL " &quot;
SPECIAL < &lt;
SPECIAL > &gt;

: (special) ( char data -- char f )
   2DUP @ =
   IF
      NIP CELL+ COUNT -1
   ELSE DROP 0
   THEN
;

: special? ( c -- c 0 | addr u -1 )
   BASE @ >R DECIMAL
   DUP BL <
   IF
     DROP BL 0 
     \ S>D <# [CHAR] ; HOLD # # # [CHAR] # HOLD [CHAR] & HOLD #> TRUE
   ELSE  
     SPECIAL-CHARS ['] (special) ITERATE-LIST2
   THEN
   R> BASE !
;

: HandleSpecialChars ( addr u -- addr u )
   0 ROT ROT
   OVER + SWAP
   ?DO
       I C@ special?
       IF
          ( n addr u )
          >R OVER CHARS PAD + R@ CMOVE
          R> +
       ELSE ( n c ) OVER CHARS PAD + C! 1+
       THEN
   LOOP PAD SWAP
;

: ATTRIBUTE-OUT ( addr-data u addr-name u -- )
    (HELP-OUT) [CHAR] = HELP-EMIT
    "h HandleSpecialChars (HELP-OUT) "h
    BL HELP-EMIT
;

: StartComment
    +indent
    S" <comment>" HELP-OUT
    TRUE TO comment?
;

: \
   comment? moduleComment? OR
   IF 
      BL SKIP BL HELP-EMIT
      0 PARSE HandleSpecialChars (HELP-OUT)
   ELSE
      POSTPONE \
   THEN
; IMMEDIATE

: StartModuleComment
    +indent
    S" <comment>" HELP-OUT
    TRUE TO moduleComment?
;

: EndModuleComment
   moduleComment?
   IF
     S" </comment>" HELP-OUT crh
     -indent
     FALSE TO moduleComment?
   THEN
;

\ ����� ������� �� ����� ����� ������ � ����� ������������
: INCLUDED ( addr u )
    generateHelp? 0=
    IF
       INCLUDED EXIT
    THEN

    EndModuleComment
  
    S" module" OPEN-TAG
    2DUP S" name" ATTRIBUTE-OUT
    CLOSE-TAG
    StartModuleComment +indent
    INCLUDED
    EndModuleComment -indent
    S" </module>" HELP-OUT crh
;

: REQUIRE
    generateHelp? 0=
    IF
       REQUIRE EXIT
    THEN

    >IN @ PARSE-NAME SFIND
    IF
       DROP >IN !
       REQUIRE
    ELSE
       2DROP
       EndModuleComment
       S" module" OPEN-TAG
       PARSE-NAME S" name" ATTRIBUTE-OUT
       CLOSE-TAG
       StartModuleComment +indent
       >IN ! REQUIRE
       EndModuleComment -indent
       S" </module>" HELP-OUT crh
    THEN
;

: :: : ;

: StartColonHelp ( flag.is-primitive -- )

  \ Skip words of target compiler
  HERE TC-IMAGE-BASE < IF DROP EXIT THEN

  EndModuleComment
  generateHelp? 0= IF DROP EXIT THEN

  >IN @ >R
  S" colon" OPEN-TAG
  PARSE-NAME S" name" ATTRIBUTE-OUT

  GET-CURRENT DUP FORTH-WORDLIST = 
  IF DROP S" FORTH" 
  ELSE CELL+ @ DUP IF COUNT ELSE DROP S" UNKNOWN" THEN
  THEN

  2DUP S" TC-TRG" COMPARE 0=
  IF 2DROP S" FORTH" THEN

  S" vocabulary" ATTRIBUTE-OUT

  IF 
     S" true" S" primitive" ATTRIBUTE-OUT
  THEN

  BASE @ HEX
  HERE S>D <# #S #> S" id" ATTRIBUTE-OUT
  BASE !
  
  BASE @ DECIMAL
  CURSTR @ S>D <# #S #> S" line" ATTRIBUTE-OUT
  BASE !

  PARSE-NAME S" (" COMPARE 0=
  IF
     S"  params=" (HELP-OUT) "h
     [CHAR] ) PARSE HandleSpecialChars HELP-OUT() "h 
  THEN   

  CLOSE-TAG
  StartComment

  R> >IN !
;

XMLHELP-OFF

: : FALSE StartColonHelp : ;


: EndColonHelp
   comment?
   IF
      crh S" </comment>" HELP-OUT crh
      -indent 
      S" </colon>" HELP-OUT crh
      0 TO comment?
   THEN
;

:: ; POSTPONE ;
  EndColonHelp
; IMMEDIATE

: START-XMLHELP
    S" spfhelp.xml" W/O CREATE-FILE THROW
    TO docHandle
    S" ?xml" OPEN-TAG
    S" 1.0" S" version" ATTRIBUTE-OUT
    S" windows-1251" S" encoding" ATTRIBUTE-OUT

    [CHAR] ? HELP-EMIT
    CLOSE-TAG
    0 xmlIndent !
    0 TO comment?
    0 TO moduleComment?

    XMLHELP-ON
    S" <forthsourcecode>" HELP-OUT +indent
;

: FINISH-XMLHELP
    S" </forthsourcecode>" HELP-OUT
    docHandle
    IF
      docHandle CLOSE-FILE THROW
    THEN
;

CREATE-XML-HELP
[IF]
   START-XMLHELP
[THEN]
