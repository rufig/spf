REQUIRE {                     ~ac/lib/locals.f
REQUIRE StartApp              ~ac/lib/win/process/process.f
\ REQUIRE DUP-HANDLE-INHERITED  ~ac/lib/win/process/pipes.f

USER StdinRH
USER StdinWH
USER StdoutRH
USER StdoutWH
USER StderrRH
USER StderrWH

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