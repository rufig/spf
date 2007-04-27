CR
.( 16 Bit Cyclic Redundancy Checksums. Version FSL1.0  29th October 1994) CR 
.(             Gordon Charlton - gordon@charlton.demon.co.uk) CR
CR 

\ Forth Scientific Library Algorithm #44

\ (c) Copyright 1994 Gordon R Charlton.  Permission is granted by
\ the author to use this software for any application provided this 
\ copyright notice is preserved.


\ ANS Forth Program.
\ Requiring ?DO \ from the Core Extensions word set.


\ This is a collection of words to create 16 bit cyclic redundancy checksums
\ (crcs) from a stream of bytes. The code is adapted from "CRC Polynomials Made
\ Plain" by Wil Baden in the 1989 Forml Conference Proceedings, Pub. Forth 
\ Interest Group 1990, pages 104-112. Modifications have been made to allow it
\ to run independantly of the cell width of the Forth system, and to include bit
\ order reversal of bytes and 16bit words, as required by some common protocols.
\
\ Descriptions of some common protocols may be found in Numerical Recipes in C,
\ The Art of Scientific Programming by Press, Vetterling, Teukolsky and 
\ Flannery, 2nd  Edition, Cambridge University Press 1992 20.3 Cyclic 
\ Redundancy and Other Checksums pages 896-901.


BASE @  HEX
\
\ CRCs are an exercise in bit-banging, so HEX is appropriate.


CREATE revtable  100 CHARS ALLOT
\
\ A lookup table for bit-reversed bytes.
 

MARKER dispose 

: rev8 ( ch--ch)  0 SWAP 
                  8 0 DO  DUP 1 AND 
                          ROT 2* OR 
                          SWAP 2/ 
                      LOOP 
                  DROP ;
\
\ Brute force bit reversal of a byte.

: filltable (  )  100 0 DO  I rev8  
                            I CHARS revtable + C!
                        LOOP ; 

filltable  dispose
\
\ Initialise the look-up table and clear out the code required to do so.


: rev8 ( ch--ch)  CHARS revtable + C@ ;
\
\ Reverse the order bits in a byte by table-lookup for speed.
 

: >< ( n--n)  DUP   FF AND  8 LSHIFT  
             SWAP FF00 AND  8 RSHIFT  OR ;
\
\ Swap the least significant 8 bits of a stack element with the next least
\ significant 8 bits. More significant bits are set to zero.
\
\ >< is a traditional name for this function, which is present as a primitive
\ on many 16 bit systems.


: rev16 ( n--n)  DUP   FF AND  rev8  8 LSHIFT  
                SWAP FF00 AND  8 RSHIFT  rev8  OR ; 
\
\ Reverse the order of bits of the 16 least significant bits of a stack element
\ More significant bits are set to zero.


CREATE crctable  100 CELLS ALLOT
\
\ A lookup table for crc values for various byte length bit patterns.


MARKER dispose 

1021 CONSTANT crc-polynomial ( CCITT or: 8005 for CRC-16)
\
\ The CCITT standard crc-polynomial is presumed. Others, such as CRC-16, which
\ is used in IBMs BISYNCH, may be editted in here)


: crc ( n ch--n)  >< XOR 
                  8 0 DO  DUP 8000 AND  
                          IF  2* FFFF AND  crc-polynomial XOR
                        ELSE  2* 
                        THEN
                    LOOP ; 
\
\ n is a CRC. crc computes a new value, to include the byte ch one bit at a
\ time. This is a slow method, used only to initialise the lookup table.
\ fairly slow method, used to set up the lookup table.
\
\ FFFF AND is, of course, redundant on a 16 bit system, but as this word is 
\ only used during compilation there is no benefit to be gained from removing
\ it from the source.


: filltable  ( ) 100 0 DO  0 I crc  I XOR  
                           I CELLS crctable + ! 
                     LOOP ;

filltable  dispose
\
\ Initialise the look-up table and clear out the code required to do so.


: crc ( n ch--n)  >< XOR >< 
                  DUP FF AND CELLS  crctable + @ 
                  XOR ;
\
\ n is a CRC. crc computes a new value, to include the byte ch.
\
\ This is the basic accumulate crc function. The words that follow illustrate
\ its application, by generating crcs for strings of characters according to
\ various conventions.


: >xmodem ( addr n--n)  0 ROT ROT 
                        OVER + SWAP 
                        ?DO  I C@ crc  1 CHARS +LOOP ;
\
\ The XMODEM convention uses a starting value of zero (all bits low).


: >x.25 ( addr n--n)  FFFF ROT ROT 
                      OVER + SWAP 
                      ?DO  I C@  rev8 crc  1 CHARS +LOOP
                      rev16 ;
\
\ X.25 uses a starting value of all bits high, and expects bytes in bit
\ reversed order (ie raw from a serial data port.) The computed checksum is 
\ likewise bit reversed.


: >crc-ccitt ( addr n--n)  0 ROT ROT
                           OVER + SWAP  
                           ?DO  I C@  rev8 crc 1 CHARS +LOOP
                           rev16 ;
\
\ CRC-CCITT has a starting value of all bits low, and is bit reversed.
 
BASE !

\ end of Cyclic Redundancy Checksums


\ Testing...

MARKER dispose 
BASE @  HEX 
 
: s1 ( --addr n)  s" An Arbitrary String" ;
: s2 ( --addr n)  s" ZYXWVUTSRQPONMLKJIHGFEDBCA" ; 

.( >xmodem ...) CR
s1 TYPE .(         gives ) s1 >xmodem  U.  .( Should be DDFC) CR
s2 TYPE .(  gives )        s2 >xmodem  U.  .( Should be B199) CR
CR
.( >x.25 ...) CR
s1 TYPE .(         gives ) s1 >x.25  U.  .( Should be 2364) CR
s2 TYPE .(  gives )        s2 >x.25  U.  .( Should be 1436) CR
CR
.( >crc-ccitt ...) 	CR
s1 TYPE .(         gives ) s1 >crc-ccitt  U.  .( Should be A5A9) CR
s2 TYPE .(  gives )        s2 >crc-ccitt  U.  .( Should be 663A) CR
CR

dispose 
BASE ! 
