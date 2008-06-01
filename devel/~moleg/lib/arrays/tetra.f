\ 2008-06-01 ~mOleg
\ Сopyright [C] 2008 mOleg mininoleg@yahoo.com
\ работа с тетрадами

 REQUIRE B@       devel\~mOleg\lib\util\bytes.f

\ преобразовать адрес тетрады в адрес байта и флаг
: tADDR ( taddr --> % addr ) DUP 2 MOD SWAP 2 / ;

\ извлечь тетраду с указанного адреса
: T@ ( u --> t ) tADDR B@ SWAP IF 0x10 / ELSE 0x0F AND THEN ;

\ сохранить тетраду по указанному адресу
: T! ( t u --> )
     tADDR TUCK B@ SWAP
      IF 0x0F AND ROT 0x10 *
       ELSE 0xF0 AND ROT
      THEN + SWAP B! ;

\ переход между байтовой адресацией и тетрадной
: A>TA ( baddr --> taddr ) 2 * ;

\ добавить по указанному адресу taddr тетраду
: T, ( t taddr --> taddr++ ) TUCK T! 1 + ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ CREATE buff
            1 buff A>TA T, 3 SWAP T, 0xF SWAP T, 2 SWAP T, 9 SWAP T, 5 SWAP T,
                    0xD SWAP T, 0xA SWAP T, 8 SWAP T, DROP
             buff @ 0xAD592F31 <> THROW
             buff A>TA 3 + T@ 2 <> THROW
             buff A>TA 6 + T@ 0xD <> THROW
  S" passed" TYPE
}test
