( ќбработка аппаратных исключений [деление на ноль, обращение
  по недопустимым адресам, и т.д.] - путем перевода в THROW.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Cент€брь 1999
)


USER EXC-HANDLER  \ аппаратные исключени€ (преобразуемые в программные)
VECT <EXC-DUMP>

: (EXC) ( exc-info -- )
  0 FS@ @                 \ Windows установила новый обработчик
                          \ но сохранила в нем адрес старого (нашего)
  DUP 0 FS!               \ восстановление этого же обработчика снова
  DESTROY-HEAP            \ удалить хип, созданный дл€ этого обработчика
  CELL+ CELL+ CELL+ @ TlsIndex! \ указатель на USER-данные сбойнувшего потока
                          \ будем импользовать его хип и USER-data
  DUP <EXC-DUMP>          \ пользовательский обработчик (дамп по умолчанию)
  EXC-HANDLER 0!
  @ THROW                 \ превращаем исключение в родное фортовое :)
;
' (EXC) WNDPROC: EXC

: DROP-EXC-HANDLER
  RDROP RDROP R> 0 FS! RDROP RDROP RDROP
;
: SET-EXC-HANDLER
  R>
  0 >R -1 >R TlsIndex@ >R 0 FS@ >R ['] EXC >R 0 FS@ >R
  RP@ 0 FS! RP@ EXC-HANDLER !
  ['] DROP-EXC-HANDLER >R  \ самоубираемый фрейм ловли аппаратн.исключени€
  >R
;
' SET-EXC-HANDLER (TO) <SET-EXC-HANDLER>

: HALT ( ERRNUM -> ) \ выход с кодом ошибки
  ExitProcess
;
