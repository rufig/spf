\ OPTIONAL BIGMATH 64 Bit Math with Rational Approximations

\ { ====================================================================
\ (C) Copyright 1999 FORTH, Inc.   www.forth.com
\ 
\ RATIONAL APPROXIMATIONS
\ ==================================================================== }
\ 
\ { --------------------------------------------------------------------
\ Given a number expressed as a ratio of 63-bit unsigned integers,
\ calculates a ratio of 31-bit numbers that very closely approximates the
\ original ratio.  Such 31-bit ratios may then be used with */ for
\ accurate multiplication by "real" constants.
\ 
\ These routines will reproduce, or improve upon, the ratios used in
\ STARTING FORTH, Leo Brodie, p.122. For best results, use the largest
\ values (with the most sig- nificant bits) possible, as in these
\ examples:
\ 
\ 18.84955592 6.00000000 RATIO . . ( Pi, gives 235619449/75000000 )
\ 19.02797280 7.00000000 RATIO . . ( e, gives 11892483/4375000 )
\ 
\ Dependencies: Double Number Operators
\ 
\ Exports: D* DU/MOD RATIO
\ -------------------------------------------------------------------- }
\ 
\ { ---------------------------------------------------------------------
\ Double Number Arithmetic by Wil Baden
\ 
\ For a full copy of the source for his article send e-mail to
\ WilBaden@Netcom.com requesting Stretching Forth #19: Double Number
\ Arithmetic.
\ 
\ TUM* TUM/ triple Unsigned Mixed Multiply and Divide.
\ 
\ T+ T- triple Add and Subtract.
\ 
\ DU/MOD Double Unsigned Division with Remainder.  Given an unsigned
\ 2-cell dividend and an unsigned 2-cell divisor,  return a 2-cell
\ remainder and a 2-cell quotient.  The algorithm is based on Knuth’s
\ algorithm in volume 2 of his Art of Computer Programming, simplified
\ for two-cell dividend and two-cell divisor.
\ 
\ --------------------------------------------------------------------- }

\ addeded 07.03.2001 by ruv
\ --- for compatibility to SPF2.5 ---
: NOT S" 0=" EVALUATE ; IMMEDIATE
\ : D-  S" DNEGATE D+" EVALUATE ; IMMEDIATE
\ : D2* S" 2DUP D+" EVALUATE ; IMMEDIATE
\ --- end block of compatibility ---


: +CARRY  ( a b -- a+b carry )  0 TUCK D+ ;
: -BORROW ( a b -- a-b borrow ) 0 TUCK D- ;

: D* ( a . b . -- a*b . )
   >R SWAP >R  2DUP UM* 2SWAP
   R> * SWAP R> * + + ;

: TUM* ( n . mpr -- t . . ) 2>R  R@ UM*  0 2R>  UM* D+ ;
: TUM/ ( t . . dvr -- n . ) DUP >R UM/MOD R> SWAP >R UM/MOD NIP R> ;

: T+ ( t1 . . t2 . . -- t3 . . )
   >R ROT >R  >R SWAP >R +CARRY  0 R> R> +CARRY D+ R> R> + + ;
: T- ( t1 . . t2 . . -- t3 . . )
   >R ROT >R  >R SWAP >R -BORROW  S>D R> R> -BORROW D+ R> R> - + ;

: NORMALIZE-DIVISOR ( divr . -- divr' . shift )
    0 >R  BEGIN
       DUP 0< NOT WHILE
          D2*  R> 1+ >R
    REPEAT  R> ;

: DU/MOD ( divd . divr . -- rem . quot . )
   ?DUP 0= IF  ( There is a leading zero "digit" in divisor. )
      >R  0 R@ UM/MOD  R> SWAP >R  UM/MOD  0 SWAP R>  EXIT
   THEN  NORMALIZE-DIVISOR DUP >R ROT ROT 2>R
   1 SWAP LSHIFT TUM*
      ( Guess leading "digit" of quotient. )
      DUP  R@ = IF  -1  ELSE  2DUP  R@ UM/MOD NIP  THEN
      ( Multiply divisor by trial quot and subtract from divd. )
      2R@  ROT DUP >R  TUM*  T-
      DUP 0< IF ( If negative, decrement quot and add to dividend. )
         R> 1-  2R@  ROT >R  0 T+
         DUP 0< IF ( If still negative, do it one more time. )
            R> 1-  2R@  ROT >R  0 T+
   THEN  THEN ( Undo normalization of dividend to get remainder. )
   R>  2R> 2DROP  1 R>  ROT >R  LSHIFT TUM/  R> 0 ;

\ { ---------------------------------------------------------------------
\ These words derive 31-bit rational approximations for numbers that
\ start out as 63-bit ratios.  It's useful for coming up with the nice
\ ratios used by  */  for producing the effect of real arithmetic; for
\ the errors in these ratios are often on the order of ten to the minus
\ eighth or better.  The method was pointed out by a nice fellow from
\ Richmond, VA and is far better than the exhaustive searches that were
\ used earlier. In all cases it will produce the same or better ratios for
\ the examples in Starting Forth.  Method derives from Euclid.
\ 
\ RATIO requires that both of its arguments be 63-bit unsigned numbers.
\ It returns a pair of 31-bit unsigned numbers in the same order that are
\ a darned good approximation to the first pair.  Data management will
\ some day be cleaned up if we ever get a  D/  that's fast enough to make
\ this whole procedure attractive for application rather than design time
\ use.
\ 
\ --------------------------------------------------------------------- }

: ARRAY ( n -- ) \ Usage <n> ARRAY <name>
   CREATE  CELLS ALLOT
   DOES> ( n -- a )
   SWAP CELLS + ;
3 2* ARRAY DD   3 ARRAY PP   3 ARRAY QQ

: ADV ( -- flag )
   0 DD 2@  2 DD 2@  DU/MOD 2SWAP  4 DD 2!  SWAP
   DUP 1 PP @ UM*  0 PP @ 0 D+  SWAP  DUP 2 PP !  0< OR
   SWAP 1 QQ @ UM*  0 QQ @ 0 D+  SWAP  DUP 2 QQ !  0< OR OR OR ;

: (RATIO) ( -- )
   2 DD 0 DD  [ 4 CELLS ] LITERAL MOVE
   1 PP 2@ 0 PP 2!  1 QQ 2@ 0 QQ 2! ;

: RATIO ( +d +d -- n n )
   2OVER 2OVER D<  DUP >R IF  2SWAP  THEN
   2 DD 2!  0 DD 2!  1 0 PP !  0 1 PP !  0 0 QQ !  1 1 QQ !
   BEGIN  2 DD 2@ OR WHILE  ADV 0= WHILE  (RATIO)  REPEAT
   THEN  1 QQ @  1 PP @  R> IF  SWAP  THEN ;

