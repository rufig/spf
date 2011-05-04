\ $Id$

( Создание словарых статей и словарей WORDLIST.
  ОС-независимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999, март 2000
)


VARIABLE _VOC-LIST \ список словарей

VECT VOC-LIST \ точка для модификаций

' _VOC-LIST ' VOC-LIST TC-VECT!  \ начальное значение (задан вирт. xt)


USER LAST     \ указывает на поле имени последней
              \ скомпилированной словарной статьи
              \ в отличие от LATEST, которое дает
              \ адрес последнего слова в CURRENT

1 CONSTANT &IMMEDIATE \ константа для высечения флажка IMMEDIATE
2 CONSTANT &VOC

WORDLIST VALUE FORTH-WORDLIST  ( -- wid ) \ 94 SEARCH
\ Возвратить wid - идентификатор списка слов, включающего все стандартные 
\ слова, обеспечиваемые реализацией. Этот список слов изначально список 
\ компиляции и часть начального порядка поиска.


: >BODY ( xt -- a-addr ) \ 94
\ a-addr - адрес поля данных, соответствующий xt.
\ Исключительная ситуация возникает, если xt не от слова,
\ определенного через CREATE.
(  1+ @ было в версии 2.5 )
  5 +
;

: +SWORD ( addr u wid -> ) \ добавление заголовка статьи с именем,
         \ заданным строкой addr u, к списку, заданному wid.
         \ Формирует только поля имени и связи с
         \ отведением памяти по ALLOT.
  HERE LAST !
  HERE 2SWAP S", SWAP DUP @ , !
;

: +WORD ( A1, A2 -> ) \ добавление заголовка статьи с именем,
         \ заданным строкой со счетчиком A1, к списку, заданному
         \ переменной A2. Формирует только поля имени и связи с
         \ отведением памяти по ALLOT. В машинном слове по
         \ адресу A2 расположен адрес поля имени статьи, с
         \ которой начинается поиск в этом списке.
         \ пример: C" SP-FORTH" CONTEXT @ +WORD
  SWAP COUNT ROT +SWORD
;

100000 VALUE WL_SIZE  \ размер памяти, выделяемой для временного словаря

LOAD-BUILD-NUMBER 1+ 
DUP SPF-KERNEL-VERSION 1000 * + VALUE VERSION  \ Версия и номер билда SPF в виде 4XXYYY
    SAVE-BUILD-NUMBER

CREATE BUILD-DATE
NOWADAYS ,"

: AT-WORDLIST-CREATING ( wid -- wid ) ... ;

: WORDLIST ( -- wid ) \ 94 SEARCH
\ Создает новый пустой список слов, возвращая его идентификатор wid.
\ Новый список слов может быть возвращен из предварительно распределенных 
\ списков слов или может динамически распределяться в пространстве данных.
\ Система должна допускать создание как минимум 8 новых списков слов в 
\ дополнение к имеющимся в системе.

  HERE VOC-LIST @ , VOC-LIST !
  HERE 0 , \ здесь будет указатель на имя последнего слова списка
       0 , \ здесь будет указатель на имя списка для именованых
       0 , \ wid словаря-предка
       0 , \ класс словаря = wid словаря, определяющего свойства данного
       0 , \ reserved, для расширений

  AT-WORDLIST-CREATING ( wid -- wid )
;
\ для временных словарей дополнительные переменные:
\       0 , \ адрес загрузки временного словаря (адрес привязки)
\       0 , \ версия ядра, которой скомпилирован временный словарь
\       0 , \ DP временного словаря (текущий размер)


: TEMP-WORDLIST ( -- wid )
\ создаст временный словарь (в виртуальной памяти)

  WL_SIZE ALLOCATE THROW DUP >R WL_SIZE ERASE
  -1      R@ ! \ не присоединяем к VOC-LIST, заодно признак временности словаря
  R@      R@ 6 CELLS + !
  VERSION R@ 7 CELLS + !
  R@ 9 CELLS + DUP CELL- !
  R> CELL+
;
: FREE-WORDLIST ( wid -- )
  CELL- FREE THROW
;

: VOC-NAME! ( c-addr wid --   )  CELL+ ! ;
: VOC-NAME@ ( wid -- c-addr|0 )  CELL+ @ ;  \ c-addr is an address of a counted string
: CLASS! ( cls wid -- ) CELL+ CELL+ CELL+ ! ;
: CLASS@ ( wid -- cls ) CELL+ CELL+ CELL+ @ ;
: PAR!   ( Pwid wid -- ) CELL+ CELL+ ! ;
: PAR@   ( wid -- Pwid ) CELL+ CELL+ @ ;
: WID-EXTRA ( wid -- addr )  4 CELLS + ; \ свободная для расширений ячейка 
\ Каждое расширение переопределяет это слово, чтобы даваемая ячейка была свободна.


\ -5 -- cfa
\ -1 -- flags
\  0 -- NFA
\  1 -- name
\  n -- LFA

CODE NAME> ( NFA -> CFA )
     MOV EAX, -5 [EAX]
     RET
END-CODE

CODE NAME>C ( NFA -> 'CFA )
     LEA EAX, -5 [EAX]
     RET
END-CODE

CODE NAME>F ( NFA -> FFA )
     LEA EAX, -1 [EAX]
     RET
END-CODE

CODE NAME>L ( NFA -> LFA )
     MOVZX EBX, BYTE [EAX]
     LEA EAX, [EBX] [EAX]
     LEA EAX, 1 [EAX]
     RET
END-CODE

CODE CDR ( NFA1 -> NFA2 )
     OR EAX, EAX
     JZ SHORT @@1
      MOVZX EBX, BYTE [EAX]
      MOV EAX, 1 [EBX] [EAX]
@@1: RET
END-CODE

: ID. ( NFA[E] -> )
  COUNT TYPE
;

: IS-IMMEDIATE ( NFA -> F )
  NAME>F C@ &IMMEDIATE AND
;
: IS-VOC ( NFA -> F )
  NAME>F C@ &VOC AND
;

\ для обратной совместимости:
: ?IMMEDIATE ( NFA -> F ) IS-IMMEDIATE ;
: ?VOC ( NFA -> F ) IS-VOC ;


: IMMEDIATE ( -- ) \ 94
\ Сделать последнее определение словом немедленного исполнения.
\ Исключительная ситуация возникает, если последнее определение
\ не имеет имени.
  LAST @ NAME>F DUP C@ &IMMEDIATE OR SWAP C!
;

: VOC ( -- )
\ Пометить последнее определенное слово признаком "словарь".
  LAST @ NAME>F DUP C@ &VOC OR SWAP C!
;

\ ==============================================
\ рефлексивность - перебор словарей и слов

: IS-CLASS-FORTH ( wid -- flag )
  CLASS@ DUP 0= SWAP FORTH-WORDLIST = OR
;
: ENUM-VOCS ( xt -- )
\ xt ( wid -- )
  >R VOC-LIST @ BEGIN DUP WHILE
    DUP CELL+ ( a wid ) R@ ROT @ >R
    EXECUTE R>
  REPEAT DROP RDROP
;
: (ENUM-VOCS-FORTH) ( xt wid -- xt )
  DUP IS-CLASS-FORTH IF SWAP DUP >R EXECUTE R> EXIT THEN DROP
;
: ENUM-VOCS-FORTH ( xt -- )
\ перебор только обычных форт-словарей (у которых CLASS равен 0 или FORTH-WORDLIST )
\ xt ( wid -- )
  ['] (ENUM-VOCS-FORTH) ENUM-VOCS  DROP
;
: FOR-WORDLIST  ( wid xt -- ) \ xt ( nfa -- )
  SWAP @ BEGIN  DUP WHILE ( xt NFA ) 2DUP 2>R SWAP EXECUTE 2R> CDR REPEAT  2DROP
;

\ ==============================================
\ отладка - поиск слова по адресу в его теле

: (NEAREST1) ( addr 0|nfa1 nfa2 -- addr 0|nfa1|nfa2 )
  DUP 0= IF DROP EXIT THEN >R
  \ сравниваем xt (адреса начала кода, cfa @)
  2DUP  DUP IF  NAME> THEN 1-
  SWAP  R@ NAME> 1- ( a1 addr a2 ) WITHIN IF DROP R> EXIT THEN RDROP
  \ 1- т.к. WITHIN строгое здесь
;
: (NEAREST2) ( addr nfa1 wid -- addr nfa2 )
  ['] (NEAREST1) FOR-WORDLIST
;
: (NEAREST3) ( addr nfa1 -- addr nfa2 )
  ['] (NEAREST2) ENUM-VOCS-FORTH
;

VECT (NEAREST-NFA) ( addr nfa1 -- addr nfa2 )

' (NEAREST3) ' (NEAREST-NFA) TC-VECT!

: (WordByAddr) ( addr -- c-addr u )
  0 (NEAREST-NFA)
  DUP 0= IF 2DROP S" <?not in the image>" EXIT THEN
  ( addr nfa )
  TUCK NAME> - ABS 4096 U< IF COUNT EXIT THEN
  \ расстояние следует проверять от xt, а не от nfa
  \ ( -- очень актуально в случае алиасов)
  DROP S" <?not found>"
;
: WordByAddr ( addr -- c-addr u )
  ['] (WordByAddr) CATCH  ?DUP IF ."  EXC:" . DROP S" <?WordByAddr exception>" EXIT THEN
  255 UMIN
;
: (WordByAddrSilent) ( addr -- c-addr u )
  0 (NEAREST-NFA) DUP 0= IF NIP DUP ( 0 0 ) EXIT THEN
  TUCK - ABS 4096 U< IF COUNT EXIT THEN
  0 ( caddr 0 )
;
: WordByAddrSilent ( addr -- c-addr u )
  ['] (WordByAddrSilent) CATCH  ?DUP IF ."  EXC:" . 0 ( x 0 ) THEN
  255 UMIN
;

\ для обратной совместимости:
: NEAR_NFA ( addr -- nfa|0 addr )
  0 (NEAREST-NFA) SWAP
;
