\ <!--BASE HREF="http://home.earthlink.net/~neilbawd/opg.html"-->

REQUIRE [IF] lib/include/tools.f
REQUIRE CASE lib/ext/case.f

( port to SPF  10.06.2005 ~ygrek )

MODULE: OPG_Formula_Translation
   0 [IF]

   If there are redefinitions of things
   you already have, ignore them for now (it won't hurt) and
   later comment them out.

   If there are redefinitions you can't tolerate, fix them
   and let me know.

   No logic changes since 1997, except:

   2000-05-15  Use `|...|` for normal Forth.  (Changed
   from `{...}` because in the FSL, `{` is used for arrays,
   in SwiftForth, `{...}` is used for commentary, and in MPE,
   `{...}` is used for local variables.)

   [THEN]

   0 [IF] =======================================================
   <A HREF="opg.txt"> <SMALL>TEXT</SMALL></A>
                               Wil Baden  1997-11-04 - 2000-05-15

   This is a implementation of Formula Translation.  It will
   translate Fortran-style assignments `varname=expr` and
   expressions `expr` to Forth.

   GLOSSARY

       ??   Accept-Char-for-Formula   Apply-Operators
       Callable   Code-Operation   FAILURE   Get-Formula
       Is+or-   Is-D-or-E   Is-a-Number   Is-an-Identifier
       LET   Memorable      NEXT-CHAR   Op-Code
       Op-Fetch   Op-Literal   Op-Pop   Op-Push   Op-Stack
       Op-Stack-Size   Op-Store   Op-Top   Operator-Precedence
       Parenthesis-Count   Replace-Last-Char   SUCCESS
       Translate-Expression   Translate-Formula
       Translate-Operand-Operator   Translate-Operation
       Word-Holder

   /GLOSSARY

   There is just one end-user word `LET`.  The formula is
   terminated by `:`.  (`LET` and `:` have been adopted from
   Basic.)

   It can be used compiling or interpreting.  It is not
   state-smart.

   An segment between |bars| will be treated as normal Forth.

   The resulting translations are the natural expansions.


       LET a-b-c-d:
       a F@  b F@  F-  c F@  F-  d F@  F-

       LET a*b-c*d:
       a F@  b F@  F*  c F@  d F@  F*  F-

       LET (a-b)*(c-d):
       a F@  b F@  F-  c F@  d F@  F-  F*

       LET x = -1:
       -1.E x F!

       LET x = (-b - SQRT (b * |FDUP| - 4*a*c)) / (2*a):
       b F@ FNEGATE b F@  FDUP F*
       4.E  a F@ F*  c F@  F*  F-    FSQRT  F-
       2.E a F@  F*  F/  x F!

   If a function doesn't begin with `F` it will first look for
   it with `F` prefixed.

   All numbers are floating point.  Variables begin with a
   letter, continue with letters and digits, and are not
   followed by a left parenthesis mark.  Function-calls have the
   same form but are followed by a left parenthesis mark.

   The operators are:

       +    -    *    /    ** or ^

   Assignments are made with `=`.  Multiple arguments of a
   function are separated by commas.

   Spaces are deleted before translation, except between `|`
   and `|`.

   Variable `DEBUG` on will show code being translated.

   This program uses Julian V. Noble's concept but not his
   <A HREF="http://Landau1.phys.virginia.edu/classes/551/ftran111.f">implementat
   Thanks to Marcel Hendrix for his ideas for extending the system.

           Examples of Use

   Operator Precedence goes through the expression putting out
   operands as it reaches them and saving operators.  Operators
   are put out when an operator of less or equal precedence is
   reached.  Thus higher precedence is performed before lower
   precedence.

   See tests at the end of the file for examples.

   ------------------------------------------------------- [THEN]

   \  Formula Translation using Operator Precedence Grammar

   VARIABLE DEBUG  0 DEBUG !  ( This is a common name. )

   ( `DEBUG` occurs in one place below.  Change it here and there. )

   0 [IF] =======================================================

           Elementary Tools

   FAILURE             ( -- )
       False exit.
   SUCCESS             ( -- )
       True exit.
   ??                  ( x "aword" -- )
       _x_ `IF` _aword_ `THEN`

   ------------------------------------------------------- [THEN]

 \ ~ygrek
 \ Я так понял что   u /STRING  используется для прохода по строке.
 \ сдвигая текущую позицию на u символов.
 \ Никаких проверок не делается.

    : /STRING ( str len n -- str+n len-n )
    \ SWAP OVER - SWAP + SWAP
     >R
       SWAP R@ + 
       SWAP R> -
    ;

  \ из toolbelt.f
    : SCAN           ( str len char -- str+i len-i )
       >R  BEGIN  DUP WHILE  OVER C@ R@ -
           WHILE  1 /STRING  REPEAT THEN
       R> DROP
    ;

   \  Common usage, especially with me.  Comment out what you already have.

       : /SPLIT  ( a m b n -- b n a m-n )  DUP >R  2SWAP  R> - ;

       : ANDIF  S" DUP IF DROP " EVALUATE ; IMMEDIATE

       : ORIF   S" DUP 0= IF DROP " EVALUATE ; IMMEDIATE

       : BOUNDS  ( str len -- str+len str )  OVER + SWAP ;

       : IS-ALPHA  ( char -- flag )  32 OR  [CHAR] a -  26 U< ;

       : IS-DIGIT  ( char -- flag )  [CHAR] 0 -  10 U< ;

       : IS-ALNUM  ( char -- flag )
           DUP IS-ALPHA  ORIF  DUP IS-DIGIT  THEN  NIP ;

       : NOT  ( x -- flag )  S" 0= " EVALUATE ; IMMEDIATE

       : OFF  0 SWAP ! ;

       : ON   TRUE SWAP ! ;

       : PLACE               ( str len addr -- )
           2DUP 2>R  CHAR+  SWAP CHARS MOVE  2R> C! ;

   : FAILURE S" FALSE EXIT " EVALUATE ; IMMEDIATE
   : SUCCESS S" TRUE EXIT " EVALUATE ; IMMEDIATE

   : ??                ( x "word" -- )
       POSTPONE IF
       BL WORD COUNT EVALUATE
       POSTPONE THEN
       ; IMMEDIATE

   0 [IF] =======================================================

           Character Handling

   NEXT-CHAR      ( -- char or 0 for EOL or negative for EOF )
       Get character from input stream.  Used in `Get-Formula`.
   Replace-Last-Char   ( str len char -- str len )
       Replace last character in a string.  Used in `Op-Literal`
       and `Accept-Char-for-Formula`.
   Is+or-         ( char -- flag )
       Test _char_ for `+` or `-`.  Used in `Is-a-Number`. `[+-]`
   Is-D-or-E      ( char -- flag )
       Test _char_ for `D`, `E`, `d`, or `e`.  Used in
       `Is-a-Number` and `Op-Literal`. `[DEde]`

   ------------------------------------------------------- [THEN]

   : NEXT-CHAR      ( -- char or 0 for EOL or negative for EOF )
       SOURCE  >IN @  >                   ( addr flag)
       IF    >IN @ CHARS + C@  1 >IN +!
       ELSE  DROP REFILL 0=               ( )
       THEN ;

   : Replace-Last-Char ( str len char -- str len )
       >R  2DUP CHARS +  R> SWAP C! ;

   : Is+or- ( char -- flag ) DUP [CHAR] + =  SWAP [CHAR] - =  OR ;
   : Is-D-or-E  ( char -- flag )  32 OR  [CHAR] d -  2 U< ;

   0 [IF] =======================================================

   Is-a-Number  ( str len -- str' len' flag )
       This awful-looking code walks through syntax for a number.
       Used in `Translate-Operand-Operator`.

   Regular Expression

       [+-]?[0-9]*([.][0-9]*)?([DEde](([-+][0-9])?[0-9]*)?

   ------------------------------------------------------- [THEN]

   : Is-a-Number           ( str len -- str' len' flag )
       DUP 0= ?? FAILURE

       \  [-+]                  Any sign.
       OVER C@ Is+or- IF
            1 /STRING
            DUP 0= ?? FAILURE
       THEN

       \  [.]?[0-9]   Begins with digit or decimal point and digit.
       OVER C@ IS-DIGIT ORIF OVER C@ [CHAR] . =  THEN 0= ?? FAILURE
       OVER C@ [CHAR] . = IF
            DUP 1 = ?? FAILURE
            OVER CHAR+ C@ IS-DIGIT NOT ?? FAILURE
       THEN

       \  [0-9]*                Any digits.
       BEGIN  OVER C@ IS-DIGIT
       WHILE  1 /STRING  DUP 0= ?? SUCCESS
       REPEAT

       \  [.][0-9]*             Decimal point and any digits
       OVER C@ [CHAR] . = IF
            BEGIN
                1 /STRING  DUP 0= ?? SUCCESS
                OVER C@ IS-DIGIT NOT
            UNTIL
       THEN

       \  [DEde](([-+][0-9])?[0-9]*)?  Exponent, sign and digits.
       OVER C@ Is-D-or-E IF
            1 /STRING  DUP 0= ?? SUCCESS
            OVER C@ Is+or- IF
                 1 /STRING
                 DUP 0= ?? FAILURE
                 OVER C@ IS-DIGIT NOT ?? FAILURE
            THEN
            \ [0-9]*
            BEGIN  DUP 0= ?? SUCCESS
                   OVER C@ IS-DIGIT
            WHILE  1 /STRING  REPEAT
       THEN

       SUCCESS ;

   0 [IF] =======================================================
   Is-an-Identifier          ( str len -- str' len' flag )
       An identifier is a letter followed by letters and digits.
       Used in `Translate-Operand-Operator` and
       `Translate-Formula`.
   ------------------------------------------------------- [THEN]

   : Is-an-Identifier                ( str len -- str' len' flag )
       DUP 0= ?? FAILURE

       OVER C@ IS-ALPHA NOT ?? FAILURE

       BEGIN  1 /STRING
              DUP 0= ?? SUCCESS
              OVER C@ IS-ALNUM NOT
       UNTIL

       SUCCESS ;

   0 [IF] =======================================================

           Op-Stack Operations

   Op-Stack-Size   ( -- n )
       Maximum size of `Op-Stack`.  Used in `Op-Push`.
   Op-Stack        ( -- addr)
       Stack to hold operators.

   Op-Push         ( op -- )
       Push _op_ on top of `Op-Stack`.
   Op-Top          ( -- op )
       The operator on top of `Op-Stack`.
   Op-Pop          ( -- )
       Remove top of `Op-Stack`.

   ------------------------------------------------------- [THEN]

   30 CONSTANT Op-Stack-Size
   CREATE Op-Stack   Op-Stack-Size 1+ CELLS ALLOT

   : Op-Push                      ( op -- )
       Op-Stack @ Op-Stack-Size CELLS < NOT
           ABORT" Too Many Elements -- Increase Op-Stack-Size "
       1 CELLS Op-Stack +!   Op-Stack DUP @ + !
       ;

   : Op-Top  ( -- op ) Op-Stack DUP @ + @ ;
   : Op-Pop  ( -- )    -1 CELLS Op-Stack +! ;

   0 [IF] =======================================================

           Application Tools

   Parenthesis-Count     ( -- addr )
       Tally for parentheses.
   Word-Holder           ( -- addr )
       Buffer for name when modifying it.
   Memorable             ( str len -- )
       Look up variable.  Used in `Op-Store` and `Op-Fetch`.
   Callable              ( str len -- str' len' )
       Look up function.  Used in `Code-Operation`.
   Translate-Operation   ( addr len -- )
       Translate operation. [Can't think of better explanation.]
   Op-Store              ( str len -- )( F: r -- )
       Make assignment.  Used in `Translate-Formula`.
   Op-Fetch              ( str len -- )( F: -- r )
       Pick up variable.  Used in `Translate-Operand-Operator`.
   Op-Literal            ( str len -- )( F: -- r )
       Take care of literal.  Used in `Translate-Operand-Operator`.

   ------------------------------------------------------- [THEN]

   VARIABLE Parenthesis-Count

       1 CONSTANT Left-Paren
       2 CONSTANT Right-Paren
       8 CONSTANT Negation
       9 CONSTANT Function-Call
      10 CONSTANT Op-Dummy

   CREATE Word-Holder  32 CHARS ALLOT

   : Memorable                     ( str len -- )
       31 MIN  Word-Holder PLACE         ( )
       Word-Holder FIND 0= IF
           COUNT TYPE SPACE  TRUE ABORT" Not Found "
       THEN
       DROP ;

   : Callable                      ( str len -- str' len' )
       OVER C@ [CHAR] F = NOT IF
              2DUP  30 MIN  DUP 1+  Word-Holder C!
              Word-Holder CHAR+  PLACE    ( . .)
              [CHAR] F  Word-Holder CHAR+  C!
              Word-Holder FIND NIP IF
                  2DROP  Word-Holder COUNT
              THEN
    THEN ;

: Translate-Operation            ( addr len -- )
    DEBUG @ IF  2DUP TYPE SPACE  THEN
    EVALUATE ;

: Op-Store                      ( str len -- )( F: r -- )
    2DUP Memorable Translate-Operation
    S" F! " Translate-Operation ;

: Op-Fetch                      ( str len -- )( F: -- r )
    2DUP Memorable Translate-Operation
    S" F@ " Translate-Operation ;

    VARIABLE Literal-State

: Op-Literal                    ( str len -- )( F: -- r )
    Literal-State OFF
    Word-Holder 0 2SWAP CHARS BOUNDS ?DO
        I C@ Is-D-or-E IF  Literal-State ON  THEN
        I C@  Replace-Last-Char  1+
    1 CHARS +LOOP
    Literal-State @ 0= IF
        [CHAR] E  Replace-Last-Char  1+
    THEN
    Translate-Operation ;

: Op-Code                       ( str len -- str len code )
    DUP 0= IF  0
    ELSE  CASE OVER C@
          [CHAR] )  OF  2  ENDOF
          [CHAR] +  OF  3  ENDOF
          [CHAR] -  OF  4  ENDOF
          [CHAR] *  OF  5  ENDOF
          [CHAR] /  OF  6  ENDOF
          [CHAR] ^  OF  7  ENDOF
          [CHAR] ,  OF  0  ENDOF
                        DUP . EMIT
                        TRUE ABORT" Illegal Operator "
          0 ENDCASE
    THEN ;

: Operator-Precedence           ( code -- precedence )
    CASE -1  OF -1  ENDOF   \  Bottom Mark
          0  OF  2  ENDOF   \  Termination or Comma
          1  OF  1  ENDOF   \  Left Paren
          2  OF  1  ENDOF   \  Right Paren
          3  OF  3  ENDOF   \  Plus
          4  OF  3  ENDOF   \  Minus
          5  OF  4  ENDOF   \  Times
          6  OF  4  ENDOF   \  Divide
          7  OF  5  ENDOF   \  Power
          8  OF  3  ENDOF   \  Negation
          9  OF  1  ENDOF   \  Function-Call
         10  OF  0  ENDOF   \  Dummy
         DROP    TRUE ABORT" Invalid Operation "
    0 ENDCASE ;

: Code-Operation               ( code -- )
    CASE 1  OF  0  -1 Parenthesis-Count +!  ENDOF
         2  OF  0        ENDOF
         3  OF  S" F+ "  ENDOF
         4  OF  S" F- "  ENDOF
         5  OF  S" F* "  ENDOF
         6  OF  S" F/ "  ENDOF
         7  OF  S" F** " ENDOF
         8  OF  S" FNEGATE "   ENDOF
         9  OF  Op-Pop Op-Top  Op-Pop Op-Top
                -1 Parenthesis-Count +!
                Callable
                ENDOF
         DROP   TRUE ABORT" Invalid Operator "
    0 ENDCASE                    ( addr k)
    ?DUP ?? Translate-Operation ;

: Apply-Operators              ( str len -- str' len' )
    BEGIN  Op-Code                 ( str len code)
           DUP 2SWAP 2>R           ( code code)( R: str len)
           >R Operator-Precedence >R  ( )( R: . . . precedence)
               BEGIN  Op-Top Operator-Precedence R@ < NOT
               WHILE  Op-Top Code-Operation  Op-Pop
               REPEAT
           R> DROP R> 2R>          ( code str len)( R: )
           DUP IF  1 /STRING  THEN
           ROT                     ( str len code)
           DUP Right-Paren =
    WHILE  DROP  Op-Pop  REPEAT
    ?DUP ?? Op-Push ;

: Translate-Operand-Operator   ( str len -- str' len' )
    \  Is it a variable or function-call?
    2DUP Is-an-Identifier IF     ( a n a+k n-k)
         DUP ANDIF OVER C@ [CHAR] ( = THEN IF
             \  It's a function-call.
             Op-Dummy Op-Push
             /SPLIT           ( a+k n-k a k)
             Op-Push Op-Push Function-Call Op-Push ( a+k n-k)
             1 Parenthesis-Count +!
             1 /STRING
         ELSE
             \  It's a variable.
             2>R  R@ - Op-Fetch  2R>
             Apply-Operators
         THEN
         EXIT
    THEN 2DROP                           ( str len)

    \  Is it a number?
    2DUP Is-a-Number IF      ( a n a+k n-k)
         2>R  R@ - Op-Literal  2R>
         Apply-Operators
         EXIT
    THEN 2DROP                           ( str len)

    \  Is it a left paren?
    OVER C@ [CHAR] ( = IF  \ )
         Op-Dummy Op-Push  Left-Paren Op-Push
         1 Parenthesis-Count +!
         1 /STRING
         EXIT
    THEN

    \  Is it a lonely minus sign?
    OVER C@ [CHAR] - = IF
         Negation Op-Push
         1 /STRING
         EXIT
    THEN

    \  Is it a lonely plus sign?
    OVER C@ [CHAR] + =  ANDIF DUP 1 > THEN  IF
         1 /STRING
         EXIT
    THEN

    \  Is it normal Forth?
    OVER C@ [CHAR] | = IF
        1 /STRING
        2DUP [CHAR] | SCAN /SPLIT
        2SWAP 2>R  Translate-Operation  2R>
        DUP IF  1 /STRING  THEN
        Apply-Operators
        EXIT
    THEN

    \  Oops.
    CR  TYPE  CR
    TRUE ABORT" Illegal Operand " ;

: Translate-Expression           ( str len -- )
    BEGIN  DUP WHILE
           Translate-Operand-Operator
    REPEAT                       2DROP
    Parenthesis-Count @ ABORT" Unmatched Parens " ;

: Translate-Formula              ( str len -- )
    0 Op-Stack !  0 Parenthesis-Count !
    2DUP Is-an-Identifier          ( str len str' len' flag)
    ANDIF DUP
    ANDIF OVER C@ [CHAR] = =
    THEN THEN IF                ( str len str' len')
          /SPLIT Op-Push Op-Push -1 Op-Push  ( str' len')
          1 /STRING
          Translate-Expression  ( )
          Op-Top -1 = NOT ABORT" Invalid Expression "
          Op-Pop Op-Top  Op-Pop Op-Top  Op-Store
    ELSE  2DROP                 ( str len)
          -1 Op-Push
          Translate-Expression  ( )
    THEN

    Op-Stack @ 1 CELLS = NOT ABORT" Invalid Formula " ;


    255 CONSTANT Formula-Length
    CREATE Formula   Formula-Length 1+ CHARS ALLOT

    VARIABLE Keep-Spaces

: Accept-Char-for-Formula    ( str length char -- str length' )
    OVER Formula-Length > ABORT" Formula Length Overflow "
    CASE
    [CHAR] | OF  [CHAR] | Replace-Last-Char 1+
                 Keep-Spaces DUP @ NOT SWAP !
             ENDOF
    [CHAR] * OF  DUP
                 ANDIF 2DUP 1- CHARS + C@ [CHAR] * = THEN
                     IF   1-  [CHAR] ^  ELSE  [CHAR] *  THEN
                 Replace-Last-Char  1+
             ENDOF
    Replace-Last-Char  1+
    0 ENDCASE ;

: Get-Formula    ( "multi-lines<colon>" -- addr len )
    Keep-Spaces OFF 
    Formula 0                    ( addr len)
    BEGIN  NEXT-CHAR             ( addr len char)
           DUP 0< ABORT" End of File "
           DUP [CHAR] : = NOT
    WHILE  DUP BL >
           ORIF  DUP BL = Keep-Spaces @ AND  THEN
           IF    Accept-Char-for-Formula
           ELSE  DROP
           THEN                  ( addr len)
    REPEAT DROP ;

EXPORT

: LET     ( "formula:" -- )( F: -- | values )
    Get-Formula Translate-Formula ; IMMEDIATE

;MODULE

\ EOF

\ ----------------------------------------------------------
\                       TESTS 
\ ----------------------------------------------------------
 REQUIRE F.   lib/include/float2.f
 \ Это обязательно потому-что FVARIABLE создаёт 8-байтный флоат
 \ а F! F@ работают с 10-байтным
 : F! DF! ;
 : F@ DF@ ;

 FDOUBLE

 FVARIABLE a  FVARIABLE b  FVARIABLE c
 FVARIABLE x  FVARIABLE w


 : TEST0   CR  LET b+c:  FE.
           CR  LET b-c:  FE.
           CR  LET 10000000*(b-c)/(b+c):  FE.
           ;

 LET b = 3:
 LET c = 4:
 .( TEST0) TEST0

 : TEST1   LET a = b*c-3.17e-5/TANH(w)+ABS(x):  CR  LET a: F. ;

 CR .( TEST1)
 LET w = 1.e-3:  LET x = -2.5:   TEST1
 
 FVARIABLE HALFPI
 LET HALFPI = 2*ATAN(1):
 .( PI=) LET HALFPI + |FDUP|: F.

 FVARIABLE disc                       ( Used for discriminant )

 : QUADRATICROOT                          ( F: a b c -- r1 r2 )
     c F!  b F!  a F!                    \ Pickup coefficients.
     LET disc = SQRT(b*b-4*a*c):            \ Set discriminant.
     LET (-b+disc)/(2*a), (-b-disc)/(2*a):
                                       \ Put values on f-stack.
     ;

 CR .( Solve x*x-3*x+2 )  LET QUADRATICROOT (1,-3, 2) : F. SPACE F.
 CR .( Find goldenratio ) LET MAX(QUADRATICROOT (1,-1,-1)) : F.

 CR .( You can also write ) 1.E -1.E -1.E QUADRATICROOT FMAX F.

 : FACTORIAL                       ( n -- )( F: -- r )
     LET w = 1:  LET x = 1:
     0 ?DO  LET w = w * x:  LET x = x + 1:  LOOP
     LET w: ;

 CR .( Another way )
 : FACTORIAL                       ( n -- )( F: -- r )
    LET w = 1:  0 ?DO  LET w = w * | I 1+ S>D D>F |:  LOOP
    LET w: ;
 6 FACTORIAL F.  .(  or ) LET FACTORIAL(|6|): F.

 CR CR .( Timing) CR

 REQUIRE Mark ~micro/lib/timer.f

 4.9e a F!
 5e b F!
 37.2e c F!

: time1 
 Timer::Mark
 10000000 0 DO
  LET SQRT(ABS(COS(b+c)*SIN(b+a)+(c+a)*(c+b)))+LN(a+b)*EXP(a+c): FDROP
 LOOP 
 Timer::ElapsedMs
 ." Elapsed : " . CR
;

: time2 
 Timer::Mark

 10000000 0 DO
  a F@ b F@ F+ FLN
  a F@ c F@ F+ FEXP F* 
  b F@ c F@ F+ FCOS
  b F@ a F@ F+ FSIN F* F+
  FABS
  FSQRT
  c F@ a F@ F+ 
  c F@ b F@ F+ F* F+ 
  FDROP 
 LOOP 
 Timer::ElapsedMs
 ." Elapsed : " . CR
;

 time1
 time2

BYE