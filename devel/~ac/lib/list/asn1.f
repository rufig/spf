\ Парсер для двоичного представления ASN.1-структур.
\ X.690 Information technology - ASN.1 encoding rules:
\ Specification of Basic Encoding Rules (BER),
\ Canonical Encoding Rules (CER) and
\ Distinguished Encoding Rules (DER)

\ Нумерация тегов указана в тексте самого ASN.1, стр.22
\ X.680 Information technology - Abstract Syntax
\ Notation One (ASN.1): Specification of basic
\ notation

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
0x0C CONSTANT ASN_UTF8_STRING
0x13 CONSTANT ASN_PRINTABLE_STRING
0x14 CONSTANT ASN_TELETEX_STRING \ openssl записывает так utf8-строки...
0x16 CONSTANT ASN_IA5_STRING     \ например email
0x17 CONSTANT ASN_UTCTime        \ например 100329134908Z
0x1E CONSTANT ASN_UNICODE_STRING \ BMPString


\ другие, из которых в поле встречается только enum
   7 CONSTANT ASN_OBJECTDESCRIPTOR
   8 CONSTANT ASN_EXTERNAL
   9 CONSTANT ASN_REAL
0x0A CONSTANT ASN_ENUM
0x0B CONSTANT ASN_EMBED
0x0D CONSTANT ASB_REL_OID
\ 0x0E, 0x0F reserved
\ 0x10 - см. sequence

\ constructed types

\ fixme: константы ASN_* частично пересекаются с ~ac/lib/win/snmp/snmp.f,
\        но не являются ни windows-, ни snmp- специфичными, поэтому надо 
\        перенести всё сюда

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
: >ASN_OID { a u \ s -- a2 u2 }
  a u OVER C@ 40 /MOD 0 
  "" -> s <# #S #> s STR+ S" ." s STR+ 0 <# #S #> s STR+ S" ." s STR+
  1- 0 MAX SWAP 1+ SWAP
  BEGIN
    DUP 0 >
  WHILE
    OVER C@ DUP 128 <
    IF
      0 <# #S #> s STR+ S" ." s STR+
      1- SWAP 1+ SWAP
    ELSE
      127 AND 7 LSHIFT >R
      BEGIN
        OVER 1+ C@ DUP 127 >
      WHILE
        127 AND R> + 7 LSHIFT >R
        1- SWAP 1+ SWAP
      REPEAT
      127 AND R> + 0 <# #S #> s STR+ S" ." s STR+
      2- SWAP 2+ SWAP
    THEN
  REPEAT 2DROP
  s STR@ 1- 0 MAX
;

: AsnInt@ ( a u -- x ) \ переполнение отбрасывается
  0 SWAP
  0 ?DO
    OVER I + C@ SWAP 8 LSHIFT +
  LOOP NIP
;
: INT. ( a u -- )
  AsnInt@ .
;
VECT vAsn1Parse

: BITS. ( a u -- )
  BASE @ >R 2 BASE ! INT. R> BASE !
EXIT \ слишком длинные бывают :)
  DUP 0= IF 2DROP EXIT THEN
  10 MIN DUMP
;
: OCT. ( a u -- )
\  BASE @ >R 2 BASE ! INT. R> BASE !
  DUP 0= IF 2DROP EXIT THEN

  70 MIN PTYPE  EXIT
  \ наличие вложенных в octet_string объектов зависит от схемы
  \ и парсить их по умолчанию не требуется
  OVER C@ ASN_SEQUENCE =
  IF ." [embed seq]" CR CR vAsn1Parse DROP
  ELSE OVER C@ ASN_IA5_STRING =
    IF ." [embed ia5]" CR CR vAsn1Parse DROP
    ELSE 70 MIN TYPE ( DUMP) THEN
  THEN
;
: ASN. { a u t -- }
  t 0x3F AND -> t
  t ASN_OBJECTIDENTIFIER = IF a u OID. EXIT THEN
  t ASN_INTEGER = IF a u INT. EXIT THEN
  t ASN_ENUM = IF a u INT. EXIT THEN
  t ASN_BITS = IF a u BITS. EXIT THEN
  t ASN_OCTETSTRING = IF a u OCT. EXIT THEN
  a u
  t ASN_TELETEX_STRING =
  IF UTF8> THEN TYPE
;

VARIABLE AsnDebug \ TRUE AsnDebug !

0
CELL -- asNextPart \ связь элементов того же уровня
CELL -- asTag
CELL -- asAddr     \ весь целиком
CELL -- asLen
CELL -- asPartAddr \ без учета заголовка
CELL -- asPartLen
CELL -- asLevel    \ уровень вложенности
CELL -- asIndex    \ номер на уровне
CELL -- asIsMultipart \ является ли составным
CELL -- asParts    \ голова списка вложенных элементов
CELL -- asChilds#  \ к-во вложенных элементов (на одном уровне)
CELL -- asPar      \ верхний уровень
CELL -- asOID      \ символьное представление OID при tag=ASN_OBJECTIDENTIFIER
CELL -- asName     \ символическое имя, составленное из порядковых номеров
                   \ на каждом уровне иерархии (подобно нумерации MIME-частей в IMAP)
                   \ - для поиска по именам вида "ASN.1.3.2"
CELL -- asEvalRes  \ фильтры в LDAP представлены в виде ASN.1-деревьев,
                   \ это поле используем для "подъема" результов вычисления
                   \ фильтров от листьев к корню
CONSTANT /AsnPart


: Asn1ParseR { a u par prev \ a2 u2 t n as -- }

  uAsnLevel 1+!
  TRUE -> t
  BEGIN
    u 1 >
    t AND \ страховка от неправильного формата
  WHILE
    n 1+ -> n
    par asChilds# 1+!
    /AsnPart ALLOCATE THROW -> as
    prev IF
      as prev asNextPart ! \ связываем в прямом порядке, а не в фортовом обратном
    ELSE
      as par asParts !
    THEN
    par as asPar !
    uAsnLevel @ 1- as asLevel !
    a as asAddr !
    u as asLen !
    a C@ DUP -> t
      as asTag !
    n as asIndex !
    n par asName @ STR@ " {s}.{n}" as asName !
    AsnDebug @ IF uAsnLevel @ 1- 0 MAX 0 ?DO ."  |" LOOP THEN
    AsnDebug @ IF t ." 0x" HEX . DECIMAL THEN
    a 1+ u 1- AsnStr> -> u2 -> a2
    AsnDebug @ IF ." (" u2 . ." ) " THEN
    a2 as asPartAddr !
    u2 as asPartLen !
    t ASN_CONSTRUCTOR AND 
    IF AsnDebug @ IF CR THEN
       TRUE as asIsMultipart !
       a2 u2 as 0 RECURSE
    ELSE
       AsnDebug @ IF a2 u2 t ASN. CR THEN
    THEN
    t ASN_OBJECTIDENTIFIER = IF a2 u2 >ASN_OID as asOID S! THEN
    a2 u2 + a u + OVER - -> u -> a
    as -> prev
  REPEAT
  uAsnLevel @ 1- uAsnLevel !
;
: Asn1Parse { a u \ as -- as }
  \ в "a u" на уровне корня может быть несколько
  \ элементов, поэтому надо создать псевдокорень со счетчиком asChilds#.
  \ Возвращается корень списка.
  \ Если вызвавшей функции нужны свойства псевдокорня,
  \ можно получить его через asPar @.
  /AsnPart ALLOCATE THROW -> as
  uAsnLevel @ as asLevel !
  a as asAddr !
  u as asLen !
  a C@ as asTag !
  " ASN" as asName !

  a u as 0 Asn1ParseR
  as asParts @
;
' Asn1Parse TO vAsn1Parse

: Asn1Dump { as -- }
  as 0= IF EXIT THEN
  BEGIN
    as asLevel @ 0 ?DO ."  |" LOOP
    as asIndex @ . ." |"
    as asTag @ ." 0x" HEX . DECIMAL
    as asPartLen @ ." (" . as asName @ STR@ TYPE ." ) "
    as asIsMultipart @
    IF CR as asParts @ RECURSE
    ELSE
       as asPartAddr @ as asPartLen @ as asTag @ ASN. CR
    THEN
    as asNextPart @ DUP 0=
    SWAP -> as
  UNTIL
;
: Asn1GetPart { pna pnu as -- as2 }
  \ найти элемент по ASN.n.n-имени
  \ если такого нет, возвращается 0
  as 0= IF 0 EXIT THEN
  BEGIN
    as asName @ STR@ pna pnu COMPARE 0=
    IF as EXIT THEN
    as asIsMultipart @
    IF pna pnu as asParts @ RECURSE
       ?DUP IF EXIT THEN
    THEN
    as asNextPart @ DUP 0=
    SWAP -> as
  UNTIL
  0
;
: Asn1GetContent { as -- a u }
  as asPartAddr @
  as asPartLen @
;
: Asn1GetPartContent { pna pnu as -- a u tag }
  pna pnu as Asn1GetPart ?DUP
  IF -> as
     as Asn1GetContent
     as asTag @
  ELSE S" " 0 THEN
;
: Asn1GetPartByOID { oida oidu as -- as2 }
  \ найти элемент по OID
  \ если такого нет, возвращается 0
  as 0= IF 0 EXIT THEN
  BEGIN
    as asOID @ ?DUP IF STR@ oida oidu COMPARE 0= ELSE FALSE THEN
    IF as EXIT THEN
    as asIsMultipart @
    IF oida oidu as asParts @ RECURSE
       ?DUP IF EXIT THEN
    THEN
    as asNextPart @ DUP 0=
    SWAP -> as
  UNTIL
  0
;

\ Asn1GetValueByOID ищет в ASN1-дереве значение (RU) по OID (2.5.4.6) такой пары
\ | | | |1 |0x30 (9 ASN.1.1.2.1.1) 
\ | | | | |1 |0x6 (3 ASN.1.1.2.1.1.1) OID=2.5.4.6.
\ | | | | |2 |0x13 (2 ASN.1.1.2.1.1.2) RU
\ результат в кодировке windows-1251

: Asn1GetValueByOID ( oida oidu as -- a u )
  DUP 0= IF DROP 2DROP S" " EXIT THEN
  Asn1GetPartByOID ?DUP
  IF asNextPart @ ?DUP
     IF DUP Asn1GetContent ROT
        asTag @ ASN_UNICODE_STRING = IF BUNICODE> THEN
     ELSE S" " THEN
  ELSE S" " THEN
;

\ Asn1GetPairValueByOID ищет в ASN1-дереве значение (bits) по OID (1.2.840.113549.1.1.1) такой пары
\ | |3 |0x30 (290 ASN.1.1.3) 
\ | | |1 |0x30 (13 ASN.1.1.3.1) 
\ | | | |1 |0x6 (9 ASN.1.1.3.1.1) OID=1.2.840.113549.1.1.1.
\ | | | |2 |0x5 (0 ASN.1.1.3.1.2) 
\ | | |2 |0x3 (271 ASN.1.1.3.2) 11000000010000000000000001...

: Asn1GetPairValueByOID ( oida oidu as -- a u )
  DUP 0= IF DROP 2DROP S" " EXIT THEN
  Asn1GetPartByOID ?DUP
  IF asPar @ ?DUP
     IF asNextPart @ ?DUP
        IF DUP Asn1GetContent ROT
           asTag @ ASN_UNICODE_STRING = IF BUNICODE> THEN
        ELSE S" " THEN
     ELSE S" " THEN
  ELSE S" " THEN
;
