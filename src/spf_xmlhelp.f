\ (c) 2006 Dmitry Yakimov, support@activekitten.com

: PARSE-NAME NextWord ;

: S, ( addr u -- )
\ Зарезервировать u байт пространства данных
\ и поместить туда содержимое u байт из addr.
  CHARS DP @ SWAP DUP ALLOT MOVE
;

: S", ( addr u -- )
\ Разместить в пространстве данных строку, заданную addr u,
\ в виде строки со счетчиком.
  DUP C, S,
;


(

Переопределяются : и ;

TODO:

+ тело форт слова пока не выводится в help, нужно ли ?

)

0 VALUE docHandle
VARIABLE xmlIndent
0 VALUE moduleCommentHere  \ ( addr.here | 0 )
0 VALUE includeBody?
0 VALUE generateHelp?
0 VALUE comment?

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

: LINK,     ( list -- )    \ скомпилировать связь с предыдущим узлом
         HERE  OVER @ ,  SWAP !  ;

VARIABLE CHAINS

\ Первоначальная компиляция CHAINS и 4 + в DOES> для того, чтобы
\ для CHAINS были такие же правила обработки, что и для других
\ списков

: CHAIN ( "name" -- )
   CREATE
       CHAINS LINK,
       0 ,
   DOES> CELL+
;

\ Возвращает параметр плюс xt получает параметры до вызова
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
   DUP 0x0A = IF FALSE EXIT THEN
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

: process-line-comment ( -- )
   comment? moduleCommentHere OR
   IF
      BL SKIP BL HELP-EMIT
      SOURCE-FOLLOWING DROP ( c-addr1 )
      [COMPILE] \  \ Do not use `0 PARSE` to be forward compatibile
      SOURCE-FOLLOWING DROP ( c-addr1 c-addr2 )
      \ Keep a line terminator (if any) in the result
      DUP CHAR- C@ 0x0A <> IF \ it is not already present
         DUP C@ 0x0D = IF CHAR+ THEN
         DUP C@ 0x0A = IF CHAR+ THEN
      THEN
      OVER - ( c-addr1 u )
      HandleSpecialChars (HELP-OUT)
   ELSE
      [COMPILE] \
   THEN
;

: StartModuleComment
    +indent
    S" <comment>" HELP-OUT
    HERE TO moduleCommentHere
;

: EndModuleComment
   moduleCommentHere
   IF
     S" </comment>" HELP-OUT crh
     -indent
     0 TO moduleCommentHere
   THEN
;

: ?EndModuleComment ( -- )
\ NB: This word may refill the input buffer,
\ so it must be called after the input buffer is processed.
   moduleCommentHere 0= IF EXIT THEN
   moduleCommentHere HERE = IF \ There was no definition yet
      BL SKIP SOURCE-FOLLOWING NIP IF EXIT THEN
      \ the parse area is empty
      REFILL DROP
      BL SKIP SOURCE-FOLLOWING NIP IF EXIT THEN
      \ the next line is empty
   THEN \ a new definition or an empty line appeared
   EndModuleComment
;

: \
   process-line-comment
   ?EndModuleComment
; IMMEDIATE

: (
   [COMPILE] (
   ?EndModuleComment
; IMMEDIATE

\ Таким образом мы знаем какой модуль в каком подключается
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
  TC-IMAGE-BASE 0= IF DROP EXIT THEN
  HERE  TC-IMAGE-BASE TC-IMAGE-SIZE OVER +  WITHIN INVERT IF DROP EXIT THEN

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
  SOURCE-FILE-LN S>D <# #S #> S" line" ATTRIBUTE-OUT
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
\ This works since TC uses `:` and `;` available in the host system


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
    0 TO moduleCommentHere

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
