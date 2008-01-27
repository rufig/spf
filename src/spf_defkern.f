( Процедуры времени выполнения для CONSTANT, VARIABLE, etc.
  ОС-независимые слова.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

CODE _CREATE-CODE
     LEA  EBP, -4 [EBP]
     MOV  [EBP], EAX
     POP EAX
     RET
END-CODE

' _CREATE-CODE TO CREATE-CODE

CODE _CONSTANT-CODE
     LEA  EBP, -4 [EBP]
     MOV  [EBP], EAX
     POP EAX
     MOV  EAX, [EAX]
     RET
END-CODE

' _CONSTANT-CODE TO CONSTANT-CODE

CODE _USER-CODE
     LEA  EBP, -4 [EBP]
     MOV  [EBP], EAX
     POP EAX
     MOV EAX, [EAX]
     LEA EAX, [EDI] [EAX]
     RET
END-CODE

' _USER-CODE TO USER-CODE

CODE USER+ ( offs -- addr )
     LEA EAX, [EDI] [EAX]
     RET
END-CODE

CODE _USER-VALUE-CODE
     LEA  EBP, -4 [EBP]
     MOV  [EBP], EAX
     POP EAX
     MOV EAX, [EAX]
     LEA EAX, [EDI] [EAX]
     MOV EAX, [EAX]
     RET
END-CODE

' _USER-VALUE-CODE TO USER-VALUE-CODE

CODE _USER-VECT-CODE
     POP  EBX
     MOV  EBX, [EBX]
     LEA  EBX, [EDI] [EBX]
     MOV  EBX, [EBX]
     JMP  EBX
     RET
END-CODE

' _USER-VECT-CODE TO USER-VECT-CODE

CODE _VECT-CODE
     POP EBX
     JMP [EBX]
END-CODE

' _VECT-CODE TO VECT-CODE

CODE _TOVALUE-CODE
     POP EBX
     LEA EBX, -9 [EBX]
     MOV [EBX], EAX
     MOV EAX, [EBP]
     LEA EBP, 4 [EBP]
     RET             
END-CODE

' _TOVALUE-CODE TO TOVALUE-CODE

CODE _TOUSER-VALUE-CODE
     POP EBX
     LEA EBX, -9 [EBX]
     MOV EBX, [EBX]
     LEA EBX, [EDI] [EBX]
     MOV [EBX], EAX
     MOV EAX, [EBP]
     LEA EBP, 4 [EBP]
     RET             
END-CODE

' _TOUSER-VALUE-CODE TO TOUSER-VALUE-CODE

CODE _SLITERAL-CODE
      LEA   EBP, -8 [EBP]
      MOV   4 [EBP], EAX 
      POP   EBX
      MOVZX EAX, BYTE [EBX] \ length
      LEA   EBX, 1 [EBX] \ skip length byte
      MOV   [EBP], EBX  \ addr
1 CHAR-SIZE = [IF]
      LEA   EBX, [EBX] [EAX] \ skip string body
      LEA   EBX, 1 [EBX] \ skip ending zero
[ELSE]
      LEA   EBX, [EBX] [EAX*2]
      LEA   EBX, 2 [EBX]
[THEN]
      JMP   EBX
END-CODE

' _SLITERAL-CODE TO SLITERAL-CODE
' _SLITERAL-CODE VALUE SLITERAL-CODE

CODE _CLITERAL-CODE
     LEA   EBP, -4 [EBP]
     MOV   [EBP], EAX
     POP   EAX
     MOVZX EBX, BYTE [EAX]
1 CHAR-SIZE = [IF]
     LEA   EBX, [EBX] [EAX]
     LEA   EBX, 2 [EBX]
[ELSE]
     LEA   EBX, [EBX*2] [EAX]
     LEA   EBX, 3 [EBX]
[THEN]
     JMP   EBX
     RET
END-CODE

' _CLITERAL-CODE TO CLITERAL-CODE

' _CLITERAL-CODE VALUE CLITERAL-CODE

CODE _---CODE
     POP EBX
     ADD EAX, [EBX]
     RET
END-CODE


' _---CODE TO ---CODE

'   _CREATE-CODE  VALUE   CREATE-CODE
'     _USER-CODE  VALUE     USER-CODE
' _CONSTANT-CODE  VALUE CONSTANT-CODE
'  _TOVALUE-CODE  VALUE  TOVALUE-CODE
' _USER-VALUE-CODE VALUE USER-VALUE-CODE
'  _TOUSER-VALUE-CODE  VALUE TOUSER-VALUE-CODE
