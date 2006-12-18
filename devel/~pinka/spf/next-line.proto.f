\ 05.Dec.2006 ruvim@forth.org.ru
\ прототип объекта, представленный исходным кодом
\ arche

( xt_of_readout_data -- )
\ xt_of_readout_data ( a u1 -- a u2 ior )

: readout? ( a u1 -- a u2 flag )
  [ COMPILE, ] THROW DUP 0<>
;

VARIABLE B0  \ начало буфера
VARIABLE R   \ указатель чтения
VARIABLE W   \ указатель записи
VARIABLE B9  \ конец буфера, граница
\ в локальном пространстве и короткие имена хороши :)

: BUF! ( a u -- ) OVER DUP B0 ! DUP R ! W !  + B9 ! ;
: BUF ( -- a u ) B0 @ B9 @ OVER - ;
: REST ( -- a u ) R @ W @ OVER - ;
: VACANT ( -- a u ) W @ B9 @ OVER - ;
: CARRY ( a u -- )  ( OVER B0 @ = IF 2DROP EXIT THEN ) BUF SEATED + W ! B0 @ R ! ;
: ELAPSE ( a u -- ) + R ! ;
: REST! ( a u -- ) DROP R ! ;
: REST+! ( a u -- ) + W ! ;

: NEXT-LINE ( -- a u true | false )
  BEGIN  REST >CHARS SPLIT-LINE IF CHARS REST! TRUE EXIT THEN CHARS CARRY
  VACANT DUP WHILE readout? WHILE REST+! REPEAT THEN 2DROP
  REST DUP IF >CHARS UNBROKEN 2DUP CHARS ELAPSE TRUE EXIT THEN NIP ( false )
;
\ т.к. буфер -- это внутреннее дело модуля, строку можем резать по пробельному символу!
