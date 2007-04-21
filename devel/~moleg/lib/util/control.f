\ 19-04-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ структуры управлени€: ветвлени€ и циклы

REQUIRE IFNOT    devel\~moleg\lib\util\ifnot.f
REQUIRE ON-ERROR devel\~moleg\lib\util\on-error.f

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

\ пока так
\ при входе в определение переменна€ controls увеличиваетс€ на 1
\ при выходе из определени€ - уменьшаетс€ на 1
: : 1 controls ! : ;
: ; controls @ 1 = IFNOT -22 THROW THEN  0 controls ! [COMPILE] ; ; IMMEDIATE

\ ---------------------------------------------------------------------------

\ Ќачало ветвлени€.  од за словом IF выполн€етс€ в случае, если flag <> 0
: IF ( flag --> )
     STATE @ IFNOT init: THEN
     2 controls +!
     HERE ?BRANCH, >MARK 1 ; IMMEDIATE

\ јльтернативное ветвление.  од за else выполн€етс€ в случае, если
\ пропущен код за основным: IF или IFNOT ветвлением.
: ELSE ( --> ) ?COMP HERE BRANCH, >RESOLVE  >MARK 2  ; IMMEDIATE

\ ќписатель начала цикла. Ќа код за словом BEGIN передаетс€ управление
\ в случае повторений цикла
: BEGIN ( --> )
        STATE @ IFNOT init: THEN
        2 controls +!
        <MARK 3 ; IMMEDIATE

\ возврат без условий на точку BEGIN. ќтмечает конец кода бесконечного цикла.
: AGAIN ( --> )
        ?COMP -2 controls +!
        3 = IFNOT -2006 THROW THEN  BRANCH,
        controls @ IFNOT ;stop THEN ; IMMEDIATE

\ ¬озврат на точку после BEGIN если flag <> 0 (цикл с постусловием)
: UNTIL ( flag --> )
        ?COMP -2 controls +!
        3 = IFNOT -2004 THROW THEN ?BRANCH,
        controls @ IFNOT ;stop THEN ; IMMEDIATE

\ условный выход из цикла, если flag = 0
\ используетс€ между BEGIN и REPEAT, отмечающими начало и конец цикла
: WHILE ( flag --> )
        ?COMP 2 controls +!
        HERE ?BRANCH, >MARK 1 2SWAP ; IMMEDIATE

\ условынй выход из цикла, если flag <> 0. »спользуетс€ аналогично WHILE
: WHILENOT ( flag --> )
           ?COMP 2 controls +!
           HERE N?BRANCH, >MARK 1 ; IMMEDIATE

\ безусловный возврат на BEGIN. »спользуетс€ вместе с BEGIN и WHILE
: REPEAT ( --> )
         ?COMP -4 controls +!
         3 = IFNOT -2005 THROW THEN BRANCH, >RESOLVE
         controls @ IFNOT ;stop THEN ; IMMEDIATE

\ Ќачало ветвлени€. ѕромежуточное им€.
: ifnot ( flag --> )
        STATE @ IFNOT init: THEN
        2 controls +!
        HERE N?BRANCH, >MARK 1 ;

\  онец ветвлени€. Ќа точку за THEN переходит управление после выполнени€
\ одной из альтернатив, то есть кода после IF IFNOT или ELSE
: THEN ( --> )
       ?COMP -2 controls +!
       >RESOLVE
       controls @ IFNOT ;stop THEN ; IMMEDIATE

\ Ќачало ветвлени€.  од за словом IFNOT выполн€етс€ в случае, если flag = 0
: IFNOT ifnot ; IMMEDIATE

\EOF -- тестова€ секци€ -----------------------------------------------------

S" должно быть true = " TYPE  1 IF ." true " ELSE ." false " THEN CR
S" должно быть false = " TYPE 0 IF ." true " ELSE ." false " THEN CR
: testa IF ." true " ELSE ." false " THEN CR ;
S" должно быть true = " TYPE  1 testa
S" должно быть false = " TYPE 0 testa
S" убывающий р€д от 10 до 0 = " TYPE 10 BEGIN DUP . DUP WHILE 1 - REPEAT DROP CR
S" убывающий р€д от 10 до 1 = " TYPE 10 BEGIN DUP . 1 - DUP 0= UNTIL DROP CR
S" убывающий р€д от 9 до 6 = "  TYPE 10 BEGIN 1 - DUP WHILE DUP 5 <> WHILE DUP . REPEAT THEN DROP CR
S" убывающий р€д от 10 до 6 = " TYPE 10 BEGIN DUP . 1 - DUP WHILE DUP 5 = UNTIL ELSE THEN DROP CR
