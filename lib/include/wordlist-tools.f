\ Tools for wordlists
\ 2015-05 rvm

\ TRAVERSE-WORDLIST
\ http://www.forth200x.org/traverse-wordlist.html

: NAME>STRING ( nfa -- addr count ) \ "name-to-string"    TOOLS-EXT
  COUNT
;

: NAME>INTERPRET ( nt -- xt ) \ "name-to-interpret" TOOLS-EXT
  NAME>
;

: NAME>COMPILE   ( nt -- w xt ) \ "name-to-compile"   TOOLS-EXT
  DUP NAME> SWAP IS-IMMEDIATE IF ['] EXECUTE ELSE ['] COMPILE, THEN
;

: TRAVERSE-WORDLIST ( i*x xt wid -- j*x ) \ "traverse-wordlist" TOOLS-EXT
  \ xt  ( i*x nt -- j*x flag ) \ iteration stops on FALSE
  @ BEGIN  DUP WHILE ( xt NFA ) 2DUP 2>R SWAP EXECUTE 2R> CDR ROT 0= UNTIL THEN 2DROP
;

\ see also:
\ ~pinka/spf/compiler/native-wordlist.f
\ FOREACH-WORDLIST-PAIR ( i*x xt wid -- j*x ) \ xt ( i*x  xt1 d-txt-name1 -- j*x )
