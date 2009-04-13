\ Переопределение части функций из sockets.f для прозрачной работы по SSL

REQUIRE {             ~ac/lib/locals.f
REQUIRE CreateSocket  ~ac/lib/win/winsock/sockets.f
REQUIRE read          ~ac/lib/win/winsock/sock2.f
REQUIRE SslInit       ~ac/lib/win/winsock/ssl.f

WARNING @ WARNING 0!
USER uSSL_OBJECT
USER uSSL_SOCKET
USER uSSL_CONTEXT
VECT dFailedSsl
VECT dSslWaitInit ' NOOP TO dSslWaitInit

: FailedSsl ( ior -- namea nameu cert )
  DUP 6 <>
  IF uSSL_SOCKET @ CloseSocket DROP
     uSSL_CONTEXT @ SSL_CTX_free 2DROP
  THEN
  uSSL_SOCKET 0! uSSL_CONTEXT 0!
  DROP S" " 0
; ' FailedSsl TO dFailedSsl

: SslServerSocket { addr u verify s -- namea nameu cert }
\ addr u - имя файла с сертификатом и закрытым ключем в PEM-формате
  SslInit
  5000 SSL-MUT @ WAIT THROW DROP
  s uSSL_SOCKET !
  dSslWaitInit
  addr u X509_FILETYPE_PEM 
  SslNewServerContext uSSL_CONTEXT !
  addr u verify ( SSL_VERIFY_PEER) uSSL_CONTEXT @ SslSetVerify
  s uSSL_CONTEXT @ ['] SslObjAccept CATCH \ 0=OK, 5=не тот сертификат, 1= нет сертификата
  SSL-MUT @ RELEASE-MUTEX DROP
  ?DUP IF NIP NIP dFailedSsl EXIT THEN
  DUP uSSL_OBJECT !
  verify 0= IF DROP S" " 0 EXIT THEN
  ?DUP IF SslGetVerifyResults THROW ROT \ ." verify:" . ." (" TYPE ." )" .
       ELSE S" " 0 THEN
;
: SslClientSocket { addr u verify s -- namea nameu cert }
\ addr u - имя файла с сертификатом и закрытым ключем в PEM-формате
  SslInit
  s uSSL_SOCKET !
  dSslWaitInit
  addr u X509_FILETYPE_PEM 
  SslNewClientContext uSSL_CONTEXT !
  addr u verify ( SSL_VERIFY_PEER) uSSL_CONTEXT @ SslSetVerify
  s uSSL_CONTEXT @ ['] SslObjConnect CATCH \ 0=OK, 5=не тот сертификат, 1= нет сертификата
  ?DUP IF NIP NIP dFailedSsl EXIT THEN
  DUP uSSL_OBJECT !
  verify 0= IF DROP S" " 0 EXIT THEN
  ?DUP IF SslGetVerifyResults THROW ROT \ ." verify:" . ." (" TYPE ." )" .
       ELSE S" " 0 THEN
;
: WriteSocket ( addr u s -- ior )
   DUP 0= IF DROP 2DROP 12005 EXIT THEN
  OVER 0= IF DROP 2DROP 0 EXIT THEN
  DUP uSSL_SOCKET @ =
  IF DROP uSSL_OBJECT @ SslWrite DUP 0 > IF DROP 0 EXIT THEN
     uSSL_OBJECT @ SSL_get_error NIP NIP
     DUP 6 = ( SSL_ERROR_ZERO_RETURN) IF DROP -1002 THEN
     DUP 5 = IF DROP WSAGetLastError ." ssl_w5_err=" DUP . DUP 0= IF DROP -1002 THEN THEN
  ELSE WriteSocket THEN
;
: WriteSocketLine ( addr u s -- ior )
  DUP >R WriteSocket ?DUP IF R> DROP EXIT THEN
  LT LTL @ R> WriteSocket
;
: WriteSocketCRLF ( s -- ior )
  HERE 0 ROT WriteSocketLine
;
: ReadSocket ( addr u s -- rlen ior )
  DUP uSSL_SOCKET @ =
  IF DROP uSSL_OBJECT @ SslRead DUP 0 > IF 0 EXIT THEN
     TIMEOUT @ uSslSinceSocketRead @ < IF 10060 EXIT THEN
     uSSL_OBJECT @ SSL_get_error NIP NIP 0 SWAP
     DUP 6 = ( SSL_ERROR_ZERO_RETURN) IF DROP -1002 THEN
     DUP 5 = IF DROP WSAGetLastError ." ssl_r5_err=" DUP . DUP 0= IF DROP -1002 THEN THEN
  ELSE ReadSocket THEN
;
: CloseSocket ( s -- ior )
  DUP uSSL_SOCKET @ =
  IF uSSL_OBJECT @ SSL_shutdown 2DROP
     uSSL_OBJECT @ SSL_free 2DROP 
     uSSL_CONTEXT @ SSL_CTX_free 2DROP
     CloseSocket DUP IF ." ssl_close_socket_err=" DUP . THEN
     uSSL_SOCKET 0!
  ELSE CloseSocket THEN
;
: read ( addr len socket -- )
  \ прочесть ровно len байт из сокета socket и записать в addr
  { _addr _len _sock \ _p }
  _sock uSSL_SOCKET @ =
  IF
    0 -> _p
    BEGIN
      _len 0 >
    WHILE
      _addr _p +  _len _sock
      ReadSocket THROW
      DUP 0= IF DROP -1002 THROW THEN ( если принято 0, то обрыв соединения )
      DUP _p + -> _p
      _len SWAP - -> _len
    REPEAT
  ELSE _addr _len _sock read THEN
;
: upTo0 ( -- )
  >IN 0!
  BEGIN
    TIB >IN @ + DUP 1 SOURCE-ID read
    >IN 1+!
    C@ 0=
  UNTIL
;
: READ-SOCK-EXACT ( a u socket -- ior )
  >R BEGIN DUP WHILE
    2DUP R@ ReadSocket ?DUP IF NIP NIP NIP RDROP EXIT THEN ( a1 u1 u2 )
    ( в случае, если принято 0, ReadSocket возвращает ior -1002,
      в отличии от READ-FILE, который возвращет ior 0 и длину 0 при
      достижении конца файла или ior 109 при достижении конца pipe
    )
    TUCK - -ROT + SWAP
  REPEAT ( a1 0 )
  NIP RDROP
;
: ReadSocketExact ( a u socket -- ior ) \ см. также "read" в sock2.f
  READ-SOCK-EXACT
;

WARNING !
