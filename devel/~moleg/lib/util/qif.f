\ 22-12-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ управление трансляцией входного потока. [IF] [IFNOT] [ELSE] [THEN]

 REQUIRE CS>         devel\~moleg\lib\util\csp.f
 REQUIRE NEXT-WORD   devel\~mOleg\lib\util\parser.f
 REQUIRE WHILENOT    devel\~moleg\lib\util\ifnot.f
 REQUIRE THIS        devel\~moleg\lib\util\useful.f
 REQUIRE ON-ERROR    devel\~moleg\lib\util\on-error.f
 REQUIRE ALIAS       devel\~moleg\lib\util\alias.f
 REQUIRE s"          devel\~moleg\lib\strings\string.f

        ALIAS 0! OFF
        ALIAS TO IS

VOCABULARY immediatest

        USER qcontrols

\ пропускать все слова до первого опозанного в словаре qiff
: -undefined ( --> )
             BEGIN NEXT-WORD DUP WHILE  \ пока не конец потока
                   [ ALSO immediatest CONTEXT @ PREVIOUS ] LITERAL
                   SEARCH-WORDLIST WHILENOT   \ пока не найдено
               REPEAT EXECUTE EXIT
             THEN -1 THROW ;

\ в случае ошибки восстановить переменные
: qerrexit ( -->)
           CSDepth BEGIN DUP WHILE CSDrop 1 - REPEAT DROP
           qcontrols OFF ;

ALSO immediatest DEFINITIONS

        VECT [IF]       IMMEDIATE  ( flag / ... --> )
        VECT [IFNOT]    IMMEDIATE  ( flag / ... --> )
        VECT [THEN]     IMMEDIATE  ( --> )
        VECT [ELSE]     IMMEDIATE  ( --> | / ... )

\ для того, чтобы обрабатывались корректно стандартные коментарии:
\ коментарий до конца строки
: \ ( / ... eol] --> )
    [COMPILE] \ qcontrols @ IF -undefined THEN ; IMMEDIATE

\ коментарий до завершающей обратной скобки
: ( ( / ... bracket --> )
    [COMPILE] ( qcontrols @ IF -undefined THEN ; IMMEDIATE

ALSO FORTH THIS

\ завершение секции управления трансляцией текста
: [THEN] ( --> )
         ['] [IF] CS@ =
         IF qcontrols @ -1 < IFNOT qcontrols OFF CSDrop EXIT-ERROR EXIT THEN
            1 qcontrols +! -undefined
          ELSE -1 THROW
         THEN ; IMMEDIATE

\ альтернативная секция управления трансляцией текста.
\ если текст до [ELSE] транслировался - за [ELSE] текст пропускается
\ если текст до [ELSE] пропускался - за [ELSE] начинает транслироваться.
: [ELSE] ( --> )
         ['] [IF] CS@ =
         IF qcontrols @ 1 + IFNOT FALSE qcontrols ! EXIT THEN
            qcontrols @ IFNOT TRUE qcontrols ! THEN
            -undefined
          ELSE -1 THROW
         THEN ; IMMEDIATE

\ начинает описание секции управления трансляцией текста,
\ если flag равн нулю, текст за [IFNOT] транслируется
\ иначе текст пропускается до первой лексемы, встреченной в
\ словаре immediatest
: [IFNOT] ( flag --> )
          ['] [IF] CS@ =
          IF qcontrols @ IF -1 qcontrols +! -undefined EXIT THEN THEN
          0 <> DUP qcontrols ! ['] [IF] >CS
          ['] qerrexit ON-ERROR
               IF -undefined THEN ; IMMEDIATE

\ начинает описание секции управления трансляцией текста,
\ если flag отличен от нуля, текст за [IF] транслируется
\ иначе текст пропускается до первой лексемы, встреченной в
\ словаре immediatest
: [IF] ( flag --> ) 0 = [COMPILE] [IFNOT] ; IMMEDIATE

 ALSO FORTH ' [IF]    PREVIOUS IS [IF]
 ALSO FORTH ' [IFNOT] PREVIOUS IS [IFNOT]
 ALSO FORTH ' [THEN]  PREVIOUS IS [THEN]
 ALSO FORTH ' [ELSE]  PREVIOUS IS [ELSE]

PREVIOUS

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ 0 [IFNOT] 82704958 [ELSE] 36547236 [THEN] 82704958 <> THROW
  S" passed" TYPE
}test

\EOF расширенный тест работоспособности

 0 [IFNOT] s" ifnot test pased" [THEN] TYPE CR
 1 [IF] s" if test pased" [THEN] TYPE CR
 0 [IFNOT] s" ifnot-else test passed" [ELSE] s" ifnot-else test falied" [THEN] TYPE CR
 0 [IF] s" if-else test failed" [ELSE] s" if-else test pased" [THEN] TYPE CR
-1 [IF] -1 [IF] s" if-if-then test passed" [THEN] [THEN] TYPE CR
 0 [IF] [IFNOT] s" enclosure test failed" TYPE CR -1 THROW [THEN]
     [ELSE] s" enclosure test passed"
   [THEN] TYPE CR
 1 [IF] s" test " TYPE
     [ELSE] 1 [IF] s" 1 failed" TYPE -1 THROW [ELSE] s" 2 failed" TYPE -1 THROW [THEN]
            s" 3 failed" TYPE -1 THROW
   [THEN] s" passed" TYPE CR
: test0 ." test0 " [ 0 ] [IF] s" failed " [ELSE] s" passed " [THEN] TYPE ; test0 CR
: test1 SP@ >R s" test1 passed "
        [ 0 ] [IF] \ s" test1 failed A " [ELSE]
                   s" test1 failed B "
              [THEN] TYPE R> SP! ; test1 CR
: test2 [ 1 ] [IF] ( s" test2 failed "
               [ELSE] ) s" test2 passed "
              [THEN] TYPE ; test2 CR

\ lib\ext\caseins.f CaseInsensitive 0 [IF] [ElSe] s" case insensitive" TYPE CR [THEN]