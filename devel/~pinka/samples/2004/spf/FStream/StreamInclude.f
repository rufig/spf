\ 20.Jan.2004     ~ruv

( Расширение SPF
    Быстрый ввод/вывод  за счет буферизации.

  Переопределяет все необходимые слова работы с файлами
  [используя библиотеку stream_io_impl.f],
  первоначальный лексикон доступен через словарь OLD-IO

  Ограничения:
    - программа не должна полагать, что SOURCE-ID == WinKernel Handle
    - к значению, возвращаемому SOURCE-ID
      можно применять только новые файловые функции SPF
)
\ Заменяет значение вектора (INCLUDED)
\ Детали в словаре FStreamSupport

VOCABULARY OLD-IO   ALSO OLD-IO   FORTH-WORDLIST @  CONTEXT @ ! PREVIOUS

REQUIRE FStreamSupport  ~pinka\samples\2004\spf\FStream\stream_io_impl.f

WARNING @ WARNING 0!

: RECEIVE-WITH  ( i*x source xt -- j*x ior )
  ['] READ-LINE SWAP RECEIVE-WITH-XT
;
: INCLUDE-FILE ( i*x fileid -- j*x ) \ 94 FILE
  BLK 0!  DUP >R  
  ['] TranslateFlow RECEIVE-WITH
  R> CLOSE-FILE THROW
  THROW
;
: (INCLUDED2) ( i*x a u -- j*x )
  R/O OPEN-FILE-SHARED THROW
  INCLUDE-FILE
;
' (INCLUDED2) TO (INCLUDED)

WARNING !
