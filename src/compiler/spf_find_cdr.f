( ѕоиск слов в словар€х [выделено из spf_find.f]
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org

  ќптимизировано by day, 29.10.2000
  ќптимизировано by mak July 26th, 2001 - 15:45
   од наследован от SEARCH-WORDLIST, by ~ygrek Nov.2006
  »справлен баг "Access Violation" и рефакторинг by ~ruv, Sep.2008 

  $Id$
)


CODE CDR-BY-NAME0 ( c-addr u nfa1|0 -- c-addr u nfa1|nfa2|0 )
    MOV EBX, [EBP] \ counter (in most cases it is 0)
    MOV EDX, # 0
    JMP SHORT @@1
@@2:
    MOV EAX, 1 [EDX] [EAX]
@@1: OR EAX, EAX
    JZ SHORT @@9   \ конец списка
    MOV DL, BYTE [EAX]
    CMP EDX, EBX
    JNZ SHORT @@2
@@9:
    RET
END-CODE


CODE CDR-BY-NAME1 ( c-addr u nfa1|0 -- c-addr u nfa1|nfa2|0 )
    MOV ECX, 4 [EBP] \ c-addr
    MOV BL, [EBP]    \ counter
    MOV BH, [ECX]    \ first char
    JMP SHORT @@1
@@2:
    AND EDX, # 0xFF
    MOV EAX, 1 [EDX] [EAX]
@@1: OR EAX, EAX
    JZ SHORT @@9  \ конец списка
    MOV DX, [EAX]
    CMP DX, BX
    JNZ SHORT @@2 \ коды равны - выход
@@9:
    RET
END-CODE


CODE CDR-BY-NAME2 ( c-addr u nfa1|0 -- c-addr u nfa1|nfa2|0 )
    MOV ECX, 4 [EBP] \ c-addr
    MOV EBX, [EBP]   \ counter (in most cases -- 2)
    MOV EDX, EBX     \ copy of the counter
    MOV BX,  [ECX]   \ first and second chars
    SHL EBX, # 0x08
    MOV BL, DL       \ counter
    JMP SHORT @@1
@@2:
    AND EDX, # 0xFF
    MOV EAX, 1 [EDX] [EAX]
@@1: OR EAX, EAX
    JZ SHORT @@9   \ конец списка
    MOV EDX, [EAX] \ полагаетс€, что тут до границы пам€ти не достанем.
    AND EDX, # 0x00FFFFFF
    CMP EDX, EBX
    JNZ SHORT @@2 \ коды равны - выход
@@9:
    RET
END-CODE


CODE CDR-BY-NAME3 ( c-addr u nfa1|0 -- c-addr u nfa1|nfa2|0 )
    MOV ECX, 4 [EBP] \ c-addr
    MOV BX, 1 [ECX]  \ second and third
    SHL EBX, # 0x10  \ 8+8
    MOV BH, [ECX]    \ first char
    MOV BL, [EBP]    \ counter
    JMP SHORT @@1
@@2:
    AND EDX, # 0xFF
    MOV EAX, 1 [EDX] [EAX]
@@1:
    OR EAX, EAX  
    JZ SHORT @@9    \ конец списка
    MOV EDX, [EAX]
    CMP EDX, EBX
    JNZ SHORT @@2   \ коды равны - выход
@@9:
    RET
END-CODE


CODE CDR-BY-NAME ( c-addr u nfa1|0 -- c-addr u nfa1|nfa2|0 )
\ тоже, что и CDR (см. в spf_wordlist.f), но кроме конца списка стопором €вл€етс€ и заданное им€.

    MOV EDX, [EBP]                \ длина (счетчик)
    CMP EDX, # 3
    JG   @@1 \  u > 3  (performs signed comparison)
    JE   ' CDR-BY-NAME3 \ u = 3
    CMP EDX, # 1
    JG   ' CDR-BY-NAME2 \ u = 2
    JE   ' CDR-BY-NAME1 \ u = 1 
    JMP  ' CDR-BY-NAME0 \ u = 0 or u < 0
@@1: \ u > 3
    CALL ' CDR-BY-NAME3
    OR EAX, EAX
    JNZ SHORT @@5
    RET \ конец списка
    \ JZ SHORT @@9
@@5:
    PUSH EDI
    MOV ESI, ECX  \ addr в искомом (see CDR-BY-NAME3)
    ADD ESI, # 3
    MOV ECX, # 0
    JMP SHORT @@3
@@2:
    AND EDX, # 0xFF
    MOV EAX, 1 [EDX] [EAX]
    OR EAX, EAX  
    JZ SHORT @@8    \ конец списка
    MOV EDX, [EAX]
    CMP EDX, EBX
    JNZ SHORT @@2   \ коды не равны - идем по списку дальше
@@3: \ сравнение остатка строк побайтно
    MOV EDI, EAX  \ в списке
    ADD EDI, # 4
    MOV CL, BL    \ counter (see CDR-BY-NAME3)
    SUB CL, # 3   \ 3 chars in the code
    PUSH ESI
    REPZ CMPS BYTE
    POP ESI
    JNZ SHORT @@2 \ строки не равны -- идем по списку дальше
@@8:
    POP EDI
@@9:
    RET
END-CODE
