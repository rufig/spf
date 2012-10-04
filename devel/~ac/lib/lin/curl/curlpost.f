\ POST-запросы с помощью CURL.
\ $Id$

REQUIRE GET-FILE      ~ac/lib/lin/curl/curl.f

10015 CONSTANT CURLOPT_POSTFIELDS
10023 CONSTANT CURLOPT_HTTPHEADER
10060 CONSTANT CURLOPT_POSTFIELDSIZE
10084 CONSTANT CURLOPT_HTTP_VERSION

ALSO libcurl.dll
ALSO libcurl.so
ALSO libcurl.so.3
ALSO libcurl.so.4

: POST-FILE-VIAPROXY { adata udata act uct addr u paddr pu \ h data slist coo -- str }
\ если прокси paddr pu - непустая строка, то явно используется этот прокси
\ curl умеет использовать переменные окружения http_proxy, ftp_proxy
\ поэтому можно не задавать прокси явно.
\ adata udata - передаваемые через POST данные.

\ act uct - content-type; если uct=0, то остается default application/x-www-form-urlencoded
\ если данные POST'а не текстовые, а двоичные, то CURL отправит не всё

\  "" -> data
  "" uCurlRes !
  0 curl_easy_init -> h
  addr CURLOPT_URL h 3 curl_easy_setopt DROP
  uCurlVerifySsl @ CURLOPT_SSL_VERIFYPEER h CURL-SETOPT

\  S" name:passw" DROP CURLOPT_USERPWD  h 3 curl_easy_setopt DROP

  pu IF paddr CURLOPT_PROXY h 3 curl_easy_setopt DROP THEN

\  65000 CURLOPT_BUFFERSIZE h 3 curl_easy_setopt DROP ( не ставится больше, чем CURL_MAX_WRITE_SIZE)

  ['] CURL_CALLBACK CURLOPT_WRITEFUNCTION h 3 curl_easy_setopt DROP
\  ^ data CURLOPT_WRITEDATA h 3 curl_easy_setopt DROP
  TlsIndex@ CURLOPT_WRITEDATA h CURL-SETOPT

  udata CURLOPT_POSTFIELDSIZE h 3 curl_easy_setopt DROP
  adata CURLOPT_POSTFIELDS    h 3 curl_easy_setopt DROP

  1 CURLOPT_HTTP_VERSION h 3 curl_easy_setopt DROP

  S" User-Agent: SP-Forth" DROP 0 2 curl_slist_append -> slist
  uct IF act slist 2 curl_slist_append -> slist  THEN
  slist CURLOPT_HTTPHEADER h 3 curl_easy_setopt DROP

\  S" " DROP CURLOPT_COOKIEFILE h 3 curl_easy_setopt DROP

  h 1 curl_easy_perform
  ?DUP IF 1 curl_easy_strerror ASCIIZ> TYPE CR THEN
  uCurlRespCode CURLINFO_RESPONSE_CODE h 3 curl_easy_getinfo DROP
\  PAD CURLINFO_CONTENT_TYPE h 3 curl_easy_getinfo 1 curl_easy_strerror ASCIIZ> TYPE CR
  slist 1 curl_slist_free_all DROP

\  ^ coo CURLINFO_COOKIELIST h 3 curl_easy_getinfo DROP ." COOK=" coo . CR

  h 1 curl_easy_cleanup DROP
\  data
  uCurlRes @
;
0x100000 31 + CONSTANT  CURLINFO_REDIRECT_URL \    = CURLINFO_STRING + 31,

: POST-CUSTOM-VIAPROXY { amethod umethod aheader uheader adata udata act uct addr u paddr pu \ h data slist coo -- str }
\ если прокси paddr pu - непустая строка, то явно используется этот прокси
\ curl умеет использовать переменные окружения http_proxy, ftp_proxy
\ поэтому можно не задавать прокси явно.
\ adata udata - передаваемые через POST (или иной метот с телом) данные.
\ act uct - content-type; если uct=0, то остается default application/x-www-form-urlencoded
\ если данные POST'а не текстовые, а двоичные, то CURL отправит всё, благодаря CURLOPT_POSTFIELDSIZE_LARGE

\  "" -> data
  "" uCurlRes !
  0 curl_easy_init -> h
  addr CURLOPT_URL h 3 curl_easy_setopt DROP
  uCurlVerifySsl @ CURLOPT_SSL_VERIFYPEER h CURL-SETOPT

\  S" name:passw" DROP CURLOPT_USERPWD  h 3 curl_easy_setopt DROP

  pu IF paddr CURLOPT_PROXY h 3 curl_easy_setopt DROP THEN

\  65000 CURLOPT_BUFFERSIZE h 3 curl_easy_setopt DROP

  ['] CURL_CALLBACK CURLOPT_WRITEFUNCTION h 3 curl_easy_setopt DROP
\  ^ data CURLOPT_WRITEDATA h 3 curl_easy_setopt DROP
  TlsIndex@ CURLOPT_WRITEDATA h CURL-SETOPT

  umethod IF amethod CURLOPT_CUSTOMREQUEST h 3 curl_easy_setopt DROP THEN

\  TRUE CURLOPT_HEADER h 3 curl_easy_setopt DROP

  udata IF
    0 udata CURLOPT_POSTFIELDSIZE_LARGE h 4 curl_easy_setopt DROP
    adata CURLOPT_POSTFIELDS    h 3 curl_easy_setopt DROP
  THEN

  1 CURLOPT_HTTP_VERSION h 3 curl_easy_setopt DROP

\  S" User-Agent: Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Win64; x64; Trident/6.0)" DROP 0 2 curl_slist_append -> slist
  uct IF act slist 2 curl_slist_append -> slist  THEN
  uheader IF aheader slist 2 curl_slist_append -> slist  THEN
  slist CURLOPT_HTTPHEADER h 3 curl_easy_setopt DROP


\  S" " DROP CURLOPT_COOKIEFILE h 3 curl_easy_setopt DROP

  h 1 curl_easy_perform
  ?DUP IF 1 curl_easy_strerror ASCIIZ> TYPE CR THEN
  uCurlRespCode CURLINFO_RESPONSE_CODE h 3 curl_easy_getinfo DROP
  slist 1 curl_slist_free_all DROP

\  ^ coo CURLINFO_REDIRECT_URL h 3 curl_easy_getinfo DROP ." REDIR=" coo . CR

\  ^ coo CURLINFO_COOKIELIST h 3 curl_easy_getinfo DROP ." COOK=" coo . CR

  h 1 curl_easy_cleanup DROP
\  data
  uCurlRes @
;
PREVIOUS PREVIOUS PREVIOUS PREVIOUS

: POST-FILE ( adata udata act uct addr u -- str )
  \ без прокси или с заданным в переменной окружения http_proxy
  2DUP FILE ?DUP
  IF 2SWAP 2DROP 2SWAP 2DROP 2SWAP 2DROP OVER >R sALLOT R> FREE THROW
  ELSE DROP S" " POST-FILE-VIAPROXY THEN
;

\EOF
S" <test>test</test>" S" Content-Type: text/xml" S" http://www.forth.org.ru/test.e" S" http://localhost:3128/" POST-FILE-VIAPROXY STR@ TYPE
REQUIRE >UTF8 ~ac/lib/win/com/com.f
\ S" status=тестирую curl" >UTF8 S" " S" http://rufig:spforth@twitter.com/statuses/update.xml" POST-FILE STR@ TYPE
