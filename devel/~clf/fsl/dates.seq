\ dates     Conversions between calendar date and Julian day number ACM# 199

\ Forth Scientific Library Algorithm #22

\ JDAY  ( d m y -- j_double )
\           Converts a (Gregorian) calendar date from the given day, month,
\           and year to the corresponding Julian day number.
\           Valid for any date.

\ JDATE  ( j_double -- d m y )
\           Converts a Julian day number to the corresponding (Gregorian)
\           calendar date (day, month, and year).  Astronomially correct
\           (Julian date begins at noon); valid for any date.

\ KDAY  ( d m yr -- k_double )
\            Converts calendar date, Gregorian Calendar to corresponding serial
\            day number, valid from 1 March 1900 (k = 1) to 31 Dec 1999
\            (k = 36465), to obtain Julian day number (valid at noon)
\             add 2415079 to k

\ KDATE  ( k_double -- da mo yr )
\            Converts serial day number to the corresponding calendar date,
\            Gregorian calendar, valid for k = 1 (1 March 1900) to
\            k = 36465 (31 Dec 1999)

\
\ This is an ANS Forth program requiring:
\      1. Requiring the Double-Number word set.
\      2. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control the visibility of internal code.
\      3. Needs the word  sd*           single * double = double_product
\         : sd*   ( multiplicand  multiplier_double  -- product_double  )
\             2 PICK * >R   UM*   R> +  ;
\      4. The compilation of the test code is controlled by the VALUE TEST-CODE?
\         and the conditional compilation words in the Programming-Tools wordset

\ Collected Algorithms from ACM, Volume 1 Algorithms 1-220,
\ 1980; Association for Computing Machinery Inc., New York,
\ ISBN 0-89791-017-6

\ (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
\ author to use this software for any application provided this
\ copyright notice is preserved.

CR .( DATES             V1.2           19 September 1994   EFC )

Private:

\ scratch space
VARIABLE da
VARIABLE mo
VARIABLE yr

Public:

: JDAY ( d m y -- j_double )

    \ adjust m and possibly y
    SWAP DUP 2 > IF   3 - SWAP
                 ELSE 9 + SWAP 1- THEN

    ROT >R SWAP >R     \ move d and m out of the way
    
    100 /MOD

    >R                 \ move quotient out of the way

    1461 UM* D2/ D2/
    
    R>  146097. sd* D2/ D2/ D+

    R> 153 * 2 + 5 / S>D D+
    R> S>D D+

    1721119. D+
    
;

: JDATE ( j_double -- d m y )
          1721119. D-

          D2* D2* 1. D- 2DUP

          \ divide by 146097. without using a d/
          5411 UM/MOD SWAP DROP 27 /MOD SWAP DROP DUP  yr !

          146097. sd* D-

          D2/ D2/
          D2* D2* 3. D+ 1461 UM/MOD
          SWAP 4 + 4 /

          5 * 3 - 153 /MOD
          mo !
          5 + 5 /  da !
          
          yr @ 100 * + yr !

          mo @ 10 < IF    3 mo +!
                    ELSE -9 mo +!  1 yr +! THEN
                        

         da @ mo @ yr @
         
;

: KDAY ( d m yr -- k_double )

         1900 -           \ just use last two decimals of year
         
         SWAP DUP 2 > IF   3 - SWAP
                      ELSE 9 + SWAP 1- THEN

         ROT >R SWAP >R      \ move d amd m out of the way

         1461 UM* D2/ D2/

         R> 153 * 2 + 5 / S>D D+

         R> S>D D+
         
;

: KDATE ( k_double -- da mo yr )
          D2* D2* 1. D-
          1461 UM/MOD
          yr !
          4 + 4 /
          5 * 3 -
          153 /MOD
          mo !
          5 + 5 /

          mo @ 10 < IF    3 mo +!
                    ELSE -9 mo +! 1 yr +! THEN

          mo @
          yr @ 1900 +
;

Reset_Search_Order


TEST-CODE? [IF]     \ test code =============================================


: date-test ( -- )

         ." JDAY: "
         22 9 1994 jday D.  ." (should be: 2449618)" CR
         ." JDATE: "
         2449618. jdate . . . ." (should be: 1994 9 22)" CR


         ." JDAY: "
         4 7 1776 jday D.  ." (should be: 2369916)" CR
         ." JDATE: "
         2369916. jdate . . . ." (should be: 1776 7 4)" CR

         ." JDAY: "
         21 7 1969 jday D.  ." (should be: 2440424)" CR
         ." JDATE: "
         2440424. jdate . . . ." (should be: 1969 7 21)" CR

         CR

         ." KDAY: "
         22 9 1994 kday D.  ." (should be: 34539)" CR
         ." KDATE: "
         34539. kdate . . . ." (should be: 1994 9 22)" CR

         ." KDAY: "
         21 7 1969 kday D.  ." (should be: 25345)" CR
         ." KDATE: "
         25345. kdate . . . ." (should be: 1969 7 21)" CR


         ." KDAY: "
         12 4 1912 kday D.  ." (should be: 4426)" CR
         ." KDATE: "
         4426. kdate . . . ." (should be: 1912 12 4)" CR

;

[THEN]





