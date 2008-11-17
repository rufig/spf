( Консольный ввод-вывод.
  ОС-независимые слова [относительно...].
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

TARGET-POSIX [IF]
\ TODO KEY EKEY
S" src/posix/con_io.f" INCLUDED
[ELSE]
S" src/win/spf_win_con_io.f" INCLUDED
[THEN]

: ENDLOG
\ Закончить лог.
    H-STDLOG
    IF
      H-STDLOG CLOSE-FILE
      0 TO H-STDLOG 
      THROW 
    THEN
; 

: STARTLOG ( -- )
\ Создать файл spf.log. Начать лог ввода/вывода.
\ Если лог уже открыт, очистить и начать заново
  ENDLOG
  S" spf.log" W/O     ( S: addr count attr -- )            
  CREATE-FILE-SHARED  ( S: addr count attr -- handle ior ) 
  THROW                                                    
  TO H-STDLOG                                              
;

: TO-LOG ( addr u -- )
\ копирует входящую строку в лог файл
  H-STDLOG IF H-STDLOG WRITE-FILE 0 THEN 2DROP
;

VECT ACCEPT

: ACCEPT1 ( c-addr +n1 -- +n2 ) \ 94
\ Ввести строку максимальной длины до +n1 символов.
\ Исключительная ситуация возникает, если +n1 0 или больше 32767.
\ Отображать символы по мере ввода.
\ Ввод прерывается, когда получен символ "конец строки".
\ Ничего не добавляется в строку.
\ +n2 - длина строки, записанной по адресу c-addr.
  OVER SWAP
  H-STDIN READ-LINE
  
  DUP 109 = IF DROP -1002 THEN THROW ( ~ruv)
  0= IF -1002 THROW THEN ( ~ac)
  
  TUCK TO-LOG
  EOLN TO-LOG \ Если ввод с user-device записать cr в лог, то есть нажали Enter
;

' ACCEPT1 ' ACCEPT TC-VECT!

: TYPE1 ( c-addr u -- ) \ 94
\ Если u>0 - вывести строку символов, заданную c-addr и u.
\ Программы, использующие управляющие символы, зависят от окружения.
  ANSI><OEM
  2DUP TO-LOG
  H-STDOUT DUP 0 > IF WRITE-FILE THROW ELSE 2DROP DROP THEN
;

' TYPE1 ' TYPE TC-VECT!

: EMIT ( x -- ) \ 94
\ Если x - изображаемый символ, вывести его на дисплей.
\ Программы, использующие управляющие символы, зависят от окружения.
  >R RP@ 1 TYPE
  RDROP
;

: CR ( -- ) \ 94
\ Перевод строки.
  EOLN TYPE
;

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
