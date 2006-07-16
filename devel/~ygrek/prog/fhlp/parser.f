REQUIRE { lib/ext/locals.f
REQUIRE /STRING lib/include/string.f
REQUIRE BOUNDS ~ygrek/lib/string.f
REQUIRE FSM: ~ygrek/lib/fsm.f

REQUIRE ENUM ~ygrek/lib/enum.f
:NONAME  \ vectors with the default xt = 2DROP
  NextWord 
\   2DUP S" \" COMPARE 0= IF 2DROP SOURCE + 0 SOURCE! EXIT THEN
   2DUP ['] VECT EVALUATE-WITH
        ['] 2DROP -ROT ['] TO EVALUATE-WITH ; ENUM VECT:

VECT: 
 OnText
 OnIndex OnSee OnRun OnInt OnComp
 OnCodeStart OnCodeEnd
 OnPreStart OnPreEnd
 OnTextStart OnTextEnd
 OnSectionStart OnGroup OnSectionEnd ;

: SkipSpaces ( a u -- a' u' ) 2DUP BOUNDS ?DO I C@ BL = IF 1 /STRING ELSE UNLOOP EXIT THEN LOOP ;

: match { a1 u1 a2 u2 \ -- -1 | 0 }
   u1 u2 < IF FALSE EXIT THEN
   a1 u2 a2 u2 COMPARE 0= ;

: pass { a1 u1 a2 u2 \ -- a u -1 | 0 }
   a1 u1 a2 u2 match IF a1 u1 u2 /STRING TRUE ELSE FALSE THEN ;

: rep ( xt n -- ) 0 ?DO DUP , 0 , LOOP DROP ;

:NONAME DUP CONSTANT 1+ ; ENUM enum:
0 enum: C_TEXT C_CODE C_PRE C_SECTION C_INDEX C_SEE C_COMP C_INT C_RUN C_GROUP ; VALUE #in

#in FSM: open
|| OnTextStart 1 || OnCodeStart 2 || OnPreStart 3 || OnSectionEnd 4 || OnIndex 0 || OnSee 0 || OnComp 0 || OnInt 0 || OnRun 0 || OnGroup 0
|| 2DROP 1       || OnCodeStart 2 || OnPreStart 3 || OnSectionEnd 4 || OnIndex 0 || OnSee 0 || OnComp 0 || OnInt 0 || OnRun 0 || OnGroup 0
|| OnTextStart 1 || 2DROP 2       || OnPreStart 3 || OnSectionEnd 4 || OnIndex 0 || OnSee 0 || OnComp 0 || OnInt 0 || OnRun 0 || OnGroup 0
|| OnTextStart 1 || OnCodeStart 2 || 2DROP 3      || OnSectionEnd 4 || OnIndex 0 || OnSee 0 || OnComp 0 || OnInt 0 || OnRun 0 || OnGroup 0
|| OnTextStart 1 || OnCodeStart 2 || OnPreStart 3 || 2DROP 4        || OnIndex 0 || OnSee 0 || OnComp 0 || OnInt 0 || OnRun 0 || OnGroup 0
FSM;

#in FSM: text
|| OnText 0 || OnText 0 || OnText 0 || OnSectionStart 0 ' 2DROP #in 4 - rep
FSM;

#in FSM: close
|| 2DROP 1 || 2DROP 2 || 2DROP 3 ' 2DROP #in 3 - rep
|| 2DROP 1 || OnTextEnd 2 || OnTextEnd 3 ' OnTextEnd #in 3 - rep
|| OnCodeEnd 1 || 2DROP 2 || OnCodeEnd 3 ' OnCodeEnd #in 3 - rep
|| OnPreEnd 1 || OnPreEnd 2 || 2DROP 3 ' OnPreEnd #in 3 - rep
FSM;

: classify { a u \ -- a u col }
\   a u >ASCIIZ DROP
   u 0= IF a u C_TEXT EXIT THEN
   a u S" >" pass IF C_CODE EXIT THEN
   a u S" $" pass IF C_PRE EXIT THEN
   a u S" &" pass IF C_INDEX EXIT THEN
   a u S" See: " pass IF C_SEE EXIT THEN
   a u S" Compilation: " pass IF C_COMP EXIT THEN
   a u S" Interpretation: " pass IF C_INT EXIT THEN
   a u S" Run-time: " pass IF C_RUN EXIT THEN
   a u S" ( " match IF a u C_RUN EXIT THEN
   a u S" *** " pass IF C_SECTION EXIT THEN
   a u S" ***g: " pass IF C_GROUP EXIT THEN
\   a u S" Group: " pass IF C_GROUP EXIT THEN
   \ default - plain text
   a u SkipSpaces C_TEXT ;

: parse classify { a u c \ -- } 
   a u c close
   a u c open
   a u c text ;

: Run ( -- ) SOURCE parse ;

