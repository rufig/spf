\ Пример работы с Amazon AWS DynamoDB.

REQUIRE STR@        ~ac/lib/str5.f
REQUIRE HMAC-SHA1   ~ac/lib/lin/crypt/gcrypt.f
REQUIRE UnixTimeRss ~ac/lib/win/date/unixtime.f 
REQUIRE SslInit     ~ac/lib/win/winsock/ssl.f
REQUIRE SocketLine  ~ac/lib/win/winsock/socketline2.f
REQUIRE fgets       ~ac/lib/win/winsock/PSOCKET.F

: AccessKeyID           S" AKIAsecret" ;
: SecretAccessKey       S" e9secret"   ;
: AwsDdbEndpointRegion  S" eu-west-1"  ;
: AwsDdbEndpoint         " dynamodb.{AwsDdbEndpointRegion}.amazonaws.com" STR@ ;

: >NUM 0 0 2SWAP >NUMBER 2DROP D>S ;

: \n
  CRLF DROP 1+ 1
;
: UnixTimeBasic ( unixtime -- addr u ) \ LOCAL
  >R RP@ gmtime NIP 
  S" %Y%m%dT%H%M%SZ" DROP 30 uLocalTime strftime NIP NIP NIP NIP 
  uLocalTime SWAP
  RDROP
;
: CurrentTimeBasic ( -- addr u )
  UnixTime UnixTimeBasic
;
: AwsDerivedKey ( service_name -- addr u )
  2>R
  CurrentTimeBasic DROP 8 " AWS4{SecretAccessKey}" STR@ HMAC-SHA256
  AwsDdbEndpointRegion 2SWAP HMAC-SHA256 
  2R> 2SWAP HMAC-SHA256 
  S" aws4_request" 2SWAP HMAC-SHA256
  \ 2DUP B>S TYPE CR
;
: AwsDdb { ba bu ma mu \ req careq s sl mem ta tu sts sa su i str la lu -- addr u }

  GCryptInit 0= IF 599 EXIT THEN
  SslInit
\  SSLeayVersion TYPE CR

  CurrentTimeBasic -> tu -> ta

  ba bu SHA256B B>S ma mu ta tu
" POST{\n}/{\n}{\n}host:{AwsDdbEndpoint}{\n}x-amz-date:{s}{\n}x-amz-target:DynamoDB_20111205.{s}{\n}{\n}host;x-amz-date;x-amz-target{\n}{s}" -> careq

  careq STR@ SHA256B B>S
  ta 8 ta tu
" AWS4-HMAC-SHA256{\n}{s}{\n}{s}/{AwsDdbEndpointRegion}/dynamodb/aws4_request{\n}{s}" -> sts

  sts STR@
  S" dynamodb" AwsDerivedKey
  HMAC-SHA256 B>S -> su -> sa

  ba bu ma mu ta tu bu sa su ta 8
" POST / HTTP/1.1
authorization: AWS4-HMAC-SHA256 Credential={AccessKeyID}/{s}/{AwsDdbEndpointRegion}/dynamodb/aws4_request,SignedHeaders=host;x-amz-date;x-amz-target,Signature={s}
host: {AwsDdbEndpoint}
connection: Close
content-length: {n}
content-type: application/x-amz-json-1.0
x-amz-date: {s}
x-amz-target: DynamoDB_20111205.{s}

{s}" -> req

  AwsDdbEndpoint 80 ( Ssl) ConnectHost \ ." conn_ior=" . 
  IF DROP S" " EXIT THEN

  DUP -> s SocketLine -> sl

  req sl fputs

  0 -> i
  BEGIN
    sl fgets STR@ DUP
  WHILE
    -> lu -> la
    i 1+ -> i
    i 1 = IF la 9 + 3 >NUM DUP . 200
             <> IF la lu TYPE CR ( sl fclose S" " EXIT) THEN
          THEN
  REPEAT 2DROP \ CR ." ---" CR

  sl SocketGetPending >STR -> str \ TYPE

  10000 ALLOCATE THROW -> mem
  BEGIN
    mem 10000 s ReadSocket 0=
  WHILE
    mem SWAP str STR+ \ TYPE
  REPEAT DROP

  mem FREE THROW
  sl fclose
  str STR@
;

\EOF

SocketsStartup DROP
S' {"Limit":3}' S" ListTables" AwsDdb TYPE CR CR
