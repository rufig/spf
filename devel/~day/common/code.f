\ »ногда нужно написать одно слово в кодах, а ассемблер подключать
\ не хочетс€ - большой очень. Ёта либа поможет в такой ситуации.
\ Dmitry Yakimov day@forth.org.ru ftech@mail.ru
\ 25.09.99

\ —ловом BEGIN-CODE открываетс€ файл codeDump.txt в который пишетс€
\ все asm слова в виде дампа, пригодного дл€ компил€ции фортом.
\ —ловом CLOSE-CODE - файл закрываетс€

0 VALUE codeAddr
VARIABLE countBytes

: BEGIN-CODE
     WARNING @ H-STDOUT
     0 WARNING ! 
     S" codeDump.txt" W/O CREATE-FILE THROW TO H-STDOUT
;     
: CLOSE-CODE
     H-STDOUT SWAP TO H-STDOUT 
     CLOSE-FILE THROW
     WARNING !
;     

: LOOP1 POSTPONE LOOP ; IMMEDIATE

CREATE COMMENTS 256 ALLOT

S" lib\ext\spf-asm.f" INCLUDED
ALSO ASSEMBLER DEFINITIONS

: CODE
      >IN @
      NextWord 2DROP
      0 PARSE COMMENTS 1+ SWAP DUP >R CMOVE
      R> COMMENTS C!
      >IN !
      CODE HERE TO codeAddr
      ." : " 
      countBytes 0!
;

: END-CODE 
    END-CODE 
    BASE @ HEX          
    LATEST COUNT TYPE ."   " COMMENTS COUNT TYPE
    CR ." [ BASE @ HEX" CR
    HERE 1-
    codeAddr 
    DO
        SPACE
        I C@ . ."  C," countBytes 1+!
        countBytes @ 4 MOD 0=  IF CR THEN
    LOOP1 
    BASE ! CR ." BASE ! ] ;"
    CR CR
;    

PREVIOUS DEFINITIONS    
ALSO ASSEMBLER
\ Examples

(
BEGIN-CODE

CODE @4+@
   MOV EAX, [EBP]
   MOV EAX, [EAX]
   ADD EAX, # 4
   MOV EAX, [EAX]
   MOV [EBP], EAX
   RET
END-CODE

CODE VECT->
     LEA EAX, 5 [EAX]
     MOV EAX, [EAX]
     RET
END-CODE

   
PREVIOUS
CLOSE-CODE
BYE



)