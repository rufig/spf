\ min openssl 1.1.0

REQUIRE X509ServerPEM        ~ac/lib/lin/openssl/x509cer.f
REQUIRE base64               ~ac/lib/string/conv.f 
REQUIRE POST-CUSTOM-VIAPROXY ~ac/lib/lin/curl/curlpost.f 

ALSO libeay32.dll
ALSO libssl.so.0.9.8
ALSO /usr/local/lib/libcrypto.so.1.1
ALSO /usr/local/lib/libssl.so.1.1

32 CONSTANT SHA256_DIGEST_LENGTH
112 CONSTANT SHA256_CTX_SIZE

: BN_num_bytes ( bn -- n )
  1 BN_num_bits 7 + 8 /
;
: urlSafeBase64Encode_str { addr u -- a2 u2 }
  addr u + addr ?DO
    I C@ [CHAR] + = IF [CHAR] - I C! THEN
    I C@ [CHAR] / = IF [CHAR] _ I C! THEN
    I C@ [CHAR] = = IF u 1- -> u THEN
  LOOP
  addr u
;
: urlSafeBase64Encode { bn \ buf d_size addr u -- addr u }
  bn BN_num_bytes -> d_size 
  d_size ALLOCATE THROW -> buf
  buf bn 2 BN_bn2bin DROP
  buf d_size base64
  urlSafeBase64Encode_str
  buf FREE THROW
;
: sha256 { addr u \ hash ctx -- a2 u2 }
  SHA256_DIGEST_LENGTH ALLOCATE THROW -> hash
  SHA256_CTX_SIZE ALLOCATE THROW -> ctx
  ctx 1 SHA256_Init 1 <> THROW
  u addr ctx 3 SHA256_Update 1 <> THROW
  ctx hash 2 SHA256_Final 1 <> THROW
  hash SHA256_DIGEST_LENGTH base64 urlSafeBase64Encode_str
  ctx FREE THROW
  hash FREE THROW
;
: sign { addr u privateKey \ context sha256_dg signatureLength signature -- a2 u2 }
  0 EVP_MD_CTX_new DUP -> context
  IF
    S" SHA256" DROP 1 EVP_get_digestbyname DUP -> sha256_dg
    IF
      0 sha256_dg context 3 EVP_DigestInit_ex 1 <> THROW
      privateKey 0 sha256_dg 0 context 5 EVP_DigestSignInit 1 <> THROW
      u addr context 3 EVP_DigestUpdate 1 <> THROW
      ^ signatureLength 0 context 3 EVP_DigestSignFinal 1 <> THROW
      signatureLength ?DUP
      IF
        ALLOCATE THROW -> signature
        ^ signatureLength signature context 3 EVP_DigestSignFinal 1 <> THROW        
        signature signatureLength base64 urlSafeBase64Encode_str
        signature FREE THROW
      ELSE
        ." unknown signature length" CR S" "
      THEN
    ELSE
      ." get_digestbyname failed" CR S" "
    THEN
  ELSE
    ." signature context creation failed" CR S" "
  THEN
;

USER nonce

: sendRequest { url_a url_u payload_a payload_u privateKey_ suffix_a suffix_u \ nonce_a nonce_u protectd_a protectd_u payld_a payld_u signature_a signature_u body_a body_u -- a u }
  nonce @ STR@ -> nonce_u -> nonce_a
  suffix_a suffix_u nonce_a nonce_u S" {" S' {s}"nonce":"{s}",{s}' S@ base64 urlSafeBase64Encode_str -> protectd_u -> protectd_a
  payload_a payload_u base64 urlSafeBase64Encode_str -> payld_u -> payld_a
  payld_a payld_u protectd_a protectd_u S' {s}.{s}' S@ privateKey_ sign -> signature_u -> signature_a
  signature_a signature_u payld_a payld_u protectd_a protectd_u S" {" S' {s}"protected":"{s}","payload":"{s}","signature":"{s}"}' S@ -> body_u -> body_a
  body_a body_u TYPE CR

  S" POST" S" " body_a body_u S" " url_a url_u S" " POST-CUSTOM-VIAPROXY STYPE CR

\ POST-CUSTOM-VIAPROXY { amethod umethod aheader uheader adata udata act uct addr u paddr pu \ h data slist coo -- str }
\ если прокси paddr pu - непустая строка, то явно используется этот прокси
\ curl умеет использовать переменные окружения http_proxy, ftp_proxy
\ поэтому можно не задавать прокси явно.
\ adata udata - передаваемые через POST (или иной метот с телом) данные.
\ act uct - content-type; если uct=0, то остается default application/x-www-form-urlencoded
\ если данные POST'а не текстовые, а двоичные, то CURL отправит всё, благодаря CURLOPT_POSTFIELDSIZE_LARGE

;

: (headerFunc) ( -- )
  NextWord S" Replay-Nonce:" COMPARE 0=
  IF NextWord ." [" 2DUP TYPE ." ]" CR " {s}" nonce ! THEN
;
: headerFunc ( addr u -- )
  ['] (headerFunc) EVALUATE-WITH
;
' headerFunc HEADER_CB !

: LE { dom_a dom_u \ bio rsa n e d privateKey_ jwkValue_u jwkValue_a jwkThumbprint_a jwkThumbprint_u headerSuffix_a headerSuffix_u payload_a payload_u }
  "" nonce !
  S" account-key.txt" FILE SWAP 2 BIO_new_mem_buf -> bio
  bio IF
    0 0 0 bio 4 PEM_read_bio_RSAPrivateKey -> rsa
    rsa IF
      0 EVP_PKEY_new -> privateKey_
      privateKey_ IF
        rsa EVP_PKEY_RSA privateKey_ 3 EVP_PKEY_assign
        IF
          ^ d ^ e ^ n rsa 4 RSA_get0_key DROP \ void
	  d IF
	    n urlSafeBase64Encode e urlSafeBase64Encode S" {"
            S' {s}"e":"{s}","kty":"RSA","n":"{s}"}' S@ -> jwkValue_u -> jwkValue_a
            jwkValue_a jwkValue_u sha256 -> jwkThumbprint_u -> jwkThumbprint_a
            jwkValue_a jwkValue_u S' "alg":"RS256","jwk":{s}}' S@ 2DUP TYPE CR -> headerSuffix_u -> headerSuffix_a

            dom_a dom_u S" {" S" {" S' {s}"resource":"new-authz","identifier":{s}"type":"dns","value":"{s}"}}' S@ -> payload_u -> payload_a
            S" https://acme-v01.api.letsencrypt.org/acme/new-authz" payload_a payload_u privateKey_ headerSuffix_a headerSuffix_u sendRequest
            S" https://acme-v01.api.letsencrypt.org/acme/new-authz" payload_a payload_u privateKey_ headerSuffix_a headerSuffix_u sendRequest
          THEN
        ELSE
          ." assign key failed" CR
        THEN
      THEN
    ELSE
      ." rsa read failed" CR
    THEN
  ELSE
    ." bio read failed" CR
  THEN
;

S" forth.org.ru" LE

