\ 25-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ битовый буффер накопитель

 REQUIRE ?DEFINED devel\~mOleg\lib\util\ifdef.f
 REQUIRE B@       devel\~mOleg\lib\util\bytes.f


        USER retain \ количество сохраненных бит

               8 CONSTANT bits/addr \ бит в байте
 bits/addr CELLS CONSTANT bits/cell \ бит в ячейке

\ вернуть адрес и смещение конца битового массива
: bAddr ( base --> disp addr ) retain @ bits/addr /MOD ROT + ;

\ сместить битовое поле u в старшие разряды
: [barr ( u # --> |<u # ) TUCK bits/cell SWAP - LSHIFT SWAP ;

\ поменять порядок байт в числе
: bSwap ( u --> u ) [ 0x0F B, 0xC8 B, ] ;

\ сдвинуть число u вправо на # бит с получением результата двойной длины
: shrd ( u # --> D )
       [ 0x8B B, 0xC8 B, 0x33 B, 0xC0 B, 0x8B B,
         0x55 B, 0x00 B, 0x0F B, 0xAD B, 0xD0 B,
         0xD3 B, 0xEA B, 0x89 B, 0x55 B, 0x00 B, ] ;

\ добавить битовое поле в конец битового массива
\ битовое поле начинается со старшего бита числа и занимает # бит вправо
: accrue ( u # base --> )
         bAddr >R SWAP retain +! shrd
         bSwap R@ CELL + ! bSwap R> +! ;


       USER barray
            \ адрес начала буфера

\ добавить битовое поле в конец массива
\ битовое поле начинается с 0 бита и занимает # бит влево
: bPlus ( u # --> ) [barr barray @ accrue ;

\ перед использованием bPlus надо обнулить retain и установить barray
\ shrd можно реализовать через цикл с D2/ - просто будет дольше выполняться
\ bSwap просто меняет порядок следования байт в cell на обратный

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ 0x12 8 [barr 8 = SWAP 0x12000000 = AND 0= THROW               \ [barr
      0x12345678 bSwap 0x78563412 <> THROW                          \ bSwap
      0x12345678 0x10 shrd 0x56780000 = SWAP 0x1234 = AND 0= THROW  \ shrd
      HERE 10 + barray ! 5 5 bPlus 0x12345678 0x20 bPlus
      0 bAddr 5 4 D= 0= THROW                                       \ bAddr
      barray @ @ 0xB3A29128 <> THROW                                \ bPlus
      0x11111111 0x20 bPlus barray @ CELL + @ 0x888888C0 <> THROW   \ bPlus
  S" passed" TYPE
}test



