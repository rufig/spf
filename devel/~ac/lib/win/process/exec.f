\ Простейшая работа с консольными утилитами.
\ SEXECL - запуск программы с заданной ком.строкой и stdin'ом,
\ получение её stdout'а в виде строки.
\ SEXEC - аналогично, но для потенциально бесконечных процессов,
\ поэтому результат не возвращает, а берет xt, который напускается
\ на каждую строку результата.

( примеры использования см. в конце файла )

REQUIRE ChildAppErr ~ac/lib/win/process/child_app.f
REQUIRE PipeLine    ~ac/lib/win/process/pipeline.f
REQUIRE STR@        ~ac/lib/str5.f

: SEXEC-READL { l s -- ? }
  BEGIN
    l PipeReadLine \ DUP IF ." =>" 2DUP TYPE ." <=" CR ELSE CR THEN
    s STR+ CRLF s STR+
  AGAIN
;

: SEXECL { ina inu cmda cmdu \ l s e -- outa outu erra erru }
  CreateStdPipes
  cmda cmdu ChildAppErr THROW

  \  -1 OVER WaitForSingleObject DROP CLOSE-FILE THROW
  CLOSE-FILE THROW

  inu IF ina inu StdinWH @ WRITE-FILE THROW THEN
  StdinWH @ CLOSE-FILE THROW

  "" -> s
  StdoutRH @ PipeLine -> l
  l s ['] SEXEC-READL CATCH IF 2DROP THEN
  l FREE THROW
  StdoutRH @ CLOSE-FILE THROW

  "" -> e
  StderrRH @ PipeLine -> l
  l e ['] SEXEC-READL CATCH IF 2DROP THEN
  l FREE THROW
  StderrRH @ CLOSE-FILE THROW

  s STR@  e STR@
;

: SEXEC-READ { l xt -- ? }
  BEGIN
    l PipeReadLine \ DUP IF ." =>" 2DUP TYPE ." <=" CR ELSE CR THEN
    xt EXECUTE
  AGAIN
;
: SEXEC { xt ina inu cmda cmdu \ l -- }
  CreateStdPipes
  cmda cmdu ChildAppErr THROW

  \  -1 OVER WaitForSingleObject DROP CLOSE-FILE THROW
  CLOSE-FILE THROW

  inu IF ina inu StdinWH @ WRITE-FILE THROW THEN
  StdinWH @ CLOSE-FILE THROW

  StdoutRH @ PipeLine -> l
  l xt ['] SEXEC-READ CATCH IF 2DROP THEN
  l FREE THROW
  StdoutRH @ CLOSE-FILE THROW

  StderrRH @ PipeLine -> l
  l xt ['] SEXEC-READ CATCH IF 2DROP THEN
  l FREE THROW
  StderrRH @ CLOSE-FILE THROW
;

\ S" " S" ping.exe www.forth.org.ru"    SEXECL 2DUP . . TYPE CR TYPE CR CR
\ S" " S" cvs diff child_app.f"         SEXECL 2DUP . . TYPE CR TYPE CR CR
\ S" " S" netstat дай ошибку в stderr!" SEXECL 2DUP . . TYPE CR TYPE CR CR
\ " cd pub{CRLF}ls -l{CRLF}quit{CRLF}" STR@ S" ftp.exe -Ad ftp.forth.org.ru"  SEXECL 2DUP . . TYPE CR TYPE CR CR

\ :NONAME ." [" TYPE ." ]" CR ; S" " S" ping.exe -n 15 www.forth.org.ru"  SEXEC
