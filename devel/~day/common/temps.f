( 24.09.1997 Черезов А. )
\ 28.09.1999 Якимов Д.   - только добавил конструкцию !! ... !!,
\                           аналог || ... || (( ... ))
( Также переписал часть слов на ассемблере - получилось коротко и
  очень быстродействующе.
  На входе слова с локальными переменными:
    mov eax, n
    call |DOES
  Компиляция переменной:
    mov ecx, n
    call TEMP-DOES
)  
( Простое расширение СП-Форта локальными переменными.
  Реализовано без использования LOCALS стандарта 94.

  Объявление временных переменных, видимых только внутри
  текущего слова и ограниченных временем вызова данного
  слова выполняется с помощью слова "|" аналогично
  Смолтолку: внутри определения слова используется
  конструкция
  | список локальных переменных через пробел |

  Это заставляет СП-Форт автоматически выделять место в
  стеке возвратов для этих переменных в момент вызова слова
  и автоматически освобождать место при выходе из него.

  Обращение к таким локальным переменным - как к обычным
  переменным по имени и следующими @ и !
  Имена локальных переменных существуют в динамическом
  словаре TEMP-NAMES только в момент компиляции слова, а
  после этого вычищаются и более недоступны.
)
\ Инициализация временных переменных значениями, лежащими на
\ стеке (например, входными параметрами), возможна "списком"
\ с помощью конструкции
\ (( имена инициализируемых локальных переменных ))
\ Имена должны быть ранее объявлены в слове с помощью | ... |

( Использование локальных переменных внутри циклов DO LOOP
  невозможно по причине, описанной в стандарте 94.

  При желании использовать локальные переменные в стиле VALUE-переменных
  можно использовать конструкцию
  || список локальных переменных через пробел ||
  Имена этих переменных будут давать не адрес, а свое значение.
  Соответственно присвоение значений будет осуществляться конструкцией
  -> имя
  по аналогии с присвоением значений VALUE-переменным словом TO.
)
HERE

WORDLIST CONSTANT TEMP-NAMES
VARIABLE TEMP-CNT

: INIT-TEMP-NAMES
  ALSO TEMP-NAMES CONTEXT !
  TEMP-CNT 0!
;
HEX
: toEAX, ( u -- )
   C7 C, C0 C, ,
;
: toECX, ( u -- )
   C7 C, C1 C, ,
;

DECIMAL

: DEL-NAMES ( A -- )
  DUP >R
  @
  BEGIN
    DUP 0<>
  WHILE
    DUP CDR SWAP 5 - FREE THROW
  REPEAT DROP
  R> 0!
;
: DEL-TEMP-NAMES
  TEMP-NAMES DEL-NAMES
;
HEX
: COMPIL, ( A -- )
  0E8 DOES>A @ C! DOES>A 1+!              \ машинная команда CALL
  DOES>A @ CELL+ - DOES>A @ !
  DOES>A @ 1- DOES>A !
;
DECIMAL

: TEMP-DOES
[ BASE @ HEX
 5B  C, 83  C, C0  C, 2  C,
 C1  C, E0  C, 2  C, 3  C,
 C4  C, 83  C, ED  C, 4  C,
 89  C, 45  C, 0  C, 53  C,

BASE ! ] ;

: |TEMP-DOES
[ BASE @ HEX
 5B  C, 83  C, C0  C, 2  C,
 C1  C, E0  C, 2  C, 3  C,
 C4  C, 8B  C, 0  C, 83  C,
 ED  C, 4  C, 89  C, 45  C,
 0  C, 53  C,
BASE ! ] ;

: |TEMP-DOES!
[ BASE @ HEX
 5B  C, 83  C, C0  C, 2  C,
 C1  C, E0  C, 2  C, 3  C,
 C4  C, 8B  C, 4D  C, 0  C,
 89  C, 8  C, 53  C, 83  C,
 C5  C, 4  C,
BASE ! ] ;

: |DOES_CODE
[ BASE @ HEX
 33  C, C0  C, 8B  C, D9  C,
 5A  C, 50  C, E2  C, FD  C,
 53  C, 52  C,
BASE ! ] ;

: |DROP
[ BASE @ HEX
 59  C, 58  C, E2  C, FD  C,

BASE ! ] ;

(
CODE TEMP-DOES \ eax: n -- addr 
      POP EBX 
      ADD EAX, # 2
      SHL EAX, # 2
      ADD EAX, ESP
      SUB EBP, # 4
      MOV DWORD [EBP], EAX
      PUSH EBX
      RET
END-CODE

CODE |TEMP-DOES \ eax: n -- u 
      POP EBX 
      ADD EAX, # 2
      SHL EAX, # 2      
      ADD EAX, ESP
      MOV EAX, DWORD [EAX]
      SUB EBP, # 4      
      MOV DWORD [EBP], EAX
      PUSH EBX
      RET
END-CODE

CODE |TEMP-DOES! \ x eax: n -- 
      POP EBX 
      ADD EAX, # 2
      SHL EAX, # 2
      ADD EAX, ESP
      MOV ECX, DWORD [EBP]
      MOV DWORD [EAX], ECX
      PUSH EBX
      ADD EBP, # 4
      RET
END-CODE
)

: TEMP-CREATE ( addr u -- )
  DUP 20 + ALLOCATE THROW >R
  R@ CELL+ CHAR+ 2DUP C!
  CHAR+ SWAP MOVE ( name )
  TEMP-NAMES @
  R@ CELL+ CHAR+ TEMP-NAMES ! ( latest )
  R@ CELL+ CHAR+ COUNT + DUP >R ! ( link )
  R> CELL+ DUP DOES>A ! R@ ! ( cfa )
  &IMMEDIATE R> CELL+ C! ( flags )
  ['] _CREATE-CODE COMPIL,
  TEMP-CNT @ DOES>A @ 5 + !
  TEMP-CNT 1+!
  DOES> @ toEAX, POSTPONE TEMP-DOES
;
: |TEMP-CREATE ( addr u -- )
  DUP 20 + ALLOCATE THROW >R
  R@ CELL+ CHAR+ 2DUP C!
  CHAR+ SWAP MOVE ( name )
  TEMP-NAMES @
  R@ CELL+ CHAR+ TEMP-NAMES ! ( latest )
  R@ CELL+ CHAR+ COUNT + DUP >R ! ( link )
  R> CELL+ DUP DOES>A ! R@ ! ( cfa )
  &IMMEDIATE R> CELL+ C! ( flags )
  ['] _CREATE-CODE COMPIL,
  TEMP-CNT @ DOES>A @ 5 + !
  TEMP-CNT 1+!
  DOES> @ toEAX, POSTPONE |TEMP-DOES
;
: ->
  ' 5 + @ toEAX, POSTPONE |TEMP-DOES!
; IMMEDIATE


(
CODE |DOES_CODE  \ ecx: n -- 
      XOR EAX, EAX
      MOV EBX, ECX
      POP EDX
@@1:  PUSH EAX
      LOOP @@1
      PUSH EBX    
      PUSH EDX
      RET
END-CODE

CODE |DROP
      POP ECX
@@1:  POP EAX
      LOOP @@1
      RET
END-CODE
)

: |DOES 
   R>
   |DOES_CODE
   ['] |DROP >R >R
; 
   
: PICK3
   >R ROT R> SWAP
;
: >DOES ( N -- )
  R> SWAP DUP
  BEGIN
    DUP 0<>
  WHILE
    PICK3 >R 1-
  REPEAT DROP >R ['] |DROP >R
  >R
;
: |
  BEGIN
    BL WORD COUNT 2DUP S" |" COMPARE 0<>
  WHILE
    TEMP-CREATE
  REPEAT 2DROP
  TEMP-CNT @ toECX, POSTPONE |DOES
; IMMEDIATE

: ||
  BEGIN
    BL WORD COUNT 2DUP S" ||" COMPARE 0<>
  WHILE
    |TEMP-CREATE
  REPEAT 2DROP
  TEMP-CNT @ toECX, POSTPONE |DOES
; IMMEDIATE

: !!
  BEGIN
    BL WORD COUNT 2DUP S" !!" COMPARE 0<>
  WHILE
    |TEMP-CREATE
  REPEAT 2DROP
  TEMP-CNT @ LIT, POSTPONE >DOES
; IMMEDIATE

: ((
  0
  BEGIN
    BL WORD DUP COUNT S" ))" COMPARE 0<>
  WHILE
    FIND IF >R 1+ ELSE 5012 THROW THEN
  REPEAT DROP
  BEGIN
    DUP 0<>
  WHILE
\    R> EXECUTE POSTPONE !
    R> 5 + @ toEAX, POSTPONE TEMP-DOES POSTPONE ! ( исправлено для поддержки ||)
    1-
  REPEAT DROP
; IMMEDIATE

: :: : ;

WARNING @ WARNING 0!
: : ( -- )
  : INIT-TEMP-NAMES
;

:: :NONAME ( -- )
   :NONAME INIT-TEMP-NAMES
;

:: ; ( -- )
  DEL-TEMP-NAMES PREVIOUS
  POSTPONE ;
; IMMEDIATE

WARNING !



HERE SWAP - S" Length of Temps is " TYPE . S"  bytes" TYPE CR

