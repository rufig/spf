\ $Id$
\ Andrey Filatkin, af@forth.org.ru
\ Переменные похожие на VALUE, но поддерживающие операцию AT.

\ CODE _ATVALUE-CODE
\     LEA  EBP, -4 [EBP]
\     MOV  [EBP], EAX
\     POP EAX
\     LEA EAX, -14 [EAX]
\     RET
\ END-CODE
: _ATVALUE-CODE
[ BASE @ HEX
  8D  C, 6D  C, FC  C, 89  C,
  45  C, 00  C, 58  C, 8D  C,
  40  C, F2  C, C3  C,
BASE ! ]
;

: VAR ( x "<spaces>name" -- )
  VALUE
  ['] _ATVALUE-CODE COMPILE,
;

: AT
  '
  14 +
  STATE @ IF COMPILE, ELSE EXECUTE THEN
; IMMEDIATE
