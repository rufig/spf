\  Tool Belt
REQUIRE [IF] lib/include/tools.f

0 [IF]

T 2000-08-14
Fixed several wrong stack effects in string handling.
The code was correct. (Thanks to Marcel Hendrix.)
The stack effect errors were in `/SPLIT`, `BL-SCAN`, and
`BL-SKIP`.

[THEN]

0 [IF] =======================================================
                                          Wil Baden 2000-08-14

These are common tools used in several source files.  They are
all given here so you can avoid duplicate definitions. Comment
out those that you already have or are enhancing.  Many of
them should be CODE definitions.

`0 [IF]` is the convention used for commentary, so comment
out with `\` or `FALSE [IF]` or `[VOID] [IF]`.

`[VOID]` is an immediate constant of FALSE. It is defined
first so it can be used to comment out sections of code.

Definitions in Standard Forth by Wil Baden. Any similarity
with anyone else's code is coincidental, historical, or
inevitable.

GLOSSARY

    !+   #BACKSPACE-CHAR   #CHARS/LINE   #EOL-CHAR
    #TAB-CHAR   'th   (.)   ++   ,"   -CELL   /SPLIT   2NIP
    3DROP   3DUP   @+   ANDIF   APPEND   APPEND-CHAR   STR-BACK
    BL-SCAN   BL-SKIP   BOUNDS   C+!   CELL-   EMITS
    EMPTY   ENDS?   FILE-CHECK   FOURTH   H#   HIWORD
    IS-ALNUM   IS-ALPHA   IS-DIGIT   LEXEME
    LOWORD   MAX-N   MEMORY-CHECK   NEXT-WORD   NOT   OFF
    ON   ORIF   OUT   PLACE   R'@   REWIND-FILE   STR-SCAN
    SIGN-BIT   STR-SKIP   SPLIT-NEXT-LINE   STARTS?   STRING,
    TEMP   THIRD   TRIM   VIEW-NEXT-LINE   VOCABULARY
    [DEFINED]   [UNDEFINED]   [VOID]   \\

/GLOSSARY

------------------------------------------------------- [THEN]
0 [IF] =======================================================

[VOID]          ( -- flag )
    Immediate FALSE. Used to comment out sections of code.
    IMMEDIATE so it can be inside definitions.

------------------------------------------------------- [THEN]

FALSE CONSTANT [VOID] IMMEDIATE

0 [IF] =======================================================

<A HREF="http://www.forth.com/Content/Handbook/Handbook.html">

        Forth Programmer's Handbook, Conklin and Rather
</A>

C+!                 ( n addr -- )
    Add the low-order byte of _n_ to the byte at _addr_,
    removing both from the stack.

------------------------------------------------------- [THEN]

: C+! DUP C@ ROT + SWAP C! ;

\  Definitions in "FPH Common Usage".

0 [IF] =======================================================

        Common Use

BOUNDS                ( str len -- str+len str )
    Convert _str len_ to range for DO-loop.
OFF                   ( addr  -- )
    Store 0 at _addr_. See `ON`.
ON                    ( addr -- )
    Store -1 at _addr_. See `OFF`.

------------------------------------------------------- [THEN]

: BOUNDS  ( str len -- str+len str )  OVER + SWAP ;

: OFF  ( addr -- )  0 SWAP ! ;

: ON  ( addr -- )  -1 SWAP ! ;

0 [IF] =======================================================

APPEND                ( str len add2 -- )
    Append string _str len_ to the counted string at _addr_.
    AKA `+PLACE`.
APPEND-CHAR           ( char addr -- )
    Append _char_ to the counted string at _addr_.
PLACE                 ( str len addr -- )
    Place the string _str len_ at _addr_, formatting it as a
    counted string.
STRING,               ( str len -- )
    Store a string in data space as a counted string.
,"                    ( "<ccc><quote>" -- )
    Store a quote-delimited string in data space as a counted
    string.

------------------------------------------------------- [THEN]

: APPEND              ( addr1 u addr2 -- )
    2DUP 2>R  COUNT +  SWAP MOVE ( ) 2R> C+! ;

: APPEND-CHAR         ( char addr -- )
    DUP >R  COUNT  DUP 1+ R> C!  +  C! ;

: PLACE               ( str len addr -- )
    2DUP 2>R  1+  SWAP  MOVE  2R> C! ;

: STRING,             ( str len -- )
    HERE  OVER 1+  ALLOT  PLACE ;

: ," [CHAR] " PARSE  STRING, ; IMMEDIATE

: /STRING ( str len n -- str+n len-n ) >R SWAP R@ + SWAP R> - ;
 ( SWAP OVER - -ROT + SWAP )
 ( DUP NEGATE D+ ) \ только для n>0

0 [IF] =======================================================

        Stack Handling

THIRD               ( x y z -- x y z x )
    Copy third element on the stack onto top of stack.
FOURTH              ( w x y z -- w x y z w )
    Copy fourth element on the stack onto top of stack.
3DUP                ( x y z -- x y z x y z )
    Copy top three elements on the stack onto top of stack.
3DROP               ( x y z -- )
    Drop the top three elements from the stack.
2NIP                ( w x y z -- y z )
    Drop the third and fourth elements from the stack.
R'@                 ( -- x )( R: x y -- x y )
    The second element on the return stack.

These should all be CODE definitions.

------------------------------------------------------- [THEN

: THIRD  ( x y z -- x y z x )  2 PICK ;

: FOURTH ( w x y z -- w x y z w )  3 PICK ;

: 3DUP  ( x y z -- x y z x y z )  THIRD THIRD THIRD ;

: 3DROP ( x y z -- )  DROP 2DROP ;

: 2NIP  ( w x y z -- y z )  2SWAP 2DROP ;

: R'@   S" 2R@ DROP " EVALUATE ; IMMEDIATE

[THEN]

0 [IF] =======================================================
        Short-Circuit Conditional

ANDIF               ( p ... -- flag )
    Given `p ANDIF q THEN`,  _q_ will not be performed if
    _p_ is false.
ORIF                ( p ... -- flag )
    Given `p ORIF q THEN`,  _q_ will not be performed if
    _p_ is true.

------------------------------------------------------- [THEN]

: ANDIF  S" DUP IF DROP " EVALUATE ; IMMEDIATE

: ORIF   S" DUP 0= IF DROP " EVALUATE ; IMMEDIATE

0 [IF] =======================================================

        String Handling

STR-SCAN            ( str len char -- str+i len-i )
    Look for a particular character in the specified string.
STR-SKIP            ( str len char -- str+i len-i )
    Advance past leading characters in the specified string.
STR-BACK            ( str len char -- str len-i )
    Look for a particular character in the string from the
    back toward the front.
/SPLIT          ( a m a+i m-i -- a+i m-i a i )
    Split a character string _a m_ at place given by _a+i m-i_.
    Called "cut-split" because "slash-split" is a tongue
    twister.

------------------------------------------------------- [THEN]

: STR-SCAN           ( str len char -- str+i len-i )
    >R  BEGIN  DUP WHILE  OVER C@ R@ -
        WHILE  1 /STRING  REPEAT THEN
    R> DROP ;

: STR-SKIP           ( str len char -- str+i len-i )
   >R  BEGIN  DUP WHILE  OVER C@ R@ =
        WHILE  1 /STRING  REPEAT THEN
    R> DROP ;

: STR-BACK           ( str len char -- str len-i )
    >R  BEGIN  DUP WHILE
        1-  2DUP + C@  R@ =
    UNTIL 1+ THEN
    R> DROP ;

: /SPLIT  ( a m b n -- b n a m-n )  DUP >R  2SWAP  R> - ;

0 [IF] =======================================================

TRIM            ( str len -- str len-i )
    Trim white space from end of string.
BL-SCAN         ( str len -- str+i len-i )
    Look for white space from start of string
BL-SKIP         ( str len -- str+i len-i )
    Skip over white space at start of string.

------------------------------------------------------- [THEN]

: TRIM           ( str len -- str len-i )
    BEGIN  DUP WHILE
        1-  2DUP + C@ IsDelimiter 0=
    UNTIL 1+ THEN ;

: BL-SCAN        ( str len -- str+i len-i )
    BEGIN  DUP WHILE  OVER C@ IsDelimiter 0=
    WHILE  1 /STRING  REPEAT THEN ;

: BL-SKIP        ( str len -- str+i len-i )
    BEGIN  DUP WHILE  OVER C@ IsDelimiter
    WHILE  1 /STRING  REPEAT THEN ;

0 [IF] =======================================================

STARTS?         ( str len pattern len2 -- str len flag )
    Check start of string.
ENDS?           ( str len pattern len2 -- str len flag )
    Check end of string.

------------------------------------------------------- [THEN]

: STARTS?  ( str len pattern len2 -- str len flag )
    DUP >R  2OVER  R> MIN  COMPARE 0= ;

: ENDS?  ( str len pattern len2 -- str len flag )
    DUP >R  2OVER  DUP R> - /STRING  COMPARE 0= ;

0 [IF] =======================================================

        Character Tests

IS-DIGIT        ( char -- flag )
    Test _char_ for digit [0-9].
IS-ALPHA        ( char -- flag )
    Test _char_ for alphabetic [A-Za-z].
IS-ALNUM        ( char -- flag )
    Test _char_ for alphanumeric [A-Za-z0-9].

------------------------------------------------------- [THEN]

: IS-DIGIT  ( char -- flag )  [CHAR] 0 -  10 U< ;
: IS-ALPHA  ( char -- flag )  32 OR  [CHAR] a -  26 U< ;
: IS-ALNUM  ( char -- flag )
    DUP IS-ALPHA  ORIF  DUP IS-DIGIT  THEN  NIP ;

0 [IF] =======================================================

        Common Constants

#BACKSPACE-CHAR     ( -- char )
    Backspace character.
#CHARS/LINE         ( -- n )
    Preferred width of line in source files.  Suit yourself.
#EOL-CHAR           ( -- char )
    End-of-line character.  13 for Mac and DOS, 10 for Unix.
#TAB-CHAR           ( -- char )
    Tab character.
MAX-N               ( -- n )
    Largest usable signed integer.
SIGN-BIT            ( -- n )
    1-bit mask for the sign bit.
CELL                ( -- n )
    Address units (i.e. bytes) in a cell.
-CELL               ( -- n )
    Negative of address units in a cell.

------------------------------------------------------- [THEN]

 8 CONSTANT #BACKSPACE-CHAR
62 VALUE    #CHARS/LINE
13 CONSTANT #EOL-CHAR
 9 CONSTANT #TAB-CHAR

TRUE 1 RSHIFT        CONSTANT MAX-N
TRUE 1 RSHIFT INVERT CONSTANT SIGN-BIT

-1 CELLS CONSTANT -CELL

0 [IF] =======================================================
        Filter Handling

SPLIT-NEXT-LINE     ( src . -- src' . str len )
    Split the next line from the string.
VIEW-NEXT-LINE    ( src . str len -- src . str len str2 len2 )
    Copy next line above current line.
OUT                 ( -- addr )
    Promiscuous variable.
TEMP                ( -- addr )
    Promiscuous variable.

------------------------------------------------------- [THEN]

: SPLIT-NEXT-LINE   ( src . -- src' . str len )
    2DUP #EOL-CHAR STR-SCAN 
    DUP >R  1 /STRING  2SWAP R> - ;

: VIEW-NEXT-LINE  ( src . str len -- src . str len str2 len2 )
    2OVER 2DUP #EOL-CHAR STR-SCAN NIP - ;

VARIABLE OUT
VARIABLE TEMP

0 [IF] =======================================================

        Input Stream

NEXT-WORD             ( -- str len )
    Get the next word across line breaks as a character
    string. _len_ will be 0 at end of file.
LEXEME                ( "name" -- str len )
    Get the next word on the line as a character string.
    If it's a single character, use it as the delimiter to
    get a phrase.
H#                    ( "hexnumber" -- n )
    Get the next word in the input stream as a hex
    single-number literal.  (Adopted from Open Firmware.)

------------------------------------------------------- [THEN]

: NEXT-WORD           ( -- str len )
    BEGIN   BL WORD COUNT      ( str len)
        DUP IF EXIT THEN
        REFILL
    WHILE  2DROP ( ) REPEAT ;  ( str len)

: LEXEME NextWord ;

: H#  ( "hexnumber" -- n )  \  Simplified for easy porting.
    0 0 BL WORD COUNT                   ( str len)
    BASE @ >R  HEX  >NUMBER  R> BASE !
        ABORT" Not Hex " 2DROP          ( n)
    STATE @ IF  POSTPONE LITERAL  THEN
    ; IMMEDIATE

0 [IF] =======================================================


 Generally Useful 

++ ( addr -- ) 

Increment the value at addr. 

@+ ( addr -- addr' x ) 

Fetch the value x from addr, and increment the address by one cell. 

!+ ( addr x -- addr' ) 

Store the value x into addr, and increment the address by one cell. 
------------------------------------------------------- [THEN]

: ++  ( addr -- )  1 SWAP +! ;

: @+  ( addr -- addr' x )  DUP CELL+ SWAP  @ ;

: !+  ( addr x -- addr' )  OVER !  CELL+ ;

0 [IF] =======================================================

Miscellaneous 

'th ( n "addr" -- &addr[n] ) 

Address n CELLS addr +. 

(.) ( n -- addr u ) 

Convert n to characters, without punctuation, as for . (dot), returning the 
address and length of the resulting string. 

EMITS ( n char -- ) 

Emit char n times. 

HIWORD ( xxyy -- xx ) 

The high half of the value. 

LOWORD ( xxyy -- yy ) 

The low half of the value. 

REWIND-FILE ( file-id -- ior ) 

Rewind the file. 
------------------------------------------------------- [THEN]

: 'th     ( n "addr" -- &addr[n] )
    S" 2 LSHIFT " EVALUATE
    BL WORD COUNT EVALUATE
    S" + " EVALUATE
    ; IMMEDIATE

: (.)  ( n -- addr u )  DUP ABS 0 <# #S ROT SIGN #> ;

: EMITS             ( n char -- )
    SWAP 0 ?DO  DUP EMIT  LOOP DROP ;

: HIWORD  ( xxyy -- xx )  16 RSHIFT ;
: LOWORD  ( xxyy -- yy )  65535 AND ;

: REWIND-FILE       ( file-id -- ior )
    0 0 ROT REPOSITION-FILE ;


