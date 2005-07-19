\ Упрощенное управление словарями
\ Ю. Жиловец, 17.07.2004

: >ORDER ( wid -- ) ALSO CONTEXT ! ;
: ORDER@ ( -- wid) CONTEXT @ ;
: ORDER> ( -- wid) ORDER@ PREVIOUS ;

: :WORDLIST ( wl1 -- n)
  GET-CURRENT SWAP SET-CURRENT
;

: WORDLIST: ( ->bl; -- n)
  WORDLIST DUP CONSTANT :WORDLIST
;

: WORDLIST; ( n -- )
  SET-CURRENT
;
