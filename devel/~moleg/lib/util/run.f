\ 02-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ поддержка временного буфера для создания безымянных временных слов

REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
REQUIRE ADDR     devel\~moleg\lib\util\addr.f
REQUIRE ON-ERROR devel\~moleg\lib\util\on-error.f
REQUIRE IFNOT    devel\~moleg\lib\util\ifnot.f

        \ переменная для контроля парности открывающих и закрывающих слов
        USER controls ( --> addr )

        \ размер временного буфера для сборки слов мимо кодофайла
        0x4000 CONSTANT #compbuf ( --> const )

        \ адрес временного буфера
        USER-VALUE CompBuf ( --> addr )

        \ переменная для временного хранения адреса DP из CURRENT
        USER save-dp ( --> addr )

\ восстановить системные переменные
: rest ( --> )
       save-dp A@ DP !
       0 controls !
       [COMPILE] [ ;

\ начать компиляцию во временный буфер
: init: ( --> )
        0 controls A!
        HERE save-dp A!
        CompBuf IFNOT #compbuf ALLOCATE THROW TO CompBuf THEN
    ['] rest ON-ERROR
        CompBuf DP A!
        ] ;

\ закончить компиляцию во временный буфер, выполнить его содержимое
\ восстановить состояние системных переменных
: ;stop ( --> )
        RET,
    EXIT-ERROR rest
        CompBuf EXECUTE ;

FALSE WARNING !

\ пока так
\ при входе в определение переменная controls увеличивается на 1
\ при выходе из определения - уменьшается на 1
: : 1 controls ! : ;
: ; controls @ 1 = IFNOT -22 THROW THEN  0 controls ! [COMPILE] ; ; IMMEDIATE

TRUE WARNING !

?DEFINED test{ \EOF -- Тестовая секция  ---------------------------------------

test{ \ пока просто тестирование собираемости
  S" passed" TYPE
}test



