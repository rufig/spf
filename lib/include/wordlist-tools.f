\ Tools for wordlists
\ 2015-05 rvm

\ TRAVERSE-WORDLIST
\ http://www.forth200x.org/traverse-wordlist.html

: NAME>STRING ( nt -- addr count ) \ "name-to-string" TOOLS-EXT
  COUNT
;

: NAME>INTERPRET ( nt -- xt ) \ "name-to-interpret" TOOLS-EXT
  NAME>
;

: NAME>COMPILE   ( nt -- w xt ) \ "name-to-compile" TOOLS-EXT
  DUP NAME> SWAP IS-IMMEDIATE IF ['] EXECUTE ELSE ['] COMPILE, THEN
;

: TRAVERSE-WORDLIST ( i*x xt wid -- j*x ) \ "traverse-wordlist" TOOLS-EXT
  \ xt  ( i*x nt -- j*x flag ) \ iteration stops on FALSE
  @ BEGIN  DUP WHILE ( xt NFA ) 2DUP 2>R SWAP EXECUTE 2R> CDR ROT 0= UNTIL THEN 2DROP
;

\ see also:
\   FOR-WORDLIST  ( wid xt -- ) \ xt ( nfa -- )
\     -- src/compiler/spf_wordlist.f (since 2007)
\   FOREACH-WORDLIST-PAIR ( i*x xt wid -- j*x ) \ xt ( i*x  xt1 d-txt-name1 -- j*x )
\     -- ~pinka/spf/compiler/native-wordlist.f



\ 2017-04-23
\ "SYNONYM" from TOOLS-EXT 2012

: ENROLL-NAME ( xt d-newname -- ) \ basic factor
  \ see also: ~pinka/spf/compiler/native-wordlist.f
  SHEADER LAST-CFA @ !
;
: ENROLL-SYNONYM ( d-oldname d-newname -- ) \ postfix version of SYNONYM
  2>R SFIND DUP 0= IF -321 THROW THEN ( xt -1|1 )
  SWAP 2R> ENROLL-NAME 1 = IF IMMEDIATE THEN
;
: SYNONYM ( "<spaces>newname" "<spaces>oldname" -- ) \ 2012 TOOLS EXT
  PARSE-NAME PARSE-NAME 2SWAP ENROLL-SYNONYM
;
