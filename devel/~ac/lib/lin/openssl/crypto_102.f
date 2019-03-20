REQUIRE [IF]                 lib/include/tools.f
REQUIRE X509ServerPEM        ~ac/lib/lin/openssl/x509cer.f

ALSO libeay32.dll
ALSO libssl.so.0.9.8
ALSO /usr/local/lib/libcrypto.so.1.1
ALSO /usr/local/lib/libssl.so.1.1

S" RSA_get0_key" SFIND
[IF] DROP [ELSE]

2DROP .( openssl 1.0.2 deps) CR

\ #define         X509_REQ_get_subject_name(x) ((x)->req_info->subject)

: X509_REQ_get_subject_name ( req 1 -- cn )
  DROP X509r.*req_info @ X509ri.*subject @
;
: EVP_MD_CTX_new ( 0 -- ctx )
  EVP_MD_CTX_create
;
\ struct rsa_st
0
CELL -- RSA.pad
CELL -- RSA.version
CELL -- RSA.*meth
CELL -- RSA.*engine
CELL -- RSA.*n
CELL -- RSA.*e
CELL -- RSA.*d
CELL -- RSA...
CONSTANT /RSA

\ void RSA_get0_key(const RSA *r, const BIGNUM **n, const BIGNUM **e, const BIGNUM **d)

: RSA_get0_key ( ^d ^e ^n rsa 4 -- x )
  DROP >R
  R@ RSA.*n @ SWAP !
  R@ RSA.*e @ SWAP !
  R@ RSA.*d @ SWAP !
  R>
;

[THEN]

PREVIOUS PREVIOUS PREVIOUS PREVIOUS
