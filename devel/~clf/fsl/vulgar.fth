
\ \\\\\\\\\\\\\ start of VULGAR.FTH \\\\\\\\\\\\\\\\

CR
.( Vulgar Maths Words. Version FSL1.1  23rd April 1996) CR
.(     Gordon Charlton - gordon@charlton.demon.co.uk) CR
CR

\ Forth Scientific Library Algorithm #46

\ (c) Copyright 1996 Gordon R Charlton.  Permission is granted by
\ the author to use this software for any application provided this
\ copyright notice is preserved.
\
\ ANS Forth Program with environmental dependancies.
\
\ Requiring the Double-Number word set (namely 2CONSTANT 2LITERAL D+ D- D0= D>S
\                                              D< D= DABS DNEGATE and M+).
\
\ Requiring the Floating-Point wordset (namely D>F F* F- F/ F>D FDUP FLITERAL
\                                              FLOOR FOVER and FSWAP).
\
\ Requiring the String word set (namely /STRING).
\
\ Requiring 0<> <> ?DO 2>R 2R> FALSE MARKER NIP PICK TO TRUE TUCK VALUE \
\ from the Core Extensions word set.
\
\ Requiring DU< from the Double-Number Extensions word set.
\
\ Requiring CS-ROLL from the Programming-Tools Extensions word set.
\
\ With an environmental dependancy on two's complement arithmetic.
\
\ With an environmental dependancy that the largest usable signed double
\ number be within the range of usable floating point numbers if this is
\ available from ENVIRONMENT? or that 2147483647 be within the range of
\ usable floating numbers if it is not.
\
\ A Standard System exists after the program is loaded.


\ ----- Description -----

\ This word set provides the basic arithmetic, logical, type conversion and
\ numerical output routines necessary for handling rational numbers.

\ Throughout the suite the data type "rational number" is referred to by the
\ popular name, "vulgar" as the use of the prefix V to indicate a vulgar
\ is less ambiguous than the prefix R, which may be confused with Real, by
\ which name Floating Point numbers are sometimes known.

\ In this implementation vulgars are represented by two integers, which
\ are held on the data stack in the order Numerator Denominator. The numerator
\ and denominator are always relatively prime.

\ The numerator is a signed integer, and the denominator a non-negative
\ integer.

\ Numbers to large to be represented are indicated by the special value 0 0,
\ which will propagate through a program. Most words in this suite are tolerant
\ of the overflow indicator, with the exception of those that convert vulgar
\ numbers to other numerical data types. These are flagged in the listing. In
\ general programming techniques which depend on the propogation of overflow
\ errors are discouraged by the author.

\ Zero is represented by the vulgar number 0 1.

\ Numbers which cannot be represented exactly are rounded by a mediant
\ rounding scheme as described in The Art of Compuer Programming by D E Knuth.
\ (Volume 2, Seminumerical Algorithms 2nd Edition (1981, Addison Wesley),
\ 4.5.3 Analysis of Euclids Algorithm, page 363, exercise 40) which has been
\ shown to generate best possible approximations. (A less rigorous but more
\ accessible description may be found in the hobbyist book "Recreactions in
\ the Theory of Numbers" by A H Beiler, Dover Publications Ltd, 1966.)


\ ----- Rational Representations -----

\ The range and distribution of rational numbers will vary according to the
\ stack width of a Forth system. In a 16bit system, considering positive
\ numbers only (the same arguments are applicable to negative numbers), the
\ largest representable number is 32767, and the smallest 1/32767.
\ Approximately 654,942,536 different positive numbers can be represented.
\ (This is calculated using the rule of thumb estimate 32767*32767*0.61,
\ (number of different integer pairs * approximate probability that they are
\ relatively prime). Knuth, Seminumerical Algorithms 4.5.2 Theorum D, p 324.)
\
\ However these are not evenly distributed. Half lie in the range 0<v<=1, and
\ half in the range 1<v<32767. In the range of proper fractions (<=1) they are
\ distributed as a Farey sequence (Farey series' are described in many
\ introductory texts on Number Theory. A light description may be found in
\ Beiler, Recreactions in the Theory of Numbers.) In the range of improper
\ fractions (>1) the difference between successive representable numbers
\ increases as the absolute value of the fraction increases (eg above 16384
\ only integers are representable without overflow).
\
\ For this reason, the word vsplit is provided, which separates the fractional
\ and the integral component of a vulgar fraction. If the loss of precision
\ associated with large numbers is not acceptable vsplit can be used to deal
\ with the fractional component separately, thus maintaining absolute precision.

\ On the subject of accuracy and precision is is worth noting that rational
\ representations are capable of maintaining total accuracy with simple
\ fractions, such as one third, which cannot be precisely represented in a
\ floating point representation. Knuth, amongst others, contends that
\ arithmetic using a rational representation and mediant rounding is not
\ subject to cumulative rounding errors, as it "tends to make the intermediate
\ rounding errors cancel out" (Seminumerical algorithms, 4.5.1 Fractions, page
\ 315).


\ ----- Key Words -----

\ This is a brief description of a selection of the words provided.
\ The letter v in a stack comment indicates a vulgar number as described
\ above. More detailed descriptions are embedded within the code.

\ v+ ( v1 v2--v3)         v3 is the sum of v1 and v2.

\ v* ( v1 v2--v3)         v3 is the product of v1 and v2.

\ v- ( v1 v2--v3)         v3 is v1 minus v2.

\ v/ ( v1 v2--v3)         v3 is v1 divided by v2.

\ vnegate ( v1--v2)       v2 is the product of v1 and -1.

\ vreciprocal ( v1--v2)   v2 is 1 divided by v1 v2 is the absolute value of v1.

\ v0< ( v--f)             f is TRUE if v is negative.

\ v0= ( v--f)             f is TRUE if v is zero.

\ v= ( v1 v2--f)          f is TRUE if v1 is exactly equal to v2.

\ v~ ( v1 v2--f)          f is TRUE if v1 is approximately equal to v2.

\ v< ( v1 v2--f)          f is TRUE if v1 is less than v2.

\ v> ( v1 v2--f)          f is TRUE if v1 is greater than v2.

\ vmax ( v1 v2--v3)       v3 is the larger of v1 and v2.

\ vmin ( v1 v2--v3)       v3 is the smaller of v1 and v2.

\ voverflow ( v--f)       f is TRUE if v is the special vulgar indicating
\                         that overflow has occurred in an earlier calculation.

\ s>v ( n--v)             v is the vulgar equivalent of the signed integer n.

\ v>s ( v--n)             n is the integral component of v as a signed integer
\                         Rounding is floored (ie to negative infinity).

\ f>v ( r--v)             v is a vulgar approximation to the floating point
\  or ( --v) (F: r)       number r

\ v>f ( v--r)             r is a floating point approximation to the vulgar
\  or ( v) (F: --r)       number v

\ str>v ( addr n1 n2--v)  v is an approximation of the number represented by
\                         the string of length n1 that starts at the address
\                         addr when interpreted in base n2. The string may have
\                         a leading minus sign and an embedded point.

\ vfrac ( v1--v2 )        v2 is the fractional component of v1. v2 is non-
\                         negative

\ vsplit (v1--v2 v3)      v2 is the integral component of v1 rounded as above
\                         v3 is the non-negative fractional component.

\ vulgar ( "number"--v)   v is an approximation to the number represented by
\                         the space delimited character string following in
\                         the input stream. The string is as per str>v, the
\                         global variable BASE determines the base.

\ [vulgar] ( "number")    Embeds the following space delimited string as a
\                         vulgar literal within a colon definition. Compiling
\                         version of "vulgar" (above).

\ vround ( v1 +n--v2)     v2 is an approximation to v1 such that neither the
\                         absolute value of the numerator nor the denominator
\                         exceeds +n.

\ vsimplify ( v1 +n--v2)  v2 is an approximation to v1 such that neither the
\                         numerator nor the denominator of the fractional
\                         component of v1 exceeds +n.

\ places (-- n)           n is the maximum number of digits after the point
\                         that will be displayed when a vulgar is displayed in
\                         floating point format.

\ set-places ( n)         n specifies the maximum number of digits after the
\                         point that will be displayed when a vulgar is
\                         displayed in floating point format.

\ truncation ( --f)       f is TRUE if trailing zeroes will be suppressed when
\                         a vulgar is displayed in floating point format.

\ set-truncation ( f)     f specifies whether trailing zeroes will be suppressed
\                         when a vulgar is displayed in floating point format.
\                         TRUE turns suppression on, FALSE turns it off.

\ v.fj ( v n1 n2)         display v in floating point format, justified to the
\                         left and right with spaces so that there are n1
\                         characters to the left of the point, and n2 characters
\                         to the right. No trailing zeroes. Display "Overflow"
\                         if v is the overflow indicator.

\ v.f ( v)                display v in floating point format with no
\                         justification and one trailing space. Display
\                         "Overflow" if v is the overflow indicator.

\ digits ( n)             n is the maximum number of digits that will be
\                         displayed in the numerator or denominator of the
\                         fractional part when a number is displayed in vulgar
\                         format.

\ set-digits ( --n)       n specifies the maximum number of digits that will be
\                         displayed in the numerator or denominator of the
\                         fractional part when a number is displayed in vulgar
\                         format.

\ v.j ( v n1 n2)          display v in vulgar format, justified to the left and
\                         with spaces so that there are n1 characters to the
\                         left of the space between the space between the
\                         integeral and fractional components, and n2
\                         characters to the right. Display "Overflow" if v is
\                         the overflow indicator.

\ v. ( v)                 display v in vulgar format with no justification and
\                         one trailing space. Display "Overflow" if v is the
\                         overflow indicator.

\ ----- Source Code -----

\ Non-standard Core Extensions

: 4dup ( a b c d--a b c d a b c d)  2OVER 2OVER ;
\
\ Copy top four items on stack.


: not ( f--f)  0= ;
\
\ could be defined as 0= or INVERT, as is only used on normalised booleans
\ in this code.


: ?negate ( n f-- -n)  IF  NEGATE  THEN ;
\
\ n is negated if f is true.


: mu* ( ud1 u--ud2)  TUCK * >R  UM*  R> + ;
\
\ multiply unsigned double by unsigned single, giving unsigned double result.


: um/ ( ud u--u)  UM/MOD NIP ;
\
\ divide unsigned double by unsigned single, giving unsigned single result.


: mu/ ( ud u--ud)  >R  0 R@  UM/MOD  R> SWAP >R  um/  R> ;
\
\ divide unsigned double by unsigned single, giving unsigned double result.


: um*/ ( u1 u2 u3--ud)  >R UM*  R> mu/ ;
\
\ multiply unsigned single u1 by unsigned single u2, then divide by unsigned
\ single u3, giving unsigned double result.


: um** ( u1 u2--ud)  1.  ROT 0 ?DO  2 PICK mu*  LOOP  ROT DROP ;
\
\ raise unsigned single u1 to the power specified by unsigned single u2,
\ giving unsigned double result.


0 1 2 um/ CONSTANT highbit
\
\ this is a bitmask which, in a twos complement system, is the largest
\ representable signed single (in 16bit = 8000 hex or -8000 hex).


: DONE ( compilation: dest orig1--orig2 dest)
       ( run-time: --)  POSTPONE ELSE  1 CS-ROLL ; IMMEDIATE
\
\ control flow word. Used in conjunction with IF to force an untimely exit
\ from a structure started with BEGIN eg;
\
\ BEGIN   ... ( f) IF  ... ( this code executed on exit) DONE
\         ... ( otherwise loop continues)
\ AGAIN THEN ( DONE forces branch to nearest unresolved THEN after AGAIN )
\            (      or UNTIL. WHILE is treated as AGAIN THEN             )


CHAR . VALUE point

\ for portablility. In environments where the decimal point is not a period
\ this can be changed after a program using it is loaded. E.g. in Europe one
\ might issue "CHAR , TO point".


\ Non-standard Double Extensions

: d0<> ( d--f)  D0=  not ;
\
\ returns TRUE if double number d is non-zero.


: ud* ( ud ud--ud)  DUP IF  2SWAP  THEN  DROP  mu* ;
\
\ multiply unsigned double by unsigned double, giving double result.


: d* ( d d--d)  DUP 0< >R  DABS
                2SWAP  DUP 0< >R  DABS
                ud*  R> R> XOR IF  DNEGATE  THEN ;
\
\ multiply signed double by signed double, giving signed double result.


: ut*  ( ud u--ut)  TUCK UM*  2SWAP UM*  SWAP >R  0 D+  R> ROT ROT ;
\
\ multiply unsigned double by unsigned single, giving unsigned triple
\ result.


: ut/ ( ut u--ud)  DUP >R  UM/MOD  ROT ROT R>  UM/MOD  NIP SWAP ;
\
\ divide unsigned triple by unsigned single, ugiving unsigned double
\ result.


: mu*/ ( ud1 u1 u2--ud2)  >R ut*  R> ut/ ;
\
\ Multiply ud1 by u1 producing the triple-cell intermediate result t.
\ Divide t by u2 giving quotient ud2.


: +d/ ( +d1 +d2--+d3)  ?DUP IF  DUP 1+  0 1 ROT  um/
                                DUP >R  mu*
                                >R OVER SWAP R@ um*/ D-
                                2R> mu*/  NIP 0
                          ELSE  mu/
                          THEN ;

\ divide non-negative double +d1 by strictly positive double +d2,
\ giving double quotient d3.
\
\ The algorithm is described in "Long Divisors and Short Fractions
\ by Prof. Nathaniel Grossman, in Forth Dimensions Volume VI No. 3.
\
\ Grossman cites Abramowitz M and I A Stegun, Handbook of Mathematical
\ Functions, National Bureau of Standards Applied Mathematics Series, 55.
\ (Reprinted by Dover Publications) page 21 and Knuth, Seminumerical Algorithms
\ as his references.


: +d/mod ( +d1 +d2--+d3 +d4)  4dup +d/  2DUP 2>R  ud*  D- 2R> ;
\
\ divide non-negative double +d1 by strictly positive double +d2,
\ giving double remainder d3 and double quotient d4.


: >double ( addr n1--d n2 true|false)
          DUP IF  OVER C@ [CHAR] - =  DUP >R  IF  1 /STRING  THEN
                  0. 2SWAP >NUMBER
                  OVER C@ point =  OVER AND  IF  1 /STRING  THEN
                  DUP >R  >NUMBER
                  IF  2R> 2DROP 2DROP DROP FALSE
                ELSE  DROP  2R> >R  IF  DNEGATE  THEN  R>  TRUE
                THEN
            ELSE  2DROP 0. 0 TRUE
            THEN ;
\
\ translate string at addr of length n to double number d in the current base
\ If string starts with - then d is negative. One embedded point is allowed. If
\ present then n2 is equal to the position of the point in the string. If no
\ point is present then dpl is equal to n1. TRUE indicates that conversion was
\ successful. FALSE indicates that an illegal character was present in the
\ string. If FALSE is returned d and dpl are not present on the stack. A null
\ string is interpreted as zero. (As are the strings "." "-" and ".-".)


\ Non-Standard String Extensions

: >ch ( addr n1 ch--n2)  OVER SWAP 2SWAP
                         0 ?DO  2DUP C@ =
                                IF  ROT DROP I ROT ROT  LEAVE THEN
                                CHAR+
                          LOOP 2DROP ;
\
\ search string at addr of length n1 for character ch. If it is present then
\ n2 is the position of the first occurance of ch in the string. If it is not
\ present then n2 is equal to n1.


: hasch ( addr n ch--f)  OVER >R  >ch  R>  <> ;
\
\ f is TRUE if character ch is present in the string of length n that starts at
\ address addr.


\ Vulgar Simplification

: gcd ( n n--n)  ABS  SWAP ABS
                 BEGIN  DUP  WHILE  TUCK MOD  REPEAT
                 DROP ;
\
\ returns the single greatest common denominator of the absolute value
\ of two signed single numbers. If either number is zero, returns the absolute
\ value of the other number. Uses Euclids Algorithm.


: normal ( v--v)  2DUP gcd  TUCK / >R  /  R> ;
\
\ normalises a vulgar by ensuring the numerator and denominator are relatively
\ prime.


: ud>+n? ( ud--+n f)  OVER highbit AND OR  0<> ;
\
\ converts unsigned double ud to non-negative single +n. f is TRUE if the
\ conversion was not successful.


VARIABLE numerator           \ private to the vulgar approximation routines.
VARIABLE prev.numerator      \ private to the vulgar approximation routines.

VARIABLE denominator         \ private to the vulgar approximation routines.
VARIABLE prev.denominator    \ private to the vulgar approximation routines.

: setvars  (  )   0 numerator !    1 prev.numerator !
                1 denominator !  0 prev.denominator ! ;
\
\ the first approximation to a vulgar number is 1. Approximations are held
\ in the variables numerator and denominator. The "zeroth" approximation
\ is the overflow condition, which is represented by the vulgar 0 1. (This
\ will be adjusted to 0 0 on exit from the approximation routine.)
\
\ When a new approximation is generated the previous one
\ is stashed in the variables prev.numerator and prev.demoninator.
\
\ setvars initialises these prior to generating approximations.


: num>? ( ud--u f)  numerator @ mu*
                    prev.numerator @ 0 D+  ud>+n? ;
\
\ the next approximation to the numerator u is the current approximation
\ multiplied by ud, which is the next number in the continued fraction of
\ the vulgar being approximated, plus the previous approximation.
\ flag is true if the next approximation cannot be represented as a non-
\ negative single integer (ie the approximation is as good as it can get).


: den>? ( ud--u f)  denominator @ mu*
                    prev.denominator @ 0 D+  ud>+n? ;
\
\ the next approximation to the denominator u, is the current approximation
\ multiplied by ud, which is the next number in the continued fraction of
\ the vulgar being approximated, plus the previous approximation.
\ flag is true if the next approximation cannot be represented as a non-
\ negative single integer (ie the approximation is as good as it can get).


: next! ( +v)  denominator @  prev.denominator !  denominator !
                 numerator @    prev.numerator !    numerator ! ;
\
\ make the new approximation the current approximation, and the current
\ approximation the previous approxinmation.


: dv>udv? ( dv--+dv f)  2SWAP DUP 0< >R  DABS 2SWAP R> ;
\
\ return the absolute value a signed double vulgar. f is true if the argument
\ was negative. A double vulgar is represented on the stack as dnumerator
\ +ddenominator, where the sign is held in the numerator as per single vulgars


: reduce ( dv--v)  setvars  dv>udv? >R
                   BEGIN  2DUP d0<>
                   WHILE  2OVER 2DUP d0<> IF  +d/mod  THEN
                          2DUP num>? IF  next! DROP  DONE
                          ROT ROT den>? IF  next!  DONE
                          next! 2SWAP
                   REPEAT THEN THEN 2DROP 2DROP
                   prev.numerator @  R> ?negate
                   prev.denominator @ ;
\
\ return the normalised vulgar which most closely approximates the signed
\ double vulgar passed to it. Returns 1 0 if the double vulgar was too large
\ and positive to be represented or -1 0 if too large and negative. Numbers
\ too small to be represented are rounded to zero (0 1).
\
\ Works by generating approximations from successive numbers in the continued
\ fraction expansion of dv, until no more numbers are available, or overflow
\ occurs.
\
\ The first number in the continued fraction expansion is the integral
\ component and the next the integral component of the reciprocal of the
\ fractional component and so on. This is best demonstrated with a pocket
\ calculator. Pi is 3.14159... so the continued fraction starts with 3 (the
\ integral component. The reciprocal of the fractional component (0.14159..)
\ is 7.06251..., so the next number in the expansion is 7. The reciprocal of
\ 0.06251 is 15.99659..) so the next number is 15 and so on.
\
\ The continued fraction of any rational number terminates when the fractional
\ component becomes zero.


: small? ( dv--f)  highbit 0 DU< >R
                   DABS  highbit 0 DU<  R> AND ;
\
\ returns TRUE if double vulgar dv can be normalised by "normal", rather than
\ the slower "reduce".


: dv>v ( dv--v)  4dup small? IF  DROP NIP normal  ELSE  reduce  THEN
                 DUP 0= IF NIP 0 THEN ;
\
\ returns the vulgar that most closely approximates the unnormalised double
\ vulgar dv. If overflow is detected (denominator is zero) action is taken to
\ ensure the overflow indicator 0 0 is returned.


\ Vulgar Arithmetic

: v+ ( v v--v)  ROT 2DUP UM* 2>R  ROT M*  2SWAP M*  D+  2R>  dv>v ;
\
\ add two vulgars using naive algorithm, generating double length result, then
\ round to single. Empirical tests showed that on the development system the
\ naive method was a little faster than the method recommended by Knuth
\ (Seminumerical algorithms 4.5.1 Fractions).


: v* ( v v--v)  ROT UM*  2SWAP M*  2SWAP dv>v ;
\
\ multiply two vulgars using naive algorithm, generating double length result,
\ then round to single. Empirical tests show that on the development system
\ the naive method was a little faster than the method recommended by Knuth
\ (seminumerical algorithms 4.5.1 Fractions).


: vnegate ( v--v)  SWAP NEGATE SWAP ;
\
\ return vulgar * -1. The sign bit is in the numerator.


: vreciprocal ( v--v)  SWAP DUP 0< IF  ABS vnegate  THEN ;
\
\ the reciprocal of a vulgar is trivial (SWAP). The sign bit needs moving
\ back to the numerator.


: v- ( v1 v2--v3)  vnegate v+ ;
\
\ subract vulgar v2 from vulgar v1 giving vulgar result.


: v/ ( v1 v2--v3)  vreciprocal v* ;
\
\ divide vulgar v2 by vulgar v1 giving vulgar result.


: vabs ( v--v)  SWAP ABS SWAP ;
\
\ return absolute value of vulgar argument.


\ Vulgar Comparison

: v0< ( v--f)  DROP 0< ;
\
\ flag is TRUE if vulgar v is negative.


: v0= ( v--f)  0 1 D= ;
\
\ flag is true if vulgar v is zero.


: v= ( v v--f)  D= ;
\
\ flag is true if the two vulgar arguments are equal. This test is trivial
\ as vulgars are kept in normalised form.


: v~ ( v v--f)  v- v0= ;
\
\ f is TRUE if the two vulgar arguments are approximately equal
\
\ The difference between two vulgars may be less than the smallest vulgar that
\ is representable with a single length denominator. In this instance the two
\ vulgars may be reasonably described as approximately equal. Note that two
\ overflow indicators are equal, but are not approximately equal!


: v< ( v1 v2--f)  ROT ROT M*  2SWAP M*  2SWAP D< ;
\
\ f is TRUE if vulgar v1 is less than vulgar v2. Returns FALSE if either
\ argument is the overflow condition.
\
\ It is not possible to determine if one vulgar is larger than another by
\ subtracting one from another and examining the sign of the difference, as
\ they may be approximately equal, so the difference would be rounded to zero.
\ This avoids that problem and is faster. See Knuth, Seminumerical Algorithms
\ 4.5 Rational Arithmetic, Exercise 1.


: v> ( v1 v2--f)  2SWAP v< ;
\
\ f is TRUE if vulgar v1 is greater than vulgar v2. Returns FALSE if either
\ argument is the overflow condition.


: voverflow ( v--f)  D0= ;
\
\ f is TRUE if vulgar v indicates overflow has occurred previously.
\
\ This word should be used where overflow is possible. (Although propagation
\ of overflow is possible, the author does not endorse it.)


: vmax ( v1 v2--v3) 2DUP voverflow >R
                    4DUP v<  R> OR  IF  2SWAP THEN  2DROP ;
\
\ returns the larger of the two vulgar arguments. Will always return the
\ overflow condition, if present.


: vmin ( v1 v2--v3) 2DUP voverflow >R
                    4DUP v>  R> OR  IF  2SWAP THEN  2DROP ;
\
\ returns the smaller of the two vulgar arguments. Will always return the
\ overflow condition, if present.


\ Vulgar Conversion

1 CONSTANT s>v ( n--v)
\
\ promote single integer to vulgar equivalent. n --> n 1


: v>s ( v--n)  >R S>D  R> FM/MOD NIP ;
\
\ return the integral component of vulgar v as a signed integer.
\
\ Floored rounding (to negative infinity) is used as other parts of the
\ suite require it.
\
\ ***** This word may be intolerant of overflow on some systems. *****


: str>v ( addr n1 n2--v)  >R >double  not ABORT" Non-numerical string"
                          R> SWAP um**  dv>v ;
\
\ convert character string at addr of length n1 to vulgar v using n2 as the
\ radix (base). The string should conform with the description in >double.


: vfrac ( v1--v2)  DUP IF TUCK >R S>D  R> FM/MOD DROP  SWAP  THEN ;
\
\ return the fractional component of vulgar v1 as non-negative vulgar v2.
\
\ Floored rounding (to negative infinity) is used as other parts of the
\ suite require it. This ensures v2 is positive. The test for non-zero
\ ensures this word is tolerant of the overflow condition.


: vsplit ( v1--v2 v3)  2DUP DUP IF  v>s s>v  THEN
                       2SWAP vfrac ;
\
\ return the integral component of vulgar v1 as vulgar v2 and the fractional
\ component as non-negative vulgar v2.
\
\ Floored rounding (to negative infinity) is used as other parts of the
\ suite require it. The test for non-zero ensures this word is tolerant of the
\ overflow condition.


\ : v>f ( v--r or: ( v) ( F: --r)  >R S>D D>F  R> S>D D>F  F/ ;
\
\ convert vulgar v to floating point number r. v should be within the range
\ of representable floating point numbers.
\
\ ***** This word may be intolerant of overflow on some systems. *****


MARKER discard
: get-dbig  S" MAX-D" ENVIRONMENT? not IF  2147483647.  THEN ;
get-dbig  discard  2CONSTANT dbig
\
\ The 2constant dbig represents the largest usable positive double number.
\ If, on a given system, this is larger than 2,147,483,647 but not known by
\ ENVIRONMENT? the source should be edited to show the correct value. The
\ number dbig should be representable as a floating point number.
\
\ get-dbig is discarded after use as it is not required beyond this point.


\ : f>v ( r--v or: ( --v) ( F: r)  FDUP FLOOR  FSWAP FOVER F-
\                                  [ dbig D>F ] FLITERAL  F*
\                                  F>D dbig dv>v  2>R
\                                  F>D D>S s>v  2R> v+ ;
\
\ convert floating point number r to vulgar v. r should be in the range of
\ representable vulgars.
\
\ The method used here was chosen for minimal impact on environmental
\ dependancies. On some systems it may not give the best possible
\ approximations. Where the internal structure of a floating point number is
\ known (this should be described in the documentation accompanying a standard
\ system) there may be some benefit to reading the exponent and mantissa
\ directly and generating an approximation from that using a method broadly
\ equivalent to that used in str>v, (above). If the internal representation is
\ not available, or is inappropriate, there may be some benefit to converting
\ the internal representation to IEEE 64bit, using DF! in the Floating-Point
\ Numbers Extensions word set, and reading that directly. It is most likely
\ that only very unusual systems will have recourse to these techniques.


\ Vulgar Literals

: vulgar ( "number"--v)  BL WORD COUNT  BASE @  str>v ;
\
\ translate the space delimited character string following vulgar in the input
\ stream into a vulgar using the current value of BASE as the radix. ie,
\ assuming DECIMAL ;
\
\ vulgar 3.14159265 2CONSTANT pi
\
\ \ pi will return 355 133 (in a 16bit system) which has an error
\ \ of 8.5 * 10^-8
\
\ See Starting Forth by Leo Brodie (2nd edition 1987 Prentice Hall) page 102
\ et seq. for a discussion of the use of rational approximations in Forth
\ outside of this suite.


: [vulgar] ( compilation: "number"--)
           ( run-time: --v)  vulgar  POSTPONE 2LITERAL ; IMMEDIATE
\
\ during compilation translate the space delimited character string following
\ [vulgar] in the input stream into a vulgar using the current value of BASE
\ as the radix and compile into the definition as a literal. ie, assuming
\ DECIMAL ;
\
\ : CIRCUMFERENCE ( n1--n2) [vulgar] 3.14159265 */ ;
\
\ \ given the diameter of a circle n1, return the circumference n2.


\ Vulgar Rounding

: v>uv? ( v--uv f)  2DUP vabs  2SWAP v0< ;
\
\ uv is the absolute value of the vulgar v, f is TRUE if v was negative.


: snum>? ( u1 u2--u3 f)  >R  numerator @ *
                         prev.numerator @ + DUP R> U> ;
\
\ the next approximation to the numerator u3, is the current approximation
\ multiplied by u1, which is the next number in the continued fraction of
\ the vulgar being approximated, plus the previous approximation. flag is true
\ if the next approximation is greater than u2.
\
\ There is no need for double length results here, as the vulgar being
\ approximated is single length, so an approximation cannot generate an
\ overflow.


: sden>? ( u1 u2--u3 f)  >R  denominator @ *
                      prev.denominator @ + DUP R> U> ;
\
\ the next approximation to the denominator u3, is the current approximation
\ multiplied by u1, which is the next number in the continued fraction of
\ the vulgar being approximated, plus the previous approximation. flag is true
\ if the next approximation is greater than u2.
\
\ There is no need for double length results here, as the vulgar being
\ approximated is single length, so an approximation cannot generate an
\ overflow.


: vround ( v1 +n--v2)  >R  2DUP voverflow
                       IF  R> DROP
                     ELSE  setvars  v>uv? R> 2>R
                           BEGIN  DUP
                           WHILE  OVER DUP IF  /MOD  THEN
                                   DUP R@ snum>? IF  next!  DONE
                                  SWAP R@ sden>? IF  next!  DONE
                                  next! SWAP
                           REPEAT THEN THEN 2DROP R> DROP
                           prev.numerator @  R> ?negate
                           prev.denominator @
                     THEN ;
\
\ returns an approximation to the vulgar number v1 such that neither the
\ numerator nor the denominator exceeds the positive integer n.

\ This is the same algorithm as "reduce" (above), restricted to a single length
\ argument and thus avoiding the inefficiencies of the double length maths.
\ The intent is that, where high precision is not an issue, vround can be
\ inserted at key points in the code to ensure the quicker "normalise" path is
\ taken in subsequent words that call DV>V


: vsimplify ( v1 +n--v2)  >R vsplit  R> vround v+ ;
\
\ returns an approximation to the vulgar number v1 such that neither the
\ numerator nor the denominator of the fractional component of v1 exceeds the
\ positive integer n.
\
\ This word is intended primarily for use in the vulgar output routines, but
\ may be of use elsewhere.


\ Vulgar Output

5 VALUE places
\
\ returns the maximum number of digits after the point that will be included
\ in the pictured numeric output string by #vf (below) and hence displayed by
\ those words that use it.


: set-places  ( n)  TO places ;
\
\ n is the maximum number of digits to be displayed after the decimal point
\ in words that display vulgar numbers in floating point format.
\
\ Caution should be exercised in setting this to large values, as it has the
\ potential for causing the pictured numerical output buffer to overflow.
\
\ The names and behaviour of places and set-places were chosen for consistency
\ with the words PRECISION and SET-PRECISION in the Floating-Point Numbers
\ Extensions word set. This is also true of truncation and set-truncation, and
\ of places and set-places (below).

TRUE VALUE truncation
\
\ returns TRUE if trailing zeroes will be truncated when displaying a vulgar
\ number in floating point format.


: set-truncation ( f)  TO truncation ;
\
\ If f is TRUE trailing zeroes will be truncated when displaying a vulgar
\ number in floating point format.


: #vf ( +v--0 0)  0 SWAP
                  places 1+ 0 DO  DUP >R UM/MOD
                                  SWAP BASE @ UM*  R>
                              LOOP
                  2DROP DROP
                  places ?DUP IF  0 DO  S>D #  2DROP  LOOP
                                  point HOLD
                                THEN
                  S>D #S ;
\
\ append the positive vulgar +v to the pictured numeric output string as a
\ floating point number. That is to say, the integral component, followed by
\ a point, followed by as many digits as specified by places. If places is zero
\ no point is included. Returns 0 0 for consistency with other pictured numeric
\ output conversion words. The conversion is done according to the current
\ value of BASE.
\
\ Note that the conversion routine yields digits after the point in the order
\ natural for displaying them, which is in reverse order for #. The numbers
\ yielded are therefore placed on the stack in the first loop and removed by
\ # in the second loop. In a system which has a limited stack space it may be
\ necessary to rewrite this routine to use an ancilliary stack to perform this
\ reversal, if a large number of digits after the point are required (but see
\ also the note following set-places (above)).


: <#vf#> ( v--addr n)  2DUP voverflow
                       IF  2DROP S" Overflow"
                     ELSE  OVER ABS SWAP  <#  #vf  ROT SIGN  #>
                     THEN ;
\
\ Returns a string representing the vulgar v at the address addr, and of length
\ n. The string is as described in #vf (above), but will have a preceding minus
\ sign if v was negative. If v is the overflow indicator, returns the string
\ "Overflow".

: -zeroes ( addr n1--addr n2)
          2DUP point hasch
          IF  BEGIN  1-  2DUP CHARS + C@
                     [CHAR] 0 <>
              UNTIL
              2DUP CHARS + C@  point =
              IF  2  ELSE  1  THEN  +
        THEN ;
\
\ the string at addr of length n1 is stripped of trailing "0"s, returning a
\ string of length n2. If there is no point in the string no stripping takes
\ place. At least one character will remain after the point.


: v.fj ( v n1 n2)  >R >R  <#vf#>
                   truncation IF  -zeroes  THEN
                   2DUP  point >ch  R> OVER - SPACES
                   OVER 2SWAP TYPE
                   2DUP = IF  2DROP R> 1+
                        ELSE  - 1+ R> + THEN SPACES ;
\
\ display vulgar v according to the rules described in <#vf#> (above) The
\ display string will be padded with leading spaces until there are n1
\ characters before the point and padded with trailing spaces until there are
\ n2 characters after the point. This allows numbers to be aligned about the
\ point for display in tabular form. If there is no point in the string it will
\ be padded with n2+1 trailing spaces for consistency. Trailing zeroes will be
\ truncated according to the rules described in -zeroes (above). If n1 is less
\ than the number of characters to be displayed before the point no spaces will 
\ be displayed, but the string will not be foreshortened. Therefore setting n1
\ to zero will switch off right justification. If n2 is less than the number of
\ characters to the right of the point no spaces will be displayed, but the
\ string will not be truncated. If n2 is zero and places is also zero one
\ trailing space will be displayed in lieu of the point. Therefore n2 should be
\ -1 to switch off left justification, as this will inhibit all trailing
\ spaces.


: v.f ( v)  0 -1 v.fj SPACE ;
\
\ display a vulgar number in floating point format as described in v.fj (above)
\ but without left or right justification, and with one trailing space.


: #v ( +v--0 0)  2DUP v0= IF  [CHAR] 0 HOLD
                        ELSE  DUP 1 = not
                              IF  DUP S>D #S 2DROP  [CHAR] / HOLD
                                  2DUP MOD S>D #S 2DROP
                                  2DUP < not IF  BL HOLD  THEN
                            THEN
                            2DUP < not IF  v>s S>D #S  THEN
                        THEN  2DROP 0. ;
\
\ append positive vulgar +v to the pictured numeric output string according to
\ the following rules.
\   If +v is zero append "0".
\   If +v has an integral component but no fractional component, append that
\         number.
\   If +v has a fractional component but no integral component append "a/b"
\         where a is the numerator, and b the denominator.
\   If +v has both a an integral and a fractional component append "a b/c"
\         where a is the integral component, b the numerator and c the
\         denominator of the fractional component. There is a space between
\         the integral and fractional components.
\
\ The conversion is done according to the current value of BASE.


: <#v#> ( v--addr len) 2DUP voverflow
                         IF  2DROP S" Overflow"
                       ELSE  OVER ABS SWAP  <#  #v  ROT SIGN  #>
                       THEN ;
\
\ Returns a string representing the vulgar v at the address addr, and of length
\ n. The string is as described in #v (above), but will have a preceding minus
\ sign if v was negative. If v is the overflow indicator, returns the string
\ "Overflow".


3 VALUE digits
\
\ return the maximum number of digits to be displayed in the numerator or
\ denominator of a vulgar number, when displayed in vulgar format.


: set-digits ( n)  TO digits ;
\
\ n is the maximum number of digits to be displayed in the numerator or
\ denominator of a vulgar number, when displayed in vulgar format.


: digits> ( --u)  digits  BASE @ SWAP um**  -1 M+ DROP ;
\
\ u is the largest number that can be represented in the current base that
\ does not have more than "digits" number of digits in it.


: v.j ( v n1 n2)  >R >R digits> vsimplify  <#v#>
                  2DUP [CHAR] / hasch
                  IF  2DUP BL >ch 2DUP >R =
                      IF  2R> >R 1+ SPACES
                          TYPE
                          2R> - SPACES
                    ELSE  2R> DUP >R - SPACES
                          TUCK TYPE
                          2R> + 1+ SWAP - SPACES
                    THEN
                ELSE  R> OVER - SPACES
                      TYPE
                      R> 1+ SPACES
                THEN ;
\
\ display vulvar number v in vulgar format, as described in <#v#> (above),
\ padded with up to n1 leading spaces, and up to n2 trailing spaces, such that
\ the number is justified about the space between the integral and fractional
\ component, if present. If there is no integral component an additional
\ leading space is displayed in lieu of the central space. If there is no
\ fractional component an additional trailing space is displayed in lieu of the
\ central space. No more than "digits" number of characters will be displayed
\ in the numerator or denominator. n1 should be -1 to switch off leading spaces
\ entirely, and likewise n2 for trailing spaces.


: v. ( v)  -1 -1 v.j  SPACE ;
\
\ display a vulgar number in vulgar format as described in v.f (above) but
\ without left or right justification, and with one trailing space.

\ End of vulgar Word Set

\ Testing...
\
\ The test suite has an environmental dependancy on 32 bit arithmetic.
\ It is not comprehensive.

MARKER Test-words

: v**n ( v +n--v)  1 s>v  ROT 0 ?DO  2OVER v*  LOOP 2SWAP 2DROP ;
\
\ raise vulgar v to power of non-negative single n.


: factorial ( n--n)  1 SWAP  1+ 1 ?DO  I *  LOOP ;
\
\ n2 = n1!


: e**v ( v1--v2)  0 S>V 13 0 DO  2OVER I v**n
                                 I factorial s>v  v/  v+
                             LOOP
                  2SWAP 2DROP ;
\
\ returns vulgar approximation to e^x, where x is the vulgar number v1.
\
\ Computed as first thirteen terms of power series.

CR
.( e^x for various numbers...) CR
CR
.(                e = )  1 1  e**v v.f  .( should be 2.71828) CR
.( Square root of e = )  1 2  e**v v.f  .( should be 1.64872) CR
.(        e squared = )  2 1  e**v v.f  .( should be 7.38905) CR
CR
.( and now as vulgar fractions...) CR
CR
.(                e = )  1 1  e**v v.  .( should be 2 385/536) CR
.( Square root of e = )  1 2  e**v v.  .( should be 1 428/743) CR
.(        e squared = )  2 1  e**v v.  .( should be 7 263/676) CR
CR

( dispose of) Test-words

\ \\\\\\\\\\\\\\ end of VULGAR.FTH \\\\\\\\\\\\\\\
