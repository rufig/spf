( попытка реализации кольцевой многозадачности/многопоточности )
 .( Round Robin priority multitasking v0.49 for sp-forth4 ) CR
 .(     HELP will be added soon ) CR
 .(	no portability to other systems :-( ) CR
\ SET-OPT 
\  To Do: 
\       + - приоритеты задач
\       + - управление задачами самостоятельное/переключатель/другая_задача
\       ? - связь между задачами, работа с каналами данных
\	- - пауза реального времени
\       ?? - оптимизация по быстродействию при возможности
\       - - независимые переменные (вероятно, но маловозможно)
\       - - максимально возмажная независимость от реализации шитого кода,
\       архитектуры процессора

\ особенности реализации
\       - изначальная ориентация на spf-подобный код

 (
_______наброски по кольцу
\ [...] - ячейка, хар-ая задачу {в конкретной реализации может быть
  размером от бита до двойного слова}

"""""описание/состояние задачи"""""""

[статус/состояние задачи]
        0  активна { будет запущена, когда дойдет очередь}
        -1  спит { кольцо будет включать следующую за ней задачу пока флаг 
        установлен}
        х[>0]  { столько оборотов кольца осталось до следующей активации
        задачи после ее последнего переключения; инкрементируется каждый
        оборот}

[приоритет]
        0  высший {если не спит, запускается при каждом обороте кольца}
        x[>0]  приоритет {если не спит, запускается каждый х-ый цикл}
        x[<-1]  неопределено

"""""""связь по кольцу""""""""""""

[следующая задача]
        номер следующей задачи{}

[предыдущая задача] 
        номер предыдущей задачи{}

"""""""сохранение задач"""""""""""

[стек данных]
[стек возвратов]
[адрес возврата]
[идентификатор]
[user область]

==========================================================================
        * замечание1: флаг деактивирующий задачу может быть выставлен
        самой задачей, другой задачей, кольцом{???}

        * замечание2: пока собственные у задач только стеки, работают в
        общем блоке памяти но каждая в своей области, возможно в дальнейшем
        блок будет разбит на  сегменты
        
        * замечание3: задаче выделяется 512 ячеек памяти под стеки {по 256}
        + 108 байт под регистры сопроцессора, хотелось бы и их сохранить
        + собственная область памяти {х байт} в которой они расположены;
        стеки закинем по старшим адресам, расти они будут ест-но вниз

)

HERE
\ доп. слова, их немного
\ : -- CREATE OVER , + DOES> @ + ;
\ структура-описатель задачи
0
CELL -- Status
CELL -- Priority
CELL -- NextTask
CELL -- PrevTask
CELL -- Task_sp0
CELL -- Task_sp
CELL -- Task_rp
CELL -- Task_rp0
CELL -- Task_fp
CELL -- TaskID
CELL -- UserArea
CONSTANT ring_str_size

\ поле описателей задач
CREATE Ring     64 ring_str_size *  ALLOT \ пока рассчитываем на 64 задачи

\ введем понятие стека свободных указателей, каждый из которых указывает
\ на свободное место в кольце (указатель на описатель задачи)
\ при запуске задачи, она получает элемент стека указателей, который
\ становится ее идентификатором, по завершении задача кладет этот
\ указатель обратно

CREATE ID_stack 64 ALLOT \ стек указателей (растет в сторону увеличеня адресов))

: init_ID 64 0 ?DO I ID_stack I + C! LOOP ;
init_ID
VARIABLE ID_pointer     ID_stack ID_pointer !

: ID_get ( -- free_id ) ID_pointer @ C@ ID_pointer 1+! ;
: ID_free ( id -- ) -1 ID_pointer +! ID_pointer @ C! ;

: Ring[] ( i -- addr[i] ) ring_str_size * Ring + ; \ возвращает адрес описания и-той задачи/нити

  0 VALUE RT \ текущая задача - необязательно активная, просто ее описатель
             \ анализируется в данное время

  VARIABLE TaskNum \ задач в кольце
  
  0 VALUE NEW_T
  0 VALUE _prev 0 VALUE _next
  
: other@ ; : other! ;


( ________________________________________________________________
рисунок1, добавление задачи
---------------------------------
<< - указатель на пред. задачу
>> - указатель на след. задачу
>х>, <x< - содержимое

<< 1 >> << 2 >> << 3 >> - кольцо задач

<3< [1] >2> <1< [2] >3> <2< [3] >1> - тоже, но подробнее
пусть текущая - 2, добавим задачу 4 -- << 4 >>

[2]>> -> [4]>>  \ берем у 2 указатель на след. задачу, запоминаем, 
                \ записываем в 4 как след. задачу 3
 {4} -> [2]>>   \ записываем 4 в указатель след. у 2
  {2} -> [4]<<  \ записываем 2 в указатель пред. у 4
   {4} -> [3]<< \ записываем 4 как пред. для 3
связи м/у задачами сформировали

рассмотрим случай когда задач в кольце ещё нет, для первой задачи
в этом случае будем иметь:
<< 1 >> -- <1< [1] >1>, текущая ест-но; она добавим к ней задачу 4 << 4 >>

[1]>> -> [4]>>
 {4} -> [1]>>
  {1} -> [4]<<
   {4} -> [1]<<
___________________________________________________________________)


0 Ring[] TO RT

: define_task ( memory status priority xt -- )
ID_get DUP Ring[] TO NEW_T \ в NEW_T - начальный адрес свободного описателя
NEW_T TaskID !          >R
NEW_T Priority !        NEW_T Status !
DUP 512 CELLS + 128 + ALLOCATE THROW NEW_T UserArea !
NEW_T UserArea @ + 256 CELLS + DUP 256 CELLS + DUP 8 +
\ определим новые стеки задачи
NEW_T Task_fp !
NEW_T Task_rp ! R> NEW_T Task_rp @ !
NEW_T Task_sp !
\ установим начальные указатели стеков - изначально стеки пусты
NEW_T Task_sp @ NEW_T Task_sp0 !
NEW_T Task_rp @ NEW_T Task_rp0 !
;

: add_to_ring ( -- )
TaskNum @ IF
  RT PrevTask @ DUP >R 
  NEW_T NextTask !
  NEW_T RT NextTask !
  RT NEW_T PrevTask !
  NEW_T R> PrevTask !
  NEW_T TO RT -1 TO NEW_T \ сделали новую задачу текущей
ELSE \ а задача-то первая!!!
  NEW_T TO RT
  RT DUP NextTask !
  RT DUP PrevTask !
THEN
TaskNum 1+!
;


( ________________________________________________________________
рисунок2, удаление задачи из кольца
----------------------------------
удаление задачи.

кольцо: << 1 >> << 2 >> << 3 >>, удалим задачу 2, она текущая, если нет сделаем
подробнее:
<3< [1] >2>  <1< [2] >3>  <2< [3] >1>

[2]>> -> [1]>>
 [2]<< -> [3]<<
  идентификатор задачи обратно на стек свободных указателей
__________________________________________________________________ )



: terminate ( delete_task) ( id -- )
RT >R
Ring[] TO RT
RT NextTask @ TO _next ( 3)
RT PrevTask @ TO _prev ( 1)
RT NextTask @ _prev NextTask !
RT PrevTask @ _next PrevTask !
RT TaskID @ ID_free RT UserArea @ FREE THROW
R> TO RT
-1 TaskNum +!
;

: find_active_task
   RT Status @
    0 > IF -1 RT Status +! THEN \ -1 задача спит, смотрим следующую за 
                                \ ней по кольцу, ищем не спящую
   BEGIN RT NextTask @ TO RT RT Status @ \ DUP . ." -status "
   DUP 0 > IF -1 RT Status +! THEN 0=
   UNTIL
;

: check_priority
\ анализ приоритета
RT Priority @ RT Status ! ;

: save_task
RP@ SP@ \ CELL+
RT Task_sp 2!
other! ;

: analiz
RT NextTask @ TO RT
\ анализ состояния задачи
RT Status @ \ ( 0|-1|U )
   0<> IF
   find_active_task
THEN
;
  
: switch ( PAUSE ) \ "переключатель" задач
\ запомним состояние задачи
\ ." [" S0 @ . SP@ . ." ]" 
  save_task
\ ." [" S0 @ . SP@ . ." ]" 
\ переходим на анализ следующей задачи
  analiz
\ ." [" S0 @ . SP@ . ." ]"   
  check_priority
\ ." [" S0 @ . SP@ . ." ]"   
\ переключение задачи
RT Task_sp0 2@ ( sp s0 ) S0 ! SP!
RT Task_rp 2@ ( r0 rp ) RP! R0 !
;

VARIABLE _S VARIABLE _R
VARIABLE _S0 VARIABLE _R0

: activate ( -- ) \ запуск "многозадачного" слова
RP@ SP@ \ взяли текущее состояние системы, запомним его где-нибудь
CELL+ _S ! _R ! S0 @ _S0 ! R0 @ _R0 !
\ взяли текущее слово из кольца - обычно это будет последнее определенное слово
  other@
  RT Task_sp0 @ S0 !
  RT Task_sp @ SP!
  RT Task_rp0 @ R0 !
  RT Task_rp @ RP!
  \ переходим на выполнение кольцевых задач
." activatied  "
;

: stop \  а вот про стоп то и подзабыли, попробуем исправить
RT NextTask @ TO _next ( 3)
RT PrevTask @ TO _prev ( 1)
RT NextTask @ _prev NextTask !
RT PrevTask @ _next PrevTask !
\  удалили нашу задачу из кольца - оборвали связи 
  -1 TaskNum +! \ уменьшили кол-во выполняемых задач на одну
TaskNum @ IF \ смотрим, а не последняя ли мы задача остались???
        \ нет не последняя, переключаемся
 RT TaskID @ ID_free \ ( id task_area -- ) освободили описатель
\ RT UserArea @ FREE THROW \ ( addr_to _free -- ) освободили пользовательскую область задачи
   switch
ELSE
\ восстанавливаем исходный поток, до активации слова
   _S0 @ S0 ! _S @ SP!
   _R @ RP! _R0 @ R0 !
    RT TaskID @ ID_free \ ( id task_area -- ) освободили описатель
    RT UserArea @ FREE THROW \ ( addr_to _free -- ) освободили пользовательскую область задачи
THEN ;

: sleep ( -- ) -1 RT Status ! switch ;
: suspend ( id -- ) Ring[] Status -1 SWAP ! ;
: resume ( id -- ) Ring[] Status 0 SWAP ! ;

.( Size of Ring.f is ) HERE SWAP - . CR

\EOF ===================================================================

CR .( SAMPLE, TESTING) CR  0 VALUE RR

\ EOF 

.( 2 - speed testing2) CR
WINAPI: GetTickCount KERNEL32.DLL

0 VALUE TT1 0 VALUE TT2 0 VALUE TT3
.( defining tasks )
: TEST1 1000000 0 ?DO switch LOOP stop ; .( .)
: TEST2 1000000 0 ?DO switch LOOP stop ; .( .)
: TEST3 1000000 0 ?DO switch LOOP stop ; .( .)
.( adding to ring )
10 0 0 ' TEST1 define_task add_to_ring .( .)
10 0 1 ' TEST2 define_task add_to_ring .( .)
10 0 2 ' TEST3 define_task add_to_ring .( .)
.( done) CR
: TEST4 activate ;

.( starting    PRESS ANY KEY TO BEGIN ) CR KEY DROP 

.( Ring speed test...)
GetTickCount
TEST4
GetTickCount
SWAP - 30000000 SWAP / 1000 * . .( switching per second)
.(  done ) CR

\EOF
.( 1 - task switching testing ) CR
0 VALUE RR
: ?? ( id ) \ распечатаем описатель и-той задачи
DUP Ring[] TO RR
. ." -task control block" CR
." ____________________" CR
RR Status @ . CR
RR Priority @ . CR
RR NextTask @ . CR
RR PrevTask @ . CR
RR Task_sp @ . CR
RR Task_rp @ . CR
RR Task_fp @ . CR
\ RR RetAddr @ . CR
RR TaskID @ . CR
RR UserArea @ . CR
;

.( defining tasks )
: TEST1 10 0 ?DO ." TEST1 " I . ." {" S0 @ . SP@ . ." }" 1 .S DROP ." <<1 " CR switch LOOP stop ; .( .)
: TEST2 10 0 ?DO ." TEST2 " I . ." {" S0 @ . SP@ . ." }" 55 77 .S 2DROP ." <<2 " CR switch LOOP stop ; .( .)
: TEST3 10 0 ?DO ." TEST3 " I . ." <<3 " CR switch LOOP stop ; .( .)
.( adding to ring )
10 0 0 ' TEST1 define_task add_to_ring .( .)
10 0 2 ' TEST2 define_task add_to_ring .( .)
10 0 2 ' TEST3 define_task add_to_ring .( .)
.( done) CR
: TEST4 activate ." ring was done" ;
.( starting    PRESS ANY KEY TO BEGIN ) CR STARTLOG KEY DROP TEST4
\EOF


