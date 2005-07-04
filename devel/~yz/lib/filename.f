REQUIRE CODE lib/ext/spf-asm-tmp.f

\ находит последний указанный символ в строке
CODE last-character ( z с -- z'/0)
\ AL - символ
\ EBX - текущий указатель
\ ECX - начало строки
     MOV EBX, [EBP]
     MOV ECX, EBX
     LEA EBP, 4 [EBP]
\ находим конец строки
@@2: CMP BYTE [EBX], # 0
     JE SHORT @@3
     INC EBX
     JMP SHORT @@2

@@3: CMP BYTE [EBX], AL
     JE SHORT @@4
     CMP EBX, ECX
     JE SHORT @@5
     DEC EBX
     JMP SHORT @@3
\ нашли
@@4: MOV EAX, EBX
     RET
\ не нашли
@@5: XOR EAX, EAX
     RET
END-CODE

\ заменяет последний указанный символ в строке на 0
: -trail ( z c -- )
  2DUP last-character ?DUP IF 
    ( z c z1) 0 SWAP C! 2DROP 
  ELSE
    ( z с ) DROP
  THEN 
;
