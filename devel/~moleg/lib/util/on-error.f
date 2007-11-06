\ 20-04-2007 ~mOleg для SPF4.18
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ вложенные обработчики ошибок.

\    Иногда необходимо выполнять определенные действия транзактивно,
\ то есть в случае ошибки обработки нужно восстановить, например,
\ измененные переменные, контекст, текущий словарь, закрыть открытый
\ файл и тому подобные вещи и при этом нет никакой возможности
\ воспользоваться CATCH THROW механизмом...

 REQUIRE ADDR     devel\~moleg\lib\util\addr.f

\ ---------------------------------------------------------------------------

        \ количество возможных обработчиков на стеке состояний.
        0x20 VALUE #err-handlers

  \ создали стек ошибок
  USER-CREATE ERRORS  #err-handlers CELLS USER-ALLOT

  \ указатель на текущую ошибку
  USER-VALUE cur-err-h

\ при выходе все обработчики выталкиваются из стека и исполняются.
\ В самом низу стека обработчиков ошибок находится неудаляемый базовый
\ обработчик.

\ текущий обработчик ошибок хранится по адресу addr
: err-handler ( --> addr ) cur-err-h ADDR * ERRORS + ;

\ добавивить реакцию в текущий список обработчиков
: ON-ERROR   ( 'cfa --> )
             cur-err-h 1 + #err-handlers MIN TO cur-err-h
             err-handler A! ;

\ вытолкнуть обработчик из стека
\ самый первый обработчик не выталкивается никогда
: EXIT-ERROR ( --> ) cur-err-h 1 - 0 MAX TO cur-err-h ;

\ при возникновении ошибки ее надо обработать согласно установленному
\ порядку обработчиков.
: IS-ERROR ( err-num --> )
           BEGIN cur-err-h WHILE
                 err-handler A@ EXECUTE
               EXIT-ERROR
           REPEAT
           err-handler A@ EXECUTE ;

\ настройка обработчика - должна выполняться один раз на поток:
        ' ERROR2 err-handler !
        ' IS-ERROR TO ERROR

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ : sample DROP BYE ;
      : simple S" passed" TYPE CR ;
      : error CR S" can't perform EXIT-ERROR" TYPE ;
      ' sample ON-ERROR
      ' simple ON-ERROR
      ' error ON-ERROR
      EXIT-ERROR
      alskjfl   \ это ошибка
}test

\EOF -- тестовая секция -----------------------------------------------------

: 3st-err ." first error handler: " ." error number - " DUP . CR ;
: 2st-err ." second error handler " CR ;
: 1st-err DROP FORTH_ERROR ; \ это, чтобы система не ругалась на ошибку.

' 1st-err ON-ERROR
' 2st-err ON-ERROR
' 3st-err ON-ERROR

 adfasdf  \ это ошибка 8)
\ после отработки ошибок в стеке обработчиков остается лишь один системный




