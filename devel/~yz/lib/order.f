\ Упрощенное управление словарями
\ Ю. Жиловец, 17.07.2004

: >ORDER ( wid -- ) ALSO CONTEXT ! ;
: ORDER@ ( -- wid) CONTEXT @ ;
: ORDER> ( -- wid) ORDER@ PREVIOUS ;
