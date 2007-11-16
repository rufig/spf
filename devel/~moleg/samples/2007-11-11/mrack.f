 HEX

 \ создаем массив замены четырехбитных масок
 : dmk
 F 7 B 3 D 5 9 1 E 6 A 2 C 4 8 0
 10 ALLOCATE THROW
 10 0 DO DUP I +  ROT SWAP C! LOOP ;
 dmk VALUE ddmk

 : revarr_ ( c -- c' )
   \ число со стека разлогаем на состовляющие
   8 0 DO DUP 0x00000F AND SWAP 4 RSHIFT LOOP DROP
   \ состовляющие складываем в обратном порядке заменяя на зеркальные
   0 8 0 DO ddmk ROT + C@ I 4 * LSHIFT  + LOOP ;

 \ собсттвено переработка массива
 : revarr ( adr u -- )
   0 DO DUP I CELLS + DUP @ revarr_ SWAP ! LOOP DROP ;

DECIMAL