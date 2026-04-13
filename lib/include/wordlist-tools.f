\ Tools for wordlists
\ 2015-05 rvm

\ TRAVERSE-WORDLIST
\ http://www.forth200x.org/traverse-wordlist.html

: NAME>INTERPRET ( nt -- xt ) \ "name-to-interpret" TOOLS-EXT
  NAME>
;

: NAME>COMPILE   ( nt -- w xt ) \ "name-to-compile" TOOLS-EXT
  DUP NAME> SWAP IS-NAME-IMMEDIATE IF ['] EXECUTE ELSE ['] COMPILE, THEN
;

: TRAVERSE-WORDLIST ( i*x xt wid -- j*x ) \ "traverse-wordlist" TOOLS-EXT
  \ xt  ( i*x nt -- j*x flag ) \ iteration stops on FALSE
  \ NB This word is not allowed to expose the current definition or hidden definitions, if any (see "SMUDGE")
  \ https://forth-standard.org/proposals/traverse-wordlist-does-not-find-unnamed-unfinished-definitions?hideDiff#reply-487
  SWAP >R  LATEST-NAME-IN ( nt|0 )
  BEGIN DUP WHILE ( nt ) R@ OVER >R EXECUTE R> SWAP WHILE NAME>NEXT-NAME REPEAT THEN DROP RDROP
;

\ see also:
\   FOR-WORDLIST  ( wid xt -- ) \ xt ( nt -- )
\     -- src/compiler/spf_wordlist.f (since 2007)
\   FOREACH-WORDLIST-PAIR ( i*x xt wid -- j*x ) \ xt ( i*x  xt1 d-txt-name1 -- j*x )
\     -- ~pinka/spf/compiler/native-wordlist.f


\ NB the word `SYNONYM` is in the kernel now.
