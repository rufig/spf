
\ двухсвязный список для небольшого кол-ва элементов

0
CELL -- .next
CELL -- .prev
CELL -- .list
\ дальше данные пользователя
VALUE /node

0
CELL -- .listNodeSize
CELL -- .listFirstNode
\ CELL -- .listLastNode
VALUE /list
   
: firstNode ( list -- addr | 0 )
   .listFirstNode @
;
\ : lastNode ( list -- addr | 0 )
\   .listLestNode @
\ ;

: listNodeSize ( list - u )
   .listNodeSize @
;

: InsertNode ( addr list )
   2DUP SWAP .list !
   
   DUP firstNode
   ?DUP
   IF
       \ addr list fnode
       ROT  2DUP .next ! \ list fnode addr
       TUCK SWAP .prev !
       SWAP
   THEN       
   .listFirstNode !
;

: ZALLOCATE ( u -- addr ior )
   DUP ALLOCATE THROW
   TUCK SWAP 0 FILL
;

: AllocateNode ( list -- addr | 0 )
   DUP .listNodeSize @ ZALLOCATE \ list addr
   TUCK SWAP InsertNode
;

: list: ( u  "ccc" )
\ u размер элемента
  CREATE
    ,
    0 , \ first node
  DOES>
;

: ForEach ( xt list -- )
\ xt ( node -- )
   SWAP >R
   firstNode
   BEGIN
      DUP
   WHILE
      DUP .next @
      SWAP R@ EXECUTE
   REPEAT R> 2DROP
;

: ?ForEach ( xt list -- node | 0 )
\ xt ( node -- f ) если f = 0 то прекратить обход
   SWAP >R
   firstNode
   BEGIN
      DUP
   WHILE
      DUP .next @ \ curr next
      OVER R@ EXECUTE \ curr next f
      0= IF R> 2DROP EXIT 
         ELSE NIP
         THEN
   REPEAT R> 2DROP 0
;

: ForEach:
   ' POSTPONE LITERAL
     POSTPONE SWAP
     POSTPONE ForEach
; IMMEDIATE

: ?ForEach:
   ' POSTPONE LITERAL
     POSTPONE SWAP
     POSTPONE ?ForEach
; IMMEDIATE

: FreeNode ( node -- )
   >R
   R@ .prev @ ?DUP
   IF
      R@ .next @ SWAP .next !
   THEN
   
   R@ .next @ ?DUP
   IF
      R@ .prev @ SWAP .prev !
   THEN
   
   R@ DUP .list @ firstNode =
   IF
     R@ .next @ R@ .list @ .listFirstNode !
   THEN
   
   R> FREE THROW
;

: FreeList ( list -- )
   ['] FreeNode SWAP ForEach
;

VARIABLE listSize_

: (listSize)
    1 listSize_ +!
    DROP
;

: listSize ( list -- u )
    listSize_ 0!
    ['] (listSize) SWAP ForEach
    listSize_ @
;

\EOF

.( =====================================) CR
/node
CELL -- .val
VALUE /myList

/myList list: bullets

0 VALUE lastAdded
: add
	bullets AllocateNode TO lastAdded
;

add lastAdded .val 1 SWAP !
add lastAdded .val 2 SWAP !
add lastAdded .val 3 SWAP !
lastAdded FreeNode
add lastAdded .val 4 SWAP !

: print
    .val @ . CR
;
' print bullets ForEach

BYE

\EOF

/node
CELL -- .val
VALUE /myList

/myList list: bullets

bullets AllocateNode .val 1 SWAP !
bullets AllocateNode .val 2 SWAP !
bullets AllocateNode .val 3 SWAP !
bullets AllocateNode .val 4 SWAP !

: print
    .val @ . CR
;

: (DeleteThird) ( node - f )
    DUP .val @ 3 =
    IF
       FreeNode
    ELSE DROP
    THEN
    -1
;

: DeleteThird
   ['] (DeleteThird) bullets ?ForEach DROP
;

: test
   ['] print bullets ForEach
   DeleteThird CR
   ['] print bullets ForEach
   bullets FreeList
;

test