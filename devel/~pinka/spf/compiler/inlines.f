\ 18.Feb.2007 Sun 18:31
\ $Id$
\ see also src/compiler/spf_inline.f

\ This module provides a mechanism for associating a definition with a code generator
\ (compiler) for that definition (the corresponding word, if any, should be an ordinary word).
\ ADVISE-COMPILER ( xt.compiler xt.target -- )
\   Bind xt.compiler to xt.target
\   xt.compiler ( -- ) is a code generator for xt.target
\ OBTAIN-COMPILER? ( xt.target -- xt.compiler true | xt.target false )
\   Return a compiler for xt.target
\
\ Also, this module defines compilers for immediate R-words.
\
\ Note: This module does not affect the `COMPILE,` built-in word in any way.

\ NB: `ADVICE-COMPILER` (a noun) was renamed to `ADVISE-COMPILER` (a verb).


REQUIRE [:        lib/include/quotations.f


MODULE: fix-inlines-support

REQUIRE BIND-NODE ~pinka/samples/2006/lib/plain-list.f

VARIABLE h-compilers

EXPORT

: ADVISE-COMPILER ( xt.compiler xt.target -- )
  0 , HERE SWAP , SWAP , h-compilers BIND-NODE
;
: OBTAIN-COMPILER? ( xt.target -- xt.compiler true | xt.target false )
  DUP h-compilers FIND-NODE IF NIP CELL+ @ TRUE EXIT THEN FALSE
;
\ да, вот так :)  И не надо вводить дополнительных полей в старые заголовки.
\ -----


DEFINITIONS \ private words


: COMPILE(>R)       POSTPONE >R ;
: COMPILE(R>)       POSTPONE R> ;
: COMPILE(RDROP)    POSTPONE RDROP ;


' COMPILE(>R)         ' >R      ADVISE-COMPILER
' COMPILE(R>)         ' R>      ADVISE-COMPILER
' COMPILE(RDROP)      ' RDROP   ADVISE-COMPILER



[DEFINED] NON-OPT-WL [IF] \ An old version of spf4
\ Define compilers for counterpart words outside of NON-OPT-WL
\ (as in old spf4 versions, Tick searches in NON-OPT-WL at the first place)

\ NON-OPT-WL contained words:  EXECUTE  ?DUP  R>  >R  RDROP

: ?advise-secondary ( xt.compiler sd.name -- )
  2DUP NON-OPT-WL FIND-NAME-IN 0= IF 2DROP DROP EXIT THEN
  FIND-NAME ?FOUND NAME> ADVISE-COMPILER
;


' COMPILE(>R)     S" >R"      ?advise-secondary
' COMPILE(R>)     S" R>"      ?advise-secondary
' COMPILE(RDROP)  S" RDROP"   ?advise-secondary


S" ?DUP" FIND-NAME ?FOUND IS-NAME-IMMEDIATE [IF]
VERSION 0430 1000 * U< [IF] .( Error: at least spf4 v4.30 is required) CR ABORT [THEN]
\ This works correctly since spf4 v4.30
[: POSTPONE ?DUP ;]  DUP    ' ?DUP  ADVISE-COMPILER   S" ?DUP" ?advise-secondary
[THEN]

S" EXECUTE" FIND-NAME ?FOUND IS-NAME-IMMEDIATE [IF]
VERSION 0430 1000 * U< [IF] .( Error: at least spf4 v4.30 is required) CR ABORT [THEN]
\ This works correctly since spf4 v4.30
[: POSTPONE EXECUTE ;]  DUP    ' EXECUTE  ADVISE-COMPILER   S" EXECUTE" ?advise-secondary
[THEN]


[THEN] \ End of defined NON-OPT-WL



\ Заглушки-пустышки с флагом immediate
\ -- их и без того оптимизатор выкусывает,
\ а immediate -- повод не пускать в forthml
S" CHARS" FIND-NAME ?DUP [IF] IS-NAME-IMMEDIATE [IF]
' NOOP ' CHARS    ADVISE-COMPILER
[THEN] [THEN]
S" >CHARS" FIND-NAME ?DUP [IF] IS-NAME-IMMEDIATE [IF]
' NOOP ' >CHARS   ADVISE-COMPILER
[THEN] [THEN]



S" R@" FIND-NAME ?DUP [IF] IS-NAME-IMMEDIATE [IF]
[: POSTPONE R@ ;]  ' R@  ADVISE-COMPILER
[THEN] [THEN]

S" 2R@" FIND-NAME ?DUP [IF] IS-NAME-IMMEDIATE [IF]
[: POSTPONE 2R@ ;]  ' 2R@  ADVISE-COMPILER
[THEN] [THEN]

S" 2>R" FIND-NAME ?DUP [IF] IS-NAME-IMMEDIATE [IF]
[: POSTPONE 2>R ;]  ' 2>R  ADVISE-COMPILER
[THEN] [THEN]

S" 2RDROP" FIND-NAME ?DUP [IF] IS-NAME-IMMEDIATE [IF]
[: POSTPONE 2RDROP ;]  ' 2RDROP  ADVISE-COMPILER
[THEN] [THEN]


\ Для слов, чувствительных к уровню стека возвратов, нельзя делать хвостовую оптимизацию.
\ Прописываю собственный компилятор для слова "2R>", чтобы генерить верный код
\ для него даже при включенной хвостовой оптимизации ("?C-JMP").

S" 2R>" FIND-NAME ?FOUND IS-NAME-IMMEDIATE [IF]
[: POSTPONE 2R> HERE DROP ( \ a hint for the optimizer ) ;]  ' 2R>  ADVISE-COMPILER
[ELSE]
: COMPILE(2R>)
  ['] 2R> COMPILE,
  HERE TO :-SET
;

' COMPILE(2R>) ' 2R> ADVISE-COMPILER
[THEN]


;MODULE
