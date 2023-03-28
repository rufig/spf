\ $Id$

\ Originally
\ From: "Ilya S. Potrepalov" <potrepalov@asc-ural.ru>
\ Date: Thu, 23 Feb 2006 13:55:01 +0000 (UTC)
\ Newsgroups: fido7.su.forth
\ Message-ID: <dtkera$r89$93914@www.fido-online.com>

\ ASNI'фикация SP-FORTH'а

BASE @ DECIMAL

REQUIRE CASE         lib/ext/case.f
REQUIRE /STRING      lib/include/string.f
REQUIRE [IF]         lib/include/tools.f
REQUIRE SAVE-INPUT   lib/include/core-ext.f
[DEFINED] WINAPI: [IF]
REQUIRE RENAME-FILE  lib/win/file.f
[ELSE]
REQUIRE RENAME-FILE  lib/posix/file.f
[THEN]
REQUIRE D0<          lib/include/double.f
REQUIRE ANSI-FILE    lib/include/ansi-file.f

[UNDEFINED] INCLUDE [IF]
: INCLUDE ( i*x "name" -- j*x )
  PARSE-NAME INCLUDED
;
[THEN]

WARNING @  0 WARNING !

DECIMAL

: ?DUP  ?DUP ;  \ ?DUP в SP-FORTH'е state-smart, а это не по стандарту

: CONVERT  ( ud1 c-addr1 -- ud2 c-addr2 )
    \ from gforth
    CHAR+ TRUE >NUMBER DROP
;

VARIABLE SPAN  0 SPAN !
: EXPECT  ( a u -- )
    \ это лучше, чем ничего
    ACCEPT SPAN !
;

: D.R  ( d +n -- )
    >R DUP >R  DABS  <# #S R> SIGN #>
    R> OVER - 0 MAX SPACES  TYPE
;
    

\ ANSI said: "If a system provides any standard word for accessing
\ mass storage, it shall also implement the Block word set".
\
\ BLOCK word set
\
\ Table 9.2 - THROW code assignments
\
\ -35     invalid block number

VARIABLE BLK  0 BLK !
: BLOCK   -35 THROW ;
: BUFFER  -35 THROW ;
: FLUSH ;
: LOAD    -35 THROW ;
: SAVE-BUFFERS ;
: UPDATE ;

: BIN ;
: FILE-STATUS  2DROP  0 -21 ; \ unsupported operation


WARNING !
BASE !

\ END OF FILE
