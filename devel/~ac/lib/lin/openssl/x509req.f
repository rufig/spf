\ Функции генерации запросов X.509-сертификатов (PKCS #10) через openssl.
\ (Необходимость возникла в связи с тем, что в InternetExplorer7 встроенные
\ функции X509Enrollment работают только при разрешенном ActiveX, что бывает
\ редко, старый IE5/6-способ (через capicom - xenroll.cab) в IE7 не работает,
\ а в IE8 beta2 вообще нет рабочего способа создать ключи и запрос сертификата,
\ т.е. генерацию запроса приходится реализовать у клиента самостоятельно).
\ См. RFC2314, RFC2311

\ Сработает только при запуске из exe, экспортирующих OPENSSL_Applink,
\ см. applink.f, либо при использовании libeay.dll, скомпилированного без
\ applink. Под Linux applink не нужен, используются временные файлы.

REQUIRE STR@            ~ac/lib/str5.f
REQUIRE SO              ~ac/lib/ns/so-xt.f
REQUIRE RSA_F4          ~ac/lib/lin/openssl/x509h.f
REQUIRE OPENSSL_Applink ~ac/lib/lin/openssl/applink.f

ALSO SO NEW: libeay32.dll
ALSO SO NEW: libssl.so.0.9.8
ALSO SO NEW: libssl.so.10
ALSO SO NEW: libcrypto.so.10
ALSO SO ?NEW: libc.so.6
ALSO SO NEW: msvcrt.dll

: SSLeayUseApplink? ( -- flag )
  2 1 SSLeay_version ASCIIZ> S" -DOPENSSL_USE_APPLINK" SEARCH NIP NIP
;
: SSLeayVersion ( -- addr u )
  0 1 SSLeay_version ASCIIZ>
;

VARIABLE RSA_GK \ установить в true, если нужнен "progress bar" при создании ключа

:NONAME ( *arg n p -- ) { \ c }
\ openssl использует эту функцию для визуализации процесса генерации ключа
\ можно этого не делать :)
  RSA_GK @ IF
    [CHAR] B -> c
    DUP 0 = IF [CHAR] . -> c THEN
    DUP 1 = IF [CHAR] + -> c THEN
    DUP 2 = IF [CHAR] * -> c THEN
    DUP 3 = IF CR 0 -> c THEN
    c IF c EMIT THEN
  THEN
  0
; 3 CELLS CALLBACK: _rsa_gk_cb

: X509AddNameEntry { va vu na nu name -- }
  0 -1 -1 va MBSTRING_UTF8 na name 7 X509_NAME_add_entry_by_txt DROP
;
: X509MkReq { cna cnu ea eu oua ouu oa ou la lu ca cu \ pk req rsa name -- req pk }
\ Создать запрос X.509-сертификата в формате PKCS #10 с заданными параметрами субъекта
\ При использовании не-ascii-символов входные строки должны быть в UTF8.

  0 EVP_PKEY_new -> pk
  0 X509_REQ_new -> req

  0 ['] _rsa_gk_cb RSA_F4 2048 4 RSA_generate_key -> rsa
  rsa EVP_PKEY_RSA pk 3 EVP_PKEY_assign 1 <> THROW

  pk req 2 X509_REQ_set_pubkey DROP
  req X509r.*req_info @ X509ri.*subject @ -> name \ макрос X509_REQ_get_subject_name(x) ((x)->req_info->subject)

  ca cu   S" C"            name X509AddNameEntry \ countryName
  la lu   S" L"            name X509AddNameEntry \ localityName
  oa ou   S" O"            name X509AddNameEntry \ organizationName
  oua ouu S" OU"           name X509AddNameEntry \ organizationalUnitName
  ea eu   S" emailAddress" name X509AddNameEntry \ emailAddress
  cna cnu S" CN"           name X509AddNameEntry \ commonName

  0 EVP_sha1 pk req 3 X509_REQ_sign DROP
  req pk
;
: X509Req2PEM { req f -- }
  req f 2 PEM_write_X509_REQ DROP
;
: X509Pk2PEM { pk f -- }
  0 0 0 0 0 pk f 7 PEM_write_PrivateKey DROP
;
: X509Req2TXT { req f -- }
  req f 2 X509_REQ_print_fp DROP
;
: X2PEMs { x addr u xt \ f -- a2 u2 }
  S" w" DROP addr 2 fopen -> f
  x f xt EXECUTE
  f 1 fclose DROP
  addr u FILE
;
: X509ExpReq { req pk addr u -- reqa requ pkeya pkeyu printa printu } \ без applink
  req addr u " {s}.req"     STR@ ['] X509Req2PEM X2PEMs
  pk  addr u " {s}.pk"      STR@ ['] X509Pk2PEM  X2PEMs
  req addr u " {s}_req.txt" STR@ ['] X509Req2TXT X2PEMs
;
: X509Req2PEMstr { req pk \ stdout -- str_req str_pkey str_print }
\ Экспортировать строчное представление str_req " -----BEGIN CERTIFICATE REQUEST-----[...]" (в формате PEM)
\ для передачи в подписывающий CA,
\ а также str_pkey - закрытый ключ в формате PEM "-----BEGIN RSA PRIVATE KEY-----[...]" для подписей,
\ и str_print

\ можно напрямую использовать h-stdout из ~ac/lib/win/file/crt.f 
\ но более универсальным путем экспорта запроса сертификата будет сборка str5-строки, а не файла,
\ виртуальный apilink-io в openssl дает нам возможность его "обмануть", подсунув tlsindex вместо хэндла
\ На Linux applink не используется.

\ на случай подключения dll без applink'а используем временные файлы:
  SSLeayUseApplink? 0= IF req pk S" _noapplink_" X509ExpReq >STR >R >STR >R >STR R> R> EXIT THEN

  OnWindows: TlsIndex@ -> stdout
  OnLinux: S" w" DROP H-STDOUT 2 fdopen -> stdout

  "" ap_str ! 
  req stdout 2 PEM_write_X509_REQ DROP ap_str @
 
  "" ap_str !
  0 0 0 0 0 pk stdout 7 PEM_write_PrivateKey DROP ap_str @

  "" ap_str !
  req stdout 2 X509_REQ_print_fp DROP ap_str @
;

PREVIOUS PREVIOUS PREVIOUS PREVIOUS PREVIOUS PREVIOUS

\EOF

: TEST { \ bio_err  }
\  CRYPTO_MEM_CHECK_ON 1 CRYPTO_mem_ctrl DROP
\  BIO_NOCLOSE h-stderr 2 BIO_new_fp -> bio_err

\  S" Eserv Admin" S" admin@firm.tld" S" IT" S" Company" S" City" S" RU" X509MkReq X509Req2PEMstr
\  STYPE CR STYPE CR STYPE CR

  S" Eserv Admin" S" admin@firm.tld" S" IT" S" Company" S" City" S" RU" X509MkReq S" server" X509ExpReq
  TYPE CR TYPE CR TYPE CR

; \ TEST
