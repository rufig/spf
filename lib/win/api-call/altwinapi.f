\ Более быстрый вариант _WINAPI-CODE

S" lib\ext\spf-asm-tmp.f" INCLUDED

MODULE: ALTWINAPI

CODE _WINAPI-CODE
      POP  EBX
      MOV  -4 [EBP], EAX
      MOV  EAX, [EBX]
      OR   EAX, EAX
      LEA  EBP, -4 [EBP]
      JNZ  SHORT @@1
      CALL  ' AO_INI
      JZ  SHORT @@3
      MOV [EBX], EAX

@@1:  MOV  ECX, 12 [EBX]
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
      CALL EAX
      RET

@@4:  CALL EAX
      RET

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

: WINAPI: ( "ИмяПроцедуры" "ИмяБиблиотеки" -- )
  NEW-WINAPI?
  IF HEADER
  ELSE
    -1
    >IN @  HEADER  >IN !
  THEN
  ['] _WINAPI-CODE COMPILE,
  __WIN:
;

;MODULE
