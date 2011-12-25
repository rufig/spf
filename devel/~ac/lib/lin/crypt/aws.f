\ Пример работы с Amazon AWS S3.

REQUIRE STR@        ~ac/lib/str5.f
REQUIRE HMAC-SHA1   ~ac/lib/lin/crypt/gcrypt.f
REQUIRE base64      ~ac/lib/string/conv.f 
REQUIRE UnixTimeRss ~ac/lib/win/date/unixtime.f 
REQUIRE POST-FILE   ~ac/lib/lin/curl/curlpost.f 

: \n
  CRLF DROP 1+ 1
;
: UnixTimeZ ( unixtime -- addr u ) \ UTC
  >R RP@ gmtime NIP 
  S" %a, %d %b %Y %H:%M:%S" DROP 30 uLocalTime strftime NIP NIP NIP NIP 
  uLocalTime SWAP
  RDROP
  " {s} +0000" STR@ \ в форматной строке strftime не принимает
;
: CurrentTimeZ ( -- addr u )
  UnixTime UnixTimeZ
;
: AwsPUT { va vu cta ctu na nu bucketa bucketu hosta hostu la lu pwa pwu \ da du s ma mu -- result }
  \ va vu - значение, которое разместить в S3
  \ cta ctu - content-type
  \ na nu - имя объекта (URL без хоста и корзины)
  \ la lu - логин (AWS Access Key Id)
  \ pwa pwu - AWS Secret Access Key
  \ result - HTTP-код ответа (200=ОК)

  GCryptInit 0= IF 599 EXIT THEN
  na nu bucketa bucketu
  CurrentTimeZ 2DUP -> du -> da 
  cta ctu
  va vu MD5B base64 2DUP -> mu -> ma
  " PUT{\n}{s}{\n}{s}{\n}{s}{\n}/{s}{s}" STR@ \ 2DUP TYPE CR
  pwa pwu HMAC-SHA1 base64 \ 2DUP TYPE CR
  la lu da du ma mu
" Content-MD5: {s}
Date: {s}
Authorization: AWS {s}:{s}" STR@

  S" PUT" 2SWAP va vu cta ctu " Content-Type: {s}" STR@ na nu 
  hosta hostu bucketa bucketu
  " http://{s}.{s}{s}" STR@ S" " POST-CUSTOM-VIAPROXY
  uCurlRespCode @ DUP 200 <> IF SWAP STYPE CR ELSE SWAP DROP THEN
;
