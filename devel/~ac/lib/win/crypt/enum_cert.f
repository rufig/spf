( перебор сертификатов в хранилище и поиск сертификата по subject )
REQUIRE GetCertSubjectName ~ac/lib/win/crypt/cert.f 

WINAPI: CertOpenStore               CRYPT32.DLL
WINAPI: CertFindCertificateInStore  CRYPT32.DLL
WINAPI: CertEnumCertificatesInStore CRYPT32.DLL

9                CONSTANT CERT_STORE_PROV_SYSTEM
1 16 LSHIFT      CONSTANT CERT_SYSTEM_STORE_CURRENT_USER
7 16 LSHIFT 7 OR CONSTANT CERT_FIND_SUBJECT_STR

: CERTIFICATE_STORE_NAME S" MY" DROP ;

: CERT_SUBJECT_NAME  S" Thawte" DROP ;

: TEST { \ ss cert }
  CERTIFICATE_STORE_NAME CERT_SYSTEM_STORE_CURRENT_USER 0 0 CERT_STORE_PROV_SYSTEM CertOpenStore DUP . -> ss
  ss 0= THROW
  0 CERT_SUBJECT_NAME CERT_FIND_SUBJECT_STR 0 X509_ASN_ENCODING PKCS_7_ASN_ENCODING OR ss CertFindCertificateInStore -> cert
  cert IF ." found:" cert GetCertSubjectName TYPE CR THEN
  0
  BEGIN
    ss CertEnumCertificatesInStore DUP
  WHILE
    DUP GetCertSubjectName TYPE CR
  REPEAT DROP
; TEST
