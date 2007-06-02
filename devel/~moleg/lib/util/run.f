\ 02-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ поддержка временного буфера дл€ создани€ безым€нных временных слов

REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
REQUIRE ADDR     devel\~moleg\lib\util\addr.f
REQUIRE ON-ERROR devel\~moleg\lib\util\on-error.f
REQUIRE IFNOT    devel\~moleg\lib\util\ifnot.f

        \ переменна€ дл€ контрол€ парности открывающих и закрывающих слов
        USER controls ( --> addr )

        \ размер временного буфера дл€ сборки слов мимо кодофайла
        0x4000 CONSTANT #compbuf ( --> const )

        \ адрес временного буфера
        USER-VALUE CompBuf ( --> addr )

        \ переменна€ дл€ временного хранени€ адреса DP из CURRENT
        USER save-dp ( --> addr )

\ восстановить системные переменные
: rest ( --> )
       save-dp A@ DP !
       0 controls !
       [COMPILE] [ ;

\ начать компил€цию во временный буфер
: init: ( --> )
        0 controls A!
        HERE save-dp A!
        CompBuf IFNOT #compbuf ALLOCATE THROW TO CompBuf THEN
    ['] rest ON-ERROR
        CompBuf DP A!
        ] ;

\ закончить компил€цию во временный буфер, выполнить его содержимое
\ восстановить состо€ние системных переменных
: ;stop ( --> )
        RET,
    EXIT-ERROR rest
        CompBuf EXECUTE ;

FALSE WARNING !

\ пока так
\ при входе в определение переменна€ controls увеличиваетс€ на 1
\ при выходе из определени€ - уменьшаетс€ на 1
: : 1 controls ! : ;
: ; controls @ 1 = IFNOT -22 THROW THEN  0 controls ! [COMPILE] ; ; IMMEDIATE

TRUE WARNING !

?DEFINED test{ \EOF -- “естова€ секци€і ---------------------------------------

test{ \ пока просто тестирование собираемости
  S" passed" TYPE
}test



