\ Получение файлов по HTTP/FTP через библиотеку CURL
\ ~ac: переписал через xt-so.f 18.08.2005
\ $Id$

WARNING @ WARNING 0!
REQUIRE SO            ~ac/lib/ns/so-xt.f
REQUIRE QUICK_WNDPROC ~af/lib/quickwndproc.f 
REQUIRE STR@          ~ac/lib/str5.f
WARNING !

ALSO SO NEW: libcurl.dll

10001 CONSTANT CURLOPT_FILE
10002 CONSTANT CURLOPT_URL
10004 CONSTANT CURLOPT_PROXY
20011 CONSTANT CURLOPT_WRITEFUNCTION
CURLOPT_FILE CONSTANT CURLOPT_WRITEDATA

:NONAME { stream nmemb size ptr \ asize -- stream nmemb size ptr size*nmemb }
  size nmemb * -> asize
  ptr asize stream @ STR+
  stream nmemb size ptr asize
; QUICK_WNDPROC CURL_CALLBACK

: HTTP_GET_VIAPROXY { addr u paddr pu \ h data -- str }
\ если прокси paddr pu - непустая строка, то явно используется этот прокси
\ curl умеет использовать переменные окружения http_proxy, ftp_proxy
\ поэтому можно не задавать прокси явно

  "" -> data
  0 curl_easy_init -> h
  addr CURLOPT_URL h 3 curl_easy_setopt DROP

  pu IF paddr CURLOPT_PROXY h 3 curl_easy_setopt DROP THEN

  CURL_CALLBACK CURLOPT_WRITEFUNCTION h 3 curl_easy_setopt DROP
  ^ data CURLOPT_WRITEDATA h 3 curl_easy_setopt DROP

  h 1 curl_easy_perform
  ?DUP IF 1 curl_easy_strerror ASCIIZ> TYPE CR THEN
  h 1 curl_easy_cleanup DROP
  data
;
: HTTP_GET ( addr u -- str )
  \ без прокси или с заданным в переменной окружения http_proxy
  S" " HTTP_GET_VIAPROXY
;

\EOF
: TEST
  S" http://xmlsearch.yandex.ru/xmlsearch?query=sp-forth" HTTP_GET STYPE
  S" http://xmlsearch.yandex.ru/xmlsearch?query=sp-forth" S" http://otradnoe:3128/" HTTP_GET_VIAPROXY STYPE
  S" ftp://ftp.forth.org.ru/" HTTP_GET STYPE
;
TEST
