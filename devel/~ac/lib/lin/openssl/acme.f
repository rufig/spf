\ min openssl 1.1.0

REQUIRE X509ServerPEM        ~ac/lib/lin/openssl/x509cer.f
REQUIRE EVP_MD_CTX_new       ~ac/lib/lin/openssl/crypto_102.f
REQUIRE X509MkReq2           ~ac/lib/lin/openssl/x509req2.f
REQUIRE base64               ~ac/lib/string/conv.f 
REQUIRE POST-CUSTOM-VIAPROXY ~ac/lib/lin/curl/curlpost.f 
REQUIRE JsonParse            ~ac/lib/transl/json.f 
REQUIRE CREATE-FILE-PATH     ~ac/lib/win/file/utils.f

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
USER link

: sendRequest { url_a url_u payload_a payload_u privateKey_ suffix_a suffix_u \ nonce_a nonce_u protectd_a protectd_u payld_a payld_u signature_a signature_u body_a body_u -- a u }
  nonce @ STR@ -> nonce_u -> nonce_a
  suffix_a suffix_u nonce_a nonce_u S" {" S' {s}"nonce":"{s}",{s}' S@ base64 urlSafeBase64Encode_str -> protectd_u -> protectd_a
  payload_a payload_u base64 urlSafeBase64Encode_str -> payld_u -> payld_a
  payld_a payld_u protectd_a protectd_u S' {s}.{s}' S@ privateKey_ sign -> signature_u -> signature_a
  signature_a signature_u payld_a payld_u protectd_a protectd_u S" {" S' {s}"protected":"{s}","payload":"{s}","signature":"{s}"}' S@ -> body_u -> body_a
  body_a body_u TYPE CR

  S" POST" S" " body_a body_u S" " url_a url_u S" " POST-CUSTOM-VIAPROXY STR@
;

: (headerFunc) ( -- )
  NextWord S" Replay-Nonce:" COMPARE 0=
  IF NextWord ." Replay-Nonce:[" 2DUP TYPE ." ]" CR " {s}" nonce ! THEN
  >IN 0! NextWord S" Link:" COMPARE 0=
  IF NextWord ." Link:[" 2DUP TYPE ." ]" CR " {s}" link ! THEN
  \ варианты Link в ответах на разные запросы:
  \ <https://acme-v01.api.letsencrypt.org/acme/authz/fQ...>;rel="up"
  \ <https://acme-v01.api.letsencrypt.org/acme/issuer-cert>;rel="up"		
;
: headerFunc ( addr u -- )
  ['] (headerFunc) EVALUATE-WITH
;

: (ParseLink) ( -- addr u )
  [CHAR] < SKIP [CHAR] > PARSE
;

: ESERV_WEB_ROOT S" C:/web" ;
: ESERV_CERT_DIR S" C:/E5/cert" ;

: ProcessHttpChallenge { token_a token_u uri_a uri_u jwkThumbprint_a jwkThumbprint_u privateKey_ headerSuffix_a headerSuffix_u dom_a dom_u \ url_a url_u keyAuthorization_a keyAuthorization_u file_a file_u h reqBio keyBio csr_a csr_u pkey_a pkey_u -- }
  token_a token_u dom_a dom_u " http://{s}/.well-known/acme-challenge/{s}" STR@ -> url_u -> url_a
  jwkThumbprint_a jwkThumbprint_u token_a token_u " {s}.{s}"  STR@ -> keyAuthorization_u -> keyAuthorization_a
  CR ." url:" url_a url_u TYPE CR
  ." key:" keyAuthorization_a keyAuthorization_u TYPE CR CR

  token_a token_u dom_a dom_u " {ESERV_WEB_ROOT}/{s}/.well-known/acme-challenge/{s}" STR@ -> file_u -> file_a
  file_a file_u R/W CREATE-FILE-PATH THROW -> h
  keyAuthorization_a keyAuthorization_u h WRITE-FILE THROW
  h CLOSE-FILE THROW

  uri_a uri_u
  keyAuthorization_a keyAuthorization_u S" {" S' {s}"resource":"challenge","keyAuthorization":"{s}"}' S@ 2DUP TYPE CR
  privateKey_ headerSuffix_a headerSuffix_u sendRequest TYPE CR
  \ KEY DROP
  3 0 DO ." ." 1000 PAUSE LOOP CR

\  dom_a dom_u S" ac@forth.org.ru" S" IT" dom_a dom_u S" Kaliningrad" S" RU" X509MkReq -> pk -> req 
  dom_a dom_u X509MkReq2 -> keyBio -> reqBio
  keyBio X509ReadBio 2DUP TYPE CR -> pkey_u -> pkey_a
  reqBio X509ReadBio base64 urlSafeBase64Encode_str -> csr_u -> csr_a

\  S" https://acme-staging.api.letsencrypt.org/acme/new-cert"
  S" https://acme-v01.api.letsencrypt.org/acme/new-cert"
  csr_a csr_u S" {" S' {s}"resource":"new-cert","csr":"{s}"}' S@ 2DUP TYPE CR
  privateKey_ headerSuffix_a headerSuffix_u sendRequest \ здесь может быть JSON-ответ с ошибкой вместо сертификата
  ?DUP IF
    OVER C@ [CHAR] { =
    IF TYPE CR
    ELSE
      \ 2DUP S" server.der" WFILE
      X509DER2PEM \ 2DUP S" server.pem" WFILE
      dom_a dom_u " {ESERV_CERT_DIR}/{s}.pem" STR@ -> file_u -> file_a
      file_a file_u R/W CREATE-FILE-PATH THROW -> h
      ( cert ) h WRITE-FILE THROW
      pkey_a pkey_u h WRITE-FILE THROW
      link @ STR@ ." Link:" 2DUP TYPE CR
      ['] (ParseLink) EVALUATE-WITH 2DUP TYPE CR
      GET-FILE STR@ X509DER2PEM \ 2DUP S" ca.pem" WFILE
      h WRITE-FILE THROW
      h CLOSE-FILE THROW

    THEN
  ELSE
     DROP ." Empty reply" CR
  THEN
\ -----BEGIN CERTIFICATE-----
\ -----BEGIN PRIVATE KEY-----
\  req .
\  0 BIO_s_mem .
;
: ProcessChallenge { x t jwkThumbprint_a jwkThumbprint_u privateKey_ headerSuffix_a headerSuffix_u dom_a dom_u \ t2 type token uri -- }
  t js_object <> IF ." challenge is not object" CR EXIT THEN
  S" type" x SEARCH-WORDLIST 
  IF >BODY JsonVal@ -> t2 -> type
     t2 js_string = IF ." type:" type STR@ TYPE CR THEN
  ELSE
     ." unknown challenge type" CR EXIT
  THEN
  S" token" x SEARCH-WORDLIST 
  IF >BODY JsonVal@ -> t2 -> token
     t2 js_string = IF ." token:" token STR@ TYPE CR THEN
  ELSE
     ." unknown challenge token" CR EXIT
  THEN
  S" uri" x SEARCH-WORDLIST 
  IF >BODY JsonVal@ -> t2 -> uri
     t2 js_string = IF ." uri:" uri STR@ TYPE CR THEN
  ELSE
     ." unknown challenge uri" CR EXIT
  THEN
  type STR@ S" http-01" COMPARE 0=
  IF
    \ если status=valid, а не pending, то повторную валидацию проводить не нужно (LE и не будет делать попытку)
    token STR@ uri STR@ jwkThumbprint_a jwkThumbprint_u privateKey_ headerSuffix_a headerSuffix_u dom_a dom_u ProcessHttpChallenge
  THEN
;
: LE { dom_a dom_u \ bio rsa n e d privateKey_ jwkValue_u jwkValue_a jwkThumbprint_a jwkThumbprint_u headerSuffix_a headerSuffix_u payload_a payload_u x t }
  "" nonce !
  "" link !
  ['] headerFunc HEADER_CB !
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
            S" https://acme-v01.api.letsencrypt.org/acme/new-authz" payload_a payload_u privateKey_ headerSuffix_a headerSuffix_u sendRequest TYPE CR
            S" https://acme-v01.api.letsencrypt.org/acme/new-authz" payload_a payload_u privateKey_ headerSuffix_a headerSuffix_u sendRequest 2DUP TYPE CR
\            S" https://acme-staging.api.letsencrypt.org/acme/new-authz" payload_a payload_u privateKey_ headerSuffix_a headerSuffix_u sendRequest TYPE CR
\            S" https://acme-staging.api.letsencrypt.org/acme/new-authz" payload_a payload_u privateKey_ headerSuffix_a headerSuffix_u sendRequest 2DUP TYPE CR            
            JsonParse 2DUP -> t -> x JsonPrint
            t js_object = IF
              S" challenges" x SEARCH-WORDLIST 
              IF >BODY JsonVal@ -> t -> x
                 t js_array = IF
                   x @ BEGIN DUP WHILE DUP NAME> >BODY JsonVal@ 2DUP . . CR jwkThumbprint_a jwkThumbprint_u privateKey_ headerSuffix_a headerSuffix_u dom_a dom_u ProcessChallenge CDR REPEAT DROP
                 ELSE
                   ." 'challenges' is not array" CR
                 THEN
              THEN
            ELSE
              ." unknown reply format" CR
            THEN
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
  ." DONE" CR
;

\ S" forth.org.ru" LE
S" LE.exe" SAVE BYE
