( ��������� ������� ���������� ��� CONSTANT, VARIABLE, etc.
  ��-����������� �����.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  �������������� �� 16-���������� � 32-��������� ��� - 1995-96��
  ������� - �������� 1999
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
      MOVZX EAX, BYTE [EBX]
      LEA   EBX, 1 [EBX]
      MOV   [EBP], EBX
      LEA   EBX, [EBX] [EAX]
      LEA   EBX, 1 [EBX]
      JMP   EBX
END-CODE

' _SLITERAL-CODE TO SLITERAL-CODE

CODE _CLITERAL-CODE
     LEA   EBP, -4 [EBP]
     MOV   [EBP], EAX
     POP   EAX
     MOVZX EBX, BYTE [EAX]
     LEA   EBX, [EBX] [EAX]
     LEA   EBX, 2 [EBX]
     JMP   EBX
     RET
END-CODE

' _CLITERAL-CODE TO CLITERAL-CODE



' _SLITERAL-CODE      >VIRT VALUE SLITERAL-CODE
' _CLITERAL-CODE      >VIRT VALUE CLITERAL-CODE

0  VALUE  DOES-CODE \ this value is initialized in ./compiler/spf_defwords.f
    '   _CREATE-CODE  >VIRT VALUE CREATE-CODE
        ' _USER-CODE  >VIRT VALUE USER-CODE
    ' _CONSTANT-CODE  >VIRT VALUE CONSTANT-CODE
     ' _TOVALUE-CODE  >VIRT VALUE TOVALUE-CODE
   ' _USER-VALUE-CODE >VIRT VALUE USER-VALUE-CODE
 ' _TOUSER-VALUE-CODE >VIRT VALUE TOUSER-VALUE-CODE
         ' _VECT-CODE >VIRT VALUE VECT-CODE

\ NB: these values are used in ./macroopt.f "CON>LIT"
