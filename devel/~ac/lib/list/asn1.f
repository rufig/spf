\ Справочник OIDs: http://www.alvestrand.no/objectid/1.2.840.113549.1.9.1.html
\ http://www.oid-info.com/cgi-bin/display?tree=1.2.840.113549.1.1.4&see=all

REQUIRE >UTF8  ~ac/lib/lin/iconv/iconv.f 

\ basic ASN.1 types
1 CONSTANT ASN_BOOLEAN
2 CONSTANT ASN_INTEGER \ (ASN_UNIVERSAL | ASN_PRIMITIVE | 0x02)
3 CONSTANT ASN_BITS
4 CONSTANT ASN_OCTETSTRING
5 CONSTANT ASN_NULL
6 CONSTANT ASN_OBJECTIDENTIFIER

\ string types
0x0C CONSTANT UTF8_STRING
0x13 CONSTANT PRINTABLE_STRING
0x14 CONSTANT TELETEX_STRING \ openssl записывает так utf8-строки...
0x16 CONSTANT IA5_STRING     \ например email
0x17 CONSTANT UTCTime        \ например 100329134908Z
0x1E CONSTANT UNICODE_STRING \ BMPString

\ constructed types

0x00 CONSTANT ASN_UNIVERSAL
0x40 CONSTANT ASN_APPLICATION
0x80 CONSTANT ASN_CONTEXT
0xC0 CONSTANT ASN_PRIVATE

0x00 CONSTANT ASN_PRIMITIVE
0x20 CONSTANT ASN_CONSTRUCTOR

0x30 CONSTANT ASN_SEQUENCE \ (ASN_UNIVERSAL | ASN_CONSTRUCTOR | 0x10)
0x31 CONSTANT ASN_SET

\ #define SNMP_PDU_GET                (ASN_CONTEXT | ASN_CONSTRUCTOR | 0x0)
\ #define SNMP_PDU_GETNEXT            (ASN_CONTEXT | ASN_CONSTRUCTOR | 0x1)
\ #define SNMP_PDU_RESPONSE           (ASN_CONTEXT | ASN_CONSTRUCTOR | 0x2)
\ #define SNMP_PDU_SET                (ASN_CONTEXT | ASN_CONSTRUCTOR | 0x3)
\ #define SNMP_PDU_V1TRAP             (ASN_CONTEXT | ASN_CONSTRUCTOR | 0x4)
\ #define SNMP_PDU_GETBULK            (ASN_CONTEXT | ASN_CONSTRUCTOR | 0x5)
\ #define SNMP_PDU_INFORM             (ASN_CONTEXT | ASN_CONSTRUCTOR | 0x6)
\ #define SNMP_PDU_TRAP               (ASN_CONTEXT | ASN_CONSTRUCTOR | 0x7)

\ #define ASN_IPADDRESS               (ASN_APPLICATION | ASN_PRIMITIVE | 0x00)
\ #define ASN_COUNTER32               (ASN_APPLICATION | ASN_PRIMITIVE | 0x01)
\ #define ASN_GAUGE32                 (ASN_APPLICATION | ASN_PRIMITIVE | 0x02)
\ #define ASN_TIMETICKS               (ASN_APPLICATION | ASN_PRIMITIVE | 0x03)
\ #define ASN_OPAQUE                  (ASN_APPLICATION | ASN_PRIMITIVE | 0x04)
\ #define ASN_COUNTER64               (ASN_APPLICATION | ASN_PRIMITIVE | 0x06)
\ #define ASN_UINTEGER32              (ASN_APPLICATION | ASN_PRIMITIVE | 0x07)
\ #define ASN_RFC2578_UNSIGNED32      ASN_GAUGE32


: AsnStrDer> { a u \ u2 l z lz -- a2 u2 }
  a C@ 128 = IF a 1+ -1 EXIT THEN \ indefinite form - до end-of-contents octets
  a C@ DUP 128 < IF a 1+ SWAP EXIT THEN
  \ а для 128 и более байтов в asn.1 требуется 2 или более байтов на длину
  \ 0x81 0x80 - представление длины 128
  127 AND DUP -> u2 \ длина длины
  0 ?DO
    a 1+ I + C@ l 8 LSHIFT + -> l
  LOOP
  a 1+ u2 + l
;
: AsnStr> { a u \ u2 l i -- a2 u2 }
\ преобразует строку с asn1-счетчиком (a) в форт-строку a2 u2
\ см. ту же функцию asn_str> в ~ac/lib/lin/asn1/tasn1.f 
  a C@ 128 <> IF a u AsnStrDer> EXIT THEN
  a 1+ -> a u 1- -> u
  BEGIN
    a l + W@ 0= IF 
                  l 2+ -> l i 1- -> i
                  i 0 > 0= IF a l EXIT THEN
                THEN
    l 1+ -> l \ пропуск тега
    a l + u l - AsnStrDer> DUP -1 =
    IF 2DROP l 1+ -> l i 1+ -> i
    ELSE
       DUP 0=
       IF 2DROP l 1- -> l
       ELSE + a - -> l THEN
    THEN
  AGAIN
;

USER uAsnLevel

: OID. ( a u -- )
  OVER C@ 40 /MOD 0 
  ." OID=" <# #S #> TYPE ." ." 0 <# #S #> TYPE ." ."
  1- 0 MAX SWAP 1+ SWAP
  BEGIN
    DUP 0 >
  WHILE
    OVER C@ DUP 128 <
    IF
      0 <# #S #> TYPE ." ."
      1- SWAP 1+ SWAP
    ELSE
      127 AND 7 LSHIFT >R
      BEGIN
        OVER 1+ C@ DUP 127 >
      WHILE
        127 AND R> + 7 LSHIFT >R
        1- SWAP 1+ SWAP
      REPEAT
      127 AND R> + 0 <# #S #> TYPE ." ."
      2- SWAP 2+ SWAP
    THEN
  REPEAT 2DROP
;

: INT. ( a u -- )
  0 SWAP
  0 ?DO
    OVER I + C@ SWAP 8 LSHIFT +
  LOOP . DROP
;
VECT vAsn1Read

: BITS. ( a u -- )
  BASE @ >R 2 BASE ! INT. R> BASE !
EXIT
  DUP 0= IF 2DROP EXIT THEN
  10 MIN DUMP
;
: OCT. ( a u -- )
\  BASE @ >R 2 BASE ! INT. R> BASE !
  DUP 0= IF 2DROP EXIT THEN
  OVER C@ ASN_SEQUENCE =
  IF ." [embed seq]" CR CR vAsn1Read
  ELSE OVER C@ IA5_STRING =
    IF ." [embed ia5]" CR CR vAsn1Read
    ELSE 30 MIN TYPE ( DUMP) THEN
  THEN
;
: ASN. { a u t -- }
  t 0x3F AND -> t
  t ASN_OBJECTIDENTIFIER = IF a u OID. EXIT THEN
  t ASN_INTEGER = IF a u INT. EXIT THEN
  t ASN_BITS = IF a u BITS. EXIT THEN
  t ASN_OCTETSTRING = IF a u OCT. EXIT THEN
  a u
  t TELETEX_STRING =
  IF UTF8> THEN TYPE
;

: Asn1Read { a u \ a2 u2 t -- }
  uAsnLevel 1+!
  TRUE -> t
  BEGIN
    u 1 >
    t AND \ страховка от неправильного формата
  WHILE
    uAsnLevel @ 1- 0 MAX 0 ?DO ."  |" LOOP
    a C@ DUP -> t ." 0x" HEX . DECIMAL
    a 1+ u 1- AsnStr> -> u2 -> a2
    ." (" u2 . ." ) "
    t ASN_CONSTRUCTOR AND IF CR a2 u2 RECURSE ELSE a2 u2 t ASN. CR THEN
    a2 u2 + a u + OVER - -> u -> a
  REPEAT
  uAsnLevel @ 1- uAsnLevel !
;
' Asn1Read TO vAsn1Read
