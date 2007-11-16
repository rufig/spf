
 REQUIRE FOR   devel\~mOleg\lib\util\for-next.f

\ произвести реверс бит указанного числа
: revcell ( u - u ) 0  32 0 DO  SWAP 0 D2*  I LSHIFT ROT +  LOOP  NIP ;

\ для массива addr # произвести битовый реверс
: revarr ( addr # --> )
         FOR DUP @ revcell OVER !
             CELL +
         TILL DROP ;

