( ќбработка аппаратных исключений [деление на ноль, обращение
  по недопустимым адресам, и т.д.] - путем перевода в THROW.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Cент€брь 1999
)


USER EXC-HANDLER  \ аппаратные исключени€ (преобразуемые в программные)
VECT <EXC-DUMP>

USER ExceptionRecord

: (EXC) ( DispatcherContext ContextRecord EstablisherFrame ExceptionRecord -- flag )
  (ENTER) \ фрейм дл€ стека данных
  0 FS@ @ \ адрес нашего фрейма обработки исключений под новым виндовым фреймом
  DUP 0 FS! \ восстанавливаем его чтобы продолжать ловить exceptions в будущем
  CELL+ CELL+ @ TlsIndex! \ указатель на USER-данные сбойнувшего потока

\  2DROP 2DROP
\  0 (LEAVE)               \ это если нужно передать обработку выше

  DUP <EXC-DUMP>
  @ THROW                 \ превращаем исключение в родное фортовое :)
;

: DROP-EXC-HANDLER
  R> 0 FS! RDROP RDROP
\  EXC-HANDLER 0!
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

: HALT ( ERRNUM -> ) \ выход с кодом ошибки
  ExitProcess
;
