\ $Id$
\ libcurl options

REQUIRE CURL-SETOPT ~ac/lib/lin/curl/curl.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE list? ~ygrek/lib/list/ext.f
REQUIRE /TEST ~profit/lib/test.f

: LIST> ['] NOOP SWAP mapcar ;

MODULE: curlopt

USER-VALUE CURLOPTLIST

: CURLOPT-APPLY ( h -- h )
   LAMBDA{ OVER >R LIST> R> CURL-SETOPT } CURLOPTLIST mapcar
   CURLOPTLIST FREE-LIST
   () TO CURLOPTLIST ;

..: AT-THREAD-STARTING () TO CURLOPTLIST ;..
() TO CURLOPTLIST

..: AT-CURL-PRE CURLOPT-APPLY ;..

EXPORT

: CURLOPT! ( val opt -- ) SWAP %[ % % ]% vnode as-list CURLOPTLIST cons TO CURLOPTLIST ;

;MODULE

/TEST

\ nothing cause sf.net is redirecting
S" sf.net" GET-FILE DUP STR@ . DROP STRFREE

TRUE CURLOPT_FOLLOWLOCATION CURLOPT!
S" sf.net" GET-FILE DUP STR@ . DROP STRFREE

