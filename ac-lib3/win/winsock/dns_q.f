\ RFC1035

REQUIRE GetDNS  ~ac/lib/win/winsock/get_dns.f
REQUIRE WriteTo ~ac/lib/win/winsock/sockname.f

\  +---------------------+
\  |        Header       |
\  +---------------------+
\  |       Question      | the question for the name server
\  +---------------------+
\  |        Answer       | RRs answering the question
\  +---------------------+
\  |      Authority      | RRs pointing toward an authority
\  +---------------------+
\  |      Additional     | RRs holding additional information
\  +---------------------+
\ RR = "resource record"

0
2 -- HeaderID       \ "номер запроса" (в ответе будет он же)
2 -- HeaderBits     \ набор битовых флагов
2 -- HeaderQDCOUNT  \ number of entries in the question section.
2 -- HeaderANCOUNT  \ number of resource records in the answer section
2 -- HeaderNSCOUNT  \ number of name server resource records in the authority records section.
2 -- HeaderARCOUNT  \ number of resource records in the additional records section.
CONSTANT /Header

USER DNSQUERY
USER DNSREPLY
USER QID
USER DDP
USER REP
USER BS
VARIABLE DNS-SERVER
USER IS-SUCCESS
USER ATTEMPTS
USER RLIST
USER CURRENT-R
VARIABLE DnsDebug

  1 CONSTANT TYPE-A
  2 CONSTANT TYPE-NS
  5 CONSTANT TYPE-CNAME
  6 CONSTANT TYPE-SOA
 12 CONSTANT TYPE-PTR
 15 CONSTANT TYPE-MX
 16 CONSTANT TYPE-TXT
252 CONSTANT QTYPE-AXFR
  1 CONSTANT CLASS-IN
255 CONSTANT QCLASS-ANY
10000 CONSTANT /DNSREPLY

: >B<
  256 /MOD SWAP 256 * +
;

: TOKEN, ( addr u -- )
  DUP DDP @ C! DDP 1+!
  DDP @ SWAP DUP DDP +! MOVE
;

: WT, ( x -- )
  >B< DDP @ W! DDP 1+! DDP 1+!
;

: HOLDS ( addr u -- )
  SWAP OVER + SWAP 0 ?DO DUP I - 1- C@ HOLD LOOP DROP
;

: -s
  HERE DNS-SERVER ! BL WORD ", 0 C,
;

0
4 -- RLnext
4 -- RLname
4 -- RLtype
4 -- RLhost
4 -- RLparam1
CONSTANT /RL

: XCOUNT
  DUP @ SWAP CELL+ SWAP
;

: FreeField ( af -- )
  DUP @ ?DUP IF FREE THROW THEN 0!
;

: GetFieldData ( af -- addr u )
  @ ?DUP IF XCOUNT ELSE S" " THEN
;

: SetFieldData ( addr u af -- )
  { a u af \ mem }
  af FreeField
  u CELL+ ALLOCATE THROW -> mem
  u mem ! a mem CELL+ u MOVE
  mem af !
;

: AddName ( addr u -- )
  /RL ALLOCATE THROW >R
  R@ /RL ERASE
  R@ RLname SetFieldData
  RLIST @ R@ RLnext !
  R@ RLIST !
  R> CURRENT-R !
;
: FreeRlist
  RLIST @
  BEGIN
    DUP
  WHILE
    DUP RLnext @ SWAP FREE DROP
  REPEAT RLIST !
;
: PrintRL ( addr -- )
  >R
  R@ RLname GetFieldData TYPE SPACE
  R@ RLtype @ DUP TYPE-MX = IF DROP ." MX " ELSE . THEN
  R@ RLhost GetFieldData TYPE SPACE
  R@ RLparam1 @ .
  R> DROP
;
: PrintRLIST ( -- )
  RLIST @
  BEGIN
    DUP
  WHILE
    DUP PrintRL CR
    RLnext @
  REPEAT DROP
;
: PrintReceivedMXs ( -- )
  RLIST @
  BEGIN
    DUP
  WHILE
    DUP RLtype @ TYPE-MX =
    IF DUP PrintRL CR THEN
    RLnext @
  REPEAT DROP
;
: EnumReceivedMXs ( -- n )
  0 >R
  RLIST @
  BEGIN
    DUP
  WHILE
    DUP RLtype @ TYPE-MX =
    IF R> 1+ >R THEN
    RLnext @
  REPEAT DROP
  R>
;

: PrepareDnsQuery ( qtype addr u -- )

  DNSQUERY @ 0= IF 500 ALLOCATE THROW DNSQUERY ! THEN
  DNSQUERY @ 500 ERASE
  DNSREPLY @ ?DUP IF /DNSREPLY ERASE THEN

  FreeRlist
  QID 1+! QID W@ >B< DNSQUERY @ HeaderID W!

  \ HeaderBits =0 в обычных нерекурсивных запросах
  1 DNSQUERY @ HeaderBits C! \ RD - recurse desired

  1 >B< DNSQUERY @ HeaderQDCOUNT W!

  \ больше в запросе нет секций
  \ дальше за заголовком идут QNAME QTYPE QCLASS

  DNSQUERY @ /Header + DDP !
  BEGIN
    DUP
  WHILE
    2DUP S" ." SEARCH
    IF ( addr u addr-d u-rem )
       1- >R NIP ( addr addr-d  R: u-rem-1 )
       DUP 1+ >R
       OVER - ( адрес длина_токена_имени    R: длина_остатка адрес_остатка )
       TOKEN,
       R> R>
    ELSE 2DROP TOKEN, HERE 0 THEN
  REPEAT TOKEN,
  WT, QCLASS-ANY WT,
;

: SendDnsQuery
  DNS-SERVER @ 0= 
  IF GetDNS ?DUP 
            IF COUNT + 1+ DNS-SERVER !
            ELSE C" localhost" DNS-SERVER ! THEN
  THEN
  DNS-SERVER @ COUNT GetHostIP THROW 53
  DNSQUERY @ DDP @ OVER - \ 2DUP DUMP
  BS @ WriteTo
;

: PrintName
  BEGIN
     REP @ C@ DUP 0 > DEPTH 30 < AND
  WHILE
    64 > 
    IF REP @ DUP >R W@ >B< 255 AND DNSREPLY @ + REP ! RECURSE R> REP ! 2 REP +!
       EXIT
    ELSE REP @ COUNT 2DUP + REP ! TYPE ." ." THEN
  REPEAT DROP
  SPACE REP 1+!
;
: ParseName1 ( -- ... )
  BEGIN
     REP @ C@ DUP 0 > DEPTH 30 < AND
  WHILE
    64 > 
    IF REP @ DUP >R W@ >B< 255 AND DNSREPLY @ + REP ! RECURSE R> REP ! 2 REP +!
       EXIT
    ELSE REP @ COUNT 2DUP + REP ! THEN
  REPEAT DROP
  REP 1+!
;
: ParseName ( -- addr u )
  HERE 0
  ParseName1
  0 0 <# 2DROP
  BEGIN
    DUP
  WHILE
    HOLDS [CHAR] . HOLD
  REPEAT
  #>
  1- SWAP 1+ SWAP 0 MAX
;
: ParseAddName ( -- )
  ParseName AddName
;

: PrintType
  ." Type=" REP @ W@ >B< . 2 REP +!
;

: ParseType
  REP @ W@ >B< 2 REP +!
  CURRENT-R @ ?DUP IF RLtype ! ELSE DROP THEN
;

: PrintClass
  ." Class=" REP @ W@ >B< . 2 REP +!
;

: ParseClass
  2 REP +!
;

: PrintTTL
  ." TTL=" REP @ @ . 4 REP +!
;

: ParseTTL
  4 REP +!
;

: NextRD
  REP @ W@ >B< 2 + REP +!
;

: PrintRD
  CR ." RD="
  REP @ 8 - W@ >B< TYPE-MX =

  IF ." MX Pref="
     REP @ 2 + W@ >B< . ." Host="
     REP @ DUP >R 4 + REP ! PrintName R> REP ! CR
     NextRD EXIT
  THEN

  REP @ 8 - W@ >B< TYPE-A =
  IF ." A IP="
     REP @ 2 + @ NtoA TYPE CR NextRD EXIT
  THEN

  REP @ 8 - W@ >B< TYPE-NS =
  IF ." NS Host="
     REP @ DUP >R 2 + REP ! PrintName R> REP ! CR
     NextRD EXIT
  THEN

  REP @ W@ >B< DUP . 2 REP +!
  REP @ OVER CR DUMP CR
  REP +!
;

: ParseRD

  REP @ 8 - W@ >B< TYPE-MX =
  IF 
     REP @ 2 + W@ >B< CURRENT-R @ RLparam1 ! 
     REP @ DUP >R 4 + REP ! ParseName CURRENT-R @ RLhost SetFieldData
     R> REP !
     NextRD EXIT
  THEN

  NextRD
;

: PrintDnsQuestions ( n -- )
  ." Questions:" CR
  0 DO
    PrintName
    PrintType
    PrintClass CR
  LOOP CR
;
: ParseDnsQuestions ( n -- )
  0 DO
    ParseName 2DROP
    ParseType
    ParseClass
  LOOP
;

: PrintDnsAnswers ( n -- )
  0 DO
    PrintName
    PrintType
    PrintClass
    PrintTTL
    PrintRD CR
  LOOP CR
;
: ParseDnsAnswers ( n -- )
  0 DO
    ParseAddName
    ParseType
    ParseClass
    ParseTTL
    ParseRD
  LOOP
;

: PrintDnsReply
  DNSREPLY @ >R
  R@ HeaderID W@ >B< QID W@ <> IF ." ID mismatch." CR R> DROP EXIT THEN
  CR
  ." ReplyBits: " R@ HeaderBits W@ >B< 2 BASE ! U. 10 BASE ! CR
  ." Questions: " R@ HeaderQDCOUNT W@ >B< . CR \ number of entries in the question section.
  ." Answers: " R@ HeaderANCOUNT W@ >B< . CR \ number of resource records in the answer section
  ." NS RRs: " R@ HeaderNSCOUNT W@ >B< . CR \ number of name server resource records in the authority records section.
  ." Additional: " R@ HeaderARCOUNT W@ >B< . CR \ number of resource records in the additional records section.
  R@ /Header + REP !
  R@ HeaderQDCOUNT W@ >B< ?DUP IF PrintDnsQuestions THEN
  R@ HeaderANCOUNT W@ >B< ?DUP IF ." Answers:" CR PrintDnsAnswers THEN
  R@ HeaderNSCOUNT W@ >B< ?DUP IF ." NS RRs:" CR PrintDnsAnswers THEN
  R@ HeaderARCOUNT W@ >B< ?DUP IF ." Additional:" CR PrintDnsAnswers THEN
  R> DROP
;
: ParseDnsReply
  ( RLIST 0!) FreeRlist CURRENT-R 0!
  DNSREPLY @ >R
  R@ /Header + REP !
  R@ HeaderQDCOUNT W@ >B< ?DUP IF ParseDnsQuestions THEN
  R@ HeaderANCOUNT W@ >B< ?DUP IF ParseDnsAnswers THEN
  R@ HeaderNSCOUNT W@ >B< ?DUP IF ParseDnsAnswers THEN
  R@ HeaderARCOUNT W@ >B< ?DUP IF ParseDnsAnswers THEN
  R> DROP
;

: RecvDnsReply
  DNSREPLY @ 0=
  IF /DNSREPLY ALLOCATE THROW DNSREPLY ! THEN
  DNSREPLY @ /DNSREPLY ERASE
  DNSREPLY @ /DNSREPLY BS @ ReadFrom
  DnsDebug @ 0=
  IF 2DROP DROP 
  ELSE . . DNSREPLY @ SWAP ( 23 16 *) /DNSREPLY MIN DUMP CR PrintDnsReply CR THEN
;

: host ( type "dns-server" "host" -- )
  SocketsStartup DROP
  CreateUdpSocket THROW BS !
  8000 BS @ SetSocketTimeout THROW
  BL WORD HERE SWAP ", 0 C, DNS-SERVER !
  BL PARSE  PrepareDnsQuery
  BEGIN
    ['] SendDnsQuery CATCH ?DUP IF ." SEND-RESULT=" . THEN
    ['] RecvDnsReply CATCH CR DUP ." RECV-RESULT=" . CR 0=
    DUP IF ParseDnsReply PrintReceivedMXs THEN
    DNSREPLY @ HeaderBits W@ >B< 15 AND 0= AND
    DNSREPLY @ HeaderID W@ >B< QID W@ = AND
    DUP IS-SUCCESS !
    ATTEMPTS 1+!
    ATTEMPTS @ 6 > OR
  UNTIL
  IS-SUCCESS @ .
;

USER DNS-FAIL
VARIABLE Verbose?
TRUE Verbose? !

: DnsValidateEmailDomain ( addr u -- flag )
  { a u }
  u 7 < IF FALSE EXIT THEN
  a u S" @" SEARCH
  IF 1- SWAP 1+ SWAP -> u -> a THEN
  FALSE DNS-FAIL !
  ATTEMPTS 0!
  TYPE-MX a u PrepareDnsQuery
  BEGIN
    ['] SendDnsQuery CATCH ?DUP 
        IF Verbose? @ IF 
             CR ." Can't send DNS request (err=)" . 
           THEN
           TRUE DNS-FAIL !
        ELSE ( ." .") THEN
    ['] RecvDnsReply CATCH
    ?DUP IF DUP 10060 = 
            IF DROP Verbose? @ IF ." timeout " THEN
            ELSE Verbose? @ IF . ELSE DROP THEN 
            THEN FALSE 
         ELSE TRUE THEN
    DUP IF ParseDnsReply THEN
    DNSREPLY @ HeaderBits W@ >B< 15 AND 0= AND
    DNSREPLY @ HeaderID W@ >B< QID W@ = AND
    DUP IS-SUCCESS !
    ATTEMPTS 1+!
    ATTEMPTS @ 6 > OR
  UNTIL
  IS-SUCCESS @ 
  IF Verbose? @ IF CR PrintReceivedMXs THEN
     EnumReceivedMXs 
     IF TRUE
     ELSE \ ." Empty MX list."
        FALSE
     THEN
  ELSE 1 ( ошибка DNS, принимаем все Email) THEN
;
: DnsValidateList ( addr u -- )
  SocketsStartup DROP
  CreateUdpSocket THROW BS !
  8000 BS @ SetSocketTimeout THROW
  R/O OPEN-FILE THROW >R
  BEGIN
    TIB C/L R@ READ-LINE THROW
  WHILE
    #TIB ! >IN 0!
\    [CHAR] @ WORD DROP
    NextWord 2DUP TYPE SPACE
    DnsValidateEmailDomain . CR
  REPEAT DROP
  R> CLOSE-FILE THROW
;

: GetMXs ( domaina domainu -- flag )
  IS-SUCCESS 0! DnsValidateEmailDomain IS-SUCCESS @
  EnumReceivedMXs 0<> AND
;
: NextMX ( -- servera serveru true | false )
  { \ pref mx }
  70000 -> pref
  RLIST @
  BEGIN
    DUP
  WHILE
    DUP RLtype @ TYPE-MX =
    IF
      DUP RLparam1 @ DUP pref < IF -> pref DUP -> mx ELSE DROP THEN
    THEN
    RLnext @
  REPEAT DROP
  pref 70000 = IF FALSE EXIT THEN
  70001 mx RLparam1 !
  mx RLhost GetFieldData TRUE
;

\ TYPE-MX host main.svlm.com swr.da.ru

\ -s ns1.granitecanyon.com
\ -s eserv.ru

Verbose? 0! S" C:\eserv2\mail\lists\eserv_drweb.txt" DnsValidateList
