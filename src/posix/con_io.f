\ $ Id$
\ 
\ Консольный ввод-вывод.
\ Ю. Жиловец, 9.05.2007

   0 VALUE  H-STDIN    \ хэндл файла - стандартного ввода
   1 VALUE  H-STDOUT   \ хэндл файла - стандартного вывода
   2 VALUE  H-STDERR   \ хэндл файла - стандартного вывода ошибок
   0 VALUE  H-STDLOG

VECT ANSI><OEM
' NOOP ' ANSI><OEM TC-VECT! \ dummy

VECT KEY
' FALSE ' KEY   TC-VECT!

VECT KEY?
' FALSE ' KEY?  TC-VECT!
