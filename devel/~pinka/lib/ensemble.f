
\ 14.Apr.2001 
\ добавление ensemble{}^
\            Ensemble-ForEach
\            Ensamble-Volume
\ * Ensemble-ForEach итерирует по _значениям_ (было по адресам значений)


\ 06.07.2000  ruv

( реализация множеств произвольных элементов.

  Элемент состоит из ключа [1 CELLS] и значения [1 CELLS] 
  элементы идендифицируются ключом.
  элементы во множестве не повторяются.

  множество имеет размер [число элементов] и, возможно, именя.
  Задания множества
    - в словаре:    число_элементов -- идендификатор
    - в словаре:    имя число_элементов --  \ имя:   -- идендификатор
    - динамически:  число_элементов -- идендификатор

  Операции
    добавление элемента [ключ значение] ко множеству.
    получение значения по ключу.
    исключение элемента из множества  по ключу.
    получить число элементов в множестве [?]

  Множество реализуется в виде упорядоченного по ключам массива.
  Выбрка производится бинарным поиском ключа в массиве.
  При добавлении элемента, для него ищется его место, остальные сдвигаются.

  Основное назначение - ассоциация ключа со значением.
)

(
    multitude \
               > ?
    ensemble  /       ансамбль. ?. ;]
)



\ Create-Ensemble  ( n -- ) \ "name"
\ создать множесто на n элементов в области словаря
\ name ( -- Ens )  - дает идендификатор множества

\ New-Ensemble  ( n -- Ens ) 
\ создать множесто на n элементов в динамически распределяемой памяти.

\ Del-Ensemble ( Ens -- )
\ освобождение, если создано динамически.

\ ensemble+   ( key value  Ens -- )
\ добавить элемент [key value] к множеству Ens

\ ensemble-   ( key Ens -- )
\ исключить элемент, идендифицируемый key из мнжества Ens

\ ensemble{}  ( key Ens -- value true |  key Ens -- false )
\ получить значение по key  из множества Ens
\ value - значение элемента, идендифецированного ключом key (если он есть в множестве)
\ {} - говорит о том, что доступ происходит по ключу
\ ( когда [] - что доступ по индексу...)


REQUIRE  {        ~ac\lib\locals.f
REQUIRE  InVoc{   ~ac\lib\transl\vocab.f

InVoc{ vocEnsemble

0 
4 -- 'elemcount
4 -- 'elemcountmax
0 --  base
CONSTANT /header

(  4    4
   key  value
)
8 CONSTANT /el

\ Created-Ensemble
\ : Ensemble-Created  ( a-name len-name -- Ens ) 
\ ;

Public{

: Create-Ensemble  ( n -- ) \ "name"
  CREATE  
  HERE >R
  DUP  /el *  /header + DUP ALLOT
  R@ SWAP ERASE
  R> 'elemcountmax !
;

: New-Ensemble  ( n -- Ens ) 
  DUP  /el *  /header + DUP ALLOCATE THROW >R
  R@ SWAP ERASE
  R@ 'elemcountmax !  R>
;
: Del-Ensemble ( Ens -- )
  FREE THROW
;

}Public



: []  ( i a-base -- ai@ )
  SWAP /el * + @
;
: []!  ( key i a-base -- )
  SWAP /el * + !
;
: []^   ( i a-base -- a ) 
  SWAP /el * + 
;

: v[]  ( i a-base -- ai@ )
  SWAP /el * + CELL+ @
;
: v[]!  ( value  i a-base -- )
  SWAP /el * + CELL+ !
;
: v[]^   ( i a-base -- a ) 
  SWAP /el * + CELL+
;

: .ensemble ( Ens -- )    \ для отладки
  DUP base SWAP ( a-base Ens )
  'elemcount @  0 ?DO   CR 
      I OVER [] .  I OVER v[] .
  LOOP DROP
;

: find_place  { key  l r  mas -- j }  \ l <= j <= r \ r_0 = count
\ возвращает место элемента с таким же ключом или большим.
  BEGIN
    r l - 2 < IF
        l r = IF  l EXIT THEN
        l mas []  key U<  IF  r EXIT THEN
        l EXIT
    THEN
    l r + 2 /
    DUP mas []     ( j j_key )
    key U<  IF -> l ELSE -> r THEN
  AGAIN
;

: _find_place  { key  l r  mas -- j }  \ l <= r ; l <= j <= r
  BEGIN
    l r <>           WHILE
    l mas [] key U<  WHILE
    l 1+ -> l
  REPEAT THEN  l
;


Public{

: ensemble+   { value key Ens \ n -- }  \ Ens-Include 
  Ens 'elemcount @   Ens 'elemcountmax @  = IF EXIT THEN
  key  0  Ens 'elemcount @   Ens base   find_place -> n
  n Ens 'elemcount @  U< IF
      n  Ens base  []   key = IF EXIT THEN
      n  Ens base  []^  DUP /el +  \ откуда, куда
      Ens 'elemcount @  n - /el *  \ сколько
      MOVE
  THEN
  key   n  Ens base   []!
  value n  Ens base  v[]!
  Ens 'elemcount  1+!
;

: ensemble-   { key Ens \ n -- }
  key  0  Ens 'elemcount @  Ens base   find_place -> n
  n Ens 'elemcount @  =    IF EXIT THEN
  n  Ens base  []   key <> IF EXIT THEN
  n  Ens base  []^   DUP /el +  SWAP \ откуда, куда
  Ens 'elemcount @  n - 1-  /el *    \ сколько
  MOVE
  -1 Ens 'elemcount  +!
;

: ensemble{}  { key Ens \ n -- value true | key Ens -- false }
  key  0  Ens 'elemcount @  DUP >R   Ens base   find_place -> n
  R> n  =  IF FALSE EXIT THEN
  n  Ens base  [] key <> IF FALSE EXIT THEN
  n  Ens base v[]  TRUE
;

: ensemble{}^  { key Ens \ n -- a  } \ делает вставку пустого, если нету.
  key  0  Ens 'elemcount @   Ens base   find_place -> n
  n Ens 'elemcount @  U< IF 
      n  Ens base  []   key = IF \ нашелся.
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
  key  n  Ens base   []!
       n  Ens base  v[]^
  DUP 0!
;

: Ensemble-ForEach  ( xt Ens -- )  
\ xt ( value -- )
  DUP base CELL+ ( skip key ) SWAP 'elemcount @   /el * OVER + SWAP ?DO  ( xt )
      I @ SWAP DUP >R EXECUTE R>
  /el +LOOP  DROP
;
        
: Ensemble-Volume ( Ens -- volume )  \ Ensemble-Power \?
  'elemcount @
;

: .ensemble  .ensemble ;


}Public

}PrevVoc
\EOF
 ( example:
: test  { \ ens -- }
  10  New-Ensemble -> ens
  10  0 DO I 2/   I ens ensemble+  LOOP
  11 -1 DO CR I . I ens ensemble{} IF . ELSE ." not found" THEN LOOP
  ens Del-Ensemble
; \ )

 ( example:
REQUIRE .S lib\include\tools.f
: .el  \ a -- \
\  CR .S DUP CELL- @ . @ .  
   CR .S .
;
: test  
  12  New-Ensemble 
  10  0 DO DUP I 2/   I ROT ensemble+  LOOP
  11 -2 DO CR I . I OVER ensemble{} IF . ELSE ." not found" THEN LOOP
  11 -2 DO CR I . I OVER ensemble{}^ ?DUP IF @ . ELSE ." out of band" THEN  LOOP
  CR
  ['] .el OVER Ensemble-ForEach
  Del-Ensemble
; \ )

 (
ALSO vocEnsemble  DEFINITIONS
10 Create-Ensemble  ens
0 10  ens ensemble+ 
1 11  ens ensemble+ 
2 09  ens ensemble+ 
\ )
