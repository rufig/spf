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

: FailedSsl ( ior -- namea nameu cert )
  uSSL_SOCKET @ CloseSocket DROP uSSL_SOCKET 0!
  DROP S" " 0
; ' FailedSsl TO dFailedSsl

: SslServerSocket { addr u verify s -- namea nameu cert }
\ addr u - имя файла с сертификатом и закрытым ключем в PEM-формате
  SslInit
  -1 SSL-MUT @ WAIT THROW DROP
  s uSSL_SOCKET !
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
  DUP uSSL_SOCKET @ =
  IF DROP uSSL_OBJECT @ SslWrite DUP 0 > IF DROP 0 EXIT THEN
     uSSL_OBJECT @ SSL_get_error NIP NIP
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
     uSSL_OBJECT @ SSL_get_error NIP NIP 0 SWAP
  ELSE ReadSocket THEN
;
: CloseSocket ( s -- ior )
  DUP uSSL_SOCKET @ =
  IF uSSL_OBJECT @ SSL_free 2DROP 
     uSSL_CONTEXT @ SSL_CTX_free 2DROP
  THEN
  CloseSocket
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
WARNING !

