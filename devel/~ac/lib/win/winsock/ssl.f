( openssl брать на openssl.org, gnutls win32 на http://josefsson.org/gnutls4win/ )

REQUIRE {             ~ac/lib/locals.f
REQUIRE CreateSocket  ~ac/lib/win/winsock/sockets.f
REQUIRE FreeLibrary   ~ac/lib/win/dll/load_lib.f
REQUIRE CREATE-MUTEX  lib/win/mutex.f
REQUIRE [DEFINED]     lib/include/tools.f 

VARIABLE SSL_LIB
VARIABLE SSLE_LIB
VARIABLE TLSLIB
VECT dSslWaitIdle :NONAME 20 PAUSE ; TO dSslWaitIdle

USER uSslSinceSocketRead \ Сколько времени прошло с момента запуска чтения.
                         \ SslRead только обнуляет счетчик, а его использование
                         \ предусмотрено в режиме неблокирующих сокетов, когда
                         \ таймауты автоматически не работают.

: LoadLibEx ( addr u -- h )
  DROP LOAD_WITH_ALTERED_SEARCH_PATH 0 ROT LoadLibraryExA
;
: LoadSslLibrary ( -- )
  TLSLIB @ 1 =
  IF
    S" ..\ext\libgnutls-openssl-13.dll" LoadLibEx ?DUP IF SSL_LIB ! EXIT THEN
    S" libgnutls-openssl-13.dll " LoadLibEx ?DUP IF SSL_LIB ! EXIT THEN
  ELSE
    S" ..\ext\libssl32.dll" LoadLibEx ?DUP IF SSL_LIB ! EXIT THEN
    S" .\libssl32.dll" LoadLibEx ?DUP IF SSL_LIB ! EXIT THEN
    S" conf\plugins\ssl\libssl32.dll" LoadLibEx ?DUP IF SSL_LIB ! EXIT THEN
    S" ..\CommonPlugins\plugins\ssl\libssl32.dll" LoadLibEx ?DUP IF SSL_LIB ! EXIT THEN
    S" libssl32.dll" LoadLibEx ?DUP IF SSL_LIB ! EXIT THEN
  THEN
  -2009 THROW
;
: LoadSsleLibrary ( -- )
  TLSLIB @ 1 =
  IF
    S" ..\ext\libgnutls-openssl-13.dll" LoadLibEx ?DUP IF SSL_LIB ! EXIT THEN
    S" libgnutls-openssl-13.dll " LoadLibEx ?DUP IF SSL_LIB ! EXIT THEN
  ELSE
    S" ..\ext\libeay32.dll" LoadLibEx ?DUP IF SSLE_LIB ! EXIT THEN
    S" .\libeay32.dll" LoadLibEx ?DUP IF SSLE_LIB ! EXIT THEN
    S" conf\plugins\ssl\libeay32.dll" LoadLibEx ?DUP IF SSLE_LIB ! EXIT THEN
    S" ..\CommonPlugins\plugins\ssl\libeay32.dll" LoadLibEx ?DUP IF SSLE_LIB ! EXIT THEN
    S" libeay32.dll" LoadLibEx ?DUP IF SSLE_LIB ! EXIT THEN
  THEN
  -2009 THROW
;
VARIABLE SSL-MUT

: CREATE-SSL-MUT
  SSL-MUT @ 0= 
  IF 0 0 0 CreateMutexA SSL-MUT ! THEN
;

VARIABLE SSLAPLINK

: SSLAPI:
  >IN @ CREATE >IN ! 
  HERE SSLAPLINK @ , SSLAPLINK ! ( связь )
  0 , 
  BL WORD ", 0 C,
  DOES> CELL+ DUP @ ?DUP IF NIP API-CALL EXIT THEN
  SSL_LIB @ 0= IF LoadSslLibrary THEN
  DUP CELL+
  [DEFINED] _WINAPI-TRACE [IF] DUP _WINAPI-TRACE [THEN]
  COUNT DROP SSL_LIB @ GetProcAddress DUP ROT ! API-CALL
;
: SSLEAPI:
  >IN @ CREATE >IN ! 
  HERE SSLAPLINK @ , SSLAPLINK ! ( связь )
  0 , 
  BL WORD ", 0 C,
  DOES> CELL+ DUP @ ?DUP IF NIP API-CALL EXIT THEN
  SSLE_LIB @ 0= IF LoadSsleLibrary THEN
  DUP CELL+
  [DEFINED] _WINAPI-TRACE [IF] DUP _WINAPI-TRACE [THEN]
  COUNT DROP SSLE_LIB @ GetProcAddress DUP ROT ! API-CALL
;

SSLAPI: SSL_load_error_strings
SSLAPI: SSL_library_init
SSLAPI: SSL_CTX_new
\ SSLAPI: SSL_CTX_set_options \ #define SSL_CTX_set_options(ctx,op) SSL_CTX_ctrl((ctx),SSL_CTRL_OPTIONS,(op),NULL)
SSLAPI: SSL_CTX_ctrl
SSLAPI: TLSv1_method
SSLAPI: TLSv1_client_method
SSLAPI: TLSv1_server_method
SSLAPI: TLSv1_1_server_method
SSLAPI: SSLv3_method
SSLAPI: SSLv23_method
SSLAPI: SSL_new
SSLAPI: SSL_set_fd
SSLAPI: SSL_connect
SSLAPI: SSL_accept
SSLAPI: SSL_write
SSLAPI: SSL_read
SSLAPI: SSL_shutdown
SSLAPI: SSL_get_error
SSLAPI: SSL_CTX_use_certificate_file
SSLAPI: SSL_CTX_use_certificate_chain_file
SSLAPI: SSL_load_client_CA_file
SSLAPI: SSL_CTX_set_client_CA_list
SSLAPI: SSL_CTX_load_verify_locations
SSLAPI: SSL_CTX_use_RSAPrivateKey_file
SSLAPI: SSL_CTX_set_default_passwd_cb
SSLAPI: SSL_set_accept_state
SSLAPI: SSLv23_server_method
SSLAPI: SSLv23_client_method
SSLAPI: SSLv3_client_method
SSLAPI: SSL_free
SSLAPI: SSL_CTX_free

SSLAPI: SSL_CTX_set_verify
SSLAPI: SSL_set_verify
SSLAPI: SSL_renegotiate
SSLAPI: SSL_do_handshake
SSLAPI: SSL_get_verify_result
SSLAPI: SSL_get_peer_certificate
SSLAPI: SSL_CTX_set_verify_depth
SSLAPI: SSL_ctrl
SSLAPI: SSL_set_session_id_context

SSLAPI: SSL_set_ex_data
SSLAPI: SSL_get_ex_data
SSLAPI: SSL_CTX_callback_ctrl
\ SSLAPI: SSL_CTX_set_tlsext_servername_arg
SSLAPI: SSL_set_SSL_CTX
SSLAPI: SSL_CTX_set_cipher_list
SSLAPI: SSL_CTX_Free

\ SSLAPI: SSL_CTX_sess_accept_renegotiate

\ с 0.9.8j: SNI
\  SSL_set_tlsext_host_name = SSL_ctrl(s,SSL_CTRL_SET_TLSEXT_HOSTNAME,TLSEXT_NAMETYPE_host_name,(char *)name)

SSLAPI: SSL_get_servername \ (const SSL *s, const int type) ;
\ SSLAPI: SSL_get_servername_type \ (const SSL *s) ;

\ на практике компрессию в SSL/TLS никто не использует
\ SSLAPI: SSL_COMP_add_compression_method
\ SSLEAPI: COMP_zlib

SSLEAPI: X509_get_subject_name
SSLEAPI: X509_NAME_oneline
SSLEAPI: X509_verify_cert_error_string
SSLEAPI: SSLeay_version

\ SSLAPI: ERR_error_string       libssl32.dll
\ SSLAPI: SSL_CTX_set_client_cert_cb libssl32.dll

1 CONSTANT X509_FILETYPE_PEM
2 CONSTANT X509_FILETYPE_ASN1
3 CONSTANT X509_FILETYPE_DEFAULT

0 CONSTANT SSL_VERIFY_NONE
1 CONSTANT SSL_VERIFY_PEER
2 CONSTANT SSL_VERIFY_FAIL_IF_NO_PEER_CERT
4 CONSTANT SSL_VERIFY_CLIENT_ONCE

32 CONSTANT SSL_CTRL_OPTIONS
53 CONSTANT SSL_CTRL_SET_TLSEXT_SERVERNAME_CB
55 CONSTANT SSL_CTRL_SET_TLSEXT_HOSTNAME

\ NameType value from RFC 3546
0 CONSTANT TLSEXT_NAMETYPE_host_name 

0x01000000 CONSTANT SSL_OP_NO_SSLv2
0x02000000 CONSTANT SSL_OP_NO_SSLv3
0x04000000 CONSTANT SSL_OP_NO_TLSv1

VARIABLE vSSL_INIT

: SslInit ( -- )
  CREATE-SSL-MUT
  vSSL_INIT @ 0=
  IF
    10000 SSL-MUT @ WAIT THROW DROP
    SSL_load_error_strings DROP
    SSL_library_init vSSL_INIT !
    SSL-MUT @ RELEASE-MUTEX DROP
  THEN
;
USER uSSL_CONTEXT
USER uCertType
USER uSslServer \ сервер получает здесь имя хоста, указанное в tlsext в ClientHello
VECT vSslServer ' NOOP TO vSslServer
VECT vSslSniHostName ' 2DROP TO vSslSniHostName

:NONAME { srv al ssl \ ti sna snu pema ctx -- done }
  \ ." SNI_CB:" ssl . al . srv .
  TlsIndex@ -> ti
  0 ssl SSL_get_ex_data NIP NIP TlsIndex!

  TLSEXT_NAMETYPE_host_name ssl SSL_get_servername NIP NIP
  ?DUP IF ASCIIZ> -> snu -> sna
          ( ." CB SSL host name=") sna snu vSslSniHostName
          sna uSslServer !
          sna snu vSslServer 2DUP sna snu COMPARE IF DROP -> pema
          TLSv1_1_server_method SSL_CTX_new NIP -> ctx
	  S" HIGH:!aNULL:!MD5:!RC4" DROP ctx SSL_CTX_set_cipher_list NIP NIP 1 <> THROW
          uCertType @ pema ctx SSL_CTX_use_certificate_file NIP NIP NIP 1 <> THROW
          uCertType @ pema ctx SSL_CTX_use_certificate_chain_file NIP NIP NIP 1 <> THROW
          uCertType @ pema ctx SSL_CTX_use_RSAPrivateKey_file NIP NIP NIP 1 <> THROW
          ctx ssl SSL_set_SSL_CTX DROP 2DROP
\          uSSL_CONTEXT @ SSL_CTX_Free 2DROP
          ctx uSSL_CONTEXT !
          ELSE 2DROP THEN
       THEN
  ti TlsIndex!
  srv al ssl
  0 \ SSL_TLSEXT_ERR_OK

; 12 CALLBACK: SSL_SNI_CALLBACK

: SslNewServerContext { pema pemu type \ c -- context }
  SSLv23_server_method SSL_CTX_new DUP 0= THROW NIP
\  TLSv1_1_server_method SSL_CTX_new DUP 0= THROW NIP
\ http://www.openssl.org/docs/ssl/SSL_CTX_new.html#
  -> c
  type uCertType !
  c uSSL_CONTEXT !

\  SSL_OP_NO_SSLv2 c SSL_CTX_set_options NIP NIP DROP

  0 SSL_OP_NO_SSLv2 SSL_OP_NO_SSLv3 OR  SSL_CTRL_OPTIONS c SSL_CTX_ctrl DROP 2DROP 2DROP
  S" HIGH:!aNULL:!MD5:!RC4" DROP c SSL_CTX_set_cipher_list NIP NIP DROP

\ сертификаты и ключи, используемые в соединении
  pemu
  IF
    type pema c SSL_CTX_use_certificate_file NIP NIP NIP 1 <> THROW
    type pema c SSL_CTX_use_certificate_chain_file NIP NIP NIP 1 <> THROW
    type pema c SSL_CTX_use_RSAPrivateKey_file NIP NIP NIP 1 <> THROW
  THEN

  ['] SSL_SNI_CALLBACK SSL_CTRL_SET_TLSEXT_SERVERNAME_CB c SSL_CTX_callback_ctrl 2DROP 2DROP
\  TlsIndex@ c SSL_CTX_set_tlsext_servername_arg DROP 2DROP

  c
;
: SslNewClientContext { pema pemu type \ c -- context }
\  SSLv23_client_method 
  TLSv1_client_method
  SSL_CTX_new DUP 0= THROW NIP
  -> c

\ сертификаты и ключи, используемые в соединении
  pemu
  IF
    type pema c SSL_CTX_use_certificate_file NIP NIP NIP 1 <> THROW
    type pema c SSL_CTX_use_RSAPrivateKey_file NIP NIP NIP 1 <> THROW
  THEN
  c
;
: SslSetVerifyDepth  ( depth context -- )
  SSL_CTX_set_verify_depth DROP 2DROP
;
: SslSetVerify { pema pemu mode context -- }
  pemu
  IF
    0 pema context SSL_CTX_load_verify_locations NIP NIP NIP 1 <> THROW
  THEN
  0 mode context SSL_CTX_set_verify 2DROP 2DROP

\ эти CA передаются сервером в запросе сертификата, и клиент может
\ автоматически выдавать нужный сертификат, без выдачи окошка со списком юзеру
\  pema SSL_load_client_CA_file NIP
\  ?DUP IF context SSL_CTX_set_client_CA_list NIP NIP . THEN
;

\ fixme:
: SslRenegotiate { ssl \ s_server_auth_session_id_context -- }
  \ запросить клиентский сертификат во время уже установленной сессии
  \ (когда уже известен клиентский запрос, например)

  0 SSL_VERIFY_FAIL_IF_NO_PEER_CERT ( SSL_VERIFY_PEER OR)
  ssl SSL_set_verify 2DROP 2DROP

  \ Stop the client from just resuming the un-authenticated session
  \      SSL_set_session_id_context(ssl,
  \        (void *)&s_server_auth_session_id_context,
  \        sizeof(s_server_auth_session_id_context));
  2 -> s_server_auth_session_id_context
  4 ^ s_server_auth_session_id_context ssl SSL_set_session_id_context . DROP 2DROP

  ssl SSL_renegotiate ." reneg=" DUP . NIP 1 <> ABORT" SSL renegotiation error1"
  ssl SSL_do_handshake ." handsh=" DUP . NIP 1 <> ABORT" SSL renegotiation error2"
  \      ssl->state=SSL_ST_ACCEPT;
  \      if(SSL_do_handshake(ssl)<=0)
  \        berr_exit("SSL renegotiation error");
;
: SslGetVerifyResults { conn \ cert name mem -- cert addr u ior } \ ior=X509_V_OK=0
\ addr нужно после использования освобождать
  conn SSL_get_peer_certificate NIP -> cert
  cert
  IF
    cert X509_get_subject_name NIP -> name
    name
    IF
      500 DUP ALLOCATE THROW DUP -> mem name X509_NAME_oneline 2DROP 2DROP
      cert mem ASCIIZ>
    ELSE cert S" " THEN
    conn SSL_get_verify_result NIP
  ELSE 0 S" " 1 THEN
;
USER uSslHost   \ здесь задается имя хоста, передаваемое в tlsext ClientHello при исходящих соединениях

: SetSslHost ( addr -- )
  uSslHost !
;
: SslObjConnect ( socket context -- conn_obj ) \ connection
  SSL_new DUP 0= THROW NIP
  >R
  uSslHost @ ?DUP IF TLSEXT_NAMETYPE_host_name SSL_CTRL_SET_TLSEXT_HOSTNAME R@ SSL_ctrl ( 1, если поддерживается) DROP 2DROP 2DROP THEN
  R@ SSL_set_fd 0= THROW 2DROP
  BEGIN
    R@ SSL_connect DUP 1 <>
  WHILE
    SWAP SSL_get_error DUP 3 <> IF THROW THEN
    DROP 2DROP
    dSslWaitIdle
  REPEAT
  DROP RDROP
;
: SslObjAccept ( socket context -- conn_obj ) \ connection
  SSL_new DUP 0= THROW NIP
  DUP >R SSL_set_fd 0= THROW 2DROP
  TlsIndex@ 0 R@ SSL_set_ex_data 2DROP 2DROP

  BEGIN
    R@ SSL_accept DUP 1 <>
  WHILE
    SWAP SSL_get_error DUP 2 <> IF THROW THEN \ SSL_ERROR_WANT_READ=2
    DROP 2DROP
    dSslWaitIdle
  REPEAT
  DROP RDROP
;
: SslWrite { addr u conn_obj -- n }
\  >R SWAP R> SSL_write NIP NIP NIP
  conn_obj 0= IF 5 THROW THEN
  BEGIN
    u addr conn_obj SSL_write NIP NIP NIP DUP 1 <
  WHILE
    conn_obj SSL_get_error DUP 3 <> IF 2DROP EXIT THEN
    DROP 2DROP
\    dSslWaitIdle \ если внутри SslRead:dSslWaitIdle используется SslWrite, то может получиться бесконечная рекурсия dSslWaitIdle
  REPEAT
;
: SslRead { addr u conn_obj -- n }
\  >R SWAP R> SSL_read NIP NIP NIP
  conn_obj 0= IF 5 THROW THEN
  -1 uSslSinceSocketRead !
  BEGIN
    u addr conn_obj SSL_read NIP NIP NIP DUP 1 <
  WHILE
    conn_obj SSL_get_error DUP 2 <> IF 2DROP EXIT THEN
    DROP 2DROP
    TIMEOUT @ uSslSinceSocketRead @ < IF 0 EXIT THEN
    ['] dSslWaitIdle CATCH ?DUP IF ." SLL_R_WI_err=" . THEN
  REPEAT
;
