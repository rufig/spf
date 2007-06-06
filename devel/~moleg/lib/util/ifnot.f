\ 21-02-2007 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ конструкции, которых не хватает в СПФ

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f

\ выдает смещение от текущего адреса до указанного.
?DEFINED atod : atod ( addr --> disp )  HERE CELL+ - ;

\ ветвление по нулю
: N?BRANCH, ( ? )
            ?SET
            0x85 TO J_COD
            ???BR-OPT
            SetJP  SetOP
            J_COD    \  JX без 0x0F
            0x0F     \  кусок от JX
            C, C,
            DUP IF atod THEN , DP @ TO LAST-HERE ;

\ пропустить, если 0 иначе переход за ELSE
: IFNOT ( flag --> ) ?COMP 0 N?BRANCH, >MARK 1 ; IMMEDIATE

\ продолжать цикл, если 0
: WHILENOT ( flag --> ) ?COMP 0 N?BRANCH, >MARK 1 2SWAP ; IMMEDIATE

?DEFINED test{ \EOF \ -- тестовая секция -------------------------------------

test{
      12345 CONSTANT zzzz
      09845 CONSTANT xxxx

      : sample ( flag --> n ) IFNOT zzzz ELSE xxxx THEN ;
      TRUE sample xxxx <> THROW
      FALSE sample zzzz <> THROW

      : simple ( flag --> )
               zzzz BEGIN SWAP WHILENOT DROP TRUE xxxx REPEAT ;

      FALSE simple xxxx <> THROW
      TRUE simple zzzz <> THROW

      S" passed" TYPE
}test



