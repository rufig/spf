\ промежуточное. до ver 0.3 не доведено

\ Отладчик времени выполнения слов (profiler).  SPF3.70
\ example - в конце.

\ history
\ 11.1999,,, 02.2000
\ 06.07.2000  ver 0.1
\    - сменил имя debug на profile 
\    - было LAST @ ,сделал LATEST (***) ( чтобы с locals.f правильно работало и вообще.)
\      / profiler.f должен подключатся до locals.f, чтобы работал для слов с локальными переменными /
\    - ведение списка слов  с таймеров
\    - сброс статистики
\    - если 0 вызовов, то не выводит строку для этого слова.
\ 27.11.2000   ver 0.2
\    - отвязка от структуры словаря. достигнуто минимальными изменениями и переработкой.

\ 12.03.2001   ver 0.3
\    * фикс THROW  - неверно получало timer-info текущего слова.
\    * пофиксил получение timer-info - слово last_timer_info

\ 19.Nov.2002 Tue 01:02
\    * исправил ошибку в слове DU< 
\     see:
\        From: mlg 3 <m_l_g3@yahoo.com>
\        To: spf-dev@lists.sourceforge.net
\        Date: Sat, 9 Nov 2002 10:05:16 -0800 (PST)

\ Copyright (C) R.P., 1999-2002

\  profile on    - включить компиляцию кода таймера  ( на все след. слова вешается таймер  )
\  profile off   - отключить компиляцию кода таймера ( на все след. слова таймер не вешается)
\  timer on/off  - если вЫключено, то ничего не подсчитывается.
\  ResetProfiles - сбросить статистику.
\  .AllStatistic - генерирует статистику по времени выполнения каждого слова
\  Формат  
\      Calls      Ticks      AverageTicks  Name     (Rets)
\ Где
\  Calls        - количество вызовов
\  Ticks        - общее время работы слова
\  AverageTicks - среднее время за вызов
\  Name         - имя
\  (Rets)       - число зафиксированных возвратов, если оно отличается
\                 от числа вызов. Суммарное и среднее время считается только 
\                 по зафиксированным выходам.
\                 Выходы фиксируются по EXIT , THROW , ";"

\ Данный профайлер не реентерабелен к многопоточности и рекурсии.
\ Т.е. если слово с таймером  будет рекурсиво  вызываться или будет
\ работать одновременно в разных потоках, то  результаты для этого слова будут 
\ не верны.

\ Неопределенная ситуация, если значение profile меняется 
\ в процессе компиляции слова  с off  на  on
\ Т.е. значение profile лучше не менять во время компиляции слова :)
\  ( например, последовательностью  [ profile on ]   )

\ Значение AverageTicks  занимает DWORD. 
\ если результат не влезает, то выводится '-'
\ Это может произойти, если среднее время выполнения превысит ~14 сек ( на 300 МГц)
\ ( если бы были слова D* D/ то не было бы этого ограничения  ;)
 

REQUIRE [DEFINED] lib\include\tools.f
REQUIRE U.R       lib\include\CORE-EXT.F
REQUIRE UD.RS     ~pinka\lib\print.f

.( ----- Loading profiler...) CR

: >NAME  ( CFA -- NFA )
    4 -  1- ( зависит от реализации словарной статьи ***) 
    DUP >R  ( a ) \ на стеке - адрес последнего символа имени
    BEGIN  ( a )
        1-  DUP C@   ( a b )
        OVER + R@  =  
    UNTIL   RDROP
;


(  В Pentium'е разработчиками была введена команда RDTSC, возвращающая число
тактов процесора с момента подачи на него напряжения. Код этой команды $0F $31.
команда возвращает восьмибайтное число в регистрах EDX:EAX. 
)

[DEFINED] TIMER@ [IF]

: GetTacts  S" TIMER@" EVALUATE ; IMMEDIATE   \ for jp-forth

[ELSE]

: GetTacts  ( -- tlo thi )
( see ~pinka\lib\TOOLS\GenTimer.f  )
[ BASE @ HEX   \ для SPF3x
 F  C, 31  C, 83  C, ED  C,
 8  C, 89  C, 55  C, 0  C,
 89  C, 45  C, 4  C,
BASE ! ] ;

[THEN]


VARIABLE profile  \ будет ли компилироваться код таймера при определении слов.
VARIABLE timer    \ будут ли засекатся данные (время, вызовы, етк).


: on  ( a -- )  -1 SWAP ! ;
: off ( a -- )   0! ;

\ - - - - -
 timer  on
 profile off
\ - - - - -

 VOCABULARY vocProfiler
 ALSO vocProfiler DEFINITIONS



0 VALUE List-First   \ голова списка. ( цепочка от первого добавленного в список к последнему)
0 VALUE List-Last    \ последний элемент.


\ =============================================
\ организация  таймера

\ 5 CONSTANT offset1  \ смещение между HERE перед определением слова и NFA этого слова
\ HEX F0F0F0F0 DECIMAL  CONSTANT timer-id  \ идендификатор слова с таймером.
HEX 56FAC6E3 DECIMAL  CONSTANT timer-id  \ идендификатор слова с таймером.


\ структура данных для каждого профилируемого слова.

  0
  4 -- id           \ = timer-id
  4 -- ^name         \ c-addr of word name
  8 -- ticks        \ сумматор времени выполнения
  4 -- count-in     \ счетчик входов
  4 -- count-out    \ счетчик выходов
  8 -- time-curr    \ показания при входе
  4 -- next         \ связываю в список.
CONSTANT /timer_info


WORDLIST CONSTANT shadows

: article  ( -- a-timer_info ) \ name -- name 
( создать словарную статью с timer_info )

  WARNING @  WARNING 0!
  GET-CURRENT  shadows SET-CURRENT
  >IN @  CREATE  
         LATEST >R
  >IN !
  SET-CURRENT
  WARNING !

  HERE
  /timer_info ALLOT  DUP /timer_info ERASE
  R> OVER ^name !  >R ( R: a-timer_info )
  timer-id  R@ id !

    List-Last IF
      R@ List-Last next !
      R@ TO List-Last
    ELSE
      R@ TO List-First
      R@ TO List-Last
    THEN
  RDROP
;

: timer_info ( NFA -- a-timer_info | 0 )
\  DUP ID. CR
\ При коллизии имени будет найден последний вариант.
  COUNT  shadows SEARCH-WORDLIST
  IF EXECUTE ELSE 0 THEN
;

: last_timer_info  ( --  a-timer_info )
   shadows @ \ nfa last in shadows
   ?DUP IF NAME> EXECUTE  EXIT THEN
   ." address of timer_info = 0 " ABORT
;

: start-timer ( a-timer_info -- )
    timer @ 0= IF DROP EXIT THEN
    >R  GetTacts  R@ time-curr  2!
    R> count-in 1+!
;

: stop-timer  ( a-timer_info -- )
    timer @ 0= IF DROP EXIT THEN
    DUP >R time-curr 2@ DNEGATE  GetTacts D+
    R@ ticks 2@ D+  R@ ticks 2!  R>  count-out 1+!
;

: have-timer ( NFA -- a-timer_info true | false )
    timer_info  ?DUP 0<>
;

\ |||||||||||||||||||||||||||||||
: (THROW)   ( ior  a -- )
    OVER IF stop-timer ELSE DROP THEN
;

: :: : ;
\ |||||||||||||||||||||||||||||||

\ ==========================================


: .border ( -- )
  SPACE [CHAR] | EMIT SPACE
;

: .ticks ( a-timer_info -- )
  ticks 2@  16 UD.RS  .border
;
: .calls ( a-timer_info -- )
  count-in  @  10  U.RS  .border
;
: .rets ( a-timer_info -- )
  count-out  @  ." ( " 10  U.R  ."  )"
;
: .name ( a-timer_info -- )
   ^name @
   DUP ID. SPACE
   ?IMMEDIATE  IF ." - Imed " THEN
;

: DU< ( d1 d2 -- f ) ( d1_lo d1_hi d2_lo d2_hi -- f )
\  ROT SWAP U> IF 2DROP FALSE EXIT THEN
\  U<
   ROT 2DUP = IF 2DROP U< ELSE U> NIP NIP THEN
;

: .average ( a-timer_info -- )
  >R
  R@ count-out @ DUP IF  ( n )
\     R@ ticks 2@ ROT  UM/MOD NIP

     R@ ticks 2@ ROT >R  ( R: n )
     2DUP R@ -1 UM* DU< 0= IF
       RDROP
       2DROP 13 SPACES ." -" .border RDROP EXIT
     THEN
       R> UM/MOD NIP
     
  THEN    14 U.RS  .border
  RDROP 
;

: .title  ( -- )
  CR  ."  Calls       Ticks              AverageTicks     Name     (Rets)"
;

: .result ( a-timer_info -- )
    DUP count-in  @ 0= IF DROP EXIT THEN \ чтобы не было вывода не работавших слов.
    CR
    DUP .calls
    DUP .ticks
    DUP .average
    DUP .name
    DUP count-in @  OVER count-out @ <>  
    IF DUP .rets THEN
    DROP
;


VARIABLE 'named?  \ ячейка, хранящая флаг:  было ли у последнего определения имя.

 PREVIOUS DEFINITIONS   
 ALSO vocProfiler

\ ================================================================
\ Public - секция.


: GetTimes  (  CFA -- d-ticks u-rets  true | false )
    >NAME
    have-timer IF
      >R
      R@ ticks 2@
      R> count-out  @
      TRUE  EXIT
   THEN  FALSE
;

: ResetProfiles  ( -- )
  List-First
  BEGIN
  DUP WHILE >R
    0 0  R@ ticks     2!
    0    R@ count-in  ! 
    0    R@ count-out !
    0 0  R@ time-curr 2!
    R> next @
  REPEAT DROP
;


\ ---------------------------------------------------------------
\ вывод без сортировки

\ старый вариант. узнает слово с таймеров по идендификатору.
\ ( вывод ограничен контекстом словарей )
: .AllStatistic_o ( -- )  
  .title
  GET-ORDER
  0 DO
    @
    BEGIN  ( NFA )
      DUP 0 <>
    WHILE
      DUP have-timer IF
        .result
      THEN  CDR
    REPEAT  DROP
  LOOP CR
;

\ новый варинат. выводит все  по списку.
: .AllStatistic ( -- )
  .title
  List-First
  BEGIN
  DUP WHILE
    DUP .result
    next @
  REPEAT DROP CR
; ( в ver 0.2 тут можно уже просто сделать ForEach-Word
но список через next остался в наследство с прошлой версии, 
пусть уж работает... ;)


: .StatisticByCFA ( CFA_last_word -- )  \ 
  .title
    >NAME
    BEGIN  ( NFA )
      DUP 0 <>
    WHILE
      DUP  have-timer IF  ( NFA a-timer_data  )
        .result
      THEN  CDR
    REPEAT  DROP  CR
;


\ ---------------------------------------------------------------
\ переопределение слов, отвечающих за вызов и возврат.

: EXIT
    profile @  IF    ( LAST @  timer_info)  last_timer_info
        POSTPONE LITERAL   POSTPONE stop-timer
    THEN
    POSTPONE EXIT
; IMMEDIATE


: THROW  ( errno -- )
    STATE @ 0= IF  THROW EXIT THEN
    profile @  IF
          last_timer_info
          POSTPONE LITERAL   POSTPONE (THROW)
    THEN 
    POSTPONE THROW
; IMMEDIATE

: : ( -- )
 profile @  IF
    article
    :  \ <== Attention!
    last_timer_info   POSTPONE LITERAL
    POSTPONE start-timer
    'named? on
    EXIT
 THEN :
;

:: ; ( -- )  
    profile @  IF
        'named? @ IF \ чтобы пропустить :NONAME 
          last_timer_info
          POSTPONE LITERAL   POSTPONE stop-timer
          'named? off
        THEN
    THEN
    POSTPONE ;
; IMMEDIATE

 PREVIOUS

 profile on

.( ----- Profiler loaded and turned on.) CR

\ ---------------------------------------------------------------
\ Example
\ : test  ( -- )
\   ResetProfiles  t1 .AllStatistic  KEY DROP  
\   ResetProfiles  t2 .AllStatistic  KEY DROP
\ ;

