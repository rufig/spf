\ $Id$
\ Регулярные выражения (regular expressions)
\ Прямая реализация NFA алгоритма из http://swtch.com/~rsc/regexp/regexp1.html

\ Преимущества реализации на форте по сравнению с внешними dll
\ 1 - не нужна dll :)
\ 2 - можно сделать именованные карманы
\ 3 - выражения явно заданные словом RE" парсятся на этапе компиляции и сохраняют в
\     кодофайл готовую структуру дерева состояний экономя на этом в рантайме!

\ TODO: пункт 2
\ TODO: ускорить capturing

\ Сделано :
\ () выделение подвыражения
\ ? оператор "0 или 1"
\ * оператор "0 или больше"
\ + оператор "1 или больше"
\ | оператор "или"
\ . любой символ
\ квотирование специальных символов, а именно . \ ( ) * | + ? { [
\ \w \s \d \W \S \D \t \n \r \x3F
\ [ перечисление множества символов внутри квадратных скобок, отрицание и диапазон

\ Цель: POSIX - http://www.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap09.html
\ Отличия:
\ - закрывающая круглая скобка всегда special
\   должно быть "... special when matched with a preceding left-parenthesis, ..."
\ - нет backreferences - \1 \2 итд
\ - однобайтовые символы (unicode to do?), классы символов - только для латинских
\ - . (точка) ловит любой символ, с кодом 0 тоже

\ NB Есть ещё Perl'овские регулярные выражения - http://perldoc.perl.org/perlre.html
\    но они заточены под бэктрекинговую реализацию, как следствие слишком сложны и запутанны,
\    поэтому с ними совместимости не будет и не планируется

\ -----------------------------------------------------------------------

\ Скомпилировать регэксп заданный строкой
\ RE" ( regexp" -- re )

\ Применить регулярное выражение re-a re-u к строке a u, без отслеживания подвыражений
\ stre_fast_match? ( a u re-a re-u -- ? )

\ Сопоставить скомпилированный регэксп и строку, без отслеживания подвыражений
\ re_fast_match? ( a u re -- ? )

\ Применить регулярное выражение re-a re-u к строке a u, сохранить подвыражения
\ stre_match? ( a u re-a re-u -- ? )

\ Сопоставить скомпилированный регэксп и строку, сохранить подвыражений
\ re_match? ( a u re -- ? )

\ Скобочное подвыражение из последнего re_match? или stre_match?
\ get-group ( n -- a u )
\ Если n = 0 - вся строка
\ Для n > 0 - счёт идёт по открывающим скобкам слева-направо
\ Если n больше чем число скобочных подвыражений - исключение
\ Для подвыражений которые не сопоставились возвращается 0 0
\ Для подвыражений которые сопоставились с пустым местом возвращается addr 0

\ В случае некорректного регекспа выкидывается исключение и течёт память

\ Примерная оценка скорости (10000 вызовов), ms
\ stre_match - 6891
\ re_match - 2938
\ stre_fast_match - 4328
\ re_fast_match - 672

\ -----------------------------------------------------------------------

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE >= ~profit/lib/logic.f
REQUIRE ANSI-FILE lib/include/ansi-file.f
REQUIRE состояние ~profit/lib/chartable.f
REQUIRE { lib/ext/locals.f
REQUIRE list-find ~ygrek/lib/list/more.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE BOUNDS ~ygrek/lib/string.f
REQUIRE ENUM: ~ygrek/lib/enum.f
REQUIRE A_AHEAD ~mak/lib/a_if.f
REQUIRE NUMBER ~ygrek/lib/parse.f
REQUIRE new-set ~pinka/lib/charset.f

REQUIRE write-list ~ygrek/lib/list/write.f
REQUIRE U.R lib/include/core-ext.f

\ -----------------------------------------------------------------------

MODULE: regexp

state in-branch-0
state in-branch-1
state in-branch-2
state in-branch-3

state start-fragment
state no-brackets-fragment
state brackets-fin
state fragment-final current-state VALUE 'fragment-final
state fragment-error
state fragment-charset-1
state fragment-charset-2
state fragment-charset-all

state quoted-symbol

VECT RESERVE

: RESERVE-DYNAMIC LAMBDA{ ALLOCATE THROW } TO RESERVE ;
: RESERVE-STATIC LAMBDA{ HERE SWAP ALLOT } TO RESERVE ;

RESERVE-DYNAMIC

0 VALUE re_limit \ конечный адрес обработки
0 VALUE re_start \ начальный адрес обработки
0 VALUE re_def_groups \ подвыражения в результате последнего сопоставления
() VALUE re_brackets \ список пар nfa соответствующих парам скобок во время построения дерева
0 VALUE re_nfa_count \ подсчёт числа nfa в текущем RE (во время построения дерева)
0 VALUE re_gen  \ номер поколения (при сопоставлении), идёт в отметку .gen в nfa
0 VALUE re_str_pos \ позиция в строке (при сопоставлении), для учёта положения скобок

\ -----------------------------------------------------------------------

:NONAME DUP CONSTANT 1+ ; ENUM 1+const:
:NONAME DUP CONSTANT 2* DUP 0= ABORT" Overflow!" ; ENUM flags:

256 1+const:
 STATE_SPLIT STATE_FINAL
 STATE_MATCH_ANY
 STATE_WORD_CHAR STATE_WORD_CHAR_NOT
 STATE_SPACE_CHAR STATE_SPACE_CHAR_NOT
 STATE_DIGIT_CHAR STATE_DIGIT_CHAR_NOT
 STATE_MATCH_SET STATE_MATCH_SET_NOT
; VALUE N_STATE

\ Состояние
0
CELL -- .c    \ тип состояния
CELL -- .out1 \ первый выход
CELL -- .out2 \ второй
CELL -- .flags
CELL -- .gen  \ номер поколения (во время матчинга, отслеживание текущих состояний)
CELL -- .set  \ для .c=STATE_MATCH_SET здесь указатель на set
CONSTANT /NFA

1 flags: NFA_GROUP_START NFA_GROUP_END ; DROP

\ Фрагмент (используется только на этапе построения дерева)
0
CELL -- .i  \ начальное состояние этого фрагмента (адрес nfa)
CELL -- .o  \ список выходов этого фрагмента (элементы - адреса ячеек куда записывается адрес след. nfa)
CELL -- .b  \ учёт скобок - список указателей на brackets-pair
CONSTANT /FRAG

\ Регулярное выражение
0
CELL -- .nfa \ дерево состояний
CELL -- .sub \ подвыражения
CELL -- .nfa-n \ общее кол-во различных состояний в этом RE
CONSTANT /RE

\ -----------------------------------------------------------------------

: !>> ( addr u -- addr+CELL ) OVER ! CELL + ;

0
CELL -- .a.size
CELL -- .a.n
0 -- .a.data
CONSTANT /arr

: reserve-array { n | bytes -- arr }
    n CELLS /arr + -> bytes bytes RESERVE >R R@ bytes ERASE n R@ .a.n ! bytes R@ .a.size ! R> ;

: a:create { n | bytes -- arr }
    n CELLS /arr + -> bytes bytes ALLOCATE THROW >R R@ bytes ERASE 0 R@ .a.n ! bytes R@ .a.size ! R> ;
: a:full ( arr -- a u ) DUP .a.size @ ;
: a:copy ( arr -- arr' ) a:full DUP ALLOCATE THROW >R R@ SWAP MOVE R> ;

: a:free FREE THROW ;

: a:n .a.n @ ;

: a:elem ( n arr -- ) .a.data SWAP CELLS + ;
: a:append ( val arr -- )
   { arr }
   arr a:n arr a:elem !
   arr .a.n 1+! ;

: a:iter-> ( arr --> elem \ <-- )
   PRO
   DUP .a.data { z }
   .a.n @ 0 ?DO
    z CONT
    z CELL+ -> z
   LOOP ;

: a:scan-> ( arr --> elem@ \ elem|0 <-- TRUE|FALSE )
   PRO
   DUP .a.data { z }
   .a.n @ 0 ?DO
    z @ CONT IF z UNLOOP EXIT THEN
    z CELL+ -> z
   LOOP 0 ;

: save-subs ( -- subs )
   re_brackets length 2 * reserve-array DUP
   .a.data
   LAMBDA{ >R R@ car !>> R> cdar !>> } re_brackets mapcar
   DROP
   re_brackets length 2 * OVER .a.n ! ;

: adjust-sub-state { val nfa subs -- }
   subs .a.data
   subs .a.n @ 0 ?DO
    DUP @ nfa = IF val OVER ! THEN
    CELL+
   LOOP
   DROP ;

: new-brackets-pair ( -- pair ) %[ 0 % 0 % ]% vnode as-list DUP re_brackets cons TO re_brackets ;

: set-brackets-start ( start-nfa brackets-pair -- ) OVER .flags NFA_GROUP_START SWAP ! car setcar ;
: set-brackets-end ( end-nfa brackets-pair -- ) OVER .flags NFA_GROUP_END SWAP ! car cdr setcar ;

: print-array { arr }
  CR arr .a.n @ " [{n}] : " STYPE
  arr a:iter-> @ . ;

: normalize-subs { a u subs | z -- }
   0 subs a:elem -> z
   a u z 2!
   z 2 CELLS + -> z
   subs a:n 2/ 1 ?DO
    z @ u < z CELL+ @ u 1 + < AND IF z @ a + z CELL+ @ z @ - z 2! ELSE 0 0 z 2! THEN
    z 2 CELLS + -> z
   LOOP ;

: get-sub { n subs -- a u }
   n 2 * subs .a.n @ < NOT ABORT" Man, you've crossed the bounds!"
   n 2 * subs a:elem 2@ ;

\ -----------------------------------------------------------------------

: new-chclass
  256 ;

\ -----------------------------------------------------------------------

VARIABLE process-continue

: run-parser ( a - )
   1 TO размер-символа
   поставить-курсор
   process-continue ON
   BEGIN
    process-continue @
   WHILE
    отсюда re_limit >= IF закончить-обработку EXIT THEN
    дать-букву выполнить-один-раз
   REPEAT ;

\ включить-отладку-автомата

\ -----------------------------------------------------------------------

: FREE-FRAG ( frag -- )
   DUP .b @ empty? NOT IF CR ." Fragment's bracket list not empty!" ABORT THEN
   DUP .o @ FREE-LIST
   FREE THROW ;

: FREE-NFA ( nfa -- )
   DUP .set @ ?DUP IF FREE THROW THEN
   FREE THROW ;

: frag ( nfa out-list -- frag )
   /FRAG ALLOCATE THROW >R
   R@ .o !
   R@ .i !
   () R@ .b !
   R> ;

: nfa { c link1 link2 | nfa -- nfa }
   /NFA RESERVE -> nfa
   c nfa .c !
   link1 nfa .out1 !
   link2 nfa .out2 !
   0 nfa .flags !
   0 nfa .gen !
   0 nfa .set !
   re_nfa_count 1+ TO re_nfa_count
   nfa ;

\ создать фрагмент с состоянием входа c
: liter ( c -- frag ) 0 0 nfa %[ DUP .out1 % ]% frag ;

: set-liter ( set c -- frag ) liter TUCK .i @ .set ! ;

\ привязать все выходы фрагмента frag1 к состоянию nfa
: link { frag1 nfa -- }
   \ все незакрытые подвыражения в frag1 завершаются в nfa
   nfa LAMBDA{ ( end-nfa pair ) OVER SWAP set-brackets-end } frag1 .b @ mapcar DROP
   frag1 .b @ FREE-LIST   () frag1 .b !
   nfa LAMBDA{ ( nfa frag1.o.addr ) OVER SWAP ! } frag1 .o @ mapcar DROP ;

\ присоединить все выходы фрагмента frag в текущий список
: outs% ( frag -- ) .o @ ['] % SWAP mapcar ;

\ конечное состояние
: finalstate ( -- nfa ) STATE_FINAL 0 0 nfa ;

\ пустой фрагмент
: emptyfragment ( -- nfa ) STATE_SPLIT liter ;

\ добавить конечное состояние
: finalize ( frag -- frag ) DUP finalstate link ;

: move-brackets { src dst -- }
   src .b @ dst .b @ concat-list dst .b !
   () src .b ! ;

\ последовательное соединение двух фрагментов
: concat { e1 e2 -- e }
  e1 e2 .i @ link
  e1 .i @ %[ e2 outs% ]% frag
  e2 OVER move-brackets
  e2 FREE-FRAG
  e1 FREE-FRAG ;

\ 0 or 1
: op-? { e1 -- e }
  STATE_SPLIT 0 e1 .i @ nfa
  %[ DUP .out1 % e1 outs% ]% frag
  e1 OVER move-brackets
  e1 FREE-FRAG ;

\ 0 or more
: op-* { e1 -- e }
  STATE_SPLIT 0 e1 .i @ nfa
  e1 OVER link
  ( nfa )
  %[ DUP .out1 % ]% frag
  e1 FREE-FRAG ;

\ 1 or more
: op-+ { e1 -- e }
  STATE_SPLIT 0 e1 .i @ nfa
  e1 OVER link
  ( nfa )
  e1 .i @ %[ SWAP .out1 % ]% frag
  e1 FREE-FRAG ;

\ alternation
: op-| { e1 e2 }
  STATE_SPLIT e1 .i @ e2 .i @ nfa
  %[ e1 outs% e2 outs% ]% frag
  e1 OVER move-brackets
  e2 OVER move-brackets
  \ DUP .b @ ." ???" write-list
  e1 FREE-FRAG
  e2 FREE-FRAG ;

\ -----------------------------------------------------------------------

: RANGE>S ( addr1 addr2 -- addr1 u ) OVER - 0 MAX ;

: op: S" +?*" all-asc: ;
: |: [CHAR] | asc: ;
: left: [CHAR] ( asc: ;
: right: [CHAR] ) asc: ;
: backslash: [CHAR] \ asc: ;
: [: [CHAR] [ asc: ;
: ]: [CHAR] ] asc: ;

: unquote-next-liter ( -- nfa ) current-state >R quoted-symbol дать-букву execute-one R> current-state! ;


256 state-table perform-operation

all: CR ." Bad operation!" ABORT ;
symbol: * op-* ;
symbol: ? op-? ;
symbol: + op-+ ;


: HEXNUMBER ( a u -- n ) BASE @ >R HEX NUMBER 0= THROW R> BASE ! ;

\ Квотирование
quoted-symbol

all: CR ." ERROR: Quoting \" symbol EMIT ."  not allowed!" fragment-error ;
S" .\()*|+?{[" all-asc: symbol liter ;
symbol: t 0x09 liter ; \ Tab
symbol: n 0x0A liter ; \ LF
symbol: r 0x0D liter ; \ CR
symbol: x \ \x3F - символ с кодом 0x3F
   отсюда 2 + re_limit > IF ABORT THEN
   отсюда 2 HEXNUMBER liter
   отсюда 2 + поставить-курсор ;
symbol: w STATE_WORD_CHAR liter ;
symbol: W STATE_WORD_CHAR_NOT liter ;
symbol: s STATE_SPACE_CHAR liter ;
symbol: S STATE_SPACE_CHAR_NOT liter ;
symbol: d STATE_DIGIT_CHAR liter ;
symbol: D STATE_DIGIT_CHAR_NOT liter ;


\ VARIABLE indent
\ : doi CR indent @ SPACES  ;

\ ветка - одна из альтернатив |
\ Парсит кусок RE который представляет собой одну или более веток одного уровня
: get-branches ( -- frag )
    \ doi ." get-branch " DEPTH .
    \ indent 1+!
    current-state >R
    in-branch-0
    отсюда run-parser
    current-state 'fragment-final <>
    R> current-state!
    process-continue ON
    IF ABORT THEN
    \ indent @ 1- indent !
    \ IF doi ." get-branch fail" ABORT THEN
    \ doi ." get-branch done"
;

\ Фрагмент - совпадающий символ или символ с оператором
\ Выбрать один фрагмент. Ветка тоже фрагмент
: get-fragment ( -- frag )
   \ doi ." get-fragment " DEPTH .
   \ indent 1+!
   current-state >R
   start-fragment
   отсюда run-parser
   current-state 'fragment-final <>
   R> current-state!
   process-continue ON
   IF ABORT THEN
   \ indent @ 1- indent !
   \ IF doi ." get-fragment fail" ABORT THEN
   \ doi ." get-fragment done"
;

\ get-fragment и get-branches рекурсивно вызывают друг-друга
\ Первый отвечает за простые фрагменты - второй за скобочные

\ Содержимое скобок - это ветка (возможно единственная) - последовательность фрагментов

\ На стеке фрагментов пусто
in-branch-0

all: rollback1 get-fragment in-branch-1 ;
|: emptyfragment in-branch-2 ;
right: fragment-error ;
end-input: fragment-error ;


\ на стеке один фрагмент
in-branch-1

all: rollback1 get-fragment concat ;
|: in-branch-2 ;
right: rollback1 fragment-final ;
end-input: fragment-final ;


\ на стеке одна ветка
in-branch-2

all: rollback1 get-fragment in-branch-3 ;
|: emptyfragment op-| ;
right: emptyfragment op-| rollback1 fragment-final ;
end-input: emptyfragment op-| fragment-final ;


\ на стеке одна ветка и один фрагмент
in-branch-3

all: rollback1 get-fragment concat ;
|: op-| in-branch-2 ;
right: op-| rollback1 fragment-final ;
end-input: op-| fragment-final ;


\ Начало RE фрагмента
start-fragment

all: symbol liter no-brackets-fragment ;
symbol: . STATE_MATCH_ANY liter no-brackets-fragment ;
op: fragment-error ;
left:
 { | pair frag }
 new-brackets-pair -> pair
 get-branches -> frag
 frag .i @ pair set-brackets-start
 pair frag .b @ vcons frag .b !
 brackets-fin frag ;
right: fragment-error ;
backslash: unquote-next-liter no-brackets-fragment ;
end-input: fragment-final ;
|: fragment-error ;
[: fragment-charset-1 ;
]: fragment-error ;


create-set cur-set
0 VALUE cur-set-state

: erase-set ( set -- ) /set ERASE ;
: copy-set ( src dst -- ) /set MOVE ;

: update-set
   symbol cur-set set+
   отсюда 2 + re_limit >= IF EXIT THEN
   отсюда C@ [CHAR] - <> IF EXIT THEN
   отсюда 1 + C@ DUP cur-set set+
   ( c1 ) symbol ( c1 c2 )
   2DUP < IF CR ." Bad order" fragment-error THEN
   2DUP EMIT EMIT
   ?DO I cur-set set+ LOOP
   отсюда 2 + поставить-курсор ;

\ внутри квадратных скобок, возможно первый символ отрицание
fragment-charset-1

on-enter: cur-set erase-set STATE_MATCH_SET TO cur-set-state ;
all: update-set fragment-charset-all ; \ ] обрабатывается как и все
CHAR ^ asc: STATE_MATCH_SET_NOT TO cur-set-state fragment-charset-2 ;
end-input: fragment-error ;

\ внутри квадратных скобок, возможно первый символ закрывающая квадратная скобка представляющая сама себя
fragment-charset-2

all: update-set fragment-charset-all ; \ ] обрабатывается как и все
end-input: fragment-error ;


\ внутри квадратных скобок
fragment-charset-all

all: update-set ;
]: /set RESERVE cur-set OVER copy-set cur-set-state set-liter no-brackets-fragment ;
end-input: fragment-error ;


\ Выражение не скобочное, т.е. один символ уже есть (и возможно сейчас будет оператор)
no-brackets-fragment

all: rollback1 fragment-final ;
op: symbol perform-operation fragment-final ;
end-input: fragment-final ;


\ конец скобочного выражения - должна быть закрывающая скобка
brackets-fin

all: fragment-error ;
right: no-brackets-fragment ;
end-input: fragment-error ;


\ Фрагмент выделен
fragment-final

on-enter: process-continue OFF ;
all: CR ." ALREADY IN FINAL STATE!" ;


\ Ошибка
fragment-error

on-enter:
 ALSO regexp
 " REGEX SYNTAX ERROR : position {отсюда re_start -} in {re_start отсюда RANGE>S}<!>{отсюда re_limit RANGE>S}"
 PREVIOUS
 CR STYPE CR
 process-continue OFF ;
all: CR ." ALREADY IN ERROR STATE!" ;

\ -----------------------------------------------------------------------

\ все посещённые во время обхода узлы
() VALUE visited

: clean-visited ( -- ) visited FREE-LIST () TO visited ;

\ рекурсивное освобождение NFA
: (FREE-NFA-TREE) ( nfa -- )
   DUP visited member? IF DROP EXIT THEN
   DUP visited vcons TO visited
   DUP .out1 @ ?DUP IF RECURSE THEN
   DUP .out2 @ ?DUP IF RECURSE THEN
   FREE-NFA ;

: FREE-NFA-TREE clean-visited (FREE-NFA-TREE) clean-visited ;

\ разобрать RE заданное строкой a u
\ в случае ошибки синтаксиса - выкидывается исключение
: (parse-full) { a u | pair re -- re }
   a TO re_start a u + TO re_limit
   re_start поставить-курсор

   \ re_brackets empty? NOT IF CR ." WARNING: regexp(1): possible memory leak" THEN
   \ re_brackets FREE-LIST

   () TO re_brackets
   new-brackets-pair -> pair \ whole string
   0 TO re_nfa_count

   get-branches
   finalize ( frag )

   /RE RESERVE -> re

   re_brackets reverse TO re_brackets
   save-subs re .sub !
   \ re_brackets write-list
   re_brackets FREE-LIST
   () TO re_brackets

   ( frag ) DUP .i @ re .nfa !
   re_nfa_count re .nfa-n !
   FREE-FRAG
   re ;

EXPORT

\ освободить всю структуру данных представляющую регулярное выражение
\ только для re созданных по RESERVE-DYNAMIC
: FREE-REGEX ( re -- )
   DUP .nfa @ FREE-NFA-TREE
   DUP .sub @ a:free
   FREE THROW ;

: BUILD-REGEX ( a u -- re ) RESERVE-DYNAMIC (parse-full) ;

DEFINITIONS

: BUILD-REGEX-HERE
   STATE @ IF
    POSTPONE A_AHEAD
    RESERVE-STATIC (parse-full)
    POSTPONE A_THEN
    POSTPONE LITERAL
   ELSE
    RESERVE-STATIC (parse-full)
   THEN ; IMMEDIATE

\ -----------------------------------------------------------------------

256 state-table is_alpha_char

all: FALSE ;
CHAR a CHAR z range: TRUE ;
CHAR A CHAR Z range: TRUE ;

256 state-table is_digit_char

all: FALSE ;
CHAR 0 CHAR 9 range: TRUE ;

: is_alphanum_char ( c -- ? ) DUP is_alpha_char SWAP is_digit_char OR ;
: is_word_char ( c -- ? ) DUP is_alphanum_char SWAP [CHAR] _ = OR ;
: is_space_char ( c -- ? ) BL 1+ < ;

N_STATE state-table char-nfa-match ( c nfa -- ? )

0 N_STATE 1+ range: CR ." Attempt to match inappropriate state. Fatal error." ABORT ;
0 256 range: DROP signal = ;
STATE_FINAL          asc: 2DROP FALSE ;
STATE_MATCH_ANY      asc: 2DROP TRUE ;
STATE_WORD_CHAR      asc: DROP is_word_char ;
STATE_WORD_CHAR_NOT  asc: DROP is_word_char NOT ;
STATE_SPACE_CHAR     asc: DROP is_space_char ;
STATE_SPACE_CHAR_NOT asc: DROP is_space_char NOT ;
STATE_DIGIT_CHAR     asc: DROP is_digit_char ;
STATE_DIGIT_CHAR_NOT asc: DROP is_digit_char NOT ;
STATE_MATCH_SET      asc: .set @ belong ;
STATE_MATCH_SET_NOT  asc: .set @ belong NOT ;

\ -----------------------------------------------------------------------

\ добавить состояние в список текущих
\ nondeterm стрелки учесть тоже
: addstate { nfa s -- }
   nfa 0 = IF EXIT THEN
   nfa .gen @ ( DUP .) re_gen = IF EXIT THEN
   re_gen nfa .gen !
   nfa .c @ STATE_SPLIT = IF
    nfa .out1 @ s RECURSE
    nfa .out2 @ s RECURSE
    EXIT
   THEN
   nfa s a:append ;

\ l1 - список состояний предыдущего шага
\ c - обрабатываемый символ из строки
\ вернуть список состояний
: step { c s1 s2 | a -- }
   0 s2 .a.n !
   re_gen 1+ TO re_gen
   \ CR ." STEP " re_gen .
   0 s1 a:elem -> a
   s1 .a.n @ 0 ?DO
    c a @ DUP .c @ char-nfa-match IF a @ .out1 @ s2 addstate THEN
    a CELL+ -> a
   LOOP ;

\ добавить состояние в список текущих
\ nondeterm стрелки учесть тоже
\ z - список подвыражений
\ subs - состояние подвыражений для nfa
: subs_addstate { nfa s z subs -- }
   nfa 0 = IF EXIT THEN
   nfa .gen @ re_gen = IF EXIT THEN
   re_gen nfa .gen !

   subs a:copy TO subs

   nfa .flags @ [ NFA_GROUP_START NFA_GROUP_END OR ] LITERAL AND IF
    re_str_pos nfa subs adjust-sub-state \ ?DUP IF CR ." SUB " nfa . re_str_pos subs print-sub SWAP ! subs print-sub THEN
   THEN

   nfa .c @ STATE_SPLIT = IF
    \ CR ." SPLIT"
    nfa .out1 @ s z subs RECURSE
    \ CR ." CONTINUE"
    nfa .out2 @ s z subs RECURSE
    subs a:free
    \ CR ." <---"
    EXIT
   THEN

   nfa s a:append
   subs z a:append ;

\ l1 - список состояний предыдущего шага
\ z1 - список совпадений подвыражений для каждого состояния предыдущего шага
\ c - обрабатываемый символ из строки
\ вернуть новый список состояний и подвыражений
: subs_step { c s1 s2 z1 z2 | s z -- }

   z2 START{ a:iter-> @ a:free }EMERGE

   0 s2 .a.n !
   0 z2 .a.n !
   re_gen 1+ TO re_gen

   0 s1 a:elem -> s
   0 z1 a:elem -> z
   s1 .a.n @ 0 ?DO
    c s @ DUP .c @ char-nfa-match IF s @ .out1 @ s2 z2 z @ subs_addstate THEN
    s CELL + -> s
    z CELL + -> z
   LOOP ;

: set-default-groups
   re_def_groups ?DUP IF a:free THEN
   TO re_def_groups ;

EXPORT

: get-group ( n -- a u )
   re_def_groups 0= THROW
   re_def_groups get-sub ;

\ сопоставление RE и строки, без отслеживания подвыражений
: re_fast_match? { a u re | s1 s2 -- ? }
   re .nfa @ .gen @ 1+ TO re_gen

   re .nfa-n @ a:create -> s1
   re .nfa-n @ a:create -> s2

   re .nfa @ s1 addstate
   a u BOUNDS ?DO
    I C@ s1 s2 step
    s1 s2 -> s1 -> s2
   LOOP
   \ LAMBDA{ .c @ STATE_FINAL = } l1 list-find NIP
   \ l1 FREE-LIST
   s1 START{ a:scan-> .c @ STATE_FINAL = }EMERGE 0 <>
   re_gen re .nfa @ .gen ! \ для последующих сопоставлений
   s1 a:free
   s2 a:free
   ;

\ Совпадает ли re с подстрокой (от начала) строки a u
\ Если есть такая подстрока - вернуть её длину
\ Иначе 0
: re_sub { a u re | s1 s2 -- u1 }
   re .nfa @ .gen @ 1+ TO re_gen

   re .nfa-n @ a:create -> s1
   re .nfa-n @ a:create -> s2

   re .nfa @ s1 addstate
   0
   a u BOUNDS ?DO
    I C@ s1 s2 step
    s1 s2 -> s1 -> s2
    s1 START{ a:scan-> .c @ STATE_FINAL = }EMERGE IF ( 0 ) DROP I a - 1+ LEAVE THEN
   LOOP
   re_gen re .nfa @ .gen ! \ для последующих сопоставлений
   s1 a:free
   s2 a:free
   ( u ) ;

\ сопоставление RE и строки
: re_match?
   { a u re | s1 z1 s2 z2 subs1 ? -- ? }
   \ StartTrace
   0 TO re_str_pos
   re .nfa-n @ a:create -> s1
   re .nfa-n @ a:create -> s2
   re .nfa-n @ a:create -> z1
   re .nfa-n @ a:create -> z2

   re .nfa @ .gen @ 1+ TO re_gen
   re .nfa @ s1 z1 re .sub @ subs_addstate

   a u BOUNDS ?DO
    I a - 1 + TO re_str_pos
    \ CR re_str_pos . I C@ EMIT
    I C@ s1 s2 z1 z2 subs_step
    s1 s2 -> s1 -> s2
    z1 z2 -> z1 -> z2
    \ CR I a - . l1 write-list
   LOOP
   s1 START{ a:scan-> .c @ STATE_FINAL = }EMERGE
   DUP 0<> -> ?
   ?DUP IF
    s1 .a.data - ( offset ) z1 .a.data + @
   ELSE
    re .sub @
   THEN
   a:copy -> subs1
   a u subs1 normalize-subs
   s1 a:free
   s2 a:free
   z1 START{ a:iter-> @ a:free }EMERGE
   z2 START{ a:iter-> @ a:free }EMERGE
   z1 a:free
   z2 a:free
   subs1 set-default-groups
   re_gen re .nfa @ .gen ! \ для последующих сопоставлений
   ? ;

\ : WITH-REGEX ( re-a re-u xt -- )
\   BUILD-REGEX

: STREGEX=> ( re-a re-u --> re \ <-- ) PRO BUILD-REGEX { re } re CONT re FREE-REGEX ;

\ Применить регулярное выражение re-a re-u к строке a u, без отслеживания подвыражений
: stre_fast_match? ( a u re-a re-u -- ? ) STREGEX=> re_fast_match? ;

\ Применить регулярное выражение re-a re-u к строке a u
: stre_match? ( a u re-a re-u -- ? ) STREGEX=> re_match? ;

\ выделить строку ограниченную кавычкой.
\ кавычки внутри строки квотятся бэкслешем \" - будут заменены во время _компиляции_ на одну кавычку.
\ полученную строку скомпилировать в регексп.
\ во время исполнения положить скомпилированный регексп на стек.
: RE" \ Compile-time: ( regex" -- )
\ runtime: ( -- re )
   "" >R
   BEGIN
    [CHAR] " PARSE
    2DUP + 1- C@ [CHAR] \ =
   WHILE
    1- R@ STR+
    '' R@ STR+
   REPEAT
   R@ STR+
   R@ STR@ POSTPONE BUILD-REGEX-HERE
   R> STRFREE ; IMMEDIATE

\ Выделить строку до символа конца строки, скомпилировать в RE
\ Во время исполнения положит RE на стек
: EOLRE: ( -- re ) -1 PARSE POSTPONE BUILD-REGEX-HERE ; IMMEDIATE

;MODULE

\ -----------------------------------------------------------------------

/TEST

\ Пример убивающий backtracking реализации регулярных выражений
\ сопоставление строки aa..(N раз)..a
\ и регекспа a?a?..(N раз)..a?aa..(N раз)..a

: s^n { n s -- ss..(N раз)..s } "" n 0 DO DUP s STR@ ROT STR+ LOOP ;

: r1 { n s | q -- s }
   n s s^n
   " {$s}?" -> q
   n q s^n TUCK S+
   q STRFREE ;

: test { n | q s r -- ? }
   " a" -> q
   n q s^n -> s
   n q r1 -> r
   q STRFREE
   CR
   CR
   s STR@ r STR@ stre_match? IF ." It matches" ELSE ." Failed" THEN
   CR
   CR
   " Equivalent perl code (try it!): {CRLF}print {''}It matches\n{''} if {''}{$s}{''} =~ /{$r}/;" STYPE
   CR
( "
string :
{$s}
regex :
{$g}" STYPE)

   s STRFREE
   r STRFREE ;

40 test

\EOF
