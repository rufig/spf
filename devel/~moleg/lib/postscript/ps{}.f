\. 21-07-2004 реализация исполнимых массивов для постскрипта

Unit: eArray

\ ───────────────────────────────────────────────────────────────────────────

\      5 CONSTANT nesting

CREATE nStack 0 , nesting CELLS ALLOT

: n-- ( --> )
      nStack DUP @
      IF 1-!
       ELSE TRUE ABORT" n underflow!"
      THEN ;

: n++ ( --> )
      nStack DUP @ nesting <
      IF 1+!
       ELSE TRUE ABORT" n overflow!"
      THEN ;

: nd  ( --> ) nStack @ ;
: na  ( --> ) nStack DUP @ CELLS + ;
: n>  ( --> ) na @ DP !  n-- ;
: >n  ( --> ) n++ HERE na ! ;

\ ───────────────────────────────────────────────────────────────────────────

\    1000 CONSTANT def#

F: :def ( --> addr )
       def# ALLOCATE THROW
       >n DP ! :NONAME ;F

F: ;def ( addr --> addr )
       [COMPILE] ;
       HERE OVER - RESIZE THROW
       n> nd IF ] THEN
       ;F
EndUnit

\EOF

\ начать описание исполняемого массива
: { % ( --> addr )
    eArray :def ; IMMEDIATE

\ закончить описание исполняемого массива
: } % ( addr --> obj )
    eArray ;def ; IMMEDIATE

\EOF

{ dup over + swap .. .  n n n } Perform Dispose
{ - выделяет блок динамической памяти
    выкладывает рукоядку блока на стек данных и его адрес
    перенаправляет поток компиляции в этот блок

} - компилирует exit
    переводит систему в режим интерпретации
    фиксирует длинну блока

Таким образом создается динамическое определение без имени.

особенность в том, что такие массивы могут быть вложенными, то есть 
внутри {} могут быть другие {}

