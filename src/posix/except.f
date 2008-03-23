\ $Id$
( Обработка аппаратных исключений [деление на ноль, обращение
  по недопустимым адресам, и т.д.] - путем перевода в THROW.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Cентябрь 1999
)

   H-STDIN  VALUE  H-STDIN    \ хэндл файла - стандартного ввода
   H-STDOUT VALUE  H-STDOUT   \ хэндл файла - стандартного вывода
   H-STDERR VALUE  H-STDERR   \ хэндл файла - стандартного вывода ошибок
          0 VALUE  H-STDLOG

: AT-THREAD-FINISHING ( -- ) ... ;
: AT-PROCESS-FINISHING ( -- ) ... FREE-THREAD-MEMORY ;

: HALT ( ERRNUM -> ) \ выход с кодом ошибки
  AT-THREAD-FINISHING
  AT-PROCESS-FINISHING
  1 <( )) exit
;
