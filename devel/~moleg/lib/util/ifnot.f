\ 21-02-2007 ~mOleg 
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ конструкции, которых не хватает в СПФ

REQUIRE ?: devel\~moleg\lib\util\ifcolon.f

\ выдает смещение от текущего адреса до указанного.
?: atod ( addr --> disp )  HERE CELL+ - ;

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

\EOF

: sample ( flag --> ) IFNOT ." zero flag" ELSE ." non zero flag" THEN ;
FALSE DUP . sample CR
TRUE DUP . sample CR

: proba ( flag --> ) BEGIN DUP . DUP WHILENOT 1 - REPEAT . ;
0 proba CR
10 proba CR



