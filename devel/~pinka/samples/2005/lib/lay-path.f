\ 13.May.2005 ruvim@forth.org.ru
\ $Id$
\ Module provide words for lay a path to file (creating non-existent folders)
\ originally prime from acWEB\src\ext.f # CREATE-FILE-PATH

( example:
  S" .\test-folder\aaa\" LAY-PATH
  S" test-string" S" c:\work\test1\aaa\bbb\my-file.txt" FORCE-PATH ATTACH
)

REQUIRE [UNDEFINED]  lib/include/tools.f

[UNDEFINED] /CHAR           [IF] 1 CHARS CONSTANT /CHAR          [THEN]

[UNDEFINED] CREATE-FOLDER [IF]

[DEFINED] WINAPI: [IF]

[UNDEFINED] CreateDirectoryA [IF]
WINAPI: CreateDirectoryA   KERNEL32.DLL
[THEN]

: CREATE-FOLDER ( addr u -- ior )
  DROP 0 SWAP CreateDirectoryA ERR
;
[ELSE]

: CREATE-FOLDER ( a u -- ior )
  DROP 1 <( 511 )) mkdir ?ERR NIP       \ 511 = 0777
;
[THEN]
[THEN]

\ ===

: LAY-PATH-CATCH ( a u -- ior )
  CUT-PATH DUP 0= IF NIP EXIT THEN
  /CHAR - ( a u' )
  2DUP + DUP DUP C@ 2>R 0 SWAP C!
  2DUP FILE-EXIST IF 2DROP 0 ELSE
  2DUP RECURSE ?DUP IF NIP NIP ELSE CREATE-FOLDER THEN
  THEN R> R> C!
;
: LAY-PATH ( a u -- )
  LAY-PATH-CATCH THROW
;
: FORCE-PATH ( a u -- a u )
  2DUP LAY-PATH 
;



\EOF
\ ===

\ Another decision, not so pretty, like previous ;) 
\ Другое решение

[UNDEFINED] path_delimiter  [IF] CHAR \  VALUE path_delimiter    [THEN]

: _LAY-PATH1 ( -- )
  SOURCE DROP 0
  BEGIN
    path_delimiter PARSE DUP
    DUP IF DROP 2DUP + C@ path_delimiter = THEN
  WHILE ( a u  a1 u1 )
    NIP + 2DUP + 0 SWAP C!
    2DUP FILE-EXIST 0= IF 2DUP CREATE-FOLDER DROP THEN
    2DUP + path_delimiter SWAP C! CHAR+
  REPEAT
  2DROP 2DROP
;
: LAY-PATH-CATCH ( a u -- ior )
  ['] _LAY-PATH1 -ROT ['] CATCH EVALUATE-WITH
;
: LAY-PATH ( a u -- ior )
  LAY-PATH-CATCH THROW
;
: FORCE-PATH ( a u -- a u )
  2DUP LAY-PATH
;
