 \ произвести реверс бит указанного числа

 REQUIRE FOR   devel\~mOleg\lib\util\for-next.f
 REQUIRE ROL   shift.f

\ произвести реверс бит указанного числа
: revcell ( u --> u )
          DUP 0xFF00FF00 AND SWAP 0x00FF00FF AND 0x10 ROL OR
          DUP 0xF0F0F0F0 AND SWAP 0x0F0F0F0F AND 0x08 ROL OR
          DUP 0xCCCCCCCC AND SWAP 0x33333333 AND 0x04 ROL OR
          DUP 0xAAAAAAAA AND SWAP 0x55555555 AND 0x02 ROL OR
          0x01 ROL ;

\ для массива addr # произвести битовый реверс
: revarr ( addr # --> )
         FOR DUP @ revcell OVER !
             CELL +
         TILL DROP ;

