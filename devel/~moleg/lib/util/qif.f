\ 18-12-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ управление трансляцией входного потока. [IF] [ELSE] [THEN]

 REQUIRE CS>         devel\~moleg\lib\util\csp.f
 REQUIRE sFindIn     devel\~moleg\lib\newfind\search.f
 REQUIRE ROOT        devel\~moleg\lib\util\root.f

 ?DEFINED IS  ALIAS TO IS

ALSO ROOT DEFINITIONS

        \ следующие слова идут в ROOT, а так как ROOT всегда находится
        \ в контексте, всегда являются доступными
        VECT [IF]   IMMEDIATE  ( flag --> )
        VECT [ELSE] IMMEDIATE  ( --> )
        VECT [THEN] IMMEDIATE  ( --> )

\ альтернатива [IF] , срабатывает при flag = 0
: [IFNOT] ( flag --> ) 0 = [COMPILE] [IF] ; IMMEDIATE

RECENT

\ искать слово в словаре ROOT, если найдено, вернуть его wid
\ найденное слово должно быть immediate
: qfnd ( --> wid | 0 )
       SP@ >R
       NEXT-WORD [ ALSO ROOT CONTEXT @ PREVIOUS ] LITERAL 1 sFindIn
       imm_word = IFNOT R> SP! FALSE ELSE RDROP THEN ;

\ пропустить все слова во входном потоке вплоть до указанного a
: skipto' ( 'a / .... a --> ' ) >R BEGIN qfnd R@ = UNTIL R> ;

\ пропустить все слова во входном потоке
\ вплоть до одного из двух указанных 'a 'b
: skipto'' ( 'a 'b / .... a|b --> ' )
           2>R BEGIN 2R@ qfnd TUCK = WHILENOT \ ?a
                                   = WHILENOT \ ?b
                 REPEAT RDROP R> EXIT
               THEN 2DROP R> RDROP ;

\ функция, выполняющая действия [IF]
: [if) ( flag / ... [ELSE] | [THEN] --> )
        DUP >CS ['] [IF] >CS
        IF ELSE ['] [ELSE] ['] [THEN] skipto'' EXECUTE THEN ;

\ функция, выполняющая действия [ELSE]
: [else) CS@ ['] [IF] =
          IF 1 CSPick IF ['] [THEN] skipto' EXECUTE THEN
           ELSE -1 THROW
          THEN ;

\ функция, выполняющая действие [THEN]
: [then) CS@ ['] [IF] = IF CSDrop CSDrop ELSE -1 THROW THEN ;

\ инициализация слов [IF] [ELSE] [THEN]
 ' [if)   IS [IF]
 ' [then) IS [THEN]
 ' [else) IS [ELSE]

 ?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ 0 [IFNOT] 82704958 [ELSE] 36547236 [THEN] 82704958 <> THROW
  S" passed" TYPE
}test
