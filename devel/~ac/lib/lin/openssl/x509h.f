\ Константы и структуры, используемые при работе с x509-сертификатами.

    0x1 CONSTANT CRYPTO_MEM_CHECK_ON \ crypto.h
   0x00 CONSTANT BIO_NOCLOSE         \ bio.h
0x10001 CONSTANT RSA_F4              \ rsa.h

      6 CONSTANT NID_rsaEncryption   \ objects.f
NID_rsaEncryption CONSTANT EVP_PKEY_RSA	

            0x1000 CONSTANT MBSTRING_FLAG \ asn1.h
     MBSTRING_FLAG CONSTANT MBSTRING_UTF8
MBSTRING_FLAG 1 OR CONSTANT MBSTRING_ASC


\ typedef struct ASN1_ENCODING_st
0
CELL -- ae.enc	\ DER encoding
CELL -- ae.len	\ Length of encoding
CELL --	ae.modified \ set to 1 if 'enc' is invalid
CONSTANT /ASN1_ENCODING

\ typedef struct X509_req_info_st
0
/ASN1_ENCODING -- X509ri.enc
CELL           -- X509ri.*version
CELL           -- X509ri.*subject
CELL           -- X509ri.*pubkey
\  d=2 hl=2 l=  0 cons: cont: 00 
\	STACK_OF X509_ATTRIBUTE *attributes; /* [ 0 ] */
CONSTANT /X509_REQ_INFO

\ typedef struct X509_req_st
0
CELL -- X509r.*req_info
CELL -- X509r.*sig_alg
CELL -- X509r.*signature
CELL --	X509r.references
CONSTANT /X509_REQ
