\ 14-01-2007 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ DOES> механизм для СПФ
\ высокоуровневый вариант не требует переменной DOES>A и более портабельный.

 REQUIRE ADDR     devel\~moleg\lib\util\addr.f
 REQUIRE COMPILE  devel\~moleg\lib\util\compile.f

\ та часть, которая работает одновременно с CREATE (обычно) »
: (DOES1) ( r: addr --> ) LATEST-NAME-XT R> OVER - CFL - SWAP 1 + A! ;

\ эта часть выполняется во время вызова кода за DOES> »
: (DOES2) ( --> addr )
          2R> EXECUTE \ более быстрый вариант
          \ 2R> >R    \ более портабельный вариант
          ;

\ во время компиляции связывает текст за DOES> с текущим определением   »
\ используется в паре с CREATE : name CREATE data, DOES> ( --> 'data ) ;
: DOES> ( --> )  ?COMP  COMPILE (DOES1)  COMPILE (DOES2) ; IMMEDIATE

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ : sample CREATE , DOES> @ ;
      123 DUP sample abc  abc <> THROW
      234 DUP sample bcd  bcd <> THROW
  S" passed" TYPE
}test