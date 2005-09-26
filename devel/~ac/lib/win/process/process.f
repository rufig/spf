( ~ac: изменени€ 25.03.2004
   ƒобавлено функциональное слово StartAppWaitDir
   S" app_path.exe cmdline" S" curr_dir" wait StartAppWaitDir THROW ." res=" .
   “.е. в отличие от StartApp возвращает не сишный bool, а ior
   плюс код завершени€.  од завершени€ валидный только в случае
   ненулевого заданного времени ожидани€ wait.
   StartApp и StartAppWait теперь определены через это слово.

   ~ac: изменени€ 30.03.2004
   * ≈сли запуск неудачен, то попыток получени€ кода возврата не производитс€,
   т.к. это портит код в GetLastError и StartAppWaitDir возвращает 6.
   
   P.S. ≈сли процесс еще не завершилс€, то возвращаемый код 259.
   ≈сли ему указан неверный текущий каталог, то 267.
)

WINAPI: CreateProcessA KERNEL32.DLL
WINAPI: CreateProcessAsUserA ADVAPI32.DLL
WINAPI: WaitForSingleObject KERNEL32.DLL
WINAPI: GetExitCodeProcess KERNEL32.DLL

0
4 -- cb
4 -- lpReserved
4 -- lpDesktop
4 -- lpTitle
4 -- dwX
4 -- dwY
4 -- dwXSize
4 -- dwYSize
4 -- dwXCountChars
4 -- dwYCountChars
4 -- dwFillAttribute
4 -- dwFlags
2 -- wShowWindow
2 -- cbReserved2
4 -- lpReserved2
4 -- hStdInput
4 -- hStdOutput
4 -- hStdError
CONSTANT /STARTUPINFO

HEX 00000100 CONSTANT STARTF_USESTDHANDLES DECIMAL
0 VALUE SW_HIDE
1 CONSTANT STARTF_USESHOWWINDOW

USER SA_WAIT

: StartAppWaitDir ( S" application.exe" S" curr_directory" wait -- exit_code ior )
  SA_WAIT !
  DUP IF OVER + 0 SWAP C! ELSE 2DROP 0 THEN >R
  OVER + 0 SWAP C! >R    2R> SWAP 2>R
  5 CELLS ALLOCATE ?DUP IF R> DROP NIP EXIT THEN
  DUP \ process information
  DUP 4 CELLS ERASE
  /STARTUPINFO ALLOCATE ?DUP IF R> DROP NIP NIP EXIT THEN 
  DUP ROT ROT \ startup info
  DUP /STARTUPINFO ERASE
  /STARTUPINFO OVER cb !
  STARTF_USESHOWWINDOW OVER dwFlags !
  SW_HIDE OVER wShowWindow !

  R>    \ current dir
  0    \ environment
  0    \ creation flags
  FALSE \ inherit handles
  0 0  \ process & thread security
  R>   \ command line
  0    \ application
  CreateProcessA DUP
  ROT >R ROT >R
  IF SA_WAIT @ R@ @ WaitForSingleObject DROP
     R@ @  0 >R RP@ OVER GetExitCodeProcess DROP R> SWAP CLOSE-FILE DROP 
     R@ CELL+ @ CLOSE-FILE DROP
  ELSE 0 THEN
  R> FREE DROP R> FREE DROP
  SWAP ERR
;
: StartApp ( S" application.exe" -- flag )
  S" " 0 StartAppWaitDir NIP 0= 1 AND
;

(
  OVER + 0 SWAP C! >R
  5 CELLS ALLOCATE ?DUP IF R> DROP NIP EXIT THEN
  DUP \ process information
  DUP 4 CELLS ERASE
  /STARTUPINFO ALLOCATE ?DUP IF R> DROP NIP NIP EXIT THEN 
  DUP ROT ROT \ startup info
  DUP /STARTUPINFO ERASE
  /STARTUPINFO OVER cb !
  STARTF_USESHOWWINDOW OVER dwFlags !
  SW_HIDE OVER wShowWindow !

  0    \ current dir
  0    \ environment
  0    \ creation flags
  FALSE \ inherit handles
  0 0  \ process & thread security
  R>   \ command line
  0    \ application
  CreateProcessA DUP
  ROT >R ROT >R
  DROP
  R@ @ CLOSE-FILE DROP R@ CELL+ @ CLOSE-FILE DROP
  R> FREE DROP R> FREE DROP
;
)
: StartAppWait ( S" application.exe" -- flag )
  S" " -1 StartAppWaitDir NIP 0= 1 AND
;
(
  OVER + 0 SWAP C! >R
  5 CELLS ALLOCATE ?DUP IF R> DROP NIP EXIT THEN
  DUP \ process information
  DUP 4 CELLS ERASE
  /STARTUPINFO ALLOCATE ?DUP IF R> DROP NIP NIP EXIT THEN 
  DUP ROT ROT \ startup info
  DUP /STARTUPINFO ERASE
  /STARTUPINFO OVER cb !
  STARTF_USESHOWWINDOW OVER dwFlags !
  SW_HIDE OVER wShowWindow !

  0    \ current dir
  0    \ environment
  0    \ creation flags
  FALSE \ inherit handles
  0 0  \ process & thread security
  R>   \ command line
  0    \ application
  CreateProcessA DUP
  ROT >R ROT >R
  IF -1 R@ @ WaitForSingleObject DROP THEN
  R@ @ CLOSE-FILE DROP R@ CELL+ @ CLOSE-FILE DROP
  R> FREE DROP R> FREE DROP
;
)
: Visible
  1 TO SW_HIDE
;

(
S" \temp\clamav3\clamscan.exe" S" G:\temp\clamav3z" 3000 StartAppWaitDir . .
S" G:\temp\clamav3\clamscan.exe" S" G:\temp\clamav3" 3000 StartAppWaitDir . .
S" G:\temp\clamav3\clamscan.exe" StartApp . CR
S" G:\temp\clamav3\clamscan.exe H:\eserv2\check\vir\ibp@ibp.krasnoyarsk.su!POP3!1916726!149" S" G:\temp\clamav3" -1 StartAppWaitDir . . CR
S" G:\temp\clamav3\clamscanz.exe" StartApp . CR
S" G:\temp\clamav3\clamscan.exe" StartAppWait . CR
)
