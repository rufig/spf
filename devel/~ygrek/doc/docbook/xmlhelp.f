\ (c) 2006 Dmitry Yakimov, support@activekitten.com

\ немного подправлено чтобы работать автономно
\ + более корректное выдирание комментов из слова
\ + выдираются комменты идущие непосредственно перед словом

MODULE: xmlhelp-generator

REQUIRE [IF] lib/include/tools.f
REQUIRE STR@ ~ac/lib/str4.f
REQUIRE LAY-PATH ~pinka/samples/2005/lib/lay-path.f

\ REQUIRE >UNICODE ~ac/lib/win/com/com.f
\ : >UTF8  ( addr u -- addr2 u2 ) >UNICODE OVER >R UNICODE>UTF8 R> FREE THROW ;

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
0 VALUE moduleComment?
0 VALUE includeBody?
0 VALUE generateHelp?
0 VALUE comment?
0 VALUE str-of-comments \ номер строки из которой были выдраны коменты в последний раз
                        \ для того чтобы взять только те комменты которые идут до слова
"" VALUE comments-storage \ хранилище комментариев
0 VALUE HERE-AT-MODULE-START
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
\   >UTF8 2DUP
   docHandle
   IF
     docHandle WRITE-FILE THROW
   ELSE 
     TYPE
   THEN
\   DROP FREE THROW
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
SPECIAL " &quot; \ "
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
    TRUE TO comment?
;

: SAVE-AS-COMMENTS
        CURSTR @ str-of-comments 1+ ?DO S" <comment></comment>" HELP-OUT crh LOOP
        S" <comment>" HELP-OUT
        HandleSpecialChars (HELP-OUT)
        S" </comment>" HELP-OUT crh
        CURSTR @ TO str-of-comments ;

: simple-\
     CURSTR @ str-of-comments 1+ = 
     IF 
        BL SKIP 0 PARSE
        SAVE-AS-COMMENTS
     ELSE
        POSTPONE \
     THEN ;

: module-\
     HERE HERE-AT-MODULE-START = 
     IF
        BL SKIP 0 PARSE
        SAVE-AS-COMMENTS
     ELSE
        POSTPONE \
     THEN ;


: CHECK-AS-( ( a u -- )
   HERE HERE-AT-MODULE-START = 
   IF
    SAVE-AS-COMMENTS
   ELSE
    2DROP
   THEN ;

: StartModuleComment
    +indent
    0 TO str-of-comments
    TRUE TO moduleComment?
    HERE TO HERE-AT-MODULE-START
;

: EndModuleComment
   moduleComment?
   IF
     -indent
     FALSE TO moduleComment?
   THEN
;

: :: : ;

EXPORT

: (
  BEGIN
    [CHAR] ) >R
    R@ PARSE 2DUP CHECK-AS-( + C@ R> = 0=
  WHILE
    REFILL 0= IF EXIT THEN
  REPEAT
; IMMEDIATE


: \
   moduleComment? IF module-\ EXIT THEN
   comment? IF simple-\ EXIT THEN

   \ ELSE
   CURSTR @ str-of-comments 1+ <> IF comments-storage STRFREE "" TO comments-storage THEN
   CURSTR @ TO str-of-comments
   0 PARSE HandleSpecialChars " <comment>{s}</comment>" comments-storage S+
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
       INCLUDED EXIT
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

: StartColonHelp ( primitive? )

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

  2DUP S" TC-WL" COMPARE 0=
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

  SOURCE-NAME S" source" ATTRIBUTE-OUT

  PARSE-NAME 
  2DUP S" (" COMPARE 0=
  IF
     2DROP
     S"  params=" (HELP-OUT) "h
     [CHAR] ) PARSE HandleSpecialChars HELP-OUT() "h 
  ELSE
     S" {" COMPARE 0= IF
       S"  params=" (HELP-OUT) "h
       [CHAR] } PARSE HandleSpecialChars HELP-OUT() "h 
     THEN
  THEN   


  CLOSE-TAG
  StartComment

  CURSTR @ str-of-comments 1+ = \ comments strictly before the word definition
  IF
   comments-storage STR@ HELP-OUT
  THEN

  CURSTR @ TO str-of-comments

  R> >IN !
;

XMLHELP-OFF

: : FALSE StartColonHelp : ;


: EndColonHelp
   comment?
   IF
      crh \ S" </comment>" HELP-OUT crh
      -indent 
      S" </colon>" HELP-OUT crh
      0 TO comment?
   THEN
   "" TO comments-storage
;

:: ; POSTPONE ;
  EndColonHelp
; IMMEDIATE

: START-XMLHELP ( a u -- )
    FORCE-PATH
    W/O CREATE-FILE-SHARED THROW
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

: SET-XMLHELP-FENCE ( addr -- ) TO TC-IMAGE-BASE ;

;MODULE
