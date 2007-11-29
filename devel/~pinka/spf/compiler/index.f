\ 03.Feb.2007 ruv
\ $Id$
( Лексикон:
    HERE ALLOT , C, S,
    EXEC, LIT, 2LIT, SLIT,
    CONCEIVE GERM BIRTH

    BFW, ZBFW, RFW MBW BBW, ZBBW, BFW2, ZBFW2,
    \ abbr from -- Branch, ZeroBranch, ForWard, BackWard, Mark, Resolve.
    \ обязательно используют лишь управляющий стек.


 'S,' -- записывает только указанные ему данные и больше ничего.
 'SLIT,' -- никак не специфицирует, не навязывет формат, а лишь гарантирует [c-addr u] при исполнении;
          наличие x0 в конце строки вне счетчика -- зависит от реализации, на windows-системах рекоменуется.
 'EXEC,' -- откладывает исполнение семантики, представленной токеном xt.
 'EXIT,' -- откладывает выход из слова.

  GERM [ -- xt ] дает токен формируемого кода.
  Пара CONCEIVE [ -- ]  BIRTH [ -- xt ] сохраняет и восстанавливает предыдущий GERM
    и требует согласованности по управляющему стеку CS.

  Cлово '&' [ c-addr u -- xt ]  -- постфиксный вариант ' [tick]
  /вообще, оно к кодогенерации имеет малое отношение/.
)

REQUIRE Require   ~pinka/lib/ext/requ.f

Require CS@     control-stack.f

Include inlines.f

: DEFER-LIT, ( -- addr )
  -1 LIT,
  HERE 3 - CELL-
;
: EXEC, ( xt -- )
  \ COMPILE,
  GET-COMPILER? IF EXECUTE EXIT THEN COMPILE,
;
: EXIT, ( -- )
  RET,
;

: 2LIT, ( x x -- )
  SWAP LIT, LIT,
;
: &  ( c-addr u -- xt )  \ see also ' (tick)
  ALSO NON-OPT-WL CONTEXT !
  SFIND
  PREVIOUS
  IF EXIT THEN -321 THROW
;

\ : &EX, ( c-addr u -- )
\   & EXEC,
\ ;
\ : &LT, ( c-addr u -- )
\   I-LIT IF LIT, EXIT THEN -321 THROW
\ ;


USER GERM-A

: GERM  GERM-A @ ;
: GERM! GERM-A ! ;

S" xt.immutable.f" Included

: BFW, ( -- ) ( CS: -- a )
  0 BRANCH, >MARK >CS
;
: BFW2, ( -- ) ( CS: a1 -- a2 a1 )
  CS> BFW, >CS
;
: ZBFW, ( -- ) ( CS: -- a )
  0 ?BRANCH, >MARK >CS
;
: ZBFW2, ( -- ) ( CS: a1 -- a2 a1 )
  CS> ZBFW, >CS
;
: RFW ( -- ) ( CS: a -- )
  CS> >RESOLVE1
;

: MBW ( -- ) ( CS: -- a )
  HERE >CS
;
: BBW, ( -- ) ( CS: a -- )
  CS> BRANCH,
;
: ZBBW, ( -- ) ( CS: a -- )
  CS> ?BRANCH,
;
