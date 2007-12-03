\ 28-11-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ константы, vect и value переменные, работа с ними.
\ второй вариант.

 REQUIRE [IF]     lib\include\tools.f
 REQUIRE PERFORM  devel\~moleg\lib\util\useful.f
 REQUIRE COMPILE  devel\~moleg\lib\util\compile.f
 REQUIRE ADDR     devel\~moleg\lib\util\addr.f

WARNING 0!

\ адресная ссылка на VARIABLE переменную прямо в код компилируется
\ поэтому скорость возрастает, но при этом CFA слова менять без толку
: VARIABLE ( / NAME --> )
          CREATE 0 , IMMEDIATE
          DOES> STATE @ IF [COMPILE] LITERAL THEN ;

\ значение константы компилируется в код как литерал!
\ это значит, что подменить значение константы нельзя
: CONSTANT ( n / name --> )
           CREATE , IMMEDIATE
           DOES> @  STATE @ IF [COMPILE] LITERAL THEN ;

\ смещение относительно tls компилируется прямо в код слова
: USER ( / name --> )
       CREATE USER-HERE , CELL USER-ALLOT IMMEDIATE
       DOES> @  STATE @ IF 0x8D C, 0x6D C, 0xFC C,   \ dpush tos
                           0x89 C,  0x45 C, 0x00 C,
                           0x8D C, 0x87 C, ,         \ lea eax, [tls] # udisp
                         ELSE TlsIndex@ +
                        THEN ;

\ переменные - значения.
: VALUE ( n / name --> )
        CREATE , IMMEDIATE
        DOES> STATE @ IF LIT, COMPILE @
                       ELSE @
                      THEN ;

\ создать переменную-значение в пользовательской области процесса
: USER-VALUE ( / name --> )
             CREATE USER-HERE , CELL USER-ALLOT IMMEDIATE
             DOES> @  STATE @ IF 0x8D C, 0x6D C, 0xFC C,   \ dpush tos
                                 0x89 C, 0x45 C, 0x00 C,
                                 0x8D C, 0x97 C, ,         \ lea addr, [tls] + udisp
                                 0x8B C, 0x02 C,           \ mov eax , [addr]
                               ELSE TlsIndex@ + @
                              THEN ;

\ создать слово, хранящее адрес слова, которое может быть
\ исполнено при упоминании name. Адрес может быть изменен
\ с помощью слова IS
: VECT ( / name --> )
       CREATE ['] NOOP A,
       DOES> STATE @ IF LIT, COMPILE PERFORM
                      ELSE PERFORM
                     THEN ;

\ вектора, принадлежащие текущему потоку
: USER-VECT ( / name --> )
            CREATE USER-HERE , ADDR USER-ALLOT IMMEDIATE
            DOES> @  STATE @ IF 0x8D C, 0x97 C, , \ LEA addr , [tls] + disp
                                0xFF C, 0x12 C,   \ CALL [addr]
                              ELSE TlsIndex@ + PERFORM
                             THEN ;

\ чтобы автоматом определять тип переменной (для TO и IS)
VECT _vcsmpl USER-VECT _uvcsmpl 0 VALUE _vlsmpl USER-VALUE _uvlsmpl

\ присвоить адрес кода USER-VECT переменной
: (uisvect) ( addr / name --> )
            CFL + @
            STATE @ IF 0x8D C, 0x97 C, ,
                       0x89 C, 0x02 C,         \ MOV [addr] , tos
                       0x8B C, 0x45 C, 0x00 C,
                       0x8D C, 0x6D C, 0x04 C, \ drop
                     ELSE TlsIndex@ + A!
                    THEN ;

\ изменить содержимое переменной - вектора
: (isvect) ( addr / name --> )
           CFL +
           STATE @ IF LIT, COMPILE A!
                    ELSE A!
                   THEN ;

\ изменить значение VALUE переменной
: (tovalue) ( n addr --> )
     CFL +
     STATE @ IF LIT, COMPILE !
              ELSE !
             THEN ;

\ присвоить значение USER-VALUE переменной
: (touvalue) ( n addr --> )
      CFL + @
      STATE @ IF 0x8D C, 0x97 C, ,
                 0x89 C, 0x02 C,
                 0x8B C, 0x45 C, 0x00 C,
                 0x8D C, 0x6D C, 0x04 C,
                ELSE TlsIndex@ + !
               THEN ;

\ найти адрес начала слова по ссылке из CFA на него
: raddr ( ' --> addr ) DUP 1+ @ + ;

\ чтобы IS работал и с USER-VECT и c VECT переменными
: IS ( addr / name --> )
     ' DUP raddr
     [ ' _vcsmpl raddr  ] LITERAL OVER = IF DROP (isvect) EXIT THEN
     [ ' _uvcsmpl raddr ] LITERAL      = IF (uisvect) EXIT THEN
     ." указанное слово не является вектором!" CR -1 THROW ; IMMEDIATE

\ присвоить значение VALUE USER-VALUE VECT или USER-VECT переменной
: TO ( n / name --> )
     ' DUP raddr
     [ ' _vlsmpl  raddr ] LITERAL OVER = IF DROP (tovalue) EXIT THEN
     [ ' _uvlsmpl raddr ] LITERAL OVER = IF DROP (touvalue) EXIT THEN
     [ ' _vcsmpl  raddr ] LITERAL OVER = IF DROP (isvect) EXIT THEN
     [ ' _uvcsmpl raddr ] LITERAL      = IF DROP (uisvect) EXIT THEN
     9 + STATE @ IF COMPILE, ELSE EXECUTE THEN ; IMMEDIATE

-1 WARNING !

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ \ тут просто проверка на собираемость.
  S" passed" TYPE
}test
