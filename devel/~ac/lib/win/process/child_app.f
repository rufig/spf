REQUIRE {                     ~ac/lib/locals.f
REQUIRE StartApp              ~ac/lib/win/process/process.f
REQUIRE DUP-HANDLE-INHERITED  ~ac/lib/win/process/pipes.f

USER StdinRH
USER StdinWH
USER StdoutRH
USER StdoutWH
USER StderrRH
USER StderrWH

: CreateStdPipes ( -- i o e )
\ Создать пайпы для передачи дочернему процессу в качестве stdin/out/err
\ и вернуть их хэндлы.
\ Хэндлы родительских концов труб остаются в переменных:
\ StdinWH (туда пишется то, что попадет дочке в stdin),
\ StdoutRH (оттуда читать ответ дочки)
\ StderrRH (оттуда читать ошибки дочки)

  0 0 StdinWH StdinRH CreatePipe ERR THROW
  0 0 StdoutWH StdoutRH CreatePipe ERR THROW
  0 0 StderrWH StderrRH CreatePipe ERR THROW
  StdinRH @ DUP-HANDLE-INHERITED THROW \ StdInput !
  StdinRH @ CLOSE-FILE THROW
  StdoutWH @ DUP-HANDLE-INHERITED THROW \ StdOutput !
  StdoutWH @ CLOSE-FILE THROW
  StderrWH @ DUP-HANDLE-INHERITED THROW \ StdErr !
  StderrWH @ CLOSE-FILE THROW
;

: ChildAppErr ( input-handle output-handle err-handle a u -- p-handle ior )
  { i o e a u \ pi si res }
  5 CELLS      ALLOCATE THROW -> pi   pi 5 CELLS ERASE
  /STARTUPINFO ALLOCATE THROW -> si   si /STARTUPINFO ERASE
  /STARTUPINFO si cb !
  SW_HIDE si wShowWindow !
  STARTF_USESTDHANDLES STARTF_USESHOWWINDOW OR si dwFlags !
  i ( DUP-HANDLE-INHERITED THROW) si hStdInput !
  o ( DUP-HANDLE-INHERITED THROW) si hStdOutput !
  e ( DUP-HANDLE-INHERITED THROW) si hStdError !
  pi
  si
  0 \ cur dir
  0 \ envir
  0    \ creation flags
  TRUE \ inherit handles
  0 0  \ process & thread security
  a    \ command line
  0    \ application
  CreateProcessA ERR -> res
  pi CELL+ @ CLOSE-FILE DROP \ thread handle close
  pi @ \ process handle
 \ pi CELL+ CELL+ @ \ process id
  pi FREE DROP
  i CLOSE-FILE THROW
  o CLOSE-FILE THROW
  res
;
: ChildApp ( input-handle output-handle a u -- p-handle ior )
  2>R DUP 2R> ChildAppErr
;


\EOF
~ac/lib/str5.f

: TEST
  CreateStdPipes S" F:\spf4\spf4.exe" ChildAppErr THROW
  CLOSE-FILE DROP 

  StdoutRH @ PipeLine >R

  S" WORDS" StdinWH @ WRITE-FILE THROW
  CRLF StdinWH @ WRITE-FILE THROW

\ вторая команда может не прочитаться в spf, т.к. READ-LINE заточен на
\ чтение файлов, а не пайпов:

  S" 5 5 + ." StdinWH @ WRITE-FILE THROW
  CRLF StdinWH @ WRITE-FILE THROW

  StdinWH @ CLOSE-FILE THROW

  BEGIN
    R@ PipeReadLine ." =>" TYPE ." <=" CR
  AGAIN

  RDROP
  StdoutRH @  CLOSE-FILE THROW
;
' TEST CATCH .

(
REQUIRE fsockopen ~ac/lib/win/winsock/ws2/psocket.f
: TEST { \ s }
  SocketsStartup THROW
  " localhost" 25 fsockopen fsock
  DUP

  S" c:\spf\spf375.exe" ChildApp THROW
  -1 OVER WaitForSingleObject DROP CLOSE-FILE THROW
;
)