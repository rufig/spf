\ Вызов внешних функций, экспортированных по c-правилам

S" lib\ext\spf-asm-tmp.f" INCLUDED

CODE (CAPI-CALL) ( EAX - extern-addr, ECX - n -- x )
      OR   ECX, ECX
      JZ   SHORT @@1
      LEA  EBX, [ECX*4]
      SUB  ESP, EBX
      MOV  EDX, EDI
      MOV  EDI, ESP
      MOV  ESI, EBP
      CLD
      REP MOVS DWORD
      MOV EDI, EDX
      ADD EBP, EBX
      CALL EAX
      ADD  ESP, EBX
      RET

@@1:  CALL EAX
      RET
END-CODE

CODE CAPI-CALL ( ... n extern-addr -- x )
\ вызов внешней функции, экспортированной по c-правилам
      MOV  ECX, [EBP]
      LEA  EBP, 4 [EBP]
      CALL ' (CAPI-CALL)
      RET
END-CODE

CODE _CAPI-CODE
      POP  EBX
      MOV  -4 [EBP], EAX
      MOV  EAX, [EBX]
      OR   EAX, EAX
      LEA  EBP, -4 [EBP]
      JNZ  SHORT @@1
      MOV  EAX, EBX
      CALL ' AO_INI
      JZ  SHORT @@2
      MOV [EBX], EAX
@@1:  MOV  ECX, 12 [EBX]
      JMP ' (CAPI-CALL)
@@2:  RET
END-CODE

CODE _CVAPI-CODE
      POP  EBX
      MOV  -4 [EBP], EAX
      MOV  EAX, [EBX]
      OR   EAX, EAX
      LEA  EBP, -4 [EBP]
      JNZ  SHORT @@1
      MOV  EAX, EBX
      CALL ' AO_INI
      JZ  SHORT @@2
      MOV [EBX], EAX
@@1:  JMP ' CAPI-CALL
@@2:  RET
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
    2 CAPI: strstr msvcrt.dll

    Z" s" Z" asdf" strstr
  )
  >IN @  HEADER  >IN !
  ['] _CAPI-CODE COMPILE,
  __WIN:
;

: CVAPI: ( "ИмяПроцедуры" "ИмяБиблиотеки" -- )
\ Для функций с переменным числом параметров
\ При вызове после параметров надо указать их число
\ CVAPI: sprintf msvcrt.dll

\ 50 ALLOCATE THROW VALUE buf
\ 10 Z" %d" buf 3 sprintf
  >IN @  HEADER  >IN !
  0 ['] _CVAPI-CODE COMPILE,
  __WIN:
;
