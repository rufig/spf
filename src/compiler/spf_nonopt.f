( Слова, к-е нельзя инлайнить  ) 
( Используются словом '        )

GET-CURRENT

WORDLIST VALUE NON-OPT-WL

\ запишем адрес имени словаря
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
\ Исполнение: ( x -- ) ( R: -- x )
\ Перенести x на стек возвратов.
\ Интерпретация: семантика в режиме интерпретации не определена.
   POP  EBX
   PUSH EAX
   MOV EAX, [EBP]
   LEA EBP, 4 [EBP]
   JMP EBX
;C

CODE1 R>    \ 94
\ Исполнение: ( -- x ) ( R: x -- )
\ Перенести x со стека возвратов на стек данных.
\ Интерпретация: семантика в режиме интерпретации не определена.
     LEA EBP, -4 [EBP]
     MOV [EBP], EAX
     POP EBX
     POP EAX
     JMP EBX
;C


CODE1 ?DUP ( x -- 0 | x x ) \ 94
\ Продублировать x, если не ноль.
     OR EAX, EAX
     JNZ  ' DUP
     RET
;C

\ ================================================================
\ Вызов подпрограммы (для подпрограммного шитого кода)

CODE1 EXECUTE ( i*x xt -- j*x ) \ 94
\ Убрать xt со стека и выполнить заданную им семантику.
\ Другие изменения на стеке определяются словом, которое выполняется.
     MOV EBX, EAX
     MOV EAX, [EBP]
     LEA EBP, 4 [EBP]
     JMP EBX
;C


PREVIOUS PREVIOUS SET-CURRENT

