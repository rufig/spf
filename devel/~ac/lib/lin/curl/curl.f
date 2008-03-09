\ Получение файлов по HTTP/FTP через библиотеку CURL
\ ~ac: переписал через xt-so.f 18.08.2005
\ $Id$
\ требуется libcurl.dll - http://curl.haxx.se/latest.cgi?curl=win32-devel-ssl

REQUIRE SO            ~ac/lib/ns/so-xt.f
REQUIRE STR@          ~ac/lib/str5.f

REQUIRE ADD-CONST-VOC lib/ext/const.f
S" ~ygrek/lib/data/curl.const" ADD-CONST-VOC

ALSO SO NEW: libcurl.dll

\ Global libcurl initialization
: (CURL-GLOBAL-INIT) CURL_GLOBAL_ALL 1 curl_global_init THROW ;
: CURL-GLOBAL-INIT ['] (CURL-GLOBAL-INIT) CATCH
  ?DUP IF DUP 126 = IF DROP ELSE THROW THEN THEN
;
..: AT-PROCESS-STARTING CURL-GLOBAL-INIT ;..
CURL-GLOBAL-INIT

\ Maximum number of bytes to download. 0 - unlimited
USER-VALUE CURL-MAX-SIZE

USER uCurlRes

:NONAME { stream nmemb size ptr \ asize ti -- stream nmemb size ptr size*nmemb }
  TlsIndex@ -> ti stream TlsIndex!
  size nmemb * -> asize
  ptr asize uCurlRes @ STR+
  stream nmemb size ptr asize
  CURL-MAX-SIZE IF
    stream @ STR@ NIP CURL-MAX-SIZE > IF DROP 0 THEN
  THEN
  ti TlsIndex!
; WNDPROC: CURL_CALLBACK

: CURL-SETOPT ( value opt h -- ) 3 curl_easy_setopt THROW ;

\ Слово-расширение - вызывается перед curl_perform
: AT-CURL-PRE ( h -- h ) ... ;

\ если прокси paddr pu - непустая строка, то явно используется этот прокси
\ curl умеет использовать переменные окружения http_proxy, ftp_proxy
\ поэтому можно не задавать прокси явно.
: GET-FILE-VIAPROXY { addr u paddr pu \ h url pr -- str }
  "" uCurlRes !
  0 curl_easy_init -> h
  addr u >STR DUP -> url STRA CURLOPT_URL h CURL-SETOPT

\  S" name:passw" DROP CURLOPT_USERPWD  h 3 curl_easy_setopt DROP

  pu IF paddr pu >STR DUP -> pr STRA CURLOPT_PROXY h CURL-SETOPT THEN

  ['] CURL_CALLBACK CURLOPT_WRITEFUNCTION h CURL-SETOPT
  TlsIndex@ CURLOPT_WRITEDATA h CURL-SETOPT

  h AT-CURL-PRE DROP

  h 1 curl_easy_perform
  ?DUP IF 1 curl_easy_strerror ASCIIZ> TYPE CR THEN
  h 1 curl_easy_cleanup DROP
  url STRFREE pr ?DUP IF STRFREE THEN
  0 TO CURL-MAX-SIZE
  uCurlRes @
;

: GET-FILE ( addr u -- str )
  \ без прокси или с заданным в переменной окружения http_proxy
  2DUP FILE-EXIST IF FILE 2DUP >STR NIP SWAP FREE THROW EXIT THEN
  S" " GET-FILE-VIAPROXY
;

PREVIOUS

\ EOF
\ регистрация IP для xml-запросов к яндексу: http://xml.yandex.ru/ip.xml
: TEST
  S" http://xmlsearch.yandex.ru/xmlsearch?query=sp-forth" GET-FILE STYPE CR
  S" http://xmlsearch.yandex.ru/xmlsearch?query=sp-forth" S" http://proxy.enet.ru:3128/" GET-FILE-VIAPROXY STYPE CR
  S" ftp://ftp.forth.org.ru/" GET-FILE STYPE
;
TEST
