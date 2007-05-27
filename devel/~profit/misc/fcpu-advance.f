\ ForthCPU/VM emulator by WingLion 

\ сначала доопределение Форта (правильное, через REQUIRE)
REQUIRE AT-XY ~day\common\console.f

REQUIRE таблица ~profit\lib\chartable.f

BASE @ HEX \ предущую систему счисления лучше сохранять

CLS 0 0 AT-XY 

\ закройте глаза и не читайте следующие 3-4 строчки! 
\ почему в SPF нет слова H. - не знаю 

: H. BASE @ SWAP HEX 
  S>D <# # # # # # # # # #> TYPE SPACE 
  BASE ! 
; 

: FALSE! FALSE SWAP ! ; 
: TRUE! TRUE SWAP ! ; 
\ : 1+! 1 +! ; \ эта команда и так есть 
: 1-! -1 +! ; \ а этой в SPF не оказалось 

\ *********************** ну, привык я юзать звездюлины как разделители 
\ теперь определения для ВМ 

\ глобальные параметры 
1000 CONSTANT MemSize \ размер памяти ВМ (в байтах) 
10 CONSTANT DStS \ глубина стека данных  (в словах) 
10 CONSTANT RStS \ глубина стека возвратов (в словах) 

\ блоки ВМ 
VARIABLE PC  \ счетчик команд 
VARIABLE RAD \ регистр адреса/данных 
VARIABLE CMD \ регистр команды 
VARIABLE RADF \ флаг входного мультиплексора для RAD 
\ TRUE - RStack -> RAD 
\ FALSE - DStack ->RAD 
VARIABLE RStF \ флаг входного мультиплексора для RStack 
\ TRUE - PC+1 ->RStack 
\ FALSE - RAD ->RStack 

VARIABLE DStP \ поинтер D-стека 
CREATE DStack DStS CELLS ALLOT \ стек данных 
VARIABLE DStDO \ текущая вершина стека данных (вых. регистр стека) 

VARIABLE RStP \ поинтер R-стека 
CREATE RStack RStS CELLS ALLOT \ стек возвратов 
VARIABLE RStDO \ текущая вершина стека возвратов (вых. регистр стека) 

CREATE MEM MemSize ALLOT  \ память ВМ 
MemSize 1- CONSTANT MASK \ ограничитель памяти ВМ 

\ **************************** 

: -1OO! 1- OVER OVER C! NIP ; 
: init_MEM 
 MEM MemSize ERASE 

\ микро-DUMP памяти ВМ 

 00 00 00 00  \ nop nop 
 01 10 00 00 00 \ call 0010 
 03 55 AA 00 00 \ lit AA55 
 00 00  \ nop nop 
 01 08 00 00 00 \ call 0008 

 MEM 15 + 
 15 0 DO -1OO! LOOP 

\ 10 0 DO I DUP MEM + C! LOOP 
; 

: reset PC 0! DStP 0! RStP 0! RADF FALSE! RStF TRUE! ; 

reset init_MEM 

\ **************************** 

: OUTMST \ вывод состояния стеков и памяти 
   CR ." DataStack:" DStP @ H. 
   DStack 8 DUMP 
   CR ." RetStack:" RStP @ H. 
   RStack 8 DUMP CR 
   \ память 
   CR ." Memory:" CR 
   MEM 40 DUMP 
; 

: OUTSTR \ вывод состояния регистров 
   \ регистры 
   \   0 0 AT-XY 
   CR 
   ."  PC: " PC @ H.    \ счетчик команд 
   ."  RAD " RAD @ H.   \ регистр адреса/данных 
   ."  CMD " CMD @ H.   \ регистр команды 
   ."  DSt " DStDO @ H. \ Вершина стека данных 
   ."  RSt " RStDO @ H. \ Вершина стека возвратов 
; 

: OUTST \ вывод состояния ВМ 
\    0 0 AT-XY 
    OUTSTR 
\    OUTMST 
; 

\ **************************** 
\ Работа ВМ 
\ **************************** 
\ вспоможители 
: PC++ PC 1+! ; 
: MPC@ MEM PC @ MASK AND + @ ; 
\ читать данные из памяти ВМ по адресу PC -- МЕМ(PC) 
: MPC! MEM PC @ MASK AND + RAD @ SWAP ! ; 
\ записать данные из RAD по адресу в PC 
\ тут еще разбираться с шириной данных ВМ 

: GetLit MPC@ PC @ 4 + PC ! ; \ получить литерал 
: RdCMD MPC@ CMD C! PC++ ; \ читать команду 
\ тут может быть и какая-нибудь распаковка и доп. чтение-вперед 

\ **************************** 
\ работа со стеком возвратов 
\ **************************** 

: RStA RStP @ RStS 1- AND CELLS RStack + ; \ реальный адрес вершины 

: RNOP RStA @ RStDO ! RStF TRUE! ; \ прочитать вершину стека возвратов 

: RSWAP RNOP RStF @ IF PC @ 1+ ELSE RAD @ THEN RStA ! ; 
\ записать значение PC+1 или RAD в стек возвратов и счит. стар.вершину 

: RPUSH RStP 1+! RSWAP RNOP ; 
\ записать новое значение в стек возвратов и считать новую вершину 

: RPOP RStP 1-! RNOP ; \ снять со стека возвратов одно значение 

\ **************************** 
\ работа со стеком данных 
\ **************************** 

: DStA RStP @ DStS 1- AND CELLS DStack + ; \ реальный адрес вершины 

: DNOP DStA @ DUP DStDO ! ; \ прочитать вершину стека возвратов 

: DSWAP DNOP RAD @ DStA ! ; 
\ записать значение RAD в стек возвратов и считать старую вершину 

: DPUSH DStP 1+! DSWAP DNOP ; 
\ записать значение RAD в стек возвратов и считать новую вершину 

: DPOP DStP 1-! DNOP ; \ снять со стека возвратов одно значение 

\ **************************** 
\ работа с RAD 

: >RAD RADF @ IF RStDO ELSE DStDO THEN @ RAD ! RADF FALSE! ; 
: ALU>RAD ; \ ALU-операция 
: nRAD ; \ ничего не делать с RAD 

\ **************************** 
\ команды-команды-команды 
\ **************************** 

: advance  RdCMD RNOP DNOP nRAD ; \ перейти к следующей команде
: call MPC@ PC++ RPUSH PC ! ;
: if GetLit RAD @ IF PC ! ELSE PC++ THEN ;
: lit DPUSH GetLit RAD ! ;
: ret RPOP RStDO @ PC ! ;

\ переопределение дешифрации команд через таблицу 
10 таблица CMD-TAB
\ 0 - nop 
0 выполняет: ; 
\ 1 - call 
1 выполняет: call ;
\ 2 - if 
2 выполняет: if ;
\ 3 - lit 
3 выполняет: lit ;
\ 4 - >R 
4 выполняет: RStF FALSE! RPUSH DPOP RADF FALSE! >RAD  ; 
\ 5 - R> 
5 выполняет: RPOP DPUSH RADF TRUE! >RAD ; 
\ 6 - ret 
6 выполняет:  ret ;
\ 7 - dup 
7 выполняет: DPUSH >RAD ; 
\ 8 - drop 
8 выполняет: DPOP >RAD ; 
\ 9 - over 
9 выполняет: DPOP DSWAP >RAD DPUSH DSWAP >RAD ; 
\ A - swap 
A выполняет: DSWAP >RAD ; 
\ B - pre: 
B выполняет: ;
\ C - user: 
C выполняет: ;
\ D - sys: 
D выполняет: ; 
\ E - fetch ( @ ) 
E выполняет: 
  RPUSH RAD @ PC ! MPC@ RAD ! ret ; 
\ F - store ( ! ) 
F выполняет: 
  RPUSH RAD @ PC ! DPOP >RAD MPC! ret ; 

\ ****************************** 

: CMD@  CMD @ 0F AND ;  \ читать регистр команды 

: STEP CMD@ CMD-TAB advance ;

\ рабочий цикл 
: pp CLS 
  0 0 AT-XY  S" [ESC] - выход" TYPE 
  OUTMST CR 
  BEGIN 100 PAUSE  OUTST STEP KEY? IF KEY 1B = IF EXIT THEN THEN AGAIN ; 


BASE ! \ восстанавливаем систему счисления

pp 

\ 1000 PAUSE

\ BYE