\ 31-03-2007 ~mOleg v1.1
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ константы, vect и value переменные, работа с ними.

REQUIRE ?: devel\~moleg\lib\util\ifcolon.f

  \ размер адресной ссылки байт                                            \
    ?: ADDR ( --> const ) 4 ;                                              \
  \                                                                        \
  \ работа с адресными ссылками                                            \
    ?: A@ @ ; ?: A! ! ; ?: A, , ;                                          \
  \                                                                        \
  \ !!! часто используется и по сути выдает смещение от текущего           \
  \ адреса до указанного. Стоит вынести в отдельное слово.                 \
    ?: atod ( addr --> disp ) HERE ADDR + - ;                              \
  \                                                                        \
  \ делает то же, что и ['] name COMPILE,                                  \
  \ все-таки более однозначное слово, чем POSTPONE                         \
    ?: COMPILE ( --> ) ?COMP ' LIT, ['] COMPILE, COMPILE, ; IMMEDIATE      \

\ ---------------------------------------------------------------------------

\ создать константу »
\ отличие от СПФ-варианта в том, что значение константы компилируется
\ прямо в код, в отличие от СПФ - где в код компилируется CALL на константу.
\ И это означает, что изменение значения константы не предусматривается.
: const ( n / name --> )
        CREATE , IMMEDIATE
        DOES> @
              STATE @ IF 0x8D C, 0x6D C, 0xFC C,  \ LEA EBX, -4 [EBX]
                         0x89 C, 0x45 C, 0x00 C,  \ MOV [EBP], EAX
                         0xB8 C, ,                \ MOV EAX, # const
                       ELSE
                      THEN ;

\ создать вектор-переменную »
\ если переменная не инициализирована - выполнить NOOP
: vect ( / name --> ) HEADER ['] NOOP BRANCH, ;

\ установить новое значение vect переменной »
: (is) ( addr 'vect --> ) TUCK ADDR + - SWAP A! ;

\ изменить значение vect переменной »
: is   ( n / name --> )
       ' 1 +
       STATE @ IF LIT, COMPILE (is)
                ELSE (is)
               THEN ; IMMEDIATE

\ получить содержимое vect переменной - то есть узнать на кого она указывает»
: (from) ( addr --> addr ) 1 + DUP A@ + ADDR + ;


\ извлечь содержимое vect переменной »
: from ( / name --> addr )
       '
       STATE @ IF LIT, COMPILE (from)
                ELSE (from)
               THEN ; IMMEDIATE

\ создать value переменную »
: value ( n / name --> )
        HEADER
         0x8D C, 0x6D C, 0xFC C,  \ LEA EBX, -4 [EBX]
         0x89 C, 0x45 C, 0x00 C,  \ MOV [EBP], EAX
         0x90 C,                  \ NOP               \ выравнивание значения
         0xB8 C, ,                \ MOV EAX, # const  \ +08
         RET, ;

\ присвоить n value-переменной с именем name »
: to ( n / name --> )
     ' 8 +
     STATE @ IF LIT, COMPILE A!
              ELSE A!
             THEN ; IMMEDIATE

\ присвоить n value-переменной с именем name »
: +to ( n / name --> )
      ' 8 +
      STATE @ IF LIT, COMPILE +!
               ELSE +!
              THEN ; IMMEDIATE

\ заменить значение переменной на новое - старое вернуть. »
: change ( a addr --> b ) DUP @ -ROT ! ;

\ заменить значение value переменной на новое, старое вернуть. »
: exch ( a / name --> b )
       ' 8 +
       STATE @ IF LIT, COMPILE change
                ELSE change
               THEN ; IMMEDIATE

\ основное отличие от используемого в СПФ варианта заключается в том, что
\ используется не прямой шитый код а подпрограммный 8), что логично, так
\ как во всем остальном СПФ использует именно подпрограмный ШК.
\ второе, не менее важное отличие заключается в том, что нельзя присвоить
\ vect - значение по to а value с помощью is !!! Что вобщем-то достаточно
\ логично. Ну и с большой оглядкой надо использовать следующие варианты
\ CREATE-DOES> механизма: VALUE DOES> ; VECT DOES> ; CONSTANT DOES>
\ потому как поведение DOES> в таком случае не проходит- то есть вообще
\ не стоит использовать.

\EOF -- тестовая секция -----------------------------------------------------

                                   DECIMAL

  123 value proba S" должно быть 123 = " TYPE proba . CR
  200 to proba S" должно быть 200 = " TYPE proba . CR
  : testa 300 to proba ; testa S" должно быть 300 = " TYPE proba . CR
  vect sample sample S" должно быть " TYPE ' NOOP . S" = " TYPE from sample . CR
  : testb ." vect sample passed. " ; ' testb is sample   sample CR
  : testc from sample . ;
  S" должно быть " TYPE ' testb . S" = " TYPE testc CR
  20 +to proba S" должно быть 320 = " TYPE proba . CR
  : testd 30 +to proba ; S" должно быть 350 = " TYPE testd proba . CR
  234 exch proba S" должно быть 350 = " TYPE . CR
  S" должно быть 234 = " TYPE proba . CR

\  7-04-2007  теперь vect содержит JMP а не CALL на указанное слово
\             в связи с чем добавлено слово JMP,
\           спасибо ~mak 8) за подсказку.
\  10-04-2007 убрал слово JMP, - заменил на стандартное BRANCH,