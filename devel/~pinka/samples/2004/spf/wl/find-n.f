\ 01.Aug.2004  ruv
\ SPF4 depended ext

\ Идея слов '' '''  вроде бы от ~mlg. Давно дело было..


USER WID-FOUND
\ содержит wid последнего словаря из пройденных 
\ при поиске путем SFIND*  или переборе  ENUM-ORDER

: ENUM-ORDER ( ... xt -- ... ) \ xt ( wid -- cont-flag )
  CONTEXT  BEGIN
    2DUP 2>R @ SWAP EXECUTE
  WHILE
    2R> DUP S-O <>
  WHILE
    CELL-
  REPEAT ELSE 2R> THEN WID-FOUND ! DROP
;
: search-nfa ( a u nfa1 -- a u 0|nfa2 )
  BEGIN  ( a u NFA | a u 0 )
    DUP
  WHILE  ( a u NFA )
    >R 2DUP R@ COUNT COMPARE R> SWAP
  WHILE
    CDR  ( a u NFA2 )
  REPEAT THEN
;
\ ===========================================

: search-nfa-n ( a u nfa1 N -- a u 0|nfa2 )
  0 ?DO
    search-nfa DUP 0= IF UNLOOP EXIT THEN CDR
  LOOP search-nfa
;
: (search-wid-n) ( a u N success? wid -- a u nfa|N success? cont-flag )
  NIP @ SWAP DUP >R  search-nfa-n  ( a u 0|nfa2 )
  DUP IF RDROP TRUE FALSE ELSE DROP R> FALSE TRUE THEN
;
: find-nfa-n ( a u N -- a u 0|nfa2 )
  0 ['] (search-wid-n) ENUM-ORDER  0= IF DROP 0 THEN
;
: SFIND-N ( a u N -- xt 1 | xt -1 | 0 )
  find-nfa-n NIP NIP DUP IF
    DUP NAME> SWAP ?IMMEDIATE IF 1 ELSE -1 THEN
  THEN
;
: '' ( "<spaces>name" -- xt ) \ second-old word with this name in a one word-list
  NextWord 1 SFIND-N 0=
  IF -321 THROW THEN
;
: ''' ( "<spaces>name" -- xt ) \ third-old word with this name in a same word-list
  NextWord 2 SFIND-N 0=
  IF -321 THROW THEN
;

 ( example
: ttt 3 . ;
: ttt 2 . ;
: ttt 1 . ;

  ' ttt EXECUTE CR
 '' ttt EXECUTE CR
''' ttt EXECUTE CR

\ )

\EOF

\ ---
: (get-order) ( i*x i wid -- i*x x i+1 true )
  SWAP 1+ TRUE
;
: get-order ( -- i*x i )
  0 ['] (get-order)  -ENUM-ORDER \ revers enum
;
\ --- looked nice, is't it?
