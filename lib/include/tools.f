\ 94 TOOLS

: .S ( -- ) \ 94 TOOLS
\ —копировать и показать значени€, наход€щиес€ на стеке данных. ‘ормат зависит
\ от реализации.
\ .S может быть реализовано с использованием слов форматного преобразовани€
\ чисел. —оответственно, он может испортить перемещаемую область,
\ идентифицируемую #>.
   DEPTH 0 MAX .SN
;

: ? ( a-addr -- ) \ 94 TOOLS
\ ѕоказать значение, хран€щеес€ по адресу a-addr.
\ ? может быть реализован с использованием слов форматного преобразовани€
\ чисел. —оответственно, он может испортить перемещаемую область,
\ идентифицируемую #>.
  @ .
;
: AHEAD  \ 94 TOOLS EXT
\ »нтерпретаци€: семантика неопределена.
\  омпил€ци€: ( C: -- orig )
\ ѕоложить место неразрешенной ссылки вперед orig на стек управлени€.
\ ƒобавить семантику времени выполнени€, данную ниже, к текущему определению.
\ —емантика незавершена до тех пор, пока orig не разрешитс€ (например,
\ по THEN).
\ ¬рем€ выполнени€: ( -- )
\ ѕродолжить выполнение с позиции, заданной разрешением orig.
  HERE BRANCH, >MARK 2
; IMMEDIATE



\ [IF] [ELSE] [THEN] implementation that follows the system's cases-sensitivity mode
\ (Note that in this implementation, we do not directly use string comparison operations)
\ see: https://forth-standard.org/standard/tools/BracketELSE#contribution-121
WORDLIST DUP CONSTANT BRACKET-FLOW-WL GET-CURRENT SWAP SET-CURRENT
: [IF]   ( u.level1 -- u.level2 ) 1+ ;
: [ELSE] ( u.level1 -- u.level2 ) DUP 1 = IF 1- THEN ;
: [THEN] ( u.level1 -- u.level2 ) 1- ;
SET-CURRENT
: [ELSE] ( -- )
  1 BEGIN BEGIN NextWord DUP WHILE \ spf3/jpf3 does not provide PARSE-NAME
    BRACKET-FLOW-WL SEARCH-WORDLIST IF
      EXECUTE DUP 0= IF DROP EXIT THEN
    THEN
  REPEAT 2DROP REFILL 0= UNTIL DROP
  WARNING @ IF ."  ( WARNING: missing [THEN] ) " THEN
; IMMEDIATE
: [IF] ( flag -- ) 0= IF  ['] [ELSE]  EXECUTE  THEN ; IMMEDIATE
: [THEN] ( -- ) ; IMMEDIATE



: CS-PICK ( C: destu ... orig0|dest0 -- destu ... orig0|dest0 destu ) ( S: u -- ) \ 94 TOOLS EXT
  2* 1+ DUP >R PICK R> PICK
;

: CS-ROLL ( C: origu|destu origu-1|destu-1 ... orig0|dest0 -- origu-1|destu-1 ... orig0|dest0 origu|destu ) ( S: u -- ) \ 94 TOOLS EXT
  2* 1+ DUP >R ROLL R> ROLL
;


\ Ruvim Pinka additions:

: [DEFINED] ( -- f ) \ "name"
  NextWord  SFIND  IF DROP TRUE ELSE 2DROP FALSE THEN
; IMMEDIATE

: [UNDEFINED]  ( -- f ) \ "name"
  POSTPONE [DEFINED] 0=
; IMMEDIATE



[DEFINED] PLATFORM [IF]
\ NB: PLATFORM is missed in SPF/3.75c that is used to build SPF/4

: OS_LINUX ( -- flag )
  PLATFORM S" Linux" COMPARE 0=
;
: OS_WINDOWS ( -- flag )
  OS_LINUX 0=
;

[THEN]
