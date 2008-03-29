\ $ Id$
\ 
\ Консольный ввод-вывод.
\ Ю. Жиловец, 9.05.2007

   0 VALUE  H-STDIN    \ хэндл файла - стандартного ввода
   1 VALUE  H-STDOUT   \ хэндл файла - стандартного вывода
   2 VALUE  H-STDERR   \ хэндл файла - стандартного вывода ошибок
   0 VALUE  H-STDLOG

: TYPE1 ( c-addr u -- ) \ 94
\ Если u>0 - вывести строку символов, заданную c-addr и u.
\ Программы, использующие управляющие символы, зависят от окружения.
\  ANSI><OEM
  2DUP TO-LOG
  H-STDOUT DUP 0 > IF WRITE-FILE THROW ELSE 2DROP DROP THEN
;

' TYPE1 ' TYPE TC-VECT!

VECT KEY
' FALSE ' KEY   TC-VECT!

VECT KEY?
' FALSE ' KEY?  TC-VECT!
