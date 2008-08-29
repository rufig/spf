\ 2008-08-19 ~mOleg
\ Сopyright [C] 2008 mOleg mininoleg@yahoo.com
\ неразрушающие ветвления, ветвления по знаку

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
 REQUIRE WHILENOT devel\~moleg\lib\util\control.f
 REQUIRE B,       devel\~mOleg\lib\util\bytes.f

\ выдает смещение от текущего адреса до указанного.
?DEFINED atod : atod ( addr --> disp )  HERE CELL+ - ;

\ условное ветвление по FALSE без удаления флага
: *BRANCH, ( ADDR --> )
           0x0B B, 0xC0 B,         \ or eax, eax
           0x0F B, 0x84 B,         \ je #
           atod A, ;

\ условное ветвление если число меньше нуля без удаления флага
: -BRANCH, ( ADDR --> )
           0x83 B, 0xF8 B, 0x00 B,  \ cmp tos, # 0
           0x0F B, 0x89 B,          \ js #
           atod A, ;

\ ветвление по отрицательному значению на вершине стека, значение не удаляется
: -IF ( value --> value )
      STATE @ IFNOT init: THEN
      2 controls +!
      HERE -BRANCH, >MARK 1
      ; IMMEDIATE

\ аналогично обычному IF за исключением того, что не удаляет значение флага
: *IF ( value --> value )
      STATE @ IFNOT init: THEN
      2 controls +!
      HERE *BRANCH, >MARK 1 ; IMMEDIATE

\ аналогично обычному WHILE, но не удаляет флаг с вершины стека данных
: *WHILE ( value --> value )
         ?COMP 2 controls +!
         HERE *BRANCH, >MARK 1 2SWAP
         ; IMMEDIATE

\ аналогично обычному UNTIL, но не удаляет флаг c вершины стека данных
: *UNTIL ( value --> value )
        ?COMP -2 controls +!
        3 = IFNOT -2004 THROW THEN *BRANCH,
        controls @ IFNOT [COMPILE] ;stop THEN
        ; IMMEDIATE


?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{  0 -IF 24542857 ELSE 67029874 THEN 67029874 <> THROW THROW
      10 -IF 24542857 ELSE 67029874 THEN 67029874 <> THROW 10 <> THROW
      -1 -IF 24542857 ELSE 67029874 THEN 24542857 <> THROW 1 + THROW

       0 *IF 24542857 ELSE 67029874 THEN 67029874 <> THROW THROW
      -1 DUP *IF 24542857 ELSE 67029874 THEN 24542857 <> THROW <> THROW
     123 DUP *IF 24542857 ELSE 67029874 THEN 24542857 <> THROW <> THROW

       3 BEGIN *WHILE 1 - REPEAT THROW
       3 BEGIN 1 - *UNTIL 2 <> THROW

  S" passed" TYPE
}test































































\
