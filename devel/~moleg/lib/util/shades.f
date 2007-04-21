\ 26-03-2005 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ работа с теневыми регистрами

 0 CELL -- off_action
   CELL -- off_value
   CELL -- off_base
 CONSTANT shadow_rec

\ создать теневой регистр для порта base инициировав значением n
: Shadow ( Vect n Base / name --> )
         CREATE HERE shadow_rec ALLOT
                    TUCK off_base !
                    TUCK off_value !
                         off_action !
         DOES> ;

\ структура shadow хранит: [содержимое][адрес][вектор]
: pms ( addr --> n Port Vect )
      DUP  off_value @
      OVER off_base @
      ROT  off_action @ ;

\ сохранить содержимое теневого регистра в реальный регистр
: Update ( addr --> ) pms EXECUTE ;

\ установить указанные биты в теневом регистре
: SetH ( mask addr --> ) off_value TUCK @ OR SWAP ! ;

\ сбросить указанные в маске биты в теневом регистре
: ResH ( mask addr --> ) off_value SWAP INVERT OVER @ AND SWAP ! ;

\ инвертировать указанные биты теневого регистра
: FlipH ( mask addr --> ) off_value TUCK @ XOR SWAP ! ;

\ основные операции с регистрами - меняется содержимое теневого и реального
\ регистров
: SET   ( mask addr --> ) TUCK SetH  Update ;
: RES   ( mask addr --> ) TUCK ResH  Update ;
: FLIP  ( mask addr --> ) TUCK FlipH Update ;

\EOF - тестировани и описание -------------------------------------------------

\ При работе с реальным железом иногда возникает ситуация, что есть регистр,
\ доступный только на запись, но его содержимое необходимо, причем достаточно
\ часто знать и использовать.

\ пример использования:

: ~content CR ." в регистр " . ."  записано: " . ;

HEX

   ' ~content FFFF 345678 Shadow test

    test Update
    FF0000 test SET     .(  должно быть FFFFFF )
    00AA00 test RES     .(  должно быть FF55FF )
    FEDCBA test FLIP    .(   должно быть  18945 )
CR

\ Таким образом для указанного регистра В/В создается теневой регистр,
\ в котором можно изменять только отдельные биты или группы бит, не
\ затрагивая остальные.
\ Данный подход можно использовать не только при работе с регистрами 8)


