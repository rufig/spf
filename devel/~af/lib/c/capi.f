\ $Id$
\ Andrey Filatkin, af@forth.org.ru
\ Вызов внешних функций, экспортированных по c-правилам

S" lib\ext\spf-asm-tmp.f" INCLUDED
CODE _CAPI-CODE
      LEA  EBP, -4 [EBP]
      MOV  [EBP], EAX

      POP  EBX
      MOV  EAX, [EBX]
      OR   EAX, EAX
      JZ   SHORT @@3

@@1:  MOV  ECX, 12 [EBX]
      OR   ECX, ECX
      JZ   SHORT @@2
      LEA  EBX, [ECX*4]
      SUB  ESP, EBX
      MOV  EDX, EDI
      MOV  EDI, ESP
      MOV  ESI, EBP
      CLD
      REP  MOVS DWORD
      ADD  EBP, EBX
      MOV  EDI, EDX
      CALL EAX
      ADD  ESP, EBX
      RET

@@2:  CALL EAX
      RET

@@6:  4 ALIGN-NOP
@@3:  MOV  EAX, 4 [EBX]
      PUSH EAX
      MOV  EAX, IMAGE-BASE 0x1034 +
      CALL EAX
      OR   EAX, EAX
      JZ   SHORT @@4

      MOV  ECX, 8 [EBX]
      PUSH ECX
      PUSH EAX
      MOV  EAX, IMAGE-BASE 0x1038 +
      CALL EAX
      OR   EAX, EAX
      JZ   SHORT @@4
      MOV  [EBX], EAX
      JMP  SHORT @@1

@@4:  RET
END-CODE

: CAPI: ( "ИмяПроцедуры" "ИмяБиблиотеки" n -- )
  ( Используется для импорта c-функций.
    Полученное определение будет иметь имя "ИмяПроцедуры".
    Поле address of winproc будет заполнено в момент первого
    выполнения полученной словарной статьи.
    Для вызова полученной "импортной" процедуры параметры
    помещаются на стек данных в порядке, обратном описанному
    в Си-вызове этой процедуры. Результат выполнения функции
    будет положен на стек.
  )

  >IN @  HEADER  >IN !
  ['] _CAPI-CODE COMPILE,
  HERE >R
  0 , \ address of winproc
  0 , \ address of library name
  0 , \ address of function name
  , \ # of parameters
  IS-TEMP-WL 0=
  IF
    HERE WINAPLINK @ , WINAPLINK ! ( связь )
  THEN
  HERE DUP R@ CELL+ CELL+ !
  NextWord HERE SWAP DUP ALLOT MOVE 0 C, \ имя функции
  HERE DUP R> CELL+ !
  NextWord HERE SWAP DUP ALLOT MOVE 0 C, \ имя библиотеки
  LoadLibraryA DUP 0= IF -2009 THROW THEN \ ABORT" Library not found"
  GetProcAddress 0= IF -2010 THROW THEN \ ABORT" Procedure not found"
;

CODE CAPI-CALL ( ... n extern-addr -- x )
\ вызов внешней функции, экспортированной по c-правилам
      MOV  EBX, [EBP]
      LEA  EBP, 4 [EBP]
      MOV  EDX, EDI
      MOV  ECX, EBX
      LEA  EBX, [EBX*4]
      SUB  ESP, EBX
      MOV  EDI, ESP
      MOV  ESI, EBP
      CLD
      REP MOVS DWORD
      MOV EDI, EDX
      ADD EBP, EBX
      CALL EAX
      ADD  ESP, EBX
      RET
END-CODE
