
\ 14.Apr.2001 
\ добавление ensemble{}^
\            Ensemble-ForEach
\            Ensamble-Volume
\ * EnsembleD-ForEach итерирует по _значениям_ (было по адресам значений)


\ 06.07.2000  ruv
\ EnsemleD  - ключ двойной длины.  also see: ensemble.f

REQUIRE  {        ~ac\lib\locals.f
REQUIRE  InVoc{   ~ac\lib\transl\vocab.f


: D<>  ( d1 d2 -- flag )
  S" D= 0=" EVALUATE
; IMMEDIATE

InVoc{ vocEnsembleD

0 
4 -- 'elemcount
4 -- 'elemcountmax
0 --  base
CONSTANT /header

(  8    4
   key  value
)
12 CONSTANT /el

\ Created-ensembleD
\ : ensembleD-Created  ( a-name len-name -- Ens ) 
\ ;

Public{

: Create-EnsembleD  ( n -- ) \ "name"
  CREATE  
  HERE >R
  DUP  /el *  /header + DUP ALLOT
  R@ SWAP ERASE
  R> 'elemcountmax !
;

: New-EnsembleD  ( n -- Ens ) 
  DUP  /el *  /header + DUP ALLOCATE THROW >R
  R@ SWAP ERASE
  R@ 'elemcountmax !  R>
;
: Del-EnsembleD ( Ens -- )
  FREE THROW
;

}Public



: []  ( i a-base -- dkey )
  SWAP /el * + 2@
;
: []!  ( dkey i a-base -- )
  SWAP /el * + 2!
;
: []^   ( i a-base -- a ) 
  SWAP /el * + 
;

: v[]  ( i a-base -- ai@ )
  SWAP /el * + 8 + @
;
: v[]!  ( value  i a-base -- )
  SWAP /el * + 8 + !
;
: v[]^   ( i a-base -- a ) 
  SWAP /el * + 8 +
;

: .ensembleD ( Ens -- )    \ для отладки
  DUP base SWAP
  'elemcount @  0 ?DO   CR 
      I OVER [] SWAP . .  I OVER v[] .
  LOOP DROP
;

: find_place  ( dkey  l r  mas -- j )  \ l <= j <= r \ l_0 = count
\ возвращает место элемента с таким же ключом или большим.
  { lkey hkey  l r   mas }
  BEGIN
    r l - 2 < IF
        l r = IF  l EXIT THEN
        l mas []  lkey hkey 
        D<  IF  r EXIT THEN
        l EXIT
    THEN
    l r + 2 /
    DUP mas []     ( j j_dkey )
    lkey hkey D<   IF -> l ELSE -> r THEN
  AGAIN
;

: _find_place  ( dkey  l r  mas -- j )  \ l <= r ; l <= j <= r
  { lkey hkey l r  mas }
  BEGIN
    l r <>           WHILE
    l mas [] lkey hkey D<   WHILE
    l 1+ -> l
  REPEAT THEN  l
;


Public{

: ensembleD+   ( value dkey  Ens \ n -- )  \ Ens-Include 
  { value  lkey hkey Ens  \ n }

  Ens 'elemcount @   Ens 'elemcountmax @  = IF EXIT THEN
  lkey hkey  0  Ens 'elemcount @   Ens base   find_place -> n
  n Ens 'elemcount @  < IF
      n  Ens base  []   lkey hkey D= IF EXIT THEN \ не обновляет значение.
      n  Ens base  []^  DUP /el +  \ откуда, куда
      Ens 'elemcount @  n - /el *  \ сколько
      MOVE
  THEN
  lkey hkey   n  Ens base   []!
  value n  Ens base  v[]!
  Ens 'elemcount  1+!
;

: ensembleD-   ( dkey Ens \ n -- )
  { lkey hkey Ens \ n }
  lkey hkey  0  Ens 'elemcount @  Ens base  find_place -> n
  n Ens 'elemcount @  =    IF EXIT THEN
  n  Ens base  []   lkey hkey D<> IF EXIT THEN
  n  Ens base  []^  DUP /el +  SWAP \ откуда, куда
  Ens 'elemcount @  n - 1-  /el *    \ сколько
  MOVE
  -1 Ens 'elemcount  +!
;

: ensembleD{}  ( dkey Ens \ n -- value true | dkey Ens -- false )
  { lkey hkey Ens \ n }
  lkey hkey  0  Ens 'elemcount @   Ens base   find_place -> n
  Ens 'elemcount @  n  =  IF FALSE EXIT THEN
  n  Ens base  [] lkey hkey  D<> IF FALSE EXIT THEN
  n  Ens base v[]  TRUE
;

: ensembleD{}^  ( dkey Ens \ n -- a  ) \ делает вставку пустого, если нету.
  { lkey hkey Ens \ n }

  lkey hkey  0  Ens 'elemcount @   Ens base   find_place -> n
  n Ens 'elemcount @  < IF 
      n  Ens base  []   lkey hkey D= IF \ нашелся.
        n  Ens base  v[]^   EXIT
      THEN
      Ens 'elemcount @   Ens 'elemcountmax @  = IF 0 EXIT THEN

      n  Ens base  []^  DUP /el +  \ откуда, куда
      Ens 'elemcount @  n - /el *  \ сколько
      MOVE
  ELSE \ не нашелся
      Ens 'elemcount @   Ens 'elemcountmax @  = IF 0 EXIT THEN
  THEN
  Ens 'elemcount  1+!
  lkey hkey  n  Ens base   []!
             n  Ens base  v[]^
  DUP 0!
;

: EnsembleD-ForEach  ( xt Ens -- )  
\ xt ( a-value -- )
  DUP base 8 + ( skip dkey ) SWAP 'elemcount @   /el * OVER + SWAP ?DO ( xt )
      I @ SWAP DUP >R EXECUTE R>   ( was:  I OVER EXECUTE )
  /el +LOOP  DROP
;

: EnsembleD-Volume ( Ens -- volume )
  'elemcount @
;

: .ensembleD  .ensembleD ;

}Public

}PrevVoc

\EOF
 ( example:

: .el  \ v -- \
\  CR  OVER . DUP CELL- @ . @ .
  CR  .
;
0 VALUE ens
: test  
  12  New-EnsembleD TO ens

  10  0 DO    I   I 0 ens ensembleD+  LOOP
  11 -2 DO CR I . I 0 ens ensembleD{} IF . ELSE ." not found" THEN LOOP
  11 -2 DO CR I . I 0 ens ensembleD{}^ ?DUP IF @ . ELSE ." out of band" THEN  LOOP
  CR
  0 ['] .el ens EnsembleD-ForEach DROP
  ens Del-EnsembleD
; \ )

 (
ALSO vocEnsembleD  DEFINITIONS
10 Create-EnsembleD  ens
0 10 10 ens ensembleD+ 
1 11 10 ens ensembleD+ 
2 09 10 ens ensembleD+ 
ens .ensembleD
\ )
