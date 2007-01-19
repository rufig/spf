\ Бэкфорт, порт на SPF
\ см. http://forth.org.ru/~mlg/index.html#bacforth

REQUIRE /TEST ~profit/lib/testing.f
REQUIRE >L ~profit/lib/lstack.f
REQUIRE (: ~yz/lib/inline.f

MODULE: bac4th
: ?PAIRS <> ABORT" unpaired" ;
: >RESOLVE2 ( dest -- ) HERE SWAP ! ;
: <RESOLVE ( org -- )	, ;

: CALL, ( ADDR -- ) \ скомпилировать инструкцию ADDR CALL
  ?SET SetOP SetJP 0xE8 C,
  DUP IF DP @ CELL+ - THEN ,    DP @ TO LAST-HERE
;

12345 CONSTANT $TART
5432 CONSTANT 8ACK
4523 CONSTANT N0T
466736473 CONSTANT a99reg4te

: (ADR2) R> DUP CELL+ CELL+ >R ;

EXPORT

: ENTER POSTPONE EXECUTE ; IMMEDIATE ( \ это тоже самое, но что быстрее?
: ENTER   >R ;                           \ )

DEFINITIONS


: (NOT:)  R> RP@ >L  DUP @ >R CELL+ ENTER LDROP ;
: (-NOT)  L> RP! ;
: (-NOT2) R> L> RP! >R ;

EXPORT

: ONFALSE IF RDROP THEN ;
: ONTRUE 0= IF RDROP THEN ;

: R@ENTER, 0xFF C, 0x14 C, 0x24 C, ; \ CALL [ESP]
\ POSTPONE R@ POSTPONE EXECUTE

: PRO R> R> >L ENTER LDROP ;
\ : CONT L> >R R@ ENTER R> >L ;
: CONT L> >R [ R@ENTER, ] R> >L ;
\ : CONT (: L> >R ;) INLINE, R@ENTER, (: R> >L ;) INLINE, ; IMMEDIATE
\ Отключение оптимизатора ломает INLINE,

: RUSH
0x8B C, 0xD8 C,         \ MOV EBX, EAX
0x8B C, 0x45 C, 0x00 C, \ MOV EAX, 0 [EBP]
0x8D C, 0x6D C, 0x04 C, \ LEA EBP, 4 [EBP]
0xFF C, 0xE3 C,         \ JMP EBX
; IMMEDIATE

: RUSH> ?COMP ' BRANCH, ; IMMEDIATE \ Да-да, это GOTO...

\ обратимые операции
\ : RESTB  ( n --> n  / n <--  ) R>  OVER >R  ENTER   R> ; ( 
: RESTB [
0x5B C,                 \ POP EBX
0x50 C,                 \ PUSH EAX
0xFF C, 0xD3 C,         \ CALL EBX
0x89 C, 0x45 C, 0xFC C, \ MOV -4 [EBP] , EAX
0x58 C,                 \ POP EAX
0x8D C, 0x6D C, 0xFC C, \ LEA EBP, -4 [EBP]
] ; \ )


\ : 2RESTB ( d --> d  / d <--  ) R>  -ROT 2DUP 2>R ROT  ENTER   2R> ; (
: 2RESTB [
0x5B C,                 \ POP EBX
0xFF C, 0x75 C, 0x00 C, \ PUSH [EBP]
0x50 C,                 \ PUSH EAX
0xFF C, 0xD3 C,         \ CALL EBX
0x89 C, 0x45 C, 0xFC C, \ MOV -4 [EBP] , EAX
0x58 C,                 \ POP EAX
0x8D C, 0x6D C, 0xF8 C, \ LEA EBP, -8 [EBP]
0x8F C, 0x45 C, 0x00 C, \ POP [EBP]
] ; \ )

: BSWAP  ( a b <--> b a )      SWAP R> ENTER  SWAP ;
: SWAPB  ( a b <--> b a )      R> ENTER  SWAP ;
: BDROP  ( n <--> )            R>  SWAP >R  ENTER  R> ;
: DROPB  ( n --> n / <-- n )   R>  ENTER DROP ;
: 2DROPB ( n --> n / <-- n )   R>  ENTER 2DROP ;
: KEEP   ( addr --> / <-- )    R> SWAP DUP @  2>R ENTER 2R> SWAP ! ;
: B!     ( n addr --> / <-- )  R> OVER DUP @  2>R -ROT !  ENTER 2R> SWAP ! ;
: BC!    ( n addr --> / <-- )  R> OVER DUP C@ 2>R -ROT C!  ENTER 2R> SWAP C! ;


\ задать действия при откате ( BACK .. TRACKING ), или, иначе говоря,
\ положить адрес начала последовательности шитого между словами на стек возвратов
: BACK  ?COMP  0 CALL, >MARK 8ACK ;  IMMEDIATE
: TRACKING ?COMP  8ACK ?PAIRS  RET, >RESOLVE1 ;  IMMEDIATE
\ BACK ... TRACKING -- это аналог (: ... ;) >R , и наоборот,
\ (: ... ;) -- это аналог BACK ... TRACKING R>

: START{ ( -- org dest $TART )
?COMP
0 RLIT, >MARK
<MARK $TART
; IMMEDIATE

: DIVE ?COMP
DUP $TART = IF OVER COMPILE, THEN
; IMMEDIATE


: }EMERGE
?COMP
$TART ?PAIRS DROP
RET,
>RESOLVE2
; IMMEDIATE

: S| PRO BACK SP! TRACKING SP@ BDROP CONT ; \ Восстановление стека
\ Нужно для обеспечения баланса стека при прямом и обратном ходе, при наличии таких
\ опасных процедур как отсечения (NOT: -NOT или CUT: -CUT)

\ квантор отрицания
: NOT:  ?COMP POSTPONE (NOT:) 0 ,  >MARK N0T ; IMMEDIATE
: -NOT  ?COMP N0T ?PAIRS POSTPONE (-NOT)  >RESOLVE2 ; IMMEDIATE

\ предикат, преобразование успеха/неуспеха в логическое значение
: PREDICATE  ?COMP [COMPILE] NOT:  (: FALSE ;) RLIT, ; IMMEDIATE
: SUCCEEDS   ?COMP TRUE LIT, N0T ?PAIRS POSTPONE (-NOT2) >RESOLVE2 ; IMMEDIATE

\ квантор общности, выраженный через два вложенных квантора отрицания
: ALL [COMPILE] NOT: ; IMMEDIATE
: ARE [COMPILE] NOT: ; IMMEDIATE
\ Почему-то у mlg в дипломке согласно иллюстрации OTHER делает так (я несколько месяцев честно пытался понять этот перехлёст):
\ : OTHER ?COMP  N0T ?PAIRS  >RESOLVE2 POSTPONE (-NOT) ; IMMEDIATE
\ но должно так:
: OTHER [COMPILE] -NOT ;  IMMEDIATE
: WISE [COMPILE] -NOT ;  IMMEDIATE

\ отсечение
: CUT:                           \ отметить начало отсекаемого фрагм.
    R>  RP@ >L                   \ адр. вершины стека возвр.--> на L-стек
        BACK LDROP TRACKING      \ а при откате - убрать эту отметку
    >R ;
: -CUT      R> L> RP! >R ;       \ убрать точки возврата до отметки
: -NOCUT                         \ убрать отметку, но не точки возврата
    R>
      L> RP@ - >R                \ сохранить относит. адрес отметки
      BACK R> RP@ + >L  TRACKING \ восстановить его при откате
    >R ;

\ блок альтернатив
: *>   ?COMP  204  0 RLIT, >MARK  203 ;  IMMEDIATE
: <*>  ?COMP  203 ?PAIRS  0 RLIT, >MARK RET,  205 ROT
       >RESOLVE2  0 RLIT,  >MARK 203 ;  IMMEDIATE
: <*   ?COMP  203 ?PAIRS  0 RLIT, >MARK RET,  205 ROT
       >RESOLVE2  RET,  BEGIN  DUP 204 = 0= WHILE
       205 ?PAIRS  >RESOLVE2 REPEAT  DROP ; IMMEDIATE

\ макросы для функций агрегации, три параметра:
\ Начальное значение результата
\ Функция аггрегирования (конкатенация, суммирование логические сложение или умножение)
\ Функция успеха, может включать в себя R> ENTER

: agg{ ( -- ) ?COMP
POSTPONE (ADR2) HERE 0 , 0 , \ храним два значения: накопитель и кол-во итераций
POSTPONE !
0 RLIT, >MARK
a99reg4te ;

: {agg} ( intermed -- ) >R
DUP a99reg4te ?PAIRS
ROT DUP LIT, -ROT
POSTPONE @
R> COMPILE, ;

\ во время исполнения на стеке должно лежать значение которое надо при-обработать к начальному (добавить, сконкатенировать, умножить и т.д.)
: }agg ( agg succ -- )
?COMP  >R >R
a99reg4te ?PAIRS
OVER
LIT, R> COMPILE,
OVER CELL+ LIT, POSTPONE 1+!
RET, >RESOLVE2
LIT, R> COMPILE, ;

: +{ ?COMP 0 LIT, agg{ ; IMMEDIATE
: }+ ?COMP ['] +! ['] @ }agg ; IMMEDIATE

: len{ ?COMP 0 LIT, agg{ ; IMMEDIATE
: }len ?COMP ['] 2DROP (: CELL+ @ ;) }agg ; IMMEDIATE

: MAX{ ?COMP 0 LIT, agg{ ; IMMEDIATE
: }MAX ?COMP (: DUP @ ROT MAX SWAP !  ;) ['] @ }agg ; IMMEDIATE

: *{ ?COMP 1 LIT, agg{ ; IMMEDIATE
: }* ?COMP (: DUP @ ROT * SWAP !  ;) ['] @ }agg ; IMMEDIATE

: &{ ?COMP -1 LIT, agg{ ; IMMEDIATE
: }& ?COMP (: DUP @ ROT AND SWAP ! ;) ['] @ }agg ; IMMEDIATE

: |{ ?COMP 0 LIT, agg{ ; IMMEDIATE
: }| ?COMP (: DUP @ ROT OR SWAP ! ;) ['] @ }agg ; IMMEDIATE

: {} ?COMP ['] NOOP {agg} ; IMMEDIATE \ промежуточный результат

\ Блок AMONG  ...  EACH  ...  ITERATE
\ порождается код:
\ (among) (among>) {addr} ... (each) ... (iterate) addr: код_за_циклом
: (AMONG)
    R>                      \ Адрес (AMONG>)
    BACK L> DROP TRACKING     \ При откате убрать указатель трассы итератора
    RP@ >L                  \ Указатель начала трассы итератора
    DUP >R                  \ (AMONG>): успех цикла при неуспехе итератора
    9 + >R ;                \ Обойти (AMONG>) , запустить итератор
\   ^-- бр-р-р! а что делать?.. надо перепрыгивать через CALL (AMONG>)

: (AMONG>)
    R>                      \ Адрес ссылки на код за циклом
    L> RP@ - >R             \ Сохранить указатель начала трассы
    BACK R> RP@ + >L
         TRACKING           \ Восстановить при откате
    @ >R ;                  \ Передать управление на код за циклом

: (EACH)
    R>                      \ Адрес тела цикла
    RP@ >L                  \ Новый адрес конца трассы итератора
    BACK L> DROP            \ При откате убрать адрес конца трассы
         L@ RP! TRACKING    \  и саму трассу итератора
    >R ;                    \ Передать управление телу цикла

: (ITERATE)
    RDROP                   \ Убрать адрес кода, находящегося за циклом
    L> L>                   \ Указатели на начало и конец трассы итератора
    2DUP RP@ - >R RP@ - >R  \ Сохранить указатели трассы итератора
    BACK L> DROP            \ Убрать новый указатель начала трассы и
         R> RP@ + R> RP@ +  \ восстановить старые указатели
             >L >L TRACKING \ при откате
    OVER -                  \ Адрес конца и длина трассы итератора
    RP@ >L                  \ Новый адрес начала трассы итератора
    RP@ OVER - RP!          \ Отвести место на стеке возвратов
    RP@ SWAP MOVE           \ Скопировать трассу итератора
;                           \ EXIT передает управление итератору

: FINIS   RDROP L> >R BACK R> >L TRACKING L@ CELL- @ >R ;
: AMONG   ?COMP POSTPONE (AMONG) POSTPONE (AMONG>) 0 , >MARK 207 ; IMMEDIATE
: EACH    ?COMP 207 ?PAIRS POSTPONE (EACH) 208 ; IMMEDIATE
: ITERATE ?COMP 208 ?PAIRS POSTPONE (ITERATE) >RESOLVE2 ; IMMEDIATE

;MODULE

/TEST

: EMPTY S0 @ SP! ;

\ REQUIRE SEE lib/ext/disasm.f
\ что-то вроде локальных переменных (локальные значения, но глобальные имена)...
VARIABLE a
VARIABLE b

: r
10 a B!
a @ 1+ b B!
." r2.a=" a @ .
." r2.b=" b @ . ;

: localsTest
5 a B!
." r.a=" a @ .
r
." r.a=" a @ . ;
>> localsTest

: bt ." back" BACK ." ing" TRACKING ." track" ;
>> bt
: bt2 START{ ." back" }EMERGE ." tracking" ;
>> bt2

: INTSTO ( n <-->x ) PRO 0 DO I CONT DROP LOOP ; \ генерирует числа от 0 до n-1
: 1-20 ( <-->x ) PRO 20 INTSTO CONT ; \ выдаёт числа от 1-го до 20-и
\ : 1-20  21 BEGIN DUP R@ ENTER DROP 1- ?DUP 0= UNTIL RDROP ;
: //2 PRO DUP 2 MOD ONFALSE CONT ; \ пропускает только чётные числа
: 1-20. 1-20 //2  DUP . ;
>> 1-20.
: 1-20X 1-20 ." X" ;
>> 1-20X
: 1-20X1-20x 1-20 1-20 ." X" ;
>> 1-20X1-20x

\ Подсчёт факториала
: FACT  ( n -- x ) START{
DUP  2 < IF DROP 1 EXIT THEN
DUP  1- DIVE  * }EMERGE ;
>> 10 FACT .

: FACT2 ( n -- !n ) *{ INTSTO 1+ DUP }* ;
>> 10 FACT2 .

\ Подсчёт числа Фибоначчи
: FIB ( n -- f ) START{ DUP 3 < IF DROP 1 EXIT THEN DUP 1- DIVE SWAP 2 - DIVE + }EMERGE ;
>> 10 FIB .


: STACK  PRO  DEPTH 0  ?DO  DEPTH I - 1- PICK  CONT DROP LOOP ;  \ выдаёт стек
: STACK. STACK DUP . ;  \ печатает стек
>> 1 2 3 STACK.
>> EMPTY STACK.
>> 1 STACK. DROP

: DEPTH-b len{ STACK }len ;
>> 11 32 73 DEPTH-b . EMPTY

\ Выдаёт true если на стеке *есть* число больше 10-и
: Estack>10 PREDICATE STACK DUP 10 > ONTRUE DROP SUCCEEDS ;
\ DROP после ONTRUE нужен для убирания ненужного значения от генератора STACK, можно ли без него обойтись?
\ может сбрасывать в блоках CUT: и PREDICATE вместе со стеком возвратов и стек данных тоже?
>> 1 2 Estack>10 . EMPTY
>> 1 20 Estack>10 . EMPTY

\ Выдаёт true если на стеке *все* числа больше 10-и
: Astack>10 PREDICATE ALL STACK ARE DUP 10 > ONTRUE OTHER DROP WISE SUCCEEDS ;
>> 1 2  Astack>10 . EMPTY
>> 1 20 Astack>10 . EMPTY
>> 20 30 Astack>10 . EMPTY

: stack-sum ( x1 x2 ... xn -- x1 x2 ... xn sum  )
+{ STACK DUP }+ ;
\ сумма значений на стеке
>> 20 30 stack-sum . EMPTY
>> EMPTY stack-sum .

: stack-or |{ STACK DUP }| ;
>> TRUE FALSE FALSE stack-or . EMPTY
>> FALSE FALSE stack-or . EMPTY

: sempty NOT: STACK -NOT ." stack is empty" ;
>> EMPTY sempty
>> 1 sempty
EMPTY

: notF ( f -- ) NOT: DUP ONTRUE -NOT ." F" ; \ если f=false, то выводит "F"
: notT ( f -- ) NOT: NOT: DUP ONTRUE -NOT -NOT ." T" ; \ если f=true, то выводит "T"
: ps. ( f -- ) PREDICATE DUP ONTRUE SUCCEEDS . ; \ просто выводит логическое значение
: pns. ( f -- ) PREDICATE NOT: DUP ONTRUE -NOT SUCCEEDS . ; \ выводит обратное логическое значение

: bool PRO *> TRUE <*> FALSE <* CONT DROP ;
: check bool *> CR DUP . ." notF=" notF <*> CR DUP . ." notT=" notT <*> CR DUP . ." ps.=" ps. <*> CR DUP . ." pns.=" pns. <* ;


: alter PRO
*> S" first" <*> S" second" <*
TYPE SPACE ;
>> alter

: firstInAlter PRO CUT:
*> S" first" <*> S" second" <* -CUT
TYPE ;
>> firstInAlter

\ перебор всех подмножеств конструкцией AMONG  ...  EACH  ...  ITERATE
: SUBSETS
    AMONG   *> 1 <*> 2 <*> 5 <*   \ оставлять на стеке по очереди 1,2,5
    EACH    *> <*> DROP <*      \ успех сначала с элементом, потом без него
                            \ DROP снимает эл-т множества со стека
    ITERATE
        CR STACK. ;        \ распечатать стек с новой строки

\ перебор всех подмножеств, из статьи Dynamically Structured Codes
\ http://dec.bournemouth.ac.uk/forth/euro/ef99/gassanenko99b.pdf
: el  R@ ENTER DROP ;
: .{} CR ." { " BACK ." } " TRACKING   STACK DUP COUNT TYPE SPACE ;
: subsets C" first" el C" second" el C" third" el .{} ;
>> subsets