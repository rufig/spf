( ћакроподстановка с условием )

: ?MACRO:  ( "name <char> ccc<char>" f -- )
  : POSTPONE IF CHAR PARSE POSTPONE SLITERAL POSTPONE EVALUATE
    POSTPONE THEN
  POSTPONE ; IMMEDIATE
;

: MACRO:  ( "name <char> ccc<char>" -- )
    TRUE ?MACRO:
;

: CONDITION
    VALUE IMMEDIATE
;

\EOF

?MACRO: нажать ' S" button pressed!" TYPE'

TRUE CONDITION нажать нопку?

: go
     нажать нопку? нажать
;

go
