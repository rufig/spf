REQUIRE FILE        ~ac/lib/str2.f

WINAPI: CertCreateCertificateContext        CRYPT32.DLL
WINAPI: CertFreeCertificateContext          CRYPT32.DLL
WINAPI: CertVerifySubjectCertificateContext CRYPT32.DLL
WINAPI: CertGetNameStringA                  CRYPT32.DLL
WINAPI: CryptSignMessage                    CRYPT32.DLL
WINAPI: CryptVerifyMessageSignature         CRYPT32.DLL
WINAPI: CertCompareCertificate              CRYPT32.DLL
WINAPI: CertGetEnhancedKeyUsage             CRYPT32.DLL

0x00000001 CONSTANT X509_ASN_ENCODING
0x00010000 CONSTANT PKCS_7_ASN_ENCODING

0x00000001 CONSTANT CERT_STORE_SIGNATURE_FLAG
0x00000002 CONSTANT CERT_STORE_TIME_VALIDITY_FLAG
0x00000004 CONSTANT CERT_STORE_REVOCATION_FLAG

\ Certificate name types
1 CONSTANT CERT_NAME_EMAIL_TYPE
2 CONSTANT CERT_NAME_RDN_TYPE
3 CONSTANT CERT_NAME_ATTR_TYPE
4 CONSTANT CERT_NAME_SIMPLE_DISPLAY_TYPE
5 CONSTANT CERT_NAME_FRIENDLY_DISPLAY_TYPE

\ Certificate name flags
1 CONSTANT CERT_NAME_ISSUER_FLAG

\  Certificate name string types
1 CONSTANT CERT_SIMPLE_NAME_STR

: CertContext ( filea fileu -- cert )
  FILE SWAP X509_ASN_ENCODING PKCS_7_ASN_ENCODING OR CertCreateCertificateContext
;
: IsValidCertificateMode ( cert_subj cert_issuing mode -- flag )
  >R RP@ ROT ROT SWAP CertVerifySubjectCertificateContext 1 = R> 0= AND
;
: IsValidCertificateDate ( cert_subj -- flag )
  0 CERT_STORE_TIME_VALIDITY_FLAG IsValidCertificateMode
;
: IsSignedBy ( cert_subj cert_iss -- flag )
  CERT_STORE_SIGNATURE_FLAG IsValidCertificateMode
;
: IsSignedByAndValid ( cert_subj cert_iss -- flag )
  CERT_STORE_SIGNATURE_FLAG CERT_STORE_TIME_VALIDITY_FLAG OR
\  CERT_STORE_REVOCATION_FLAG OR
  IsValidCertificateMode
;
: GetCertificateString { cert iss name nstr \ mem -- addr u }
  512 ALLOCATE THROW -> mem
  512 mem ^ nstr iss ( или 1, если issuer)
  name
  cert CertGetNameStringA mem SWAP 1- 0 MAX
;
: GetCertSubjectName ( cert -- addr u )
  0 CERT_NAME_RDN_TYPE CERT_SIMPLE_NAME_STR GetCertificateString
;
: GetCertIssuerName ( cert -- addr u )
  1 CERT_NAME_RDN_TYPE CERT_SIMPLE_NAME_STR GetCertificateString
;

: S, ( addr u -- )
  HERE OVER ALLOT SWAP MOVE
;
: L",
  0 ?DO DUP I + C@ W, LOOP DROP 0 W,
;
: L" ( "ccc" -- )
  [CHAR] " PARSE L",
;

CREATE VERIFY_PARA 20 ,  X509_ASN_ENCODING PKCS_7_ASN_ENCODING OR ,
0 , 0 , 0 ,

: ALG_ID_MD5 S" 1.2.840.113549.1.1.4" DROP ;
\ : ALG_ID_MD5 S" 1.2.840.113549.1.1.2" ; \ MD2
\ CREATE ALG_ID_MD5 L" 1.2.840.113549.1.1.4"

CREATE SIGN_PARA 72 , X509_ASN_ENCODING PKCS_7_ASN_ENCODING OR ,
HERE 0 , (  CERT_CONTEXT )
ALG_ID_MD5 , \ 0 ( CRYPT_OBJID_BLOB ) ,
0 ,
1 , ( cMsgCert - сколько сертификатов включать в сообщение )
DUP , ( rgpMsgCert - массив указателей на включаемые сертификаты )
1 ,  , 0 , 0 , 0 , 0 ,
0 , 0 , 0 , 0 ,

: VerifySignature { addr u   \ cert size mem -- addr2 u2 cert 0   | ior }
  ^ cert
  u -> size  size ALLOCATE THROW -> mem
  ^ size mem
  u addr
  0
  VERIFY_PARA CryptVerifyMessageSignature 0 = IF GetLastError EXIT THEN
  mem size cert 0
;
: SignMessage { addr u cert \ size mem pmem paddr -- addr2 u2 0   | ior }
  cert SIGN_PARA CELL+ CELL+ !
\ ^ cert SIGN_PARA 6 CELLS + !
  u 8000 + -> size
  size ALLOCATE THROW -> mem  mem -> pmem  ^ addr -> paddr
  ^ size mem
  ^ u  paddr
  1 FALSE
  SIGN_PARA CryptSignMessage 0 = IF GetLastError EXIT THEN
  mem size 0
;
: CompareCert ( cert1 cert2 -- flag ) \ 0 означает "равны", как в COMPARE
  3 CELLS + @ SWAP 3 CELLS + @
  X509_ASN_ENCODING PKCS_7_ASN_ENCODING OR
  CertCompareCertificate 0=
;
: IsMsgSignedBy ( addr u cert -- flag ) \ true = да, подписано этим сертификатом
  >R VerifySignature IF RDROP FALSE EXIT THEN
  >R 2DROP
  2R> CompareCert 0=
;
: EnumCertExtensions { context xt \ size mem -- }
\ xt: cert addr u --
\ Массив расширений:
\ 322EE4   01 00 00 00  EC 2E 32 00  F0 2E 32 00  31 2E 33 2E ....ь.2.Ё.2.1.3.
\ 322EF4   36 2E 31 2E  34 2E 31 2E  31 38 34 37  34 2E 31 2E 6.1.4.1.18474.1.
\ 322F04   33 2E 31 30  00 00 00 00  00 00 00 00  00 00 00 00 3.10............
  1000 DUP -> size ALLOCATE THROW -> mem
  ^ size mem 0 context CertGetEnhancedKeyUsage 1 =
  IF mem CELL + @
     mem @ 0 ?DO
       context OVER I CELLS + @ ASCIIZ> xt EXECUTE
     LOOP DROP
  THEN
;

