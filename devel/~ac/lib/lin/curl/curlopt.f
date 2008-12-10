\ $Id$
\ libcurl options

REQUIRE CURL-SETOPT ~ac/lib/lin/curl/curl.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE list-ext ~ygrek/lib/list/ext.f
REQUIRE /TEST ~profit/lib/test.f

MODULE: curlopt

USER-VALUE CURLOPTLIST

: CURLOPT-APPLY ( h -- h )
   CURLOPTLIST LAMBDA{ OVER >R list::all DROP R> CURL-SETOPT } list::iter
   CURLOPTLIST list::['] free list::free-with
   list::nil TO CURLOPTLIST ;

..: AT-THREAD-STARTING list::nil TO CURLOPTLIST ;..
list::nil TO CURLOPTLIST

..: AT-CURL-PRE CURLOPT-APPLY ;..

EXPORT

{{ list
: CURLOPT! ( val opt -- ) nil cons cons CURLOPTLIST cons TO CURLOPTLIST ;
}}

;MODULE

/TEST

\ nothing cause sf.net is redirecting
S" sf.net" GET-FILE DUP STR@ . DROP STRFREE

TRUE CURLOPT_FOLLOWLOCATION CURLOPT!
S" sf.net" GET-FILE DUP STR@ . DROP STRFREE

