( Библиотека работы с DNS-серверами.
  Протокол DNS описан в RFC1035

  Обновление 19.01.2003:
  добавлено слово GetRRs, являющееся основным средством 
  DNS-запросов вместо прежних более узко специализированных.
  "Прежние" теперь могут быть в основном переписаны через GetRRs :->

  Использование:
  S" domain.name" dns-record-type GetRRs
  Например:
  S" forth.org.ru" TYPE-MX GetRRs

  Результат GetRRs - число полученных записей.
  "Нормальные" ответы - 0,1,2 и т.д. неотрицательные числа.
  Особые ответы:
  -1 - сетевые проблемы [невозможен обмен UDP-пакетами]
     это может быть следствием отсутствия модемной связи, например,
     т.е. просто недоступен целевой сервер. Или невозможно найти имена DNS-серверов.
  -2 - связь вроде есть, но ответы не приходят с 6 попыток - скорее 
     всего очень большие таймауты
  -3 - указанный домен "не существует в природе"
  -5 - DNS-сервер не хочет выполнять ваши запросы [чужой сервер, наверное]

  GetRRn отличается от GetRRs тем, что не разбирает список
  полученных записей, а только выясняет их число, т.е. экономит
  время и память, если не нужен собственно список записей. 
  Ответы все те же.

  Инициализацию сети и поиск подходящего DNS-сервера библиотека
  производит сама при первой необходимости. Но можно указать желаемый
  DNS-сервер опцией "-s сервер".

  Ещё полезные слова:
  DnsValidateDomain      [ domaina domainu -- flag ]
  DnsValidateEmailDomain [ emaila emailu -- flag ]
  Проверяют, является ли домен валидным почтовым доменом,
  т.е. можно ли на него отправлять почту. Это делается запросом
  MX- и A-записей для этого домена. Если есть хотя бы одна, то
  считается валидным. Существование имени user@ в данном домене
  не проверяется, и "отзывчивость" найденных почтовых серверов
  также не проверяется - т.е. собственно попыток почтовых сессий не
  делается. Отрицательные ответы GetRR трактуются как "невалидный
  домен". Т.е. использовать эти слова можно только при рабочем DNS.
  
  DnsDomainExists [ domaina domainu -- flag ]
  Если GetRRn возвращает -3, то домена точно нет. Все остальные
  ответы, в т.ч. отрицательные трактуются как "есть", означающее
  на деле "есть или невозможно проверить из-за проблем DNS или сети".
  Если у домена нет MX- и A-записей, то он также считается несуществующим.

  NextMX [ -- servera serveru true | false ]

  Методика перебора MX-записей по приоритетам для попыток отправки почты.
  S" domain" GetMXs 0 MAX 0 ?DO NextMX ... LOOP

  DnsDomainExists отличается от DnsValidateDomain отношением к
  ошибкам DNS. DnsDomainExists при ошибках НЕ отвергает домен,
  а DnsValidateDomain отвергает. При рабочем DNS они равноценны.
)

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
   3 VALUE vDnsAttempts \ было 6
2000 VALUE vDnsTimeout  \ было 8000

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
  1024 MIN
  SWAP OVER + SWAP 0 ?DO DUP I - 1- C@ HOLD LOOP DROP
;

: -s
  HERE DNS-SERVER ! BL WORD ", 0 ,
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
  u CELL+ CHAR+ ALLOCATE THROW -> mem
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
  ." Name=" R@ RLname GetFieldData TYPE SPACE
  ." Type=" R@ RLtype @ DUP TYPE-MX = IF DROP ." MX " ELSE . THEN
  ." Host=" R@ RLhost GetFieldData TYPE SPACE
  ." Param=" R@ RLparam1 @ .
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
: PrintReceivedRDs ( type -- )
  >R
  RLIST @
  BEGIN
    DUP
  WHILE
    DUP RLtype @ R@ =
    IF DUP PrintRL CR THEN
    RLnext @
  REPEAT DROP
  R> DROP
;

: PrintReceivedMXs ( -- )
  TYPE-MX PrintReceivedRDs
;
: EnumReceivedRDs ( type -- n )
\ имеет смысл только если записи получались не по GetRRs,
\ а другим способом. При GetRRs список и так содержит только записи
\ одного (заказанного :) типа
  0 >R
  RLIST @
  BEGIN
    DUP
  WHILE
    2DUP RLtype @ =
    IF R> 1+ >R THEN
    RLnext @
  REPEAT 2DROP
  R>
;
: EnumReceivedMXs ( -- n )
  TYPE-MX EnumReceivedRDs
;

: PrepareDnsQuery ( qtype addr u -- )
  DNSQUERY @ 0= IF 500 ALLOCATE THROW DNSQUERY ! THEN
  DNSQUERY @ 500 ERASE
\  DNSREPLY @ ?DUP IF /DNSREPLY ERASE THEN

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
    ELSE 2DROP TOKEN, PAD ( HERE) 0 THEN
  REPEAT TOKEN,
  WT, QCLASS-ANY WT,
;

: BsStartup
  SocketsStartup DROP
  CreateUdpSocket THROW BS !
  vDnsTimeout BS @ SetSocketTimeout THROW
;
: BsCloseSocket
  BS @ ?DUP IF CloseSocket DROP BS 0! THEN
;
: SendDnsQuery
  DNS-SERVER @ 0= 
  IF GetDNS ?DUP 
            IF DNS-COUNT @ 1 > IF COUNT + 1+ THEN DNS-SERVER !
            ELSE -11001 THROW THEN \ не найден DNS-сервер
  THEN
  BS @ 0= IF BsStartup THEN
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
  PAD ( HERE) 0
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


  REP @ 8 - W@ >B< TYPE-A =
  IF 
     REP @ 2 + @ NtoA CURRENT-R @ RLhost SetFieldData
     NextRD EXIT
  THEN

  REP @ 8 - W@ >B< TYPE-NS =
  IF
     REP @ DUP >R 2 + REP ! ParseName CURRENT-R @ RLhost SetFieldData
     R> REP !
     NextRD EXIT
  THEN

  REP @ 8 - W@ >B< TYPE-PTR =
  IF
     REP @ DUP >R 2 + REP ! ParseName CURRENT-R @ RLhost SetFieldData
     R> REP !
     NextRD EXIT
  THEN

\  NextRD

  REP @ W@ >B< 2 REP +!
  REP @ OVER CURRENT-R @ RLhost SetFieldData
  REP +!

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
: ParseDnsReply \ всех возвращенных полей, включая дополнительные,
  ( RLIST 0!) FreeRlist CURRENT-R 0!
  DNSREPLY @ >R
  R@ /Header + REP !
  R@ HeaderQDCOUNT W@ >B< ?DUP IF ParseDnsQuestions THEN
  R@ HeaderANCOUNT W@ >B< ?DUP IF ParseDnsAnswers THEN
  R@ HeaderNSCOUNT W@ >B< ?DUP IF ParseDnsAnswers THEN
  R@ HeaderARCOUNT W@ >B< ?DUP IF ParseDnsAnswers THEN
  R> DROP
;
: ParseAnswer \ только полей ответа
  ( RLIST 0!) FreeRlist CURRENT-R 0!
  DNSREPLY @ >R
  R@ /Header + REP !
  R@ HeaderQDCOUNT W@ >B< ?DUP IF ParseDnsQuestions THEN
  R@ HeaderANCOUNT W@ >B< ?DUP IF ParseDnsAnswers THEN
  R> DROP
;

: RecvDnsReply
  DNSREPLY @ 0=
  IF /DNSREPLY ALLOCATE THROW DNSREPLY ! THEN
  DNSREPLY @ /DNSREPLY ERASE
  DNSREPLY @ /DNSREPLY BS @ ReadFrom
  DnsDebug @ 0=
  IF 2DROP DROP 
  ELSE . . DNSREPLY @ SWAP ( 23 16 *) /DNSREPLY MIN DUMP CR 
       PrintDnsReply CR 
  THEN
;
: DNS-SERVER.
  DNS-SERVER @ ?DUP IF COUNT TYPE THEN
;

: NextDNS ( -- flag )
  DNS-SERVERS @ 0= IF GetDNS DUP 
                      IF DUP DNS-SERVER ! DnsDebug @ 
                         IF ." System DNS: " DNS-SERVER @ COUNT TYPE CR THEN
                      THEN EXIT
                   THEN
  DNS-SERVER @ COUNT + 1+
  DUP COUNT NIP 0= IF DROP FALSE EXIT THEN
  DnsDebug @ IF ." Next DNS: " DUP COUNT TYPE CR THEN
  DNS-SERVER ! TRUE
;
: GetRRs { hosta hostu type \ attempts -- n }
  DnsDebug @ IF ." GetRRs: " hosta hostu TYPE CR THEN
  1 -> attempts
  type hosta hostu PrepareDnsQuery
  BEGIN
  BEGIN
    DnsDebug @ IF attempts type hosta hostu ." DNS-QUERY(" DNS-SERVER. ." ): " TYPE ." , type=" . ." , attempt=" . CR THEN
    ['] SendDnsQuery CATCH IF -1 EXIT THEN  \ network problem
    ['] RecvDnsReply CATCH 
    ?DUP IF 10060 <> IF -1 EXIT THEN FALSE ELSE TRUE THEN
    IF 
      DNSREPLY @ HeaderBits W@ >B< 15 AND
      DUP ( RCODE) 3 = IF DROP -3 EXIT THEN \ domain not exist (authoritative!)
      DUP ( RCODE) 5 = IF DROP -5 EXIT THEN \ refused operation
      0=
      DNSREPLY @ HeaderID W@ >B< QID W@ = AND
      IF
        ParseAnswer  DnsDebug @ IF PrintRLIST THEN
        type EnumReceivedRDs
        DUP 0=
        IF
          DNSREPLY @ HeaderBits W@ >B< 128 AND \ RA - recurse available
          0= IF 
               DROP -5 \ сервер не дал ответ, т.к. не содержит этого домена
                       \ а рекурсивный запрос делать не хочет,
                       \ т.е. скорее всего задан чужой DNS-сервер
             THEN
        THEN
        EXIT
      THEN
    THEN
    attempts 1+ DUP -> attempts
    vDnsAttempts >
  UNTIL
  NextDNS 0=
  UNTIL
  -2 \ timeouts or DNS-server failure
;
\ HeaderANCOUNT W@ >B<

: GetRRn { hosta hostu type \ attempts -- n }
  DnsDebug @ IF ." GetRRn: " hosta hostu TYPE CR THEN
  1 -> attempts
  type hosta hostu PrepareDnsQuery
  BEGIN
  BEGIN
    DnsDebug @ IF attempts type hosta hostu ." DNS-QUERY(" DNS-SERVER. ." ): " TYPE ." , type=" . ." , attempt=" . CR THEN
    ['] SendDnsQuery CATCH IF -1 EXIT THEN  \ network problem or DNS-server not detected
    ['] RecvDnsReply CATCH 
    ?DUP IF 10060 <> IF -1 EXIT THEN FALSE ELSE TRUE THEN
    IF 
      DNSREPLY @ HeaderBits W@ >B< 15 AND
      DUP ( RCODE) 3 = IF DROP -3 EXIT THEN \ domain not exist (authoritative!)
      DUP ( RCODE) 5 = IF DROP -5 EXIT THEN \ refused operation
      0=
      DNSREPLY @ HeaderID W@ >B< QID W@ = AND
      IF
        DNSREPLY @ HeaderANCOUNT W@ >B<
        DUP 0=
        IF
          DNSREPLY @ HeaderBits W@ >B< 128 AND \ RA - recurse available
          0= IF 
               DROP -5 \ сервер не дал ответ, т.к. не содержит этого домена
                       \ а рекурсивный запрос делать не хочет,
                       \ т.е. скорее всего задан чужой DNS-сервер
             THEN
        THEN
        EXIT
      THEN
    THEN
    attempts 1+ DUP -> attempts
    vDnsAttempts >
  UNTIL
  NextDNS 0=
  UNTIL
  -2 \ timeouts or DNS-server failure
;

: GetDomainFromEmail
  S" @" SEARCH
  IF 1- SWAP 1+ SWAP ELSE 2DROP S" " THEN
;
: GetUserFromEmail
  2DUP S" @" SEARCH
  IF NIP - ELSE 2DROP THEN
;
: DnsValidateDomain ( domaina domainu -- flag )
  DUP 4 < IF 2DROP FALSE EXIT THEN
  2DUP TYPE-MX GetRRn 0 > IF 2DROP TRUE EXIT THEN
       TYPE-A  GetRRn 0 > IF TRUE EXIT THEN
  FALSE
;
: DnsValidateEmailDomain ( emaila emailu -- flag )
  DUP 7 < IF 2DROP FALSE EXIT THEN
  GetDomainFromEmail DnsValidateDomain
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

: GetMXs ( domaina domainu -- n )
  TYPE-MX GetRRs
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
: DnsDomainExists ( domaina domainu -- flag )
  2DUP TYPE-MX GetRRn DUP 0 > IF DROP 2DROP TRUE EXIT THEN
  DUP -3 = IF DROP 2DROP FALSE EXIT THEN
\ до сюда дошли, если нет MX-записи, но и нет ответа "нет домена"
  -2 = \ таймаут - обычно неверная настройка DNS
  IF 2DROP TRUE EXIT THEN
  TYPE-A GetRRn 0= IF FALSE EXIT THEN \ нет MX и A, считаем домен неверным
  TRUE \ домен есть, либо неверна настройка DNS, узнать достоверно нельзя
\  TYPE-NS GetRRn -3 <>
;

(
TRUE DnsDebug !
\ -s 10.1.1.2
S" eserv.ru" DnsDomainExists . \ есть MX
S" poil.usinsk.ru" DnsDomainExists . \ нет MX, есть A
S" co.nz" DnsDomainExists . \ нет MX и нет A
S" hotamil.com" DnsDomainExists . \ нет MX и нет A
S" non_existent_domain.com" DnsDomainExists . \ нет такого
)

\ TYPE-MX host main.svlm.com swr.da.ru

\ -s ns1.granitecanyon.com
\ -s eserv.ru

\ TRUE DnsDebug !
\ S" enet.ru" TYPE-MX GetRRs PrintRLIST .
\ .( ------------) CR
\ S" enet.ru" TYPE-A GetRRs PrintRLIST .
\ .( ------------) CR
\ S" eserv.ru" TYPE-MX GetRRs PrintRLIST .
\ .( ------------) CR
\ S" non.existent.domain" TYPE-SOA GetRRs PrintRLIST .
\ S" C:\eserv2\mail\lists\eserv_drweb.txt" DnsValidateList
\ S" ac@non.exist.domain" GetDomainFromEmail DnsDomainExists .
\ S" ac@whois.eserv.ru" GetDomainFromEmail DnsDomainExists .
\ S" eserv.ru" TYPE-SOA GetRRs PrintRLIST .

\ REQUIRE STR@         ~ac/lib/str2.f

\ : TXT@ ( addr u -- addr2 u2 )
\   OVER C@ OVER < 0= IF DROP COUNT EXIT THEN
\   DROP COUNT 2DUP + COUNT 2SWAP " {s}{s}" STR@
\ ;
\ S" s1024._domainkey.yahoo.com" TYPE-TXT GetRRs . 
\ RLIST @ RLhost GetFieldData TXT@ TYPE

\ PrintRLIST .
