\ $Id$

[DEFINED] CODE [IF]
CODE 1-! ( A -> )
     DEC DWORD [EAX]
     MOV EAX, [EBP]
     LEA EBP, 4 [EBP]
     RET
END-CODE
[ELSE]
: 1-! ( A -> )
[ BASE @ HEX
  FF  C, 08  C,
  8B  C, 45  C, 00  C,
  8D  C, 6D  C, 04  C,
  C3  C,
BASE ! ]
;
[THEN]
