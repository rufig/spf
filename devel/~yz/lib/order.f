\ Упрощенное управление словарями
\ Ю. Жиловец, 17.07.2004

: >ORDER ( wid -- ) ALSO CONTEXT ! ;
: ORDER@ ( -- wid) CONTEXT @ ;
: ORDER> ( -- wid) ORDER@ PREVIOUS ;

: WORDLIST: ( ->bl; -- n)
  WORDLIST DUP CONSTANT GET-CURRENT SWAP SET-CURRENT
;

: WORDLIST; ( n -- )
  SET-CURRENT
;