\ 02-12-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ стек управления компиляцией

 REQUIRE NewStack  devel\~mOleg\lib\util\stack.f

VOCABULARY C-Stack
           ALSO C-Stack DEFINITIONS

        USER-VALUE CStack  \ CSP

    100 CONSTANT #CS       \ предельная глубина стека CS

\ вернуть CSid
: CSP ( --> addr ) CStack DUP IF ELSE DROP #CS NewStack DUP TO CStack THEN ;

ALSO FORTH DEFINITIONS

\ переместить число на вершину стека CS
: >CS ( u --> ) CSP PushTo ;

\ снять число с вершины стека CS
: CS> ( --> u ) CSP PopFrom ;

\ прочитать число с вершины стека SC
: CS@ ( --> u ) CSP ReadTop ;

\ удалить верхнее значение с вершины CS
: CSDrop ( cs: u --> ) CSP DropTop ;

\ снять с CS #-тое значение
: CSPick ( # --> u ) CSP PickFrom ;

\ определить глубину CS
: CSDepth ( --> # ) CSP StackDepth ;

\ сохранить текущее состояние SP в CS
: !CSP ( --> ) SP@ >CS ;

\ проверить сбалансирован ли стек
: ?CSP ( -> flag ) SP@ CS@ <> ;

PREVIOUS PREVIOUS DEFINITIONS

?DEFINED test{ \EOF -- Тестовая секцияґ ---------------------------------------
        CSDepth 0 <> THROW
        123 >CS CS@ 123 <> THROW
        234 >CS CS@ 234 <> THROW
        345 >CS 2 CSPick 123 <> THROW
        CSDepth 3 = 0= THROW
        CS> 345 = 0= THROW
        CS> 234 = 0= THROW
        CS> 123 = 0= THROW
        !CSP SP@ CS@ <> THROW
        ?CSP THROW
test{


  S" passed" TYPE
}test



