( Процедуры времени выполнения для WINAPI и WNDPROC
  Windows-зависимые слова.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

VARIABLE AOLL
VARIABLE AOGPA
0 VALUE ST-RES

CODE _WINAPI-CODE

      LEA  EBP, -4 [EBP]
      MOV  [EBP], EAX

      POP  EBX
      MOV  EAX, [EBX]
      OR   EAX, EAX
      JZ  SHORT @@1

      MOV  ECX, 12 [EBX]
      OR   ECX, ECX
      JS   SHORT @@2
      JZ   SHORT @@4
      LEA  EBX, [ECX*4]
      SUB  ESP, EBX
      MOV  EDX, EDI
      MOV  EDI, ESP
      MOV  ESI, EBP
      CLD
      REP MOVS DWORD
      ADD  EBP, EBX
      MOV  EDI, EDX
@@4:  CALL EAX
      RET

      4 ALIGN-NOP
@@1:  PUSH EBX
      PUSH EDI
      PUSH EBP
      MOV  EAX, 4 [EBX]
      PUSH EAX
      A; 0xA1 C,  AddrOfLoadLibrary
      ALSO FORTH , PREVIOUS \   MOV  EAX, AddrOfLoadLibrary
A; HERE 4 - ' AOLL EXECUTE !
      CALL EAX
      OR   EAX, EAX
      POP EBP
      POP EDI
      POP EBX
      JZ  SHORT @@3

      PUSH EDI
      PUSH EBP
      MOV  ECX, 8 [EBX]
      PUSH ECX
      PUSH EAX
      A; 0xA1 C,  AddrOfGetProcAddress
      ALSO FORTH , PREVIOUS \    MOV  EAX, AddrOfGetProcAddress
A; HERE 4 - ' AOGPA EXECUTE !
      CALL EAX
      OR   EAX, EAX
      POP EBP
      POP EDI
      JZ  SHORT @@3
      MOV [EBX], EAX

      MOV  ECX, 12 [EBX]
@@2:  PUSH EDI
      PUSH EBP
      SUB  ESP, # 64
      MOV  EDI, ESP
      MOV  ESI, EBP
      MOV  ECX, # 16
      CLD
      REP MOVS DWORD
      MOV  EBP, ESP
      CALL EAX
      MOV  ECX, ESP
      SUB  ECX, EBP
      MOV  ESP, EBP
      ADD  ESP, # 64
      POP  EBP
      ADD  EBP, ECX
      SAR  ECX, # 2
      MOV  12 [EBX], ECX
      POP  EDI

@@3:  RET

END-CODE

' _WINAPI-CODE TO WINAPI-CODE

CODE API-CALL ( ... extern-addr -- x )
\ вызов внешней функции (API или метода объекта через COM)

      PUSH EDI
      PUSH EBP
      SUB  ESP, # 64
      MOV  EDI, ESP
      MOV  ESI, EBP
      MOV  ECX, # 16
      CLD
      REP MOVS DWORD
      MOV  EBP, ESP
      CALL EAX
      MOV  EBX, EBP
      SUB  EBX, ESP
      MOV  ESP, EBP
      ADD  ESP, # 64
      POP EBP
      SUB EBP, EBX
      POP EDI
      RET
END-CODE

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
     LEA  EBP, -4 [EBP]
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
     INT 3
     INT 3
     INT 3
     INT 3
     INT 3
     INT 3
     INT 3
     INT 3
     INT 3
     INT 3
     INT 3
     INT 3
END-CODE


' _WNDPROC-CODE TO WNDPROC-CODE

VECT FORTH-INSTANCE>  \ эти процедуры будут выполняться на входе
VECT <FORTH-INSTANCE  \ и выходе в WNDPROC-процедуры (инициализация TlsIndex)

' FORTH-INSTANCE> TO TC-FORTH-INSTANCE>
' <FORTH-INSTANCE TO TC-<FORTH-INSTANCE
