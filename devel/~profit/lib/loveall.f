\ colorlessForth без цвета. Идеи -- Chuck Moore и Terry Loveall.
\ Реализация со словами-префиксами
S" lib\ext\patch.f" INCLUDED

: [ ;
: ] ' COMPILE, ;
: n LIT, ;
 
:NONAME CREATE DOES> EXECUTE ;   ' : REPLACE-WORD
:NONAME RET, ;                   ' ; REPLACE-WORD

\EOF
\ examples
: square  ] DUP  ] *  ;
: 2x2  2 n  ] square  ] . ;