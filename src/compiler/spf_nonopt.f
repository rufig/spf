( �����, �-� ������ ���������  ) 
( ������������ ������ '        )

GET-CURRENT

WORDLIST VALUE NON-OPT-WL

\ ������� ����� ����� �������
' NON-OPT-WL EXECUTE ( wid )
LATEST-NAME NAME>CSTRING SWAP VOC-NAME!

' NON-OPT-WL EXECUTE PUSH-ORDER DEFINITIONS
TC-TRG ALSO TC-IMM

CODE1 RDROP ( -> )
     POP EBX
     LEA ESP, 4 [ESP]
     JMP EBX
;C

CODE1 >R    \ 94
\ ����������: ( x -- ) ( R: -- x )
\ ��������� x �� ���� ���������.
\ �������������: ��������� � ������ ������������� �� ����������.
   POP  EBX
   PUSH EAX
   MOV EAX, [EBP]
   LEA EBP, 4 [EBP]
   JMP EBX
;C

CODE1 R>    \ 94
\ ����������: ( -- x ) ( R: x -- )
\ ��������� x �� ����� ��������� �� ���� ������.
\ �������������: ��������� � ������ ������������� �� ����������.
     LEA EBP, -4 [EBP]
     MOV [EBP], EAX
     POP EBX
     POP EAX
     JMP EBX
;C


CODE1 ?DUP ( x -- 0 | x x ) \ 94
\ �������������� x, ���� �� ����.
     OR EAX, EAX
     JNZ  ' DUP
     RET
;C

\ ================================================================
\ ����� ������������ (��� ��������������� ������ ����)

CODE1 EXECUTE ( i*x xt -- j*x ) \ 94
\ ������ xt �� ����� � ��������� �������� �� ���������.
\ ������ ��������� �� ����� ������������ ������, ������� �����������.
     MOV EBX, EAX
     MOV EAX, [EBP]
     LEA EBP, 4 [EBP]
     JMP EBX
;C


PREVIOUS PREVIOUS SET-CURRENT

