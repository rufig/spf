\ Работа с данными
\ Ю. Жиловец, 2002

USER ptr
: init->> ( a -- )
  ptr ! ;
: push->> ( -- n)
  ptr @ ;
: pop->> ( n -- )
  ptr ! ;
: >> ( n -- )
  ptr @ !  CELL ptr +! ;
: W>> ( w -- )
  ptr @ W!  2 ptr +! ;
: C>> ( c -- )
  ptr @ C!  ptr 1+! ;
: 2>> ( d -- )
  ptr @ 2!  2 CELLS ptr +! ;
: N>> ( adr n -- )
  >R ptr @ R@ CMOVE R> ptr +! ;
: Z>> ( z -- )
  DUP ptr @ ZMOVE ZLEN 1+ ptr +! ;
\ пересылает строку, но без завершающего нуля
: z>> ( z -- )
  DUP ptr @ ZMOVE ZLEN ptr +! ;
: zeroes>> ( n -- ) 0 ?DO 0 >> LOOP ;

: (DATA) ( -- a)
  R> DUP DUP @ + >R CELL+ ;
: DATA[ ( -- a)
  ?COMP POSTPONE (DATA)
  HERE 0 , ( длина данных) [COMPILE] [ ; IMMEDIATE
: ]DATA ( a -- )
  DUP HERE SWAP - SWAP ! ] ; IMMEDIATE
  