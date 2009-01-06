\ Константы и структуры, используемые при работе с x509-сертификатами.

    0x1 CONSTANT CRYPTO_MEM_CHECK_ON \ crypto.h
   0x00 CONSTANT BIO_NOCLOSE         \ bio.h
0x10001 CONSTANT RSA_F4              \ rsa.h

      6 CONSTANT NID_rsaEncryption   \ objects.f
NID_rsaEncryption CONSTANT EVP_PKEY_RSA	

            0x1000 CONSTANT MBSTRING_FLAG \ asn1.h
     MBSTRING_FLAG CONSTANT MBSTRING_UTF8
MBSTRING_FLAG 1 OR CONSTANT MBSTRING_ASC

20 CONSTANT /SHA_DIGEST_LENGTH

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

\ typedef struct x509_cinf_st
0
CELL -- X509ci.*version		\ [ 0 ] default of v1 */
CELL -- X509ci.*serialNumber
CELL -- X509ci.*signature
CELL -- X509ci.*issuer
CELL -- X509ci.*validity
CELL -- X509ci.*subject
CELL -- X509ci.*key
CELL -- X509ci.*issuerUID		\ [ 1 ] optional in v2 */
CELL -- X509ci.*subjectUID		\ [ 2 ] optional in v2 */
CELL -- X509ci.*extensions	\ [ 3 ] optional in v3 */
CONSTANT /X509_CINF

\ typedef struct X509_val_st
0
CELL -- X509va.*notBefore
CELL -- X509va.*notAfter
CONSTANT /X509_VAL

\ typedef struct stack_st
0
CELL -- STACK.num
CELL -- STACK.**data
CELL -- STACK.sorted
CELL -- STACK.num_alloc
CELL -- STACK.*comp
CONSTANT /STACK

\ struct crypto_ex_data_st
0
/STACK -- CEX.*sk
CELL   -- CEX.dummy \ gcc is screwing up this data structure :-( */
CONSTANT /CRYPTO_EX_DATA

\ struct x509_st
0
CELL --	X509.*cert_info
CELL --	X509.*sig_alg
CELL --	X509.*signature
CELL --	X509.valid
CELL --	X509.references
CELL --	X509.*name
/CRYPTO_EX_DATA -- X509.ex_data
\ These contain copies of various extension values */
CELL --	X509.ex_pathlen
CELL --	X509.ex_pcpathlen;
CELL --	X509.ex_flags
CELL --	X509.ex_kusage
CELL --	X509.ex_xkusage
CELL --	X509.ex_nscert
CELL --	X509.*skid
CELL --	X509.*akid
CELL --	X509.*policy_cache
CELL --	X509.*rfc3779_addr
CELL --	X509.*rfc3779_asid
/SHA_DIGEST_LENGTH -- X509.sha1_hash
CELL --	X509.*aux
CONSTANT /X509
