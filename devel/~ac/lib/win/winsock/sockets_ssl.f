\ Переопределение части функций из sockets.f для прозрачной работы по SSL

REQUIRE CreateSocket  ~ac/lib/win/winsock/sockets.f
REQUIRE SslInit       ~ac/lib/win/winsock/ssl.f

WARNING @ WARNING 0!
USER uSSL_OBJECT
USER uSSL_SOCKET
USER uSSL_CONTEXT
VECT dFailedSsl

: FailedSsl ( ior -- namea nameu cert )
  DROP S" " 0
; ' FailedSsl TO dFailedSsl

: SslServerSocket { addr u verify s -- namea nameu cert }
\ addr u - имя файла с сертификатом и закрытым ключем в PEM-формате
  SslInit
  s uSSL_SOCKET !
  addr u X509_FILETYPE_PEM 
  SslNewServerContext uSSL_CONTEXT !
  addr u verify ( SSL_VERIFY_PEER) uSSL_CONTEXT @ SslSetVerify
  s uSSL_CONTEXT @ ['] SslObjAccept CATCH \ 0=OK, 5=не тот сертификат, 1= нет сертификата
  ?DUP IF NIP NIP dFailedSsl uSSL_SOCKET @ CloseSocket DROP uSSL_SOCKET 0! EXIT THEN
  DUP uSSL_OBJECT !
  ?DUP IF SslGetVerifyResults THROW ROT \ ." verify:" . ." (" TYPE ." )" .
       ELSE S" " 0 THEN
;
: SslClientSocket ( addr u s -- )
\ addr u - имя файла с сертификатом и закрытым ключем в PEM-формате
  SslInit
  uSSL_SOCKET !
  X509_FILETYPE_PEM 
  SslNewClientContext uSSL_CONTEXT !
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
  IF uSSL_OBJECT @ SSL_free 2DROP THEN
  CloseSocket
;
WARNING !

