\ FROM Boris Tereschenko 
~mak\FBasComp\FBAS.F 
REQUIRE +PLACE  ~mak\place.f

CREATE ForBuff 100 ALLOT

:  ForBuffType  ( addr len -- )
  DUP  100 ForBuff C@ - 1- U> IF ABORT THEN
  ForBuff +PLACE ;

: <BASIC> ( -- )
 BEGIN REFILL
 WHILE
   PARSE-NAME DUP
   IF   S" <\BASIC>"  COMPARE 0=  IF EXIT THEN
         0 TO InPos
          SOURCE 1+ TO InBuffSize TO InBuff
          ForBuff 0!
          ['] TYPE >BODY @ >R
          ['] ForBuffType   TO TYPE
          ['] Run CATCH  R> TO TYPE
          THROW ForBuff COUNT  EVALUATE \ TYPE \ 
   ELSE 2DROP
   THEN
 REPEAT
; IMMEDIATE

\EOF test

<BASIC>
LET A=7+4*A-9
<\BASIC>

: XXX
<BASIC>
REM comment
? "Text message"
? "First line"'"Next line","tab"
PRINT "32 = ";2*(9+7)
<\BASIC>
  4 0 DO
<BASIC> 
? "-2= ";A
<\BASIC>
  LOOP
;
