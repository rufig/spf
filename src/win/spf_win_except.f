\ $Id$

( ќбработка аппаратных исключений [деление на ноль, обращение
  по недопустимым адресам, и т.д.] - путем перевода в THROW.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Cент€брь 1999
)

   H-STDIN  VALUE  H-STDIN    \ хэндл файла - стандартного ввода
   H-STDOUT VALUE  H-STDOUT   \ хэндл файла - стандартного вывода
   H-STDERR VALUE  H-STDERR   \ хэндл файла - стандартного вывода ошибок
          0 VALUE  H-STDLOG


USER EXC-HANDLER  \ аппаратные исключени€ (преобразуемые в программные)
VECT <EXC-DUMP>

: (EXC) ( DispatcherContext ContextRecord EstablisherFrame ExceptionRecord -- flag )
  (ENTER) \ фрейм дл€ стека данных
  0 FS@ @ \ адрес нашего фрейма обработки исключений под новым виндовым фреймом
  DUP 0 FS! \ восстанавливаем его чтобы продолжать ловить exceptions в будущем
  CELL+ CELL+ @ TlsIndex! \ указатель на USER-данные сбойнувшего потока

\  2DROP 2DROP
\  0 (LEAVE)               \ это если нужно передать обработку выше

  DUP <EXC-DUMP>

  HANDLER @ 0=
  IF \ исключение в потоке, без CATCH, выдаем отчет и завершаем (~day)
     DESTROY-HEAP
     -1 ExitThread
  THEN

  FINIT \ если float исключение, восстанавливаем

  @ THROW  \ превращаем исключение в родное фортовое :)
  R> DROP   \ если все же добрались, то грамотно выходим из callback
;

: DROP-EXC-HANDLER
  R> 0 FS! RDROP RDROP
;
: SET-EXC-HANDLER
  R> R>
  TlsIndex@ >R
  ['] (EXC) >R
  0 FS@ >R
  RP@ 0 FS!
  RP@ EXC-HANDLER !
  ['] DROP-EXC-HANDLER >R \ самоубираемый фрейм ловли аппаратн.исключени€
  >R >R
;
' SET-EXC-HANDLER (TO) <SET-EXC-HANDLER>

: AT-THREAD-FINISHING ( -- ) ... ;
: AT-PROCESS-FINISHING ( -- ) ... DESTROY-HEAP ;

: HALT ( ERRNUM -> ) \ выход с кодом ошибки
  AT-THREAD-FINISHING
  AT-PROCESS-FINISHING
  ExitProcess
;
