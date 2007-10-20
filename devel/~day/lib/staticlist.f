\ $Id$

\ двухсвязный динамический список

0
CELL -- .next
CELL -- .prev
CELL -- .list
\ дальше данные пользователя
VALUE /node

0
CELL -- .listNodeSize
CELL -- .listFirstNode
CELL -- .listLastNode
VALUE /list
   
: firstNode ( list -- addr | 0 )
\ Получить первый элемент списка
   .listFirstNode @
;

: CalculateLastNode ( list -- addr | 0 )
\ Найти последний элемент списка проходом по нему
   firstNode
   DUP IF
	   BEGIN
    	  DUP .next @
	   WHILE
    	  .next @
	   REPEAT
	THEN
;

: lastNode ( list -- addr | 0 )
\ Получить последний элемент списка
   .listLastNode @
;

: listNodeSize ( list - u )
\ Вернуть размер элемента списка
   .listNodeSize @
;

: NextCircleNode ( node -- node1 )
\ Вернуть следующий элемент списка, после последнего - первый
	DUP .next @ ?DUP IF
		NIP
	ELSE
		.list @ firstNode
	THEN
;
: PrevCircleNode ( node -- node1 )
\ Вернуть предыдущий элемент списка, после первого - последний
	DUP .prev @ ?DUP IF
		NIP
	ELSE
		.list @ lastNode
	THEN
;

: InsertNodeBegin ( addr list )
\ Вставить элемент addr в начало списка list, связать.
   2DUP SWAP .list ! ( addr list )
   
   DUP firstNode ( addr list first )
   ?DUP
   IF ( addr list first )
       ROT  2DUP .next ! ( list first addr )
       TUCK SWAP .prev ! ( list addr )
       SWAP ( addr list )
   ELSE ( addr list )
       2DUP .listLastNode !
   THEN       
   .listFirstNode !
;

: InsertNodeAfter ( addr node list -- )
   OVER 0= IF NIP InsertNodeBegin EXIT THEN

   ROT SWAP
   2DUP SWAP .list ! ( node addr list )
   OVER SWAP .listLastNode !

   2DUP .prev ! ( node addr )
   OVER .next @ OVER .next !
   DUP .next @ ?DUP
   IF
      OVER SWAP .prev !
   THEN 
   SWAP .next !
;

: InsertNodeEnd ( addr list )
   DUP lastNode SWAP
   InsertNodeAfter
;

: ZALLOCATE ( u -- addr )
\ Выделить память в хипе, обнулить
   DUP ALLOCATE THROW
   TUCK SWAP 0 FILL
;

: ZALLOT ( u -- addr )
\ Выделить память в словаре, обнулить
   HERE OVER ALLOT
   TUCK SWAP 0 FILL
;

: AllocateNodeBegin ( list -- addr | 0 )
\ Создать элемент списка в хипе, вставить в список, вернуть адрес
   DUP .listNodeSize @ ZALLOCATE \ list addr
   TUCK SWAP InsertNodeBegin
;
: AllocateNodeEnd ( list -- addr | 0 )
\ Создать элемент списка в хипе, вставить в список, вернуть адрес
   DUP .listNodeSize @ ZALLOCATE \ list addr
   TUCK SWAP InsertNodeEnd
;

: AllocateNode
   AllocateNodeBegin
;

: AllotNodeBegin ( list -- addr )
\ Создать элемент списка в словаре, вставить в список, вернуть адрес
   DUP .listNodeSize @ ZALLOT \ list addr
   TUCK SWAP InsertNodeBegin
;
: AllotNodeEnd ( list -- addr )
\ Создать элемент списка в словаре, вставить в список, вернуть адрес
   DUP .listNodeSize @ ZALLOT \ list addr
   TUCK SWAP InsertNodeEnd
;

: list: ( u  "ccc" )
\ Создать в словаре именованный список с данным размером элемента
  CREATE
    ,
    0 , \ first node
    0 , \ last node
  DOES>
;

: CreateList ( u -- addr )
\ Создать в хипе список с данным размером элемента, вернуть адрес
    /list ZALLOCATE TUCK !
;

: CreateStaticList ( u -- addr )
\ Создать в словаре список с данным размером элемента, вернуть адрес
    HERE
    /list ALLOT
    TUCK !
    DUP CELL+ 0. ROT 2!
;

: ForEach ( xt list -- )
\ Выполнить  xt для каждого элемента списка
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

: ?ForEachFrom ( xt node -- node | 0 )
\ Выполнить  xt для каждого элемента списка начиная с элемента node
\ xt ( node -- f ) если f = 0 то прекратить обход
   SWAP >R
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

: ?ForEach ( xt list -- node | 0 )
\ xt ( node -- f ) если f = 0 то прекратить обход
   firstNode ?ForEachFrom
;

: ForEach:
   ' 
   STATE @ 
   IF
     POSTPONE LITERAL
     POSTPONE SWAP
     POSTPONE ForEach
   ELSE SWAP ForEach
   THEN
; IMMEDIATE

: ?ForEach:
   ' 
   STATE @
   IF
     POSTPONE LITERAL
     POSTPONE SWAP
     POSTPONE ?ForEach
   ELSE SWAP ?ForEach
   THEN
; IMMEDIATE

: FreeNode ( node -- )
\ Удалить элемент списка
   DUP DUP .list @ lastNode =
   IF
      DUP .list @ DUP lastNode .prev @
      SWAP .listLastNode !      
   THEN
      
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

: FastFreeNode FREE THROW ;

: FreeList ( list -- )
\ Удалить все элементы списка
   ['] FastFreeNode SWAP ForEach
;

VARIABLE listSize_

: (listSize)
    1 listSize_ +!
    DROP
;

: listSize ( list -- u )
    listSize_ 0!
    ForEach: (listSize)
    listSize_ @
;

VARIABLE nth
VARIABLE nfind

: (listNth)
     DROP
    nth @ nfind @ = 0=
    nth 1+!
;

: list[] ( n list -- node | 0)
   SWAP nfind !
   DUP listSize 1- nfind @ <
   IF
      DROP 0 EXIT
   THEN 

   nth 0!
   ?ForEach: (listNth)
;

: (PrintList)
    >R
    ."   item: " R@ . CR
    ."   next: " R@ .next @ . CR
    ."   prev: " R> .prev @ . CR

;

: PrintList ( list -- )
    ." list " BASE @ SWAP DUP . CR
    ."   last node: " DUP lastNode . CR
    ."   first node: " DUP firstNode . CR
    ForEach: (PrintList)
    BASE !
;

\EOF
TESTCASES staticlist.f

/node
CELL -- .val
VALUE /myList

/myList list: bullets

: add ( u -- )
    bullets AllocateNodeEnd .val !
;

1 add
2 add
3 add
4 add

{ 2 bullets list[] .val @ -> 3 }

\ ====================

VARIABLE sum

: add .val @ sum +! ;

bullets ForEach: add

{ sum @ -> 10 }

\ =====================

VARIABLE res

: check ( node -- f ) DUP .val @ 3 = IF res ! 0 ELSE DROP -1 THEN ;

bullets ?ForEach: check DROP

{ res @ .val @ -> 3 }

\ =====================

{ bullets listSize -> 4 }
{ bullets CalculateLastNode -> bullets lastNode }
{ bullets lastNode .prev @ -> bullets lastNode FreeNode bullets lastNode  }

\ ==============
bullets FreeList
res 0!
{ bullets listSize -> 0 }
{ bullets lastNode -> 0 }

END-TESTCASES