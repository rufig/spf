\ Ѕыстрый вызов API                   Mihail Maksimov

REQUIRE Code  ~mak\asm\ASM.FRT 

Code AO_INI 
      PUSH EBX
      PUSH EDI
      PUSH EBP
      MOV  EAX, [EBX+4]
      PUSH EAX
      MOV  EAX, [ { AOLL @ @ } ]
      CALL EAX
      OR   EAX, EAX
      POP EBP
      POP EDI
      POP EBX

      JZ  SHORT MM2

      PUSH EDI
      PUSH EBP
      MOV  ECX, [EBX+8]
      PUSH ECX
      PUSH EAX
      MOV  EAX, [ { AOGPA @ @ } ]
      CALL EAX
      OR   EAX, EAX
      POP EBP
      POP EDI
MM2:  RET
ENDCode

Code _RWIN-CODE

      POP  EBX
      POP  EDX

      MOV  [EBP-4], EDX
      MOV  EAX, [EBX]
      OR   EAX, EAX
      JNZ  SHORT MM1

      CALL { ' AO_INI }

      JZ  SHORT MM2

      MOV [EBX], EAX

MM1:  MOV  [EBP-8], EDI
      CALL EAX
      MOV  EDI, [EBP-8]
MM2:  JMP  [EBP-4]

ENDCode

Code _0WIN-CODE

      POP  EBX

      MOV  [EBP-4], EAX
      LEA   EBP, [EBP-4]

      MOV  EAX, [EBX]

      OR   EAX, EAX
      JNZ  SHORT MM1

      CALL { ' AO_INI }

      JZ  SHORT MM2

      MOV [EBX], EAX

MM1:  MOV  [EBP-4], EDI
      CALL EAX
      MOV  EDI, [EBP-4]
MM2:  RET

ENDCode

Code _1WIN-CODE

      POP  EBX

      PUSH  EAX

      MOV  EAX, [EBX]

      OR   EAX, EAX
      JNZ  SHORT MM1

      CALL { ' AO_INI }

      JZ  SHORT MM2

      MOV [EBX], EAX

MM1:  MOV  [EBP-4], EDI
      CALL EAX
      MOV  EDI, [EBP-4]
MM2:  RET

ENDCode


Code _2WIN-CODE

      POP  EBX
      POP  EDX

      MOV   ECX, [EBP]
      PUSH  ECX
      PUSH  EAX

      MOV  [EBP-4], EDX
      MOV  EAX, [EBX]

      OR   EAX, EAX
      JNZ  SHORT MM1

      CALL { ' AO_INI }

      JZ  SHORT MM2

      MOV [EBX], EAX

MM1:  MOV  [EBP-8], EDI
      CALL EAX
      MOV  EDI, [EBP-8]
MM2:  LEA  EBP, [EBP+4]
      JMP  [EBP-8]

ENDCode

Code _3WIN-CODE

      POP  EBX
      POP  EDX

      MOV   ECX, [EBP+4]
      PUSH  ECX
      MOV   ECX, [EBP]
      PUSH  ECX
      PUSH  EAX

      MOV  [EBP-4], EDX
      MOV  EAX, [EBX]

      OR   EAX, EAX
      JNZ  SHORT MM1

      CALL { ' AO_INI }

      JZ  SHORT MM2

      MOV [EBX], EAX

MM1:  MOV  [EBP-8], EDI
      CALL EAX
      MOV  EDI, [EBP-8]
MM2:  LEA  EBP, [EBP+8]
      JMP  [EBP-0CH]

ENDCode

Code _4WIN-CODE

      POP  EBX
      POP  EDX

      MOV   ECX, [EBP+8]
      PUSH  ECX
      MOV   ECX, [EBP+4]
      PUSH  ECX
      MOV   ECX, [EBP]
      PUSH  ECX
      PUSH  EAX

      MOV  [EBP-4], EDX
      MOV  EAX, [EBX]

      OR   EAX, EAX
      JNZ  SHORT MM1

      CALL { ' AO_INI }

      JZ  SHORT MM2

      MOV [EBX], EAX

MM1:  MOV  [EBP-8], EDI
      CALL EAX
      MOV  EDI, [EBP-8]
MM2:  LEA  EBP, [EBP+0CH]
      JMP  [EBP-10H]

ENDCode

: __WIN:  ( CFA_INI "»м€ѕроцедуры" "»м€Ѕиблиотеки" -- )

   COMPILE,
  HERE WINAP !
  0 , \ address of winproc
  0 , \ address of library name
  0 , \ address of function name
\  0 , \ # of parameters
  IS-TEMP-WL 0=
  IF
    HERE WINAPLINK @ , WINAPLINK ! ( св€зь )
  THEN
  HERE WINAP @ CELL+ CELL+ !
  HERE >R
  NextWord HERE SWAP DUP ALLOT MOVE 0 C, \ им€ функции
  HERE WINAP @ CELL+ !
  HERE >R
  NextWord HERE SWAP DUP ALLOT MOVE 0 C, \ им€ библиотеки
  R> LoadLibraryA DUP 0= IF -2009 THROW THEN \ ABORT" Library not found"
  R> SWAP GetProcAddress 0= IF -2010 THROW THEN \ ABORT" Procedure not found"
;

: _WIN: ( CFA_INI "»м€ѕроцедуры" "»м€Ѕиблиотеки" -- )
     >IN @   HEADER   >IN ! __WIN: ;

: RWIN: ['] _RWIN-CODE SkipDelimiters  >IN @  HEADER
 1+  \ обход префикса обозначающего функцию, параметры которой
\ передаютс€ через стек возвратов
    >IN !             __WIN: ;
: 0WIN: ['] _0WIN-CODE _WIN: ;
: 1WIN: ['] _1WIN-CODE _WIN: ;
: 2WIN: ['] _2WIN-CODE _WIN: ;
: 3WIN: ['] _3WIN-CODE _WIN: ;
: 4WIN: ['] _4WIN-CODE _WIN: ;

\EOF TEST

RWIN:  RSetConsoleCursorPosition KERNEL32.DLL
RWIN:  RSetConsoleTextAttribute  KERNEL32.DLL

: AT-XY ( X Y -- )
  16 LSHIFT OR >R H-STDOUT DUP >R RSetConsoleCursorPosition DROP
;

: TT-ATTR ( fg bg -- )
  16 * + >R  H-STDOUT DUP >R RSetConsoleTextAttribute U.
; \ 

 3 4 TT-ATTR 8 16 AT-XY .( XXXXX)

0WIN: GetTickCount KERNEL32.DLL

2WIN: SetConsoleCursorPosition KERNEL32.DLL
2WIN: SetConsoleTextAttribute  KERNEL32.DLL

: AT-XY ( X Y -- )
  16 LSHIFT OR H-STDOUT SetConsoleCursorPosition DROP
;

: TT-ATTR ( fg bg -- )
  16 * + H-STDOUT SetConsoleTextAttribute U.
; \ 

 2 7 TT-ATTR 16 8 AT-XY .( XXXXX)

GetTickCount U.

4WIN: MessageBoxA      USER32.DLL
  
0 S" SSSSS" DROP S" ZZZZZ" DROP  0  MessageBoxA U.
