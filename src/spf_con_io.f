( Консольный ввод-вывод.
  ОС-независимые слова [относительно...].
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

32 VALUE BL ( -- char ) \ 94
\ char - значение символа "пробел".


: SPACE ( -- ) \ 94
\ Вывести на экран один пробел.
  BL EMIT
;

: SPACES ( n -- ) \ 94
\ Если n>0 - вывести на дисплей n пробелов.
  DUP 1 < IF DROP EXIT THEN
  BEGIN
    DUP
  WHILE
    BL EMIT 1-
  REPEAT DROP
;

TARGET-POSIX [IF]
\ TODO
[ELSE]
  S" src/win/spf_win_con_io.f" INCLUDED
[THEN]
