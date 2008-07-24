\ $Id$
\ 
\ Интерфейс с внешними функциями
\ Вызовы и обратные вызовы
\ Ю. Жиловец, 5.05.07

CODE C-CALL ( x1 ... xn n adr -- res)
     MOV EBX, [EBP]      \ число аргументов
     MOV ESI, # 4
@@1: OR EBX, EBX
     JZ @@2
\     PUSH [EBP] [ESI] 
A;   0xFF C, 0x74 C, 0x35 C, 0x00 C,
     LEA ESI, 4 [ESI]
     DEC EBX
     JMP @@1
@@2: CALL EAX
     MOV ECX, [EBP]
     SHL ECX, # 2
     ADD ESP, ECX
     ADD ECX, # 4
     ADD EBP, ECX
     RET
END-CODE

CODE C-CALL2 ( x1 ... xn n adr -- dres)
  CALL ' C-CALL
  LEA EBP, -4 [EBP] 
  MOV [EBP], EAX
  MOV EAX, EDX
  RET
END-CODE

0 VALUE ST-RES

\ обработчики ненахождения ф-ии/либы
VECT PROC-ERROR
VECT LIB-ERROR

CODE _WNDPROC-CODE
     MOV  EAX, ESP
     SUB  ESP, # 3968
A;   HERE 4 - ' ST-RES 9 + EXECUTE
     PUSH EBP
     MOV  EBP, 4 [EAX] ( адрес возврата из CALLBACK )
     PUSH EBP
     MOV  EBP, EAX
     ADD  EBP, # 12
     PUSH EBX
     PUSH ECX
     PUSH EDX
     PUSH ESI
     PUSH EDI
     MOV  EAX, [EAX] ( адрес адреса форт-процедуры )
     MOV  EBX, [EAX]
     MOV  EAX, -4 [EBP]
     CALL EBX
     LEA EBP, -4 [EBP]
     MOV  [EBP], EAX
     POP  EDI
     POP  ESI
     POP  EDX
     POP  ECX
     POP  EBX
     MOV  EAX, ESP
     MOV  ESP, EBP
     MOV  EBP, 4 [EAX] \ сохраненный EBP
     MOV  EAX, [EAX]   \ адрес возврата из CALLBACK
     XCHG EAX, [ESP]
     RET
END-CODE


' _WNDPROC-CODE TO WNDPROC-CODE

VECT FORTH-INSTANCE>  \ эти процедуры будут выполняться на входе
VECT <FORTH-INSTANCE  \ и выходе в WNDPROC-процедуры (инициализация TlsIndex)

' FORTH-INSTANCE> TO TC-FORTH-INSTANCE>
' <FORTH-INSTANCE TO TC-<FORTH-INSTANCE

