\ $Id$

REQUIRE ALLOCATED ~pinka/lib/ext/basics.f
REQUIRE { lib/ext/locals.f
REQUIRE GetParamsFromString ~ac/lib/string/get_params.f
REQUIRE READ-FILE-EXACT ~pinka/lib/files-ext.f
REQUIRE NUMBER ~ygrek/lib/parse.f
REQUIRE EQUAL ~pinka/spf/string-equal.f
REQUIRE NOT ~profit/lib/logic.f
REQUIRE AsQWord ~pinka/spf/quoted-word.f

MODULE: CGI

: content:html S" Content-Type: text/html" TYPE CR ;
: content:text S" Content-Type: text/plain" TYPE CR ;
: content:xhtml S" Content-Type: application/xhtml+xml" TYPE CR ;
: content-length ( n -- ) " Content-Length: {n}" STYPE CR ;
: status ( n -- ) " Status: {n}" STYPE CR ;

: get-post-params
  S" CONTENT_LENGTH" ENVIRONMENT? NOT IF EXIT THEN
  NUMBER NOT IF EXIT THEN
  ALLOCATED 2DUP H-STDIN READ-FILE-EXACT IF 2DROP ELSE GetParamsFromString THEN ;

: get-get-params
  S" QUERY_STRING" ENVIRONMENT? IF GetParamsFromString THEN ;

: get-params
  `REQUEST_METHOD ENVIRONMENT? NOT IF EXIT THEN
   2DUP `POST CEQUAL IF 2DROP get-post-params EXIT THEN
   2DUP `GET  CEQUAL IF 2DROP get-get-params EXIT THEN
   2DROP ;

[UNDEFINED] WINAPI: [IF]

: show-environment
  S" environ" symbol-lookup symbol-address @
  BEGIN
   DUP @
  WHILE
   DUP @ ASCIIZ> TYPE CR
   CELL+
  REPEAT
  DROP ;

[ELSE]

WINAPI: GetEnvironmentStrings KERNEL32.DLL

: show-environment
  GetEnvironmentStrings
  BEGIN
   DUP B@
  WHILE
   ASCIIZ> 2DUP TYPE CR
   + 1+
  REPEAT
  DROP ;

[THEN]

;MODULE

