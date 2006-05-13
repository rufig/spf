REQUIRE ==   ~yz/lib/common.f
REQUIRE { lib/ext/locals.f
REQUIRE MGETMEM ~yz/lib/gmem.f
REQUIRE LOAD-CONSTANTS     ~yz/lib/wincons.f

: OR! ( n a -- ) SWAP OVER @ OR SWAP ! ;
: ORC! ( c a -- ) SWAP OVER C@ OR SWAP C! ;

\ Это будет наш объект, изображающий окна, кнопочки и т.д.
\ Не понимаю, зачем заводить настоящие объекты с наследованием и прочей
\ ерундой, если достаточно и обыкновенной таблицы с данными, а к ней - нужные слова
\ формат таблицы:
\ +0	b	флаги (см. ниже)
\ +1	с	данные / адрес слова get
\ +5	с	адрес слова set
\ для таблиц-шаблонов в начале еще стоит ячейка с числом записей

\ Флаги
\ 7	есть процедура-getter
\ 6	есть процедура-setter
\ 5	разделяемый объект	(пока не используется)
\ 3-0	тип данных              (пока не используется)

0x40 == set-flag
0xC0 == getset-flag

: getter? ( a -- ?) C@ 0x80 AND ;
: setter? ( a -- ?) C@ 0x40 AND ;
: shared? ( a -- ?) C@ 0x20 AND ;
: datatype ( a -- ) C@ 0x0F AND ;

\ Типы данных
\ 0 == _val  \ значение
\ 1 == _mem  \ область памяти, подлежит уничтожению через FREEMEM
\ 2 == _gdi  \ объект GDI, подлежит уничтожению через DeleteObject

2 CELLS 1+ == #tab

0 VALUE saved-names

: getproc ( index tab -- )
  >R #tab * R@ + DUP getter? IF 1+ @ R@ SWAP EXECUTE ELSE 1+ @ THEN RDROP ;

: setproc ( value index tab -- )
  >R #tab * R@ + DUP setter? IF 1+ CELL+ @ R@ SWAP EXECUTE ELSE 1+ ! THEN RDROP 
;

: indtab>a ( index tab -- addr) SWAP #tab * + 1+ ;
: store ( value index tab --) indtab>a ! ;
: storeset ( setproc index tab) indtab>a CELL+ ! ;
: setitem ( value1 value2 index tab -- )
  indtab>a >R
  SWAP R@ !
  R> CELL+ ! ;
: setflagitem ( val1 val2 flag index tab -- )
  indtab>a >R
  R@ 1- C!
  SWAP R@ !
  R> CELL+ ! ;

: make-getter ( ; index -- )
  DOES> ( tab -- ...) @ SWAP getproc ;
: make-setter ( ; index -- )
  DOES> ( ... tab -- ...) @ SWAP setproc ;
: make-constant ( ; index -- )
  DOES> ( -- index) @ ;

: table ( ->bl; parenttable/0 -- a)
  TEMP-WORDLIST TO saved-names
  CREATE HERE >R
  ?DUP IF 
    ( ptable) DUP CELL- @ DUP , #tab * DUP ALLOT ( pt #) R@ CELL+ SWAP CMOVE
  ELSE 
    0 ,
  THEN
  R>
  DOES> CELL+
;

: generate-names
  saved-names @
  BEGIN
    DUP
  WHILE
    DUP NAME> >BODY @ >R
    DUP COUNT ( a a2 n) >R PAD R@ CMOVE
    PAD R@ CREATED R>
    R@ , make-constant >R
    c: @ PAD R@ + C!
    PAD R@ 1+ CREATED R>
    R@ , make-getter
    DUP PAD + c: ! SWAP C!
    PAD SWAP 1+ CREATED
    R> , make-setter
    CDR
  REPEAT DROP ;

: endtable ( a -- ) 
  DROP 
  generate-names
  saved-names FREE-WORDLIST
;

: save-name ( ->bl; n --)
  GET-CURRENT >R
  saved-names SET-CURRENT
  CREATE ,
  R> SET-CURRENT
;

VARIABLE lastitem
: item ( ->bl ; a n -- a) 
  HERE lastitem !
  0 C, 0 , 0 ,  DUP @ save-name DUP 1+! ;

: shared  0x20 lastitem @ ORC! ;
: set  set-flag lastitem @ ORC! ;
: getset  getset-flag lastitem @ ORC! ;
: type ( n -- ) lastitem @ ORC! ;

: new-table ( table -- a)
  DUP CELL- @ #tab * DUP MGETMEM ( table # a )
  2DUP SWAP ERASE
  DUP >R SWAP CMOVE
  R> ;  

: del-table ( table -- ) MFREEMEM ;

\ ----------------------------------------
\ Формат универсальной таблицы:
\ +0 cell   число записей
\ +4 cell   текущий указатель
\ +8 ...    данные
: :no ;
: :ptr CELL+ ;
: :data 2 CELLS+ ;

: create-utable ( bytes -- ut)
  MGETMEM DUP :no 0! DUP :data OVER :ptr ! ;
: destroy-utable ( ut -- ) MFREEMEM ;
: u>> ( n ut -- )
  >R R@ :ptr @ !  R> :ptr CELL+! ;
: uw>> ( w ut -- )
  >R R@ :ptr @ W!  2 R> :ptr +! ;
: uc>> ( c ut -- )
  >R R@ :ptr @ C!  R> :ptr 1+! ;
: uan>> { a n ut -- }
  a ut :ptr @ n CMOVE
  n ut :ptr +! ;
: ut++ ( ut -- ) :no 1+! ;
: utable-size ( ut -- bytes )
  >R R@ :ptr @ R> :data - 0 :data + ;
: land-utable ( ut -- adr )
  >R HERE R@ OVER R> utable-size DUP ALLOT CMOVE ;
: land-utable-without-header ( ut -- adr )
  >R HERE R@ :data OVER R> utable-size 0 :data - DUP ALLOT CMOVE ;


\ Формат XtTable:
\ +0 c	количество записей
\ +4 c  поле связи
\ записи по две ячейки каждая:
\ id, xt

2 CELLS == #xttable

: :link CELL+ ;

VARIABLE xtname
0 VALUE xttable

0 VALUE ytable

: init-xtptr 
  300 CELLS create-utable TO xttable ;
: >xtptr ( n -- ) xttable u>> ;

: save-xtname ( a # -- )
  DUP 1+ MGETMEM xtname !
  DUP xtname @ C!  xtname @ 1+ SWAP CMOVE ;

: init-yptr
  100 CELLS create-utable TO ytable ;
: >yptr ( n -- ) ytable u>> ;
: c>yptr ( c -- ) ytable uc>> ;
: >>yptr ( a # -- )
  DUP >R ytable :ptr @ CZMOVE  R> 1+ ytable :ptr +! ;

: MESSAGES: ( ->bl; -- )
  BL PARSE save-xtname
  init-xtptr ;

: create-saved-xtname  
  xtname @ COUNT CREATED 
  xtname @ MFREEMEM ;

: land-xttable  ( -- )
  xttable land-utable :link 0! ;

: land-ytable ( -- )
  ytable land-utable-without-header DROP ;

: MESSAGES; ( -- )
  create-saved-xtname
  land-xttable  xttable destroy-utable
;

: :M ( -- xt secret-sign)
  :NONAME CELL" M:  "
;

: M: ( ->message-name; -- msg# xt secret-sign)
  BL PARSE FIND-CONSTANT2 :M
;

: M; ( msg# xt secret-sign -- )
  CELL" M:  " <> ABORT" M; без M:"
  S" ;" EVAL-WORD
  ( msg# xt ) SWAP >xtptr >xtptr  xttable ut++
; IMMEDIATE

\  xlist:
\ +0 n	указатель на первый элемент списка / 0
\ +4 n	указатель на последний элемент списка

: XLIST ( ->bl; -- )
  CREATE 0 , 0 , ;

: create-xlist ( -- xlist)
  0 0 2 CELLS MGETMEM DUP >R 2! R> ;

: empty-xlist ( xlist -- )
  0 0 ROT 2! ;
  
: insert-to-begin { xtable xlist -- }
  xlist @ IF
    xlist @ xtable :link !
  ELSE
    xtable :link 0!
    xtable xlist CELL+ !
  THEN 
  xtable xlist ! 
;

: insert-to-end { xtable xlist -- }
  xlist @ IF
    xtable xlist CELL+ @ :link !
  ELSE
    xtable xlist ! 
  THEN 
  xtable :link 0!
  xtable xlist CELL+ !
;

: find-in-xtable ( id xttable -- result true / false)
  DUP 0= IF 2DROP FALSE EXIT THEN
  DUP @ #xttable * SWAP 2 CELLS+ DUP >R + R>
  ?DO
    DUP I @ = IF DROP I CELL+ @ EXECUTE TRUE UNLOOP EXIT THEN
  #xttable +LOOP
  DROP FALSE ;

\ если вызванное слово вернуло false, делаем вид, что ничего не нашли
: ?find-in-xtable ( id xttable -- ?)
  find-in-xtable DUP IF DROP THEN ;

USER-VALUE return-value
USER-VALUE this-xlist
USER-VALUE this-id

: RETURN ( n -- ) TO return-value ;

: find-and-execute ( id xlist -- ? )
  TO this-xlist  TO this-id
  this-xlist 0= IF FALSE EXIT THEN
  this-xlist @ ?DUP 0= IF FALSE EXIT THEN
  TO this-xlist
  BEGIN
    this-id this-xlist find-in-xtable ?DUP IF EXIT THEN
    this-xlist :link @ DUP TO this-xlist
  0= UNTIL 
  FALSE ;

: ?find-and-execute ( id xlist -- ? )
  TO this-xlist  TO this-id
  this-xlist 0= IF FALSE EXIT THEN
  this-xlist @ ?DUP 0= IF FALSE EXIT THEN
  TO this-xlist
  BEGIN
    this-id this-xlist ?find-in-xtable ?DUP IF EXIT THEN
    this-xlist :link @ DUP TO this-xlist
  0= UNTIL 
  FALSE
;
