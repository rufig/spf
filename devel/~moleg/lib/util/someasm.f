\ 10-01-2007 ~mOleg
\ просто пример слова, написанного на ассемблере

\ посчитать количество бит в слове
\ не самый быстрый вариант
CODE ?bits ( N --> # )
           XOR EBX, EBX
      @@1: OR EAX, EAX
          JZ @@2
           MOV EDX, EAX
           AND EDX, # 1
           ADD EBX, EDX
           SHR EAX, # 1
          JMP @@1
      @@2: MOV EAX, EBX
         RET
      END-CODE