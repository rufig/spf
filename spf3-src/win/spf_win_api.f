( Процедуры времени выполнения для WINAPI и WNDPROC
  Windows-зависимые слова.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

VARIABLE AOLL
VARIABLE AOGPA

CODE _WINAPI-CODE
      POP  EBX
      MOV  EAX, [EBX]
      OR   EAX, EAX
      JNZ  @@1

      PUSH EBX
      PUSH ESI
      PUSH EDI
      PUSH EBP
      MOV  EAX, 4 [EBX]
      PUSH EAX
      MOV  EAX, AddrOfLoadLibrary
A; HERE 4 - ' AOLL EXECUTE !
      CALL EAX
      OR   EAX, EAX
      POP EBP
      POP EDI
      POP ESI
      POP EBX
      JZ   @@2

      PUSH EBX
      PUSH ESI
      PUSH EDI
      PUSH EBP
      MOV  ECX, 8 [EBX]
      PUSH ECX
      PUSH EAX
      MOV  EAX, AddrOfGetProcAddress
A; HERE 4 - ' AOGPA EXECUTE !
      CALL EAX
      OR   EAX, EAX
      POP EBP
      POP EDI
      POP ESI
      POP EBX
      JZ   @@2
      MOV [EBX], EAX

@@1:  PUSH ESI
      PUSH EDI
      PUSH EBP
\      PUSH ECX
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

\      POP ECX
      POP EBP
      SUB EBP, EBX
      SUB EBP, # 4
      MOV [EBP], EAX
      POP EDI
      POP ESI
@@2:  RET
END-CODE

' _WINAPI-CODE TO WINAPI-CODE

CODE API-CALL ( ... extern-addr -- x )
\ вызов внешней функции (API или метода объекта через COM)
@@1:  PUSH ESI
      PUSH EDI
      PUSH EBP
\      PUSH ECX
      SUB  ESP, # 64
      MOV  EDI, ESP
      MOV  ESI, EBP
      MOV  ECX, # 16
      CLD
      REP MOVS DWORD
      MOV  EBP, ESP
      POP  EAX  \ адрес вызываемой процедуры лежал на верхушке стека данных Форта
      CALL EAX
      MOV  EBX, EBP
      SUB  EBX, ESP
      MOV  ESP, EBP
      ADD  ESP, # 64

\      POP ECX
      POP EBP
      SUB EBP, EBX
      SUB EBP, # 4
      MOV [EBP], EAX
      POP EDI
      POP ESI
@@2:  RET
END-CODE


CODE _WNDPROC-CODE
     MOV  EAX, ESP
     SUB  ESP, # #ST-RES
     PUSH EBP
     MOV  EBP, 4 [EAX] ( адрес возврата из CALLBACK )
     PUSH EBP
     MOV  EBP, EAX
     ADD  EBP, # 8
     MOV  EAX, [EAX] ( адрес адреса форт-процедуры )
     MOV  EAX, [EAX]
     PUSH EBX
     PUSH ECX
     PUSH EDX
     PUSH ESI
     PUSH EDI
     CALL EAX
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

3968 CONSTANT #ST-RES
