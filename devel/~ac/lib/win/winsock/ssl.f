REQUIRE {             ~ac/lib/locals.f
REQUIRE CreateSocket ~ac/lib/win/winsock/sockets.f

WINAPI: SSL_load_error_strings libssl32.dll
WINAPI: SSL_library_init       libssl32.dll
WINAPI: SSL_CTX_new            libssl32.dll
WINAPI: TLSv1_method           libssl32.dll
WINAPI: SSLv3_method           libssl32.dll
WINAPI: SSL_new                libssl32.dll
WINAPI: SSL_set_fd             libssl32.dll
WINAPI: SSL_connect            libssl32.dll
WINAPI: SSL_accept             libssl32.dll
WINAPI: SSL_write              libssl32.dll
WINAPI: SSL_read               libssl32.dll
WINAPI: SSL_get_error          libssl32.dll
\ WINAPI: ERR_error_string       libssl32.dll
WINAPI: SSL_CTX_use_certificate_file libssl32.dll
WINAPI: SSL_load_client_CA_file libssl32.dll
WINAPI: SSL_CTX_set_client_CA_list libssl32.dll
WINAPI: SSL_CTX_load_verify_locations libssl32.dll
\ WINAPI: SSL_CTX_set_client_cert_cb libssl32.dll
WINAPI: SSL_CTX_use_RSAPrivateKey_file libssl32.dll
WINAPI: SSL_CTX_set_default_passwd_cb  libssl32.dll
WINAPI: SSL_set_accept_state    libssl32.dll
WINAPI: SSLv23_server_method    libssl32.dll
WINAPI: SSLv23_client_method    libssl32.dll
WINAPI: SSL_free                libssl32.dll

WINAPI: SSL_CTX_set_verify      libssl32.dll
WINAPI: SSL_get_verify_result   libssl32.dll
WINAPI: SSL_get_peer_certificate libssl32.dll

WINAPI: X509_get_subject_name   libeay32.dll
WINAPI: X509_NAME_oneline       libeay32.dll
WINAPI: X509_verify_cert_error_string libeay32.dll

1 CONSTANT X509_FILETYPE_PEM
2 CONSTANT X509_FILETYPE_ASN1
3 CONSTANT X509_FILETYPE_DEFAULT

0 CONSTANT SSL_VERIFY_NONE
1 CONSTANT SSL_VERIFY_PEER
2 CONSTANT SSL_VERIFY_FAIL_IF_NO_PEER_CERT
4 CONSTANT SSL_VERIFY_CLIENT_ONCE



: SslInit ( -- )
  SSL_load_error_strings DROP
  SSL_library_init DROP
;
: SslNewServerContext { pema pemu type \ c -- context }
  SSLv23_server_method SSL_CTX_new DUP 0= THROW NIP
\ http://www.openssl.org/docs/ssl/SSL_CTX_new.html#
  -> c

\ сертификаты и ключи, используемые в соединении
  pemu
  IF
    type pema c SSL_CTX_use_certificate_file NIP NIP NIP 1 <> THROW
    type pema c SSL_CTX_use_RSAPrivateKey_file NIP NIP NIP 1 <> THROW
  THEN
  c
;
: SslNewClientContext { pema pemu type \ c -- context }
  SSLv23_client_method SSL_CTX_new DUP 0= THROW NIP
  -> c

\ сертификаты и ключи, используемые в соединении
  pemu
  IF
    type pema c SSL_CTX_use_certificate_file NIP NIP NIP 1 <> THROW
    type pema c SSL_CTX_use_RSAPrivateKey_file NIP NIP NIP 1 <> THROW
  THEN
  c
;
: SslSetVerify { pema pemu mode context -- }
  0 pema context SSL_CTX_load_verify_locations NIP NIP NIP 1 <> THROW
  0 mode context SSL_CTX_set_verify 2DROP 2DROP

\ эти CA передаются сервером в запросе сертификата, и клиент может
\ автоматически выдавать нужный сертификат, без выдачи окошка со списком юзеру
\  pema SSL_load_client_CA_file NIP
\  ?DUP IF context SSL_CTX_set_client_CA_list NIP NIP . THEN
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
  ELSE 0 S" " THEN
  conn SSL_get_verify_result NIP
;
: SslObjConnect ( socket context -- conn_obj ) \ connection
  SSL_new DUP 0= THROW NIP
  DUP >R SSL_set_fd 0= THROW 2DROP R>
  SSL_connect DUP 1 <> IF SWAP SSL_get_error THROW ELSE DROP THEN
;
: SslObjAccept ( socket context -- conn_obj ) \ connection
  SSL_new DUP 0= THROW NIP
  DUP >R SSL_set_fd 0= THROW 2DROP R>
  SSL_accept DUP 1 <> IF SWAP SSL_get_error THROW ELSE DROP THEN
;
: SslWrite ( addr u conn_obj -- n )
  >R SWAP R> SSL_write NIP NIP NIP
;
: SslRead ( addr u conn_obj -- n )
  >R SWAP R> SSL_read NIP NIP NIP
;
