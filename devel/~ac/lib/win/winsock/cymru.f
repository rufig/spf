\ Клиент для сервисов cymru http://www.team-cymru.org/
\ И пример работы с DNS :)

REQUIRE GetRRs      ~ac/lib/win/winsock/dns_q.f
REQUIRE >ENDIAN<    ~ac/lib/win/winsock/endian.f
REQUIRE STR@        ~ac/lib/str5.f
REQUIRE UnixTimeRus ~ac/lib/win/date/unixtime.f 

: TXT@ ( addr u -- addr2 u2 )
  OVER C@ OVER < 0= IF DROP COUNT EXIT THEN
  DROP COUNT 2DUP + COUNT 2SWAP " {s}{s}" STR@
;
: GetSubdomainTxt ( da du sa su  -- a u )
  " {s}.{s}" STR@
  TYPE-TXT GetRRs 1 =
  IF
    RLIST @ RLhost GetFieldData TXT@ \ 2DUP TYPE CR
  ELSE S" " THEN
;
: GetOriginASNLine ( ip -- a u )
  S" origin.asn.cymru.com" ROT >ENDIAN< NtoA GetSubdomainTxt
;
: GetPeerASNLine ( ip -- a u )
  S" peer.asn.cymru.com" ROT >ENDIAN< NtoA GetSubdomainTxt
;
: GetASNDescrLine ( as -- )
  S" asn.cymru.com" ROT " AS{n}" STR@ GetSubdomainTxt
;
: GetIpASNDescrLine ( ip -- a u )
  GetOriginASNLine 0 0 2SWAP >NUMBER 2DROP D>S GetASNDescrLine
;
: GetHashDescrLine ( ha hu -- a u )
  S" malware.hash.cymru.com" 2SWAP GetSubdomainTxt
;
: GetHashDateMal ( ha hu -- unixtime percent )
  GetHashDescrLine 0 0 2SWAP >NUMBER 2>R D>S
  2R> 1- 0 MAX SWAP 1+ SWAP 0 0 2SWAP >NUMBER 2DROP D>S
;

\EOF

SocketsStartup THROW
S" forth.org.ru" GetHostIP THROW GetOriginASNLine TYPE CR
S" forth.org.ru" GetHostIP THROW GetPeerASNLine TYPE CR

8774 GetASNDescrLine TYPE CR
8997 GetASNDescrLine TYPE CR
9002 GetASNDescrLine TYPE CR

S" google.com" GetHostIP THROW GetOriginASNLine TYPE CR
S" google.com" GetHostIP THROW GetPeerASNLine TYPE CR

15169 GetASNDescrLine TYPE CR

S" google.com" GetHostIP THROW GetIpASNDescrLine TYPE CR
S" 6ce6f415d8475545be5ba114f208b0ff" GetHashDateMal . UnixTimeRus TYPE CR
S" 7b979f682311ffe1379df559104ce0dc" GetHashDescrLine TYPE CR
