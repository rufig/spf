\ 11.Dec.2003
 
\ Subject: [Spf-dev] новые либы
\ From: Dmitry Yakimov <ftech@tula.net>
\ Message-ID: <76202600223.20031204235513@tula.net>
\ To: spf-dev@lists.sourceforge.net
\ Date: Thu, 4 Dec 2003 23:55:13 +0300

\ Peter J. Weinberger hash function
\ Dmitry Yakimov (ftech@tula.net)

: HASH ( addr u u1 -- u2 )   
\ addr u - строка
\ если u1 не 0 хэш будет в интервале 0 ... u1-1
\ если u1=0 хэш в интервале 0 ... 2^32-1

   OVER 1 < IF 2DROP DROP 0 EXIT THEN
   ROT ROT
   
   0 \ h
   BEGIN
      OVER 0 >
   WHILE
       4 LSHIFT >R
       OVER C@ R> +
       DUP 0xF0000000 AND \ h g
       ?DUP IF
               DUP 28 RSHIFT \ h g g1
               ROT XOR XOR
            THEN
            
       >R 1- SWAP 1+ SWAP R>
   REPEAT NIP NIP
   \ interval hash 
   SWAP ?DUP IF MOD THEN
;
