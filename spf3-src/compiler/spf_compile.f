( Компиляция чисел и строк в словарь.
  ОС-независимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999, март 2000
)

  USER CURRENT     \ дает wid текущего словаря компиляции

  VARIABLE (DP)    \ переменная, содержащая HERE сегмента данных
5 CONSTANT CFL     \ длина кода, компилируемого CREATE в сегмент CS.
  USER     DOES>A  \ временная переменная - адрес для DOES>

: SET-CURRENT ( wid -- ) \ 94 SEARCH
\ Установить список компиляции на список, идентифицируемый wid.
  CURRENT !
;

: GET-CURRENT ( -- wid ) \ 94 SEARCH
\ Возвращает wid - идентификатор списка компиляции.
  CURRENT @
;

: IS-TEMP-WL ( -- flag )
\ проверяет, является ли текущий словарь компиляции временным (внешним)
  GET-CURRENT CELL- @ -1 =
;
: DP ( -- addr ) \ переменная, содержащая HERE сегмента данных
  IS-TEMP-WL
  IF GET-CURRENT 6 CELLS + ELSE (DP) THEN
;
: HERE ( -- addr ) \ 94
\ addr - указатель пространства данных.
  DP @
;

: ALLOT ( n -- ) \ 94
\ Если n больше нуля, зарезервировать n байт пространства данных. Если n меньше 
\ нуля - освободить |n| байт пространства данных. Если n ноль, оставить 
\ указатель пространства данных неизменным.
\ Если перед выполнением ALLOT указатель пространства данных выровнен и n
\ кратно размеру ячейки, он остается выровненным и после ALLOT.
\ Если перед выполнением ALLOT указатель пространства данных выровнен на
\ границу символа и n кратно размеру символа, он остается выровненным на
\ границу символа и после ALLOT.
  DP +!
;

: , ( x -- ) \ 94
\ Зарезервировать одну ячейку в области данных и поместить x в эту ячейку.
  HERE 4 ALLOT !
;

: C, ( char -- ) \ 94
\ Зарезервировать место для символа в области данных и поместить туда char.
  HERE 1 ALLOT C!
;

: W, ( word -- )
\ Зарезервировать место для word в области данных и поместить туда char.
  HERE 2 ALLOT W!
;

HEX

: COMPILE,  \ 94 CORE EXT
\ Интерпретация: семантика не определена.
\ Выполнение: ( xt -- )
\ Добавить семантику выполнения определения, представленого xt, к 
\ семантике выполнения текущего определения.
  0E8 C,              \ машинная команда CALL
  HERE CELL+ - ,
;

: BRANCH, ( ADDR -> ) \ скомпилировать инструкцию ADDR JMP
  0E9 C,
  HERE CELL+ - ,
;

: RET, ( -> ) \ скомпилировать инструкцию RET
  0C3 C,
;

: LIT, ( W -> )
\  081 C, 0ED C, 4 ,    \ SUB EBP, # 4
  083 C, 0ED C, 4 C,   \ более компактный вариант, tnx Valentine Zaretsky
  0C7 C, 045 C, 0 C, , \ MOV [EBP], DWORD #
;

: DLIT, ( D -> )
  SWAP LIT, LIT,
;

\ : ?BRANCH, ( ADDR -> ) \ скомпилировать инструкцию ADDR ?BRANCH
\   08B C, 045 C, 0 C, \ MOV EAX, [EBP]
\   083 C, 0C5 C, 4 C, \ более компактный вариант, tnx Valentine Zaretsky
\   00B C, 0C0 C,      \ OR  EAX, EAX
\   00F C, 084 C,      \ JZ
\   HERE CELL+ - ,
\ ;

: ?BRANCH, ( ADDR -> ) \ скомпилировать инструкцию ADDR ?BRANCH
\  08B C, 045 C, 0 C, \ MOV EAX, [EBP]
\  081 C, 0C5 C, 4 ,  \ ADD EBP, # 4
  083 C, 0C5 C, 4 C, \ более компактный вариант, tnx Valentine Zaretsky
\  00B C, 0C0 C,      \ OR  EAX, EAX
  083 C, 07D C, 0FC C, 0 C, \ CMP [EBP-4], # 0 --- 4 байта вместо пяти.
                            \ tnx Dmitry V. Abramov
  00F C, 084 C,      \ JZ
  HERE CELL+ - ,
;


DECIMAL

: ", ( A -> ) \ компиляция строки со счетчиком, заданной адресом A
  HERE OVER C@ 1+ DUP ALLOT CMOVE
;
: S", ( addr u -- ) \ компиляция строки, заданной addr u, в виде строки со счетчиком
  DUP C, HERE SWAP DUP ALLOT CMOVE
;

\ orig - a, 1 (short) или a, 2 (near)
\ dest - a, 3

: >MARK ( -> A )
  HERE 4 -
;

: >RESOLVE1 ( A -> )
  HERE OVER - 4 -
  SWAP !
;

: <MARK ( -> A )
  HERE
;

: >RESOLVE ( A, N -- )
  DUP 1 = IF   DROP >RESOLVE1
          ELSE 2 <> IF -2007 THROW THEN \ ABORT" Conditionals not paired"
               >RESOLVE1
          THEN
;

\ Слова для выравнивания (ALOGN*) в SPF не используются.
\ Оставлены для соответствия стандарту ANS 94.

USER ALIGN-BYTES

: ALIGNED ( addr -- a-addr ) \ 94
\ a-addr - первый выровненный адрес, больший или равный addr.
  ALIGN-BYTES @ 2DUP
  MOD ?DUP IF - + ELSE DROP THEN
;
: ALIGN ( -- ) \ 94
\ Если указатель пространства данных не выровнен -
\ выровнять его.
  HERE ALIGNED HERE - ALLOT
;


