\ 24-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ манипуляции данными на стеке возвратов

 REQUIRE ?DEFINED  devel\~moleg\lib\util\ifdef.f
 REQUIRE B@        devel\~mOleg\lib\util\bytes.f

\ REQUIRE dpush     devel\~mOleg\lib\asm\psevdoasm.f

\ поменять местами два числа
\ верхнее на стеке данных с верхним на стеке возвратов
\ CODE R><D ( r: a d: b --> r: b d: a )
\          rpop addr
\          XCHG tos , [rtop]
\        JMP addr
\     END-CODE

\ поменять местами два числа
\ верхнее на стеке данных с верхним на стеке возвратов
: R><D ( r: a d: b --> r: b d: a )
       [ 0x5B B, 0x87 B, 0x04 B, 0x24 B, 0xFF B, 0xE3 B, ] ;

\ поменять местами два числа на стеке возвратов
\ CODE RSWAP ( r: a b --> r: b a )
\            rpop addr
\            rpop temp
\            rpop cntr
\            rpush temp
\            rpush cntr
\          JMP addr
\       END-CODE

\ поменять местами два числа на стеке возвратов
: RSWAP ( r: a b --> r: b a )
        [ 0x5B B, 0x5A B, 0x59 B, 0x52 B, 0x51 B, 0xFF B, 0xE3 B, ] ;

\ удалить второй по счету элемент от вершины стека возвратов
\ CODE RNIP ( r: a b --> r: b )
\          rpop addr
\          rpop temp
\          rpop cntr
\          rpush temp
\        JMP addr
\     END-CODE

\ удалить второй по счету элемент от вершины стека возвратов
: RNIP ( r: a b --> r: b )
       [ 0x5B B, 0x5A B, 0x59 B, 0x52 B, 0xFF B, 0xE3 B, ] ;


\ копировать верхний элемент на вершине стека возвратов
\ CODE RDUP ( r: a --> r: a a )
\          rpop addr
\          MOV temp , [rtop]
\          rpush temp
\        JMP addr
\     END-CODE

\ копировать верхний элемент на вершине стека возвратов
: RDUP ( r: a --> r: a a )
       [ 0x5B B, 0x8B B, 0x14 B, 0x24 B, 0x52 B, 0xFF B, 0xE3 B, ] ;

\ положить поверх верхнего элемента копию нижнего на стеке возвратов
\ CODE ROVER ( r: a b --> r: a b a )
\           rpop addr
\           MOV temp , CELL [rtop]
\           rpush temp
\         JMP addr
\      END-CODE

\ положить поверх верхнего элемента копию нижнего на стеке возвратов
: ROVER ( r: a b --> r: a b a )
        [ 0x5B B, 0x8B B, 0x54 B, 0x24 B, 0x04 B, 0x52 B, 0xFF B, 0xE3 B, ] ;

\ подложить копию верхнего элемента, находящегося на вершине стека
\ возвратов под нижний
\ CODE RTUCK ( r: a b --> r: b a b )
\           rpop addr
\           rpop temp
\           rpop cntr
\           rpush temp
\           rpush cntr
\           rpush temp
\         JMP addr
\      END-CODE

\ подложить копию верхнего элемента, находящегося на вершине стека
\ возвратов под нижний
: RTUCK ( r: a b --> r: b a b )
        [ 0x5B B, 0x5A B, 0x59 B, 0x52 B, 0x51 B, 0x52 B, 0xFF B, 0xE3 B, ] ;

\ провернуть три верхних элемента на вершине стека возвратов влево
\ CODE RROT ( r: a b c --> r: b c a )
\          rpop addr
\          rpop temp
\          rpop cntr
\          rpop templ
\          rpush cntr
\          rpush temp
\          rpush templ
\        JMP addr
\     END-CODE

\ провернуть три верхних элемента на вершине стека возвратов влево
: RROT ( r: a b c --> r: b c a )
       [ 0x5B B, 0x5A B, 0x59 B, 0x5E B, 0x51 B, 0x52 B, 0x56 B,
         0xFF B, 0xE3 B, ] ;

\ добавить число к находящемуся на стеке возвратов
\ : R+ ( r: a d: b --> r: a+b ) 2R> -ROT + >R >R ;
\ CODE R+ ( r: a d: b --> r: a+b )
\        rpop addr
\        ADD [rtop] , tos
\        dpop tos
\      JMP addr
\   END-CODE

\ добавить число к находящемуся на стеке возвратов
: R+ ( r: a d: b --> r: a+b )
     [ 0x5B B, 0x01 B, 0x04 B, 0x24 B, 0x8B B, 0x45 B, 0x00 B,
       0x8D B, 0x6D B, 0x04 B, 0xFF B, 0xE3 B, ] ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ : first   1 >R 2 R><D R> ; first 1 2 D= 0= THROW          \ R><D
      : second  1 >R 2 >R RSWAP R> R> ; second 1 2 D= 0= THROW  \ RSWAP
      : thrid   1 >R 2 >R RNIP R> ; thrid 2 <> THROW            \ RNIP
      : fourth  1 >R RDUP R> R> ; fourth <> THROW               \ RDUP
      : fifth   1 >R 2 >R ROVER R> R> R> ;
        fifth 1 = SWAP 2 = AND SWAP 1 = AND 0= THROW            \ ROVER
      : sixth   1 >R 2 >R RTUCK R> R> R> ;
        sixth 2 = SWAP 1 = AND SWAP 2 = AND 0= THROW            \ RTUCK
      : seventh 1 >R 2 >R 3 >R RROT R> R> R> ;
        seventh 2 = SWAP 3 = AND SWAP 1 = AND 0= THROW          \ RROT
      : eighth  10 1 >R R+ R> ; eighth 11 <> THROW              \ R+

  S" passed" TYPE
}test


