\ CODE get-extension ( z -- z')
\     MOV EBX, EAX
\ @@2: CMP BYTE [EBX], # 0
\      JE SHORT @@1
\      INC EBX
\      JMP SHORT @@2
\ @@1: MOV ECX, EBX
\ @@3: CMP BYTE [ECX], # 46
\      JE SHORT @@4
\      CMP ECX, EAX
\      JE SHORT @@5
\      DEC ECX
\      JMP SHORT @@3
\ @@4: INC ECX
\      MOV EAX, ECX
\      RET
\ @@5: MOV EAX, EBX
\      RET
\ END-CODE

: get-extension  ( z -- z')
[ BASE @ HEX
 8B  C, D8  C, 80  C, 3B  C,
 0  C, 74  C, 3  C, 43  C,
 EB  C, F8  C, 8B  C, CB  C,
 80  C, 39  C, 2E  C, 74  C,
 7  C, 3B  C, C8  C, 74  C,
 7  C, 49  C, EB  C, F4  C,
 41  C, 8B  C, C1  C, C3  C,
 8B  C, C3  C, C3  C,
BASE ! ] ;


