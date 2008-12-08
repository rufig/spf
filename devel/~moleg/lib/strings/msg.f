\ 2008-11-24 ~mOleg
\ Сopyright [C] 2008 mOleg mininoleg@yahoo.com
\ работа со списком сообщений

 REQUIRE ?DEFINED     devel\~moleg\lib\util\ifdef.f
 REQUIRE FILE>HEAP    devel\~moleg\lib\win\file2heap.f
 REQUIRE ROUND        devel\~moleg\lib\util\stackadd.f

\ копировать строку asc # по указанному адресу addr
?DEFINED SCOPY : SCOPY   ( asc # addr --> ) 2DUP C! 1 + SWAP CMOVE ;

\ отправить строку в стандартный поток ошибок
?DEFINED >STDERR : >STDERR ( asc # --> ) H-STDERR WRITE-FILE DROP ;

\ ------------------------------------------------------------------------------

VOCABULARY Messages
           ALSO Messages DEFINITIONS

        USER msg-list \ ссылка на последнее сообщение в списке
        USER-VALUE last-msg    \ номер последнего созданного сообщения

0 \ формат записи сообщения
  CELL -- off_msgPrev  \ адрес предыдущего сообщения
  CELL -- off_msgName  \ номер текущего сообщения
     0 -- off_msgBody  \ строка сообщения вместе со счетчиком длины
CONSTANT /msgRecord

\ добавить новое сообщение в список сообщений
: new-msg ( asc # msg --> )
          OVER /msgRecord + 0x100 ROUND ALLOCATE THROW
          TUCK off_msgName !
          DUP >R off_msgBody SCOPY
          R@ msg-list change
          R> off_msgPrev ! ;

\ найти сообщение в списке сообщений по его номеру
: find-msg-num ( msg --> asc # true | msg false )
           >R msg-list @
           BEGIN DUP WHILE
                 DUP off_msgName @ R@ <> WHILE
               off_msgPrev @
             REPEAT RDROP off_msgBody COUNT TRUE EXIT
           THEN R> SWAP ;

\ найти номер сообщения по содержимому сообщения
: find-msg-body ( asc # --> msg | asc # false )
                2>R msg-list @
                BEGIN DUP WHILE
                      DUP off_msgBody COUNT 2R@ COMPARE WHILE
                      off_msgPrev @
                  REPEAT off_msgName @ RDROP RDROP EXIT
                THEN 2R> ROT ;

\ найти номер для следующего сообщения
: num-msg ( --> err )
          last-msg BEGIN 1 + DUP find-msg-num WHILE 2DROP REPEAT TO last-msg ;

\ найти сообщение в списке msg-list, отобразить его текст
\ если сообщения с указанным индексом err не найдено, отобразить индекс
: ~MESSAGE ( err --> ) find-msg-num IF ELSE 0 (D.) THEN TYPE ( >STDERR) ;

\ отобразить сообщение с номером msg если flag отличен от нуля,
\ выполнить THROW с кодом msg, если флаг = 0 действия не выполняются
: (ABORT) ( flag msg --> )
          SWAP IF DUP ~MESSAGE THROW ELSE DROP THEN ;

\ по содержимому строки asc # определить номер сообщения
: reffered ( asc # --> msg )
           find-msg-body DUP IF ELSE DROP num-msg DUP >R new-msg R> THEN ;

ALSO FORTH DEFINITIONS

\ вывести сообщение о ошибке
: ERROR" ( / message" --> )
         ?COMP [CHAR] " PARSE reffered
         [COMPILE] LITERAL POSTPONE DUP POSTPONE ~MESSAGE POSTPONE THROW
         ; IMMEDIATE

\ компилировать код, в случае ошибки выводящий сообщение message
: ABORT" ( / message" --> )
         ?COMP [CHAR] " PARSE reffered
         [COMPILE] LITERAL POSTPONE (ABORT) ; IMMEDIATE

\ компилировать код, выводящий сообщение message
: MESSAGE" ( / message" --> )
           [CHAR] " PARSE reffered
           STATE @ IF [COMPILE] LITERAL POSTPONE ~MESSAGE
                    ELSE DROP \ в режиме интерпретации сообщение
                              \ добавляется к списку сообщений
                   THEN ; IMMEDIATE

\ сохранить все сообщения в файл с указанным именем
: save-messages ( asc # --> )
                W/O CREATE-FILE THROW >R
                msg-list
                BEGIN @ DUP WHILE
                      DUP off_msgName @ 0 (D.) R@ WRITE-FILE THROW
                        S"  " R@ WRITE-FILE THROW
                        DUP off_msgBody COUNT R@ WRITE-FILE THROW
                        LT LTL @ R@ WRITE-FILE THROW
                    off_msgPrev
                REPEAT DROP R> CLOSE-FILE THROW ;

\ распознать число одинарной длины в виде: ddd -ddd 0xhhhh
: val ( asc # --> n )
      BASE @ >R
       OVER C@ [CHAR] - = DUP >R IF SKIP1 THEN
       OVER W@ [ S" 0x" DROP W@ ] LITERAL = IF SKIP1 SKIP1 HEX THEN
       0 0 2SWAP >NUMBER IF -1 THROW THEN DROP D>S
       R> IF NEGATE THEN
      R> BASE ! ;

\ загрузить список сообщений в память из файла Asc #
: load-messages ( asc # --> flag ) FILE>HEAP
                IF SAVE-SOURCE N>R SOURCE! 0 >IN !
                   BEGIN NextWord DUP WHILE
                         val >R 13 PARSE R> new-msg
                         1 >IN +!
                   REPEAT 2DROP
                   NR> RESTORE-SOURCE
                 ELSE FALSE
                THEN TRUE ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ \ тестирование сборки
      : test MESSAGE" passed" ;
    test
}test