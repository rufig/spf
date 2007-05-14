\ Лямбда-конструкция.
\ Код под SPF
\ идея:  SU.FORTH, от Piter Sovietov
\ Ruvim,  06.01.2000
\ 14.May.2007 добавлена установка LAST-NON для RECURSE (true-grue, ygrek)

REQUIRE AHEAD lib\include\tools.f 

: LAMBDA{  ( -- )
\ время компиляции  ( -- orig1 xt )
   LAST-NON
   POSTPONE  AHEAD
   HERE 
   DUP TO LAST-NON
; IMMEDIATE

: }        ( -- xt )
\ время компиляции  ( orig1 xt -- )
\ код внутри конструкции LAMBDA{  } не выполняется, возвращается xt на этот код.
   >R
   POSTPONE EXIT
   POSTPONE THEN
   R> POSTPONE LITERAL
   TO LAST-NON
; IMMEDIATE


( код между  LAMBDA{ ... }   работает как в отдельном слове.
  Поэтому без спец. дополнений доступа к локальным переменным не будет.
)