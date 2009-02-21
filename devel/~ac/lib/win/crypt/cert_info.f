\ извлечение дат валидности сертификата из контекста загруженного сертификата

0
CELL -- cctx.dwCertEncodingType
CELL -- cctx.pbCertEncoded
CELL -- cctx.cbCertEncoded
CELL -- cctx.pCertInfo
CELL -- cctx.hCertStore
CONSTANT /CERT_CONTEXT

0
CELL -- ci.dwVersion
   8 -- ci.SerialNumber       \ BLOB: cbData,*pbData
  12 -- ci.SignatureAlgorithm \ psz, blob
   8 -- ci.Issuer             \ blob (encoded)
   8 -- ci.NotBefore          \ filetime
   8 -- ci.NotAfter           \ filetime
   8 -- ci.Subject            \ blob
  20 -- ci.SubjectPublicKeyInfo
   8 -- ci.IssuerUniqueId     \ bit.blob
   8 -- ci.SubjectUniqueId
   4 -- ci.cExtension
   0 -- ci.rgExtension        \ массив указателей на CERT_EXTENSION
CONSTANT /CERT_INFO

: CertNotBeforeFiletime ( cert -- filetime ) \ UTC
  cctx.pCertInfo @ ci.NotBefore 2@ SWAP
;
: CertNotAfterFiletime ( cert -- filetime ) \ UTC
  cctx.pCertInfo @ ci.NotAfter 2@ SWAP
;
\ ѕреобразовани€ см. в REQUIRE FILETIME>TIME&DATE ~ac/lib/win/file/filetime.f 
