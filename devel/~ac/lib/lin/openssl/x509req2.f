\ Функции генерации запросов X.509-сертификатов (PKCS #10) с указанием только домена (в CN)
\ для использования в ACME-протоколе.

REQUIRE X509MkReq  ~ac/lib/lin/openssl/x509req.f

ALSO libcrypto-1_1.dll
ALSO libssl.so.0.9.8
ALSO /usr/local/lib/libcrypto.so.1.1
ALSO /usr/local/lib/libssl.so.1.1

: X509ReadBio { bio \ buf pos count -- addr u }
  1024 ALLOCATE THROW -> buf
  0 -> pos
  BEGIN
    1024 buf pos + bio 3 BIO_read -> count
    count 0 > IF
      pos count + -> pos
      buf pos 1024 + RESIZE THROW -> buf
      FALSE
    ELSE
      TRUE
    THEN
  UNTIL
  buf pos
;
: X509MkReq2 { dom_a dom_u \ bn rsa req cn key keyBio reqBio -- reqBio keyBio }
  0 BN_new -> bn
  RSA_F4 bn 2 BN_set_word 1 <> IF ." BN_set_word failed" EXIT THEN
  0 RSA_new -> rsa
  0 bn 2048 rsa 4 RSA_generate_key_ex 1 <> IF ." RSA_generate_key_ex failed" EXIT THEN
  0 X509_REQ_new -> req
  req 1 X509_REQ_get_subject_name -> cn
  0 -1 -1 dom_a MBSTRING_ASC S" CN" DROP cn 7 X509_NAME_add_entry_by_txt 1 <> IF ." Set CN failed" EXIT THEN
  0 EVP_PKEY_new -> key
  rsa EVP_PKEY_RSA key 3 EVP_PKEY_assign 1 <> IF ." Key assign failed" EXIT THEN
  0 BIO_s_mem 1 BIO_new -> keyBio
  0 0 0 0 0 key keyBio 7 PEM_write_bio_PrivateKey 1 <> IF ." PK write failed" EXIT THEN
\  keyBio X509ReadBio DUMP
  key req 2 X509_REQ_set_pubkey 1 <> IF ." X509_REQ_set_pubkey failed" EXIT THEN
  0 EVP_sha256 key req 3 X509_REQ_sign 256 <> IF ." REQ sign failed" EXIT THEN
  0 BIO_s_mem 1 BIO_new -> reqBio
  req reqBio 2 i2d_X509_REQ_bio 1 <> IF ." i2d_X509_REQ_bio failed" EXIT THEN
\  reqBio X509ReadBio DUMP
  reqBio keyBio
;
: X509DER2PEM { addr u \ derBio pemBio x509 -- addr2 u2 } \ на входе и выходе байтовые массивы
  0 BIO_s_mem 1 BIO_new -> derBio
  u addr derBio 3 BIO_write DROP
  0 derBio 2 d2i_X509_bio -> x509
  0 BIO_s_mem 1 BIO_new -> pemBio
  x509 pemBio 2 PEM_write_bio_X509 DROP
  pemBio X509ReadBio
;
PREVIOUS PREVIOUS PREVIOUS PREVIOUS

\ S" forth.org.ru" X509MkReq2 X509ReadBio DUMP CR X509ReadBio DUMP
\ S" server.der" FILE X509DER2PEM S" server.pem" WFILE
