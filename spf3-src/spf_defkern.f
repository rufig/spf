( Процедуры времени выполнения для CONSTANT, VARIABLE, etc.
  ОС-независимые слова.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

CODE LIT ( -- x )
     SUB EBP, # 4
     MOV [EBP], EAX
     RET
END-CODE

CODE _CREATE-CODE
     POP EAX
     SUB EBP, # 4
     MOV [EBP], EAX
     RET
END-CODE

' _CREATE-CODE TO CREATE-CODE

CODE _CONSTANT-CODE
     POP EBX
     SUB EBP, # 4
     MOV EAX, [EBX]
     MOV [EBP], EAX
     RET
END-CODE

' _CONSTANT-CODE TO CONSTANT-CODE

CODE _USER-CODE
     POP EBX
     SUB EBP, # 4
     MOV EAX, [EBX]
     ADD EAX, EDI
     MOV [EBP], EAX
     RET
END-CODE

' _USER-CODE TO USER-CODE

CODE USER+ ( offs -- addr )
     MOV EAX, [EBP]
     ADD EAX, EDI
     MOV [EBP], EAX
     RET
END-CODE

CODE _USER-VALUE-CODE
     POP EBX
     SUB EBP, # 4
     MOV EBX, [EBX] \ user-смещение
     ADD EBX, EDI
     MOV EAX, [EBX]
     MOV [EBP], EAX
     RET
END-CODE

' _USER-VALUE-CODE TO USER-VALUE-CODE

CODE _VECT-CODE
     POP EAX
     JMP [EAX]
END-CODE

' _VECT-CODE TO VECT-CODE

CODE _TOVALUE-CODE
     POP EBX
     MOV EAX, [EBP]
     ADD EBP, # 4
     SUB EBX, # 9
     MOV [EBX], EAX
     RET
END-CODE

' _TOVALUE-CODE TO TOVALUE-CODE

CODE _TOUSER-VALUE-CODE
     POP EBX
     MOV EAX, [EBP]
     ADD EBP, # 4
     SUB EBX, # 9
     MOV EBX, [EBX] \ смещение user-переменной
     ADD EBX, EDI
     MOV [EBX], EAX
     RET
END-CODE

' _TOUSER-VALUE-CODE TO TOUSER-VALUE-CODE

CODE _SLITERAL-CODE
     POP   EBX
     MOVZX EAX, BYTE [EBX]
     INC   EBX
     SUB   EBP, # 8
     MOV   [EBP], EAX
     MOV   4 [EBP], EBX
     ADD   EAX, EBX
     INC   EAX
     JMP   EAX
END-CODE

' _SLITERAL-CODE TO SLITERAL-CODE

CODE _CLITERAL-CODE
     POP   EBX
     SUB   EBP, # 4
     MOV   [EBP], EBX
     MOVZX EAX, BYTE [EBX]
     ADD   EAX, EBX
     INC   EAX
     INC   EAX
     JMP   EAX
END-CODE

' _CLITERAL-CODE TO CLITERAL-CODE

CODE _---CODE
     POP EBX
     MOV EAX, [EBX]
     ADD [EBP], EAX
     RET
END-CODE

' _---CODE TO ---CODE
