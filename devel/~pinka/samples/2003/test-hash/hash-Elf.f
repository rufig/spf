\ 02.Nov.2003 Sun 21:00

REQUIRE { lib\ext\locals.f

32 CONSTANT BITS_LEN

: HASH { a u u1 \ h -- u2 } 
 0 -> h    a u + -> u
 BEGIN a u < WHILE
   h 4 LSHIFT 1+ a C@ +   -> h  a 1+ -> a
   \ h  ?DUP IF BITS_LEN 1- RSHIFT h XOR -> h THEN
  
     h 0xF0000000 AND
     DUP IF TUCK 24 RSHIFT XOR  SWAP THEN
     -1 XOR  AND

 REPEAT  h
 u1 ?DUP IF UMOD THEN
;
( что-то, похожее на Elf..)


\EOF

\ From: "Ruvim Pinka" <ruvim@forth.org.ru>
\ To: Dmitry Yakimov <sp-forth@egroups.com>
\ Date: Sat, 9 Dec 2000 05:41:33 +0000
\ Message-ID: <14237.001209@forth.org.ru>
\ Subject: Re: [sp-forth] hash

\ ElfHash на форте

: Hash { a u \ h -- u } \  0 <= u <= max_val
 0 -> h    a u + -> u
 BEGIN a u < WHILE
   h 5 LSHIFT 1+ a C@ +   -> h  a 1+ -> a
   h &max_val AND  ?DUP IF BITS_LEN 1- RSHIFT h XOR -> h THEN
   max_val h AND -> h
 REPEAT  h
;


\ ============================================

From: "Ruvim Pinka" <ruvim@forth.org.ru>
To: All <sp-forth@egroups.com>
Date: Sat, 9 Dec 2000 05:25:34 +0000
Message-ID: <1226.001209@forth.org.ru>
Subject: [sp-forth] Hash -functions


Исходники на сях  из неких статей на тему сабжа.

========================================================================

#include <limits.h>

#define BITS_IN_int     ( sizeof(int) * CHAR_BIT )
#define THREE_QUARTERS  ((int) ((BITS_IN_int * 3) / 4))
#define ONE_EIGHTH      ((int) (BITS_IN_int / 8))
#define HIGH_BITS       ( ~((unsigned int)(~0) >> ONE_EIGHTH ))

unsigned int HashPJW
             ( const char * datum )
{
 unsigned int hash_value, i;

for ( hash_value = 0; *datum; ++datum )
 {
    hash_value = ( hash_value << ONE_EIGHTH ) + *datum;
    if (( i = hash_value & HIGH_BITS ) != 0 )
      hash_value = ( hash_value ^ ( i >> THREE_QUARTERS )) & ~HIGH_BITS;
 }
 return ( hash_value );
}

/*--- ElfHash   --------------------------------------------------- *
  The published hash algorithm used in the UNIX ELF format       *
  for object files. Accepts a pointer to a string to be hashed   *
  and returns an unsigned long.                                 *
-----------------------------------------------------------------*/
unsigned long ElfHash
( const unsigned char *name )
{
 unsigned long h = 0, g;
 while ( *name )
 {
         h = ( h << 4 ) + *name++;
 if ( g = h & 0xF0000000 ) h ^= g >> 24;
 h &= ~g;
 }
 return h;
}
========================================================================

\ ============================================
