\ $Id$
\ DES
\ 
\ FIPS 46-3 
\ http://csrc.nist.gov/publications/fips/fips46-3/fips46-3.pdf
\ 
\ Handy verbose JS implementation 
\ http://people.eku.edu/styere/Encrypt/JS-DES.html

REQUIRE BIT@ ~ygrek/lib/bit.f
REQUIRE ACCERT-LEVEL lib/ext/debug/accert.f
REQUIRE /TEST ~profit/lib/testing.f

MODULE: DES

: permute { table n addr addr1 -- }
   n 0 DO
    table B@ 1- addr BIT@ I addr1 BIT!
    table 1+ -> table
   LOOP ;

CREATE preinput 64 bits,
CREATE input 64 bits,

CREATE rL 32 bits,
CREATE rR 32 bits, 
CREATE rK 48 bits, 
CREATE fullK 64 bits,

S" ~ygrek/lib/spec/des/table.f" INCLUDED

CREATE C0 28 bits, 
CREATE D0 28 bits, 
CREATE CD0 56 bits, 

: key_sched_prepare ( -- )
   pc1l #pc1l fullK C0 permute
   pc1r #pc1r fullK D0 permute
   ACCERT2( CR ." Key : " fullK 64 BITS. )
   ACCERT2( CR ." C0 : " C0 28 BITS. )
   ACCERT2( CR ." D0 : " D0 28 BITS. )
   ;

: key_sched_next_encrypt ( round -- )
   shifts + B@ >R
   28 C0 R@ BITS-LROT
   28 D0 R> BITS-LROT ;

: key_sched_next_decrypt ( round -- )
   16 SWAP - shifts + B@ >R
   28 C0 R@ BITS-RROT
   28 D0 R> BITS-RROT ;

' key_sched_next_encrypt ->VECT key_sched_next_op ( round -- )

: key_sched_next ( round -- )
   key_sched_next_op
   C0 28 CD0  0 BITS-APPEND 
   D0 28 CD0 28 BITS-APPEND
   pc2 #pc2 CD0 rK permute
;

: key_sched_report ( -- )
   CR S" C : " TYPE C0 28 BITS.
   CR S" D : " TYPE D0 28 BITS.
   CR S" CD : " TYPE CD0 56 BITS.
   CR S" K : " TYPE rK 48 BITS. ;

: s-block { in ofs out ofz n -- }
   1 ofs + in BIT@ 3 LSHIFT 
   2 ofs + in BIT@ 2 LSHIFT OR
   3 ofs + in BIT@ 1 LSHIFT OR
   4 ofs + in BIT@ 0 LSHIFT OR ( col ) \ DUP . 

   0 ofs + in BIT@ 1 LSHIFT 
   5 ofs + in BIT@ 0 LSHIFT OR ( row ) \ DUP . 
   16 *
   16 4 * n * +
   ( col sum ) +
   s + \ DUP B@ .
   >R
   0 R@ BIT@ 3 ofz + out BIT!
   1 R@ BIT@ 2 ofz + out BIT!
   2 R@ BIT@ 1 ofz + out BIT!
   3 R@ BIT@ 0 ofz + out BIT!
   RDROP ;

CREATE f_temp 48 bits, 

: f { input K output -- }
   e #e input f_temp permute
   ACCERT2( CR ." E : " f_temp 48 BITS. )
   f_temp K 48 f_temp BITS-XOR
   ACCERT2( CR ." E XOR K : " f_temp 48 BITS. )
   8 0 DO
    f_temp I 6 * f_temp I 4 * I s-block
   LOOP 
   ACCERT2( CR ." S-boxed : " f_temp 48 BITS. )
   p #p f_temp output permute ;

CREATE old 32 bits, 

: round
   \ backup
   rL old 4 MOVE
   rR rL 4 MOVE
   rL rK rR f
   rR old 32 rR BITS-XOR ;

CREATE output 64 bits,
CREATE preoutput 64 bits,

: intro
   ip #ip preinput input permute
   input 0 + rL 4 MOVE
   input 4 + rR 4 MOVE 
   ACCERT2( CR S" preinput : " TYPE CR preinput 64 BITS. )
   ACCERT2( CR S" input : " TYPE CR input 64 BITS. )
   ;

: rounds
   ACCERT2( CR ." Initial : " )
   ACCERT2( CR ." L = " rL 32 BITS. )
   ACCERT2( CR ." R = " rR 32 BITS. )
   key_sched_prepare
   16 0 DO
     ACCERT2( CR ." Round " I . )
     I key_sched_next
     ACCERT2( key_sched_report )
     round
     ACCERT2( CR ." L = " rL 32 BITS. )
     ACCERT2( CR ." R = " rR 32 BITS. )
   LOOP ;

: outro
   rR 32 preoutput 0 BITS-APPEND
   rL 32 preoutput 32 BITS-APPEND
   ip1 #ip1 preoutput output permute 
   ACCERT2( CR ." preoutput : " preoutput 64 BITS. )
   ACCERT2( CR ." output : " output 64 BITS. )
;

: DES-BLOCK-OPERATE ( key plain -- )
   >R
   fullK 8 MOVE
   R@ preinput 8 MOVE
   intro rounds outro
   output R> 8 MOVE ;

EXPORT

\ DES оперирует с блоками данных 64 бит
\ т.е. data-addr должен указывать на 8 байт данных
\ после выполнени€ операции результат будет помещЄн обратно в data-addr
\  люч тоже должен быть 64 бит, но реально используютс€ только 56 из них
\ ќстальные примен€ютс€ дл€ контрол€ чЄтности но в этой реализации не провер€ютс€
\ т.е. key-addr должен указывать на 8 байт ключа
\ содержимое key-addr не мен€етс€

: DES-BLOCK-DECRYPT ( key-addr data-addr -- ) 
   ['] key_sched_next_decrypt TO key_sched_next_op  
   DES-BLOCK-OPERATE ;

: DES-BLOCK-ENCRYPT ( key-addr data-addr -- ) 
   ['] key_sched_next_encrypt TO key_sched_next_op  
   DES-BLOCK-OPERATE ;

;MODULE

\ -----------------------------------------------------------------------------

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f

ALSO DES

TESTCASES Key schedule

 CREATE test-key
 b- 00111011 b- 00111000 b- 10011000 b- 00110111 b- 00010101 b- 00100000 b- 11110111 b- 01011110

 test-key fullK 64 BITS-MOVE

 \ CR S" Full K : " TYPE fullK 64 BITS.
 key_sched_prepare 
 :NONAME 
   16 0 DO 
   \ key_sched_report
   I key_sched_next 
  LOOP 
  \ key_sched_report 
 ; EXECUTE

 CREATE C16 b- 01000100 b- 11000000 b- 01101011 b- 1101
 CREATE D16 b- 11001001 b- 11011000 b- 10000111 b- 1111
 CREATE K16 b- 00010001 b- 01111100 b- 10000001 b- 11010111 b- 11100001 b- 01001110

 (( C0 C16 28 BITS-EQUAL? -> TRUE ))
 (( C0 C16 28 BITS-EQUAL? -> TRUE ))
 (( D0 D16 28 BITS-EQUAL? -> TRUE ))
 (( rK K16 48 BITS-EQUAL? -> TRUE ))

END-TESTCASES

TESTCASES S block
 CREATE in b: 011011 B, 
 CREATE out 4 bits,
 in 0 out 0 0 s-block
 (( 0 out BIT@ -> 0 ))
 (( 1 out BIT@ -> 1 ))
 (( 2 out BIT@ -> 0 ))
 (( 3 out BIT@ -> 1 ))
END-TESTCASES

PREVIOUS

\EOF example 

CREATE z 8 ALLOT
S" qwertyui" DROP z 8 MOVE
CR z 64 BITS.
CR z 8 TYPE

S" secretkey" DROP z DES-BLOCK-ENCRYPT
CR z 64 BITS.
CR z 8 TYPE

S" secretkey" DROP z DES-BLOCK-DECRYPT
CR z 64 BITS.
CR z 8 TYPE

