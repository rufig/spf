\ ~ac/lib/asn1/der-test.f -- unit tests for der.f: bounds and hostile encodings.
\ Run: spf64 ~ac/lib/asn1/der-test.f
\ Every "must reject" case below is an encoding a remote peer can send us; the point of each is that
\ the parser returns FALSE rather than handing the caller a span outside the buffer.  CRLF.
REQUIRE DER-SPKI ~ac/lib/asn1/der.f
DECIMAL

VARIABLE #FAIL   0 #FAIL !
: OK? ( f a u -- )  ROT IF ." ok   " TYPE ELSE ." FAIL " TYPE  1 #FAIL +! THEN CR ;

\ a minimal but structurally real certificate:
\ SEQUENCE { SEQUENCE { [0] ver, INTEGER serial, SEQ sigAlg, SEQ issuer, SEQ validity, SEQ subject,
\                       SEQ subjectPublicKeyInfo }, SEQ sigAlg, BIT STRING sig }
CREATE CERT
   0x30 C, 0x1C C,                                   \ Certificate, 28 bytes of content
      0x30 C, 0x15 C,                                \ tbsCertificate, 21 bytes
         0xA0 C, 0x03 C, 0x02 C, 0x01 C, 0x02 C,     \ [0] version v3
         0x02 C, 0x01 C, 0x01 C,                     \ serialNumber
         0x30 C, 0x00 C,                             \ signature (alg)
         0x30 C, 0x00 C,                             \ issuer
         0x30 C, 0x00 C,                             \ validity
         0x30 C, 0x00 C,                             \ subject
         0x30 C, 0x03 C, 0x01 C, 0x02 C, 0x03 C,     \ subjectPublicKeyInfo  <-- offset 20, 5 bytes
      0x30 C, 0x00 C,                                \ signatureAlgorithm
      0x03 C, 0x01 C, 0x00 C,                        \ signatureValue
HERE CERT - CONSTANT /CERT

CREATE B 64 ALLOT                                    \ scratch for hand-built hostile TLVs
: B! { n -- a u }  n 0 DO  n 1- I -  B +  C!  LOOP  B n ;   \ bytes pushed first..last -> B

: T-WELLFORMED
   /CERT 30 = S" cert fixture is 30 bytes" OK?
   CERT /CERT DER-SPKI
   IF   ( spki-a spki-u )
      5 =  SWAP CERT 20 + =  AND   S" SPKI span is the whole TLV at offset 20" OK?
   ELSE FALSE S" DER-SPKI finds the SPKI" OK? THEN ;

: T-SHORTFORM
   0x04 0x02 0xAA 0xBB 4 B!  OVER +  ( a end )  DER-TLV
   IF   ( tag val-a val-u next-a )
      B 4 + =  SWAP 2 = AND  SWAP B 2 + = AND  SWAP 4 = AND
      S" short form: tag/value/length/next all correct" OK?
   ELSE FALSE S" short-form TLV parses" OK? THEN ;

: T-LONGFORM                                       \ 0x81 nn = long form with one length octet
   0x04 0x81 0x02 0xAA 0xBB 5 B!  OVER +  DER-TLV
   IF   ( tag val-a val-u next-a )
      B 5 + =  SWAP 2 = AND  SWAP B 3 + = AND  SWAP 4 = AND
      S" long form: length decoded from its length octets" OK?
   ELSE FALSE S" long-form TLV parses" OK? THEN ;

\ ---- the hostile cases: each MUST return FALSE ----------------------------------------------
: T-TAG-ONLY      0x30 1 B! OVER + DER-TLV 0= S" reject: tag byte with no length byte" OK? ;
: T-NO-CONTENT    0x04 0x05 2 B! OVER + DER-TLV 0= S" reject: length 5 but no content at all" OK? ;
: T-SHORT-CONTENT 0x04 0x05 0xAA 0xBB 4 B! OVER + DER-TLV 0=
                  S" reject: length 5 with only 2 content bytes" OK? ;
: T-INDEFINITE    0x30 0x80 0xAA 3 B! OVER + DER-TLV 0=
                  S" reject: indefinite length (0x80) -- not valid DER" OK? ;
: T-LEN-TRUNC     0x04 0x82 0xFF 3 B! OVER + DER-TLV 0=
                  S" reject: 2 length octets promised, 1 present" OK? ;
: T-LEN-HUGE      0x04 0x82 0xFF 0xFF 4 B! OVER + DER-TLV 0=
                  S" reject: length 65535 in a 4-byte buffer" OK? ;
: T-LEN-TOOMANY   0x04 0x89 0 0 0 0 0 0 0 0 0 11 B! OVER + DER-TLV 0=
                  S" reject: 9 length octets (cannot fit a cell)" OK? ;
: T-LEN-SIGNBIT   0x04 0x88 0xFF 0xFF 0xFF 0xFF 0xFF 0xFF 0xFF 0xFF 10 B! OVER + DER-TLV 0=
                  S" reject: length with the sign bit set" OK? ;
: T-EMPTY         B B DER-TLV 0= S" reject: empty buffer (a = end)" OK? ;

: T-SPKI-TRUNCATED                                   \ every prefix of a real cert must fail cleanly
   TRUE  /CERT 0 ?DO  CERT I DER-SPKI IF 2DROP DROP FALSE THEN  LOOP
   S" every truncated prefix of the cert is rejected, no crash" OK? ;
: T-SPKI-GARBAGE
   B 64 ERASE  B 64 DER-SPKI 0=  S" reject: all-zero buffer" OK?
   0xFF 0xFF 0xFF 0xFF 4 B! DER-SPKI 0=  S" reject: 0xFF garbage" OK?
   0x31 0x02 0x30 0x00 4 B! DER-SPKI 0=  S" reject: outer tag is SET, not SEQUENCE" OK? ;
: T-SPKI-ZEROLEN  CERT 0 DER-SPKI 0= S" reject: zero-length buffer" OK? ;

: RUN
   CR ." === der.f unit tests ===" CR
   T-WELLFORMED T-SHORTFORM T-LONGFORM
   T-TAG-ONLY T-NO-CONTENT T-SHORT-CONTENT T-INDEFINITE
   T-LEN-TRUNC T-LEN-HUGE T-LEN-TOOMANY T-LEN-SIGNBIT T-EMPTY
   T-SPKI-TRUNCATED T-SPKI-GARBAGE T-SPKI-ZEROLEN
   CR #FAIL @ IF ." FAILURES: " #FAIL @ . ELSE ." all der.f tests passed" THEN CR ;
RUN
BYE
