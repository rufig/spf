: FirstWord ( addr u -- addr1 u1 )
  >IN @ >R #TIB @ >R TIB >R
    #TIB ! TO TIB >IN 0!

    NextWord
  R> TO TIB R> #TIB ! R> >IN !
;

: MOVE-TO ( addr-src size addr-dst -- )
\ просто частовстречающаяся операция
  SWAP MOVE
;

: CONCAT-TO ( addr1 u1 addr2 u2 addr -- )
\ соединить строки addr1-u1 и addr2-u2, записать результат в addr
  >R
  2SWAP ( addr2 u2 addr1 u1 )
  SWAP OVER ( addr2 u2 u1 addr1 u1 )
  R@ MOVE-TO ( addr2 u2 u1 )
  R> + MOVE-TO
;

: CONCAT ( addr1 u1 addr2 u2 -- addr u )
\ соединить строки addr1-u1 и addr2-u2, вернуть динамически
\ выделенную область памяти с результатом. разультат -
\ null-terminaated
  2OVER NIP OVER + DUP >R 1+
  ALLOCATE THROW DUP >R
  CONCAT-TO
  R> R> 2DUP + 0 SWAP C!
;

