REQUIRE /STRING lib/include/string.f 
REQUIRE { ~ac/lib/locals.f
REQUIRE AF_INET ~nn/lib/sock2.f
REQUIRE GLOBAL ~nn/lib/globalloc.f 
\ REQUIRE DEBUG? ~nn/lib/qdebug.f
REQUIRE CreateServerSocket ~nn/lib/web/srvsock.f
REQUIRE EVAL-SUBST ~nn/lib/subst1.f


4000 CONSTANT /QUERY_BUFF

USER WEB-INFO
0
1 CELLS -- WEB-PORT
1 CELLS -- WEB-ROOT-DIR
1 CELLS -- WEB-SS   \ Server Socket
1 CELLS -- WEB-WD   \ Word list
CONSTANT /WEB-INFO

: ROOT-DIR WEB-INFO @ WEB-ROOT-DIR @ ASCIIZ> ;


USER HTTP-SOCKET
USER FILENAME

: HTTP-WRITE ( a u -- )  EVAL-SUBST HTTP-SOCKET @ WriteSocket THROW ;
: NOT_FOUND  S" HTTP/1.0 404 File not found%CRLF%Content-Type: text/html%CRLF%%CRLF%<html><body><h2>File not found</h2></body></html>" HTTP-WRITE ;
: SEND_FILE ( filename -- )
  FILENAME ! ALSO FORTH
  S" HTTP/1.0 200 OK%CRLF%%CRLF%%FILENAME @ ASCIIZ> FILE EVAL-SUBST%" HTTP-WRITE
;
VOCABULARY HTTP
GET-CURRENT ALSO HTTP DEFINITIONS
: GET { \ str -- }
  1024 ALLOCATE THROW TO str str 0!
  ROOT-DIR str +ZPLACE   BL PARSE 2DUP str +ZPLACE
  + 1- C@ [CHAR] / = IF S" index.html" str +ZPLACE THEN
  POSTPONE \
  str ASCIIZ> R/O OPEN-FILE 
  IF DROP NOT_FOUND ELSE CLOSE-FILE THROW str SEND_FILE THEN
  str FREE DROP
;
PREVIOUS SET-CURRENT

: PROCESS_REQUEST ( addr u -- )
    ALSO HTTP EVALUATE PREVIOUS
;
: (WS-THREAD) { s \ mem offs -- }
\  || s mem offs || (( s ))
  SP@ S0 !
  s HTTP-SOCKET !
  /QUERY_BUFF ALLOCATE THROW TO mem  0 TO offs
  BEGIN
    mem offs + /QUERY_BUFF offs - s ReadSocket THROW 
    offs + TO offs
    mem offs + 4 - 4 2CRLF COMPARE 0=
  UNTIL
  mem offs 2CRLF DROP 1 SEARCH
  IF DROP mem SWAP OVER - PROCESS_REQUEST
  ELSE 2DROP THEN
  mem FREE DROP
;

:NONAME ( info -- )
  WEB-INFO !
  WEB-INFO @ WEB-SS @ ['] (WS-THREAD) CATCH  ?DUP IF ." WS-THREAD ERROR "  . DROP THEN
  WEB-INFO @ WEB-SS @ CloseSocket DROP
  WEB-INFO @ GLOBAL FREE LOCAL DROP
;
TASK: WS-THREAD

: CP-WEB-INFO ( s -- a )
    /WEB-INFO GLOBAL ALLOCATE LOCAL THROW >R
    WEB-INFO @ R@ /WEB-INFO MOVE
    R@ WEB-SS !
    R>
;
: (WS-SERVER) { port \ ss -- }
  port CreateServerSocket TO ss
  BEGIN
    ss AcceptSocket 0=
  WHILE
    CP-WEB-INFO
    WS-THREAD START CloseHandle DROP
  REPEAT DROP
  ss CloseSocket THROW
;


:NONAME ( info -- ) 
    WEB-INFO !
    WEB-INFO @ WEB-PORT @ ['] (WS-SERVER) CATCH 
    ?DUP IF ." WS-THREAD ERROR "  . DROP THEN 
; TASK: WS-SERVER

: WEB-SERVER ( port S"dir" -- task_id )
  SocketsStartup THROW
  /WEB-INFO GLOBAL ALLOCATE LOCAL THROW >R 
  R@ WEB-ROOT-DIR S!
  R@ WEB-PORT !
  R> WS-SERVER START
;

\ 82 S" ." WEB-SERVER .( TYPE ") . .( STOP" TO STOP THE SERVER) CR