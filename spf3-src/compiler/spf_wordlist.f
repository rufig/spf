( Создание словарых статей и словарей WORDLIST.
  ОС-независимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999, март 2000
)

VARIABLE VOC-LIST \ список словарей

VARIABLE LAST \ указывает на поле имени последней 
              \ скомпилированной словарной статьи
              \ в отличие от LATEST, которое дает
              \ адрес последнего слова в CURRENT

1 CONSTANT &IMMEDIATE \ константа для высечения флажка IMMEDIATE
2 CONSTANT &VOC

HERE ' VOC-LIST EXECUTE !

0 ,                   \ для VOC-LIST
HERE 0 ,              \ будет адрес последнего имени
0 ,                   \ будет адрес имени словаря
0 ,                   \ предок
0 ,                   \ класс
( создаем вручную, а не по WORDLIST, чтобы предок=0 )

VALUE FORTH-WORDLIST  ( -- wid ) \ 94 SEARCH
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

: +WORD ( A1, A2 -> ) \ добавление заголовка статьи с именем,
         \ заданным строкой со счетчиком A1, к списку, заданному
         \ переменной A2. Формирует только поля имени и связи с
         \ отведением памяти по ALLOT. В машинном слове по
         \ адресу A2 расположен адрес поля имени статьи, с
         \ которой начинается поиск в этом списке.
         \ пример: C" SP-FORTH" CONTEXT @ +WORD
  HERE LAST !
  HERE ROT ", SWAP DUP @ , !
;
: +SWORD ( addr u wid -> ) \ добавление заголовка статьи с именем,
         \ заданным строкой addr u, к списку, заданному wid.
         \ Формирует только поля имени и связи с
         \ отведением памяти по ALLOT.
  HERE LAST !
  HERE 2SWAP S", SWAP DUP @ , !
;

100000 VALUE WL_SIZE  \ размер памяти, выделяемой для временного словаря

LOAD-VERSION 1+ DUP VALUE VERSION  \ Версия (номер билда, точнее) SPF
SAVE-VERSION

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
;
\ для временных словарей дополнительные переменные:
\       0 , \ адрес загрузки временного словаря (адрес привязки)
\       0 , \ версия ядра, которой скомпилирован временный словарь
\       0 , \ DP временного словаря (текущий размер)


: TEMP-WORDLIST ( -- wid )
\ создаст временный словарь (в виртуальной памяти)

  WL_SIZE ALLOCATE THROW DUP >R WL_SIZE ERASE
  -1      R@ ! \ не присоединяем к VOC-LIST, заодно признак временности словаря
  R@      R@ 5 CELLS + !
  VERSION R@ 6 CELLS + !
  R@ 8 CELLS + DUP CELL- !
  R> CELL+
;
: FREE-WORDLIST ( wid -- )
  CELL- FREE THROW
;

: CLASS! ( cls wid -- ) CELL+ CELL+ CELL+ ! ;
: CLASS@ ( wid -- cls ) CELL+ CELL+ CELL+ @ ;
: PAR!   ( Pwid wid -- ) CELL+ CELL+ ! ;
: PAR@   ( wid -- Pwid ) CELL+ CELL+ @ ;

\ -5 -- cfa
\ -1 -- flags
\  0 -- NFA
\  1 -- name
\  n -- LFA

CODE NAME> ( NFA -> CFA )
     MOV EBX, [EBP]
     SUB EBX, # 5
     MOV EAX, [EBX]
     MOV [EBP], EAX
     RET
END-CODE

CODE NAME>C ( NFA -> 'CFA )
     SUB DWORD [EBP], # 5
     RET
END-CODE

CODE NAME>F ( NFA -> FFA )
     DEC DWORD [EBP]
     RET
END-CODE

CODE NAME>L ( NFA -> LFA )
     MOV EBX, [EBP]
     XOR EAX, EAX
     MOV AL, [EBX]
     ADD EAX, EBX
     INC EAX
     MOV [EBP], EAX
     RET
END-CODE

CODE CDR ( NFA1 -> NFA2 )
     MOV EBX, [EBP]
     OR EBX, EBX
     JZ @@1
     XOR EAX, EAX
     MOV AL, [EBX]
     ADD EBX, EAX
     INC EBX
     MOV EAX, [EBX]
     MOV [EBP], EAX
@@1:  RET
END-CODE

: ID. ( NFA[E] -> )
  COUNT TYPE
;

: ?IMMEDIATE ( NFA -> F )
  NAME>F C@ &IMMEDIATE AND
;

: ?VOC ( NFA -> F )
  NAME>F C@ &VOC AND
;

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
\ отладка - поиск слова по адресу в его теле

USER WBW-NFA
USER WBW-OFFS

: WordByAddrWl ( addr wid -- nfa offs )
  -1 1 RSHIFT WBW-OFFS !
  WBW-NFA 0!
  @
  BEGIN
    DUP
  WHILE
    2DUP - DUP 0 > 
        IF WBW-OFFS @ OVER > 
           IF WBW-OFFS ! DUP WBW-NFA !
           ELSE DROP THEN
        ELSE DROP THEN
    CDR
  REPEAT 2DROP
  WBW-NFA @ WBW-OFFS @
;

USER WB-NFA
USER WB-OFFS

: WordByAddr ( addr -- c-addr u )
  \ найти слово, телу которого принадлежит данный адрес
  (DP) @ OVER >
  IF 
     -1 1 RSHIFT WB-OFFS !
     WB-NFA 0!
     VOC-LIST @
     BEGIN
       DUP
     WHILE
       2DUP ( addr voc addr voc )
       CELL+ WordByAddrWl
             WB-OFFS @ OVER >
             IF WB-OFFS ! WB-NFA !
             ELSE 2DROP THEN
       @
     REPEAT 2DROP
     WB-NFA @ ?DUP IF COUNT ELSE S" <not found>" THEN
  ELSE DROP S" <not in the image>" THEN
;