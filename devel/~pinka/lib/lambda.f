\ Лямбда-конструкция.
\ Код под SPF
\ идея:  SU.FORTH, от Piter Sovietov
\ Ruvim,  06.01.2000

REQUIRE AHEAD lib\include\tools.f 

: LAMBDA{  ( -- )
\ время компиляции  ( -- orig1 xt )
   POSTPONE  AHEAD
   HERE
; IMMEDIATE

: }        ( -- xt )
\ время компиляции  ( orig1 xt -- )
\ код внутри конструкции LAMBDA{  } не выполняется, возвращается xt на этот код.
   >R
   POSTPONE EXIT
   POSTPONE THEN
   R> POSTPONE LITERAL
; IMMEDIATE


( код между  LAMBDA{ ... }   работает как в отдельном слове.
  Поэтому без спец. дополнений доступа к локальным переменным не будет.
)