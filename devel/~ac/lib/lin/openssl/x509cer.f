REQUIRE X509Pk2PEM ~ac/lib/lin/openssl/x509req.f

ALSO libcrypto-1_1.dll
ALSO libssl.so.0.9.8
ALSO /usr/local/lib/libcrypto.so.1.1
ALSO /usr/local/lib/libssl.so.1.1

: X509AddExt { va vu nid x \ ex ctx -- }
  /X509V3_CTX ALLOCATE THROW -> ctx
  ctx X509c.*db 0! \ #define X509V3_set_ctx_nodb(ctx) (ctx)->db = NULL;
	\ * Issuer and subject certs: both the target since it is self signed, no request and no CRL */
  0 0 0 x x ctx 6 X509V3_set_ctx DROP
  va nid ctx 0 4 X509V3_EXT_conf_nid -> ex
  ex 0= IF EXIT THEN
  -1 ex x 3 X509_add_ext DROP
  ex 1 X509_EXTENSION_free DROP
;

: X509MkCert { cna cnu ea eu oua ouu oa ou la lu ca cu serial days \ pk x rsa name -- x pk }
\ Создать самоподписанный X.509-сертификат с заданными параметрами субъекта
\ При использовании не-ascii-символов входные строки должны быть в UTF8.

  0 EVP_PKEY_new -> pk
  0 X509_new -> x

  0 ['] _rsa_gk_cb RSA_F4 2048 4 RSA_generate_key -> rsa
  rsa EVP_PKEY_RSA pk 3 EVP_PKEY_assign 1 <> THROW

  2 x 2 X509_set_version DROP
  serial x 1 X509_get_serialNumber 2 ASN1_INTEGER_set DROP
\ #define		X509_get_notBefore(x) ((x)->cert_info->validity->notBefore)

  0 x X509.*cert_info @ X509ci.*validity @ X509va.*notBefore @ 2 X509_gmtime_adj DROP
  days 24 * 60 * 60 * x X509.*cert_info @ X509ci.*validity @ X509va.*notAfter @ 2 X509_gmtime_adj DROP

  pk x 2 X509_set_pubkey DROP
  x 1 X509_get_subject_name -> name

  ca cu   S" C"            name X509AddNameEntry \ countryName
  la lu   S" L"            name X509AddNameEntry \ localityName
  oa ou   S" O"            name X509AddNameEntry \ organizationName
  oua ouu S" OU"           name X509AddNameEntry \ organizationalUnitName
  ea eu   S" emailAddress" name X509AddNameEntry \ emailAddress
  cna cnu S" CN"           name X509AddNameEntry \ commonName

  name x 2 X509_set_issuer_name DROP \ самоподпись

  S" critical,CA:FALSE" NID_basic_constraints x X509AddExt \ EE
  S" keyEncipherment,dataEncipherment,keyAgreement" NID_key_usage x X509AddExt
  S" hash" NID_subject_key_identifier x X509AddExt
  S" keyid:always" NID_authority_key_identifier x X509AddExt \ ... issuer:always,
  S" serverAuth,clientAuth" NID_ext_key_usage x X509AddExt
  S" Self signed certificate for Eserv SSL/TLS" NID_netscape_comment x X509AddExt

\ CA-расширения
\  S" critical,CA:TRUE,pathlen:10" NID_basic_constraints x X509AddExt \ CA
\  S" critical,keyCertSign,cRLSign,digitalSignature" NID_key_usage x X509AddExt
\  cna cnu " URI:http://{s}/CaAuth.crl" STR@ NID_crl_distribution_points x X509AddExt
\  S" sslCA" NID_netscape_cert_type x X509AddExt \ CA-сертификат обычно не ставят на сервер
\  cna cnu " http://{s}/CaPolicy.html" STR@ NID_netscape_ca_policy_url x X509AddExt
\  cna cnu " http://{s}/CaAuth.crl" STR@ NID_netscape_revocation_url x X509AddExt

  0 EVP_sha1 pk x 3 X509_sign DROP
  x pk
;
: X509Cert2PEM { x f -- }
  x f 2 PEM_write_X509 DROP
;
: X509Cert2TXT { x f -- }
  x f 2 X509_print_fp DROP
;

: X509ExpCert { x pk addr u -- reqa requ pkeya pkeyu printa printu }
  x addr u  " {s}.cer" STR@ ['] X509Cert2PEM X2PEMs
  pk addr u " {s}_pk.pem"  STR@ ['] X509Pk2PEM   X2PEMs
  x addr u  " {s}_cer.txt" STR@ ['] X509Cert2TXT X2PEMs
;
: X509ServerPEM { x pk addr u \ f -- }
\ сертификат и закрытый ключ в одном файле - готово для использования на сервере
  x pk addr u X509ExpCert
  addr u " {s}.pem" STR@ R/W CREATE-FILE THROW -> f
  f WRITE-FILE THROW
  f WRITE-FILE THROW
  f WRITE-FILE THROW
  f CLOSE-FILE THROW
;

PREVIOUS PREVIOUS PREVIOUS PREVIOUS

\ RSA_print_fp(stdout,pkey->pkey.rsa,0);

\EOF
: TEST
  S" mail.forth.org.ru" S" ac@forth.org.ru" S" IT" S" RUFIG" S" Kaliningrad" S" RU" 1 365 X509MkCert
  S" server" X509ServerPEM
; TEST
