\ Полёт снаряда и ракеты
\ Математическое моделирование
\ (c) yGREK Heretix mailto:heretix@yandex.ru
\ 07.May.2005

REQUIRE runRK         ~ygrek/lib/difur.f
REQUIRE GLWindow      ~ygrek/lib/joopengl/GLWindow.f
REQUIRE ENUM          ~ygrek/lib/enum.f
REQUIRE tabcontrol ~ygrek/~yz/lib/wincc.f
 
VOCABULARY AC
ALSO AC DEFINITIONS
REQUIRE STR@          ~ac/lib/str2.f
PREVIOUS 
FORTH DEFINITIONS

:NONAME 0e FVALUE ; ENUM floats
:NONAME 0 VALUE ; ENUM values


PRINT-FIX
FDOUBLE

model1.f
model2.f


: >float ( ctl -- F: x ) 
  >R 
  R@ -text# ALLOCATE THROW  
  DUP R@ -text@
  DUP 
  R> -text# >FLOAT 0= IF 0e THEN
  FREE THROW
;
\ учитываем что без символа "e" вещественное число не воспринимается
\ : >fnum >FNUM OVER + DUP [CHAR] e SWAP C! 1+ 0 SWAP C! ;
: >fnum >FNUM OVER + 0 SWAP C! ;

: info { \ str }
   [ ALSO AC ]
   ALSO AC
   " Дальность {xmax >FNUM} м {CRLF}" TO str
   " Высота {ymax >FNUM} м {CRLF}" str S+ 
   " Угол падения {TEnd >FNUM} рад {CRLF}" str S+
   " Скорость падения {vEnd >FNUM} м/сек {CRLF}" str S+
   " Время {tEnd >FNUM} сек {CRLF}" str S+
   str STR@ ShowMessage  
   str STRFREE
   PREVIOUS
   [ PREVIOUS ]
;

interface1.f
interface2.f
grid.f


: main 
  WINDOWS...
  " Times New Roman Cyr" 12 create-font default-font
  0 dialog-window TO winmain
  " Мат моделирование N6. yGREK heretix. КА-21" winmain -text!

  make-grids
  GRID make-tabs | GRID; winmain -grid!
  winmain wincenter
  winmain winshow

  Model1::fill-edit
  Model2::fill-edit

  ...WINDOWS
  ." ...WINDOWS"
  BYE
;

\ main
\ EOF
' main TO <MAIN>
S" laba6.exe" SAVE
BYE


