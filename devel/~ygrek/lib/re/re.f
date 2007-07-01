\ $Id$
\ Регулярные выражения - regular expressions
\ Однобайтовые символы (unicode to do), классы символов - только для латинских
\ Прямая реализация NFA алгоритма из http://swtch.com/~rsc/regexp/regexp1.html

\ Преимущества реализации на форте по сравнению с внешними dll
\ 1 - не нужна dll :)
\ 2 - можно сделать именованные карманы
\ 3 - выражения явно заданные словом RE" парсятся на этапе компиляции и сохраняют в
\     кодофайл готовую структуру дерева состояний экономя на этом в рантайме!

\ TODO: ускорить matching \ отметка о принадлежности списку в nfa
\ TODO: ускорить capturing
\ TODO: квадратные скобки
\ TODO: пункт 2

\ POSIX standard - http://www.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap09.html
\ Perl RE doc - http://perldoc.perl.org/perlre.html

\ Сделано :
\ () выделение подвыражения
\ ? оператор "0 или 1"
\ * оператор "0 или больше"
\ + оператор "1 или больше"
\ | оператор "или"
\ . любой символ
\ \ квотирование специальных символов
\ \w \s \d \W \S \D \t \n \r \x3F

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

\ -----------------------------------------------------------------------

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE >= ~profit/lib/logic.f
REQUIRE ANSI-FILE lib/include/ansi-file.f
REQUIRE состояние ~profit/lib/chartable.f
REQUIRE { lib/ext/locals.f
REQUIRE list-find ~ygrek/lib/list/more.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE DOT-LINK ~ygrek/lib/dot.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE BOUNDS ~ygrek/lib/string.f
REQUIRE ENUM: ~ygrek/lib/enum.f
REQUIRE A_AHEAD ~mak/lib/a_if.f
REQUIRE NUMBER ~ygrek/lib/parse.f

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

state quoted-symbol

VECT RESERVE

: RESERVE-DYNAMIC LAMBDA{ ALLOCATE THROW } TO RESERVE ;
: RESERVE-STATIC LAMBDA{ HERE SWAP ALLOT } TO RESERVE ;

RESERVE-DYNAMIC

0 VALUE re_limit \ конечный адрес обработки
0 VALUE re_start \ начальный адрес обработки

0 VALUE re_def_groups \ подвыражения в результате последнего сопоставления

() VALUE re_brackets \ список пар nfa соответствующих парам скобок во время построения дерева

\ -----------------------------------------------------------------------

: !>> ( addr u -- addr+CELL ) OVER ! CELL + ;

: make-subs { n | bytes -- } n 2 * CELLS CELL + -> bytes bytes RESERVE DUP bytes ERASE n OVER ! ;
: copy-subs ( subs -- subs' ) DUP @ 2 * CELLS CELL+ DUP ALLOCATE THROW >R R@ SWAP MOVE R> ;

: save-subs ( -- subs )
   re_brackets length make-subs DUP
   CELL+
   LAMBDA{ >R R@ car !>> R> cdar !>> } re_brackets mapcar
   DROP ;

0 [IF]
: sub ( n subs -- addr ) CELL+ SWAP 2 CELLS * + ;

: set-sub-start ( u n subs -- ) sub 0 CELLS + ! ;
: set-sub-end ( u n subs -- ) sub 1 CELLS + ! ;

: get-sub-start ( n subs -- ) sub 0 CELLS + @ ;
: get-sub-end ( n subs -- ) sub 1 CELLS + @ ;
[THEN]

: adjust-sub-state { val nfa subs -- }
   subs CELL+
   subs @ 2 * 0 ?DO
    DUP @ nfa = IF val OVER ! THEN
    CELL+
   LOOP
   DROP ;

: new-brackets-pair ( -- pair ) %[ 0 % 0 % ]% vnode as-list DUP re_brackets cons TO re_brackets ;

: set-brackets-start ( start-nfa brackets-pair -- ) car setcar ;
: set-brackets-end ( end-nfa brackets-pair -- ) car cdr setcar ;

: print-sub { sub }
  CR sub @ . ." ) "
  sub CELL + sub @ 0 ?DO DUP @ 10 U.R CELL+ DUP @ 10 U.R CELL+ LOOP DROP ;

: normalize-subs { a u subs | z -- }
   subs CELL+ -> z
   a u z 2!
   z 2 CELLS + -> z
   subs @ 1 - 0 ?DO
    z @ u < z CELL+ @ u 1 + < AND IF z @ a + z CELL+ @ z @ - z 2! ELSE 0 0 z 2! THEN
    z 2 CELLS + -> z
   LOOP ;

: get-sub { n subs -- a u }
   n subs @ < NOT ABORT" Man, you've crossed the bounds!"
   n 2 CELLS * subs CELL+ + 2@ ;

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

:NONAME DUP CONSTANT 1+ ; ENUM 1+const:

256 1+const:
 STATE_SPLIT STATE_FINAL
 STATE_MATCH_ANY
 STATE_WORD_CHAR STATE_WORD_CHAR_NOT
 STATE_SPACE_CHAR STATE_SPACE_CHAR_NOT
 STATE_DIGIT_CHAR STATE_DIGIT_CHAR_NOT
; VALUE N_STATE

\ Состояние
0
CELL -- .c    \ тип состояния
CELL -- .out1 \ первый выход
CELL -- .out2 \ второй
CONSTANT /NFA

\ Фрагмент
0
CELL -- .i  \ начальное состояние этого фрагмента (адрес nfa)
CELL -- .o  \ список выходов этого фрагмента (элементы - адреса ячеек куда записывается адрес след. nfa)
CELL -- .b  \ учёт скобок - список указателей на brackets-pair
CONSTANT /FRAG

\ Регулярное выражение
0
CELL -- .nfa \ дерево состояний
CELL -- .sub \ подвыражения
CONSTANT /RE

: FREE-FRAG ( frag -- )
   DUP .b @ empty? NOT IF CR ." Fragment's bracket list not empty!" ABORT THEN
   DUP .o @ FREE-LIST
   FREE THROW ;

: FREE-NFA ( nfa -- ) FREE THROW ;

: frag ( nfa out-list -- frag )
   /FRAG ALLOCATE THROW >R
   R@ .o !
   R@ .i !
   () R@ .b !
   R> ;

: NEW-NFA /NFA RESERVE ;

: nfa { c link1 link2 | nfa -- nfa }
   NEW-NFA -> nfa
   c nfa .c !
   link1 nfa .out1 !
   link2 nfa .out2 !
   nfa ;

\ создать фрагмент с состоянием входа c
: liter ( c -- frag ) 0 0 nfa %[ DUP .out1 % ]% frag ;

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
S" .\()*|+?{" all-asc: symbol liter ;
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

   get-branches
   finalize ( frag )

   /RE RESERVE -> re

   re_brackets reverse TO re_brackets
   save-subs re .sub !
   \ re_brackets write-list
   re_brackets FREE-LIST
   () TO re_brackets

   ( frag ) DUP .i @ re .nfa !
   FREE-FRAG
   re ;

EXPORT

\ освободить всю структуру данных представляющую регулярное выражение
\ только для re созданных по RESERVE-DYNAMIC
: FREE-REGEX ( re -- )
   DUP .nfa @ FREE-NFA-TREE
   DUP .sub @ FREE THROW
   FREE THROW ;

: BUILD-REGEX ( a u -- re ) RESERVE-DYNAMIC (parse-full) ;

DEFINITIONS

: BUILD-REGEX-HERE
   POSTPONE A_AHEAD
   RESERVE-STATIC (parse-full)
   POSTPONE A_THEN
   POSTPONE LITERAL ; IMMEDIATE

\ -----------------------------------------------------------------------

: STATE>S { nfa -- a u }
   nfa .c @ STATE_SPLIT = IF S"  " EXIT THEN
   nfa .c @ STATE_FINAL = IF S" final" EXIT THEN
   nfa .c @ STATE_MATCH_ANY = IF S" any" EXIT THEN
   nfa .c @ STATE_SPACE_CHAR = IF S" space" EXIT THEN
   nfa .c @ [CHAR] \ = IF S" \\" EXIT THEN
   nfa .c @ BL 1+ < IF nfa .c @ <# [CHAR] ) HOLD S>D #S S" ascii(" HOLDS #> EXIT THEN
   nfa .c 1 ;

: (dot-draw) { from nfa | s1 s2 -- }
   nfa " {n}" DUP STR@ nfa STATE>S DOT-LABEL STRFREE
   from " {n}" -> s1  nfa " {n}" -> s2
   s1 STR@ s2 STR@ DOT-LINK
   s1 STRFREE s2 STRFREE
   nfa visited member? IF EXIT THEN
   nfa visited vcons TO visited
   nfa .out1 @ ?DUP IF nfa SWAP RECURSE THEN
   nfa .out2 @ ?DUP IF nfa SWAP RECURSE THEN ;

: dot-draw ( nfa -- ) clean-visited 0 SWAP (dot-draw) clean-visited ;

: find-finalstate ( nfa -- nfa2 ) BEGIN DUP .out1 @ WHILE .out1 @ REPEAT ;

EXPORT

\ представить RE в виде dot-диаграммы в файле a u
\ a1 u1 - символьное представление регэкспа (для надписи)
: dottify ( a1 u1 re a u -- )
   dot{
    DOT-CR S" rankdir=LR;" DOT-TYPE
    .nfa @
    DUP find-finalstate { last }
    ( nfa ) dot-draw

    \ 0 - стартовая вершина
    S" 0" S" box" DOT-SHAPE
    S" 0" 2SWAP DOT-LABEL

    \ last - финальная вершина
    " {#last}"
    DUP STR@ S" box" DOT-SHAPE
        STRFREE

   }dot ;

\ ? - флаг успеха
: dotto: ( a u "name" -- ? )
   2DUP
   RESERVE-DYNAMIC
   ['] (parse-full) CATCH
   IF
    2DROP
    2DROP
    PARSE-NAME 2DROP
    FALSE
   ELSE
    >R R@ PARSE-NAME dottify R> FREE-REGEX
    TRUE
   THEN ;

DEFINITIONS

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

N_STATE state-table char-state-match ( c -- ? )

all: CR ." Attempt to match inappropriate state. Fatal error." ABORT ;
0 256 range: signal = ;
STATE_MATCH_ANY      asc: DROP TRUE ;
STATE_WORD_CHAR      asc: is_word_char ;
STATE_WORD_CHAR_NOT  asc: is_word_char NOT ;
STATE_SPACE_CHAR     asc: is_space_char ;
STATE_SPACE_CHAR_NOT asc: is_space_char NOT ;
STATE_DIGIT_CHAR     asc: is_digit_char ;
STATE_DIGIT_CHAR_NOT asc: is_digit_char NOT ;

\ -----------------------------------------------------------------------

\ добавить состояние в список текущих
\ nondeterm стрелки учесть тоже
: addstate { nfa l -- l2 }
   nfa 0 = IF l EXIT THEN
   nfa l member? IF l EXIT THEN
   nfa .c @ STATE_SPLIT = IF
    nfa .out1 @ l RECURSE -> l
    nfa .out2 @ l RECURSE
    EXIT
   THEN
   nfa l vcons ;

\ l1 - список состояний предыдущего шага
\ c - обрабатываемый символ из строки
\ вернуть список состояний
: step { c l1 | l2 -- l }
   () TO l2
   l1
   BEGIN
    DUP empty? 0=
   WHILE
    DUP car c OVER .c @ char-state-match IF .out1 @ l2 addstate -> l2 ELSE DROP THEN
    cdr
   REPEAT
   DROP
   l2 ;

0 VALUE cur-char

\ добавить состояние в список текущих
\ nondeterm стрелки учесть тоже
\ z - список подвыражений
\ subs - состояние подвыражений для nfa
: subs_addstate { nfa l z subs -- l2 z2 }
   nfa 0 = IF l z EXIT THEN
   nfa l member? IF l z EXIT THEN
   subs copy-subs TO subs
   \ subs print-sub
   cur-char nfa subs adjust-sub-state \ ?DUP IF CR ." SUB " nfa . cur-char subs print-sub SWAP ! subs print-sub THEN
   \ subs print-sub
   nfa .c @ STATE_SPLIT = IF
    \ CR ." SPLIT"
    nfa .out1 @ l z subs RECURSE -> z -> l
    \ CR ." CONTINUE"
    nfa .out2 @ l z subs RECURSE
    subs FREE THROW
    \ CR ." <---"
    EXIT
   THEN
   \ l dump-list
   \ z dump-list
   nfa l vcons
   subs z vcons ;

\ l1 - список состояний предыдущего шага
\ z1 - список совпадений подвыражений для каждого состояния предыдущего шага
\ c - обрабатываемый символ из строки
\ вернуть новый список состояний и подвыражений
: subs_step { c l1 z1 | z2 l2 -- l z }
   () TO l2
   () TO z2
   l1
   BEGIN
    DUP empty? 0=
   WHILE
    DUP car c OVER .c @ char-state-match IF .out1 @ l2 z2 z1 car subs_addstate -> z2 -> l2 ELSE DROP THEN
    cdr
    z1 cdr TO z1
   REPEAT
   DROP
   l2 z2 ;

: set-default-groups
   re_def_groups ?DUP IF FREE THROW THEN
   TO re_def_groups ;

EXPORT

: get-group ( n -- a u )
   re_def_groups 0= THROW
   re_def_groups get-sub ;

\ сопоставление RE и строки, без отслеживания подвыражений
: re_fast_match? { a u re | l1 -- ? }
   () -> l1
   re .nfa @ l1 addstate -> l1
   a u BOUNDS ?DO
    I C@ l1 step ( l ) l1 FREE-LIST ( l ) -> l1
    \ CR I a - . l1 write-list
   LOOP
   LAMBDA{ .c @ STATE_FINAL = } l1 list-find NIP
   l1 FREE-LIST ;

\ сопоставление RE и строки
: re_match? { a u re | l1 z1 subs1 ? -- ? }
   \ StartTrace
   0 TO cur-char
   () -> l1
   () -> z1
   re .nfa @ l1 z1 re .sub @ subs_addstate -> z1 -> l1
   a u BOUNDS ?DO
    I a - 1 + TO cur-char
    \ CR cur-char . I C@ EMIT
    I C@ l1 z1 subs_step ( l z )
    LAMBDA{ FREE THROW } z1 mapcar z1 FREE-LIST l1 FREE-LIST
    ( l z ) -> z1 -> l1
    \ CR I a - . l1 write-list
   LOOP
   0
   LAMBDA{ SWAP 1+ SWAP .c @ STATE_FINAL = } l1 list-find NIP -> ?
   ? IF
    ( n ) 1- z1 nth car copy-subs -> subs1
    a u subs1 normalize-subs
   ELSE
    DROP
    0 -> subs1
   THEN
   \ z1 write-list
   LAMBDA{ FREE THROW } z1 mapcar
   l1 FREE-LIST
   z1 FREE-LIST
   subs1 set-default-groups
   ? ;

\ Применить регулярное выражение re-a re-u к строке a u, без отслеживания подвыражений
: stre_fast_match? ( a u re-a re-u -- ? )
   BUILD-REGEX { re }
   re re_fast_match?
   re FREE-REGEX ;

\ Применить регулярное выражение re-a re-u к строке a u
: stre_match? ( a u re-a re-u -- ? )
   BUILD-REGEX { re }
   re re_match?
   re FREE-REGEX ;

\ выделить строку ограниченную кавычкой
\ кавычки внутри строки квотятся бэкслешем \" - будут заменены во время _компиляции_ на одну кавычку
\ полученную строку скомпилировать в регексп
\ во время исполнения положить скомпилированный регексп на стек
\
\ corner case - если нужен обратный слеш в конце строки, то окружите всё выражение скобками
\ RE" (my_\"regex\"_here\\)" отметьте двойной слеш, т.к. надо квотить (уже на уровне синтаксиса регекспов!)
\ update: где-то читал что слеш в конце регекспа запрещён, поэтому никаких гарантий
\
: RE" \ Compile-time: ( "regex" -- )
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
