\ ѕолучение файлов по HTTP/FTP через библиотеку CURL
\ ~ac: переписал через xt-so.f 18.08.2005
\ $Id$
\ требуетс€ libcurl.dll - http://curl.haxx.se/latest.cgi?curl=win32-devel-ssl

REQUIRE SO            ~ac/lib/ns/so-xt.f
REQUIRE QUICK_WNDPROC ~af/lib/quickwndproc.f 
REQUIRE STR@          ~ac/lib/str5.f

REQUIRE ADD-CONST-VOC ~day/wincons/wc.f
S" ~ygrek/lib/data/curl.const" ADD-CONST-VOC

ALSO SO NEW: libcurl.dll

\ Global libcurl initialization
: CURL-GLOBAL-INIT CURL_GLOBAL_ALL 1 curl_global_init THROW ;
..: AT-PROCESS-STARTING CURL-GLOBAL-INIT ;..
CURL-GLOBAL-INIT

\ Maximum number of bytes to download. 0 - unlimited
USER-VALUE CURL-MAX-SIZE

:NONAME { stream nmemb size ptr \ asize -- stream nmemb size ptr size*nmemb }
  size nmemb * -> asize
  ptr asize stream @ STR+
  stream nmemb size ptr asize
  CURL-MAX-SIZE IF
    stream @ STR@ NIP CURL-MAX-SIZE > IF DROP 0 THEN
  THEN
; QUICK_WNDPROC CURL_CALLBACK

: CURL-SETOPT ( value opt h -- ) 3 curl_easy_setopt THROW ;

\ —лово-расширение - вызываетс€ перед curl_perform
: AT-CURL-PRE ( h -- h ) ... ;

\ если прокси paddr pu - непуста€ строка, то €вно используетс€ этот прокси
\ curl умеет использовать переменные окружени€ http_proxy, ftp_proxy
\ поэтому можно не задавать прокси €вно.
: GET-FILE-VIAPROXY { addr u paddr pu \ h data -- str }
  "" -> data
  0 curl_easy_init -> h
  addr u >STR DUP STRA CURLOPT_URL h CURL-SETOPT STRFREE

\  S" name:passw" DROP CURLOPT_USERPWD  h 3 curl_easy_setopt DROP

  pu IF paddr pu >STR DUP STRA CURLOPT_PROXY h CURL-SETOPT STRFREE THEN

  CURL_CALLBACK CURLOPT_WRITEFUNCTION h CURL-SETOPT
  ^ data CURLOPT_WRITEDATA h CURL-SETOPT

  h AT-CURL-PRE DROP

  h 1 curl_easy_perform
  ?DUP IF 1 curl_easy_strerror ASCIIZ> TYPE CR THEN
  h 1 curl_easy_cleanup DROP
  0 TO CURL-MAX-SIZE
  data
;

: GET-FILE ( addr u -- str )
  \ без прокси или с заданным в переменной окружени€ http_proxy
  2DUP FILE-EXIST IF FILE 2DUP >STR NIP SWAP FREE THROW EXIT THEN
  S" " GET-FILE-VIAPROXY
;

PREVIOUS
\EOF
: TEST
  S" http://xmlsearch.yandex.ru/xmlsearch?query=sp-forth" GET-FILE STYPE
  S" http://xmlsearch.yandex.ru/xmlsearch?query=sp-forth" S" http://otradnoe:3128/" GET-FILE-VIAPROXY STYPE
  S" ftp://ftp.forth.org.ru/" GET-FILE STYPE
;
TEST
