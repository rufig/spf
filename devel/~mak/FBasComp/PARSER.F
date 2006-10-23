\ ForthBasic parser

REQUIRE CASE lib\ext\case.f

0 VALUE InBuff
CREATE Buff 2048 ALLOT
0 VALUE InPos
0 VALUE InBuffSize

0 VALUE CurLine

: LoadFile ( c-addr u -- )
  R/O OPEN-FILE THROW  >R
  R@ FILE-SIZE 2DROP  2048 MAX
  Buff SWAP R@ READ-FILE DROP TO InBuffSize
  R> CLOSE-FILE DROP
  Buff TO InBuff
  0 TO CurLine
;

-1 CONSTANT tEOF
0 CONSTANT tInvalid
1 CONSTANT tCmd
2 CONSTANT tDel
3 CONSTANT tStr
4 CONSTANT tNum
5 CONSTANT tNewLine

0 VALUE TokenId
0 VALUE TokenNum
32 CONSTANT MaxTokenLen
VARIABLE (Token) MaxTokenLen ALLOT

: Token ( -- c-addr u )  (Token) COUNT   ;
: +TokenCh ( c -- )
  (Token) C@ DUP MaxTokenLen <
  IF  (Token) 1+ + C!  1 (Token) +!  ELSE  2DROP  THEN
;


: kGetChar ( -- c )
  InPos InBuffSize <
  IF  InBuff InPos + C@ InPos 1+ TO InPos  ELSE  -1  THEN
;

: UnGetChar ( -- )   InPos 1- TO InPos  ;

: UpChar ( c -- )
  DUP 96 >  OVER 123 <  AND  IF  32 -  THEN
;

: Alpha? ( c -- flag )
  UpChar  DUP 64 >  OVER 91 <  AND  SWAP 95 = OR
;
: Digit? ( c -- flag )
  DUP 47 >  SWAP 58 <  AND
;
: Delimiter? ( c -- flag )
  DUP 34 = SWAP
  >R S" !#$.,<>=+-()*/:;'" RP@ 1 COMPARE
  RDROP  OR
;
: AlphaDigit? ( c -- flag )  DUP Alpha?  SWAP Digit?  OR  ;
: Blank? ( c -- flag )  33 <  ;
: EOL? ( c -- flag )  13 =  ;
: EOF? ( c -- flag )  -1 = ;

: SkipBlanks ( -- )
  BEGIN
    kGetChar
    DUP EOF?  IF  DROP  EXIT  THEN
    DUP EOL?  IF  UnGetChar  DROP  EXIT  THEN
    Blank? 0=
  UNTIL
  UnGetChar
;

: NextChar ( -- c )
\ skip blanks, get next character
  SkipBlanks  kGetChar
;

\ : NOOP  ;

: CollectToken ( valid?-cfa -- )
  BEGIN
    kGetChar UpChar  2DUP SWAP EXECUTE
   WHILE
    +TokenCh
  REPEAT
  2DROP UnGetChar
;

: GetAlphaToken ( -- )
  ['] AlphaDigit? CollectToken
  kGetChar  36 =  IF  36 +TokenCh  THEN
  UnGetChar
  tCmd TO TokenId
;

: GetNumToken ( -- )
  ['] Digit? CollectToken
  0 0 Token >NUMBER 2DROP DROP  TO TokenNum
  tNum TO TokenId
;

: GetStrToken ( -- )
  0 (Token) C!
  BEGIN
    kGetChar  DUP 31 >  OVER 34 <> AND
   WHILE
    +TokenCh
  REPEAT
  34 =  IF  tStr  ELSE  tInvalid  THEN
  TO TokenId
;

: GetDelToken ( c -- )
  CASE
    60 ( <) OF  kGetChar
                CASE
                  61  OF  61 +TokenCh  ENDOF
                  62  OF  62 +TokenCh  ENDOF
                  UnGetChar
                ENDCASE
            ENDOF
    61 ( =) OF  kGetChar 62 =  IF  62 +TokenCh  ELSE  UnGetChar  THEN  ENDOF
  ENDCASE
  tDel TO TokenId
;

: NextToken ( -- )
  NextChar  UpChar
  0 (Token) C!
  DUP 13 =  OVER -1 =  OR
  IF
    [CHAR] : +TokenCh
    13 =  IF  CurLine 1+ TO CurLine  THEN  tNewLine TO TokenId  EXIT
  THEN
  DUP EOF?  IF  TO TokenId  EXIT  THEN
  DUP +TokenCh
  DUP Alpha?  IF  DROP  ['] GetAlphaToken
  ELSE DUP Digit?  IF  DROP ['] GetNumToken
  ELSE DUP 34 =  IF  DROP ['] GetStrToken
  ELSE DUP Delimiter?  IF  ['] GetDelToken
  ELSE DROP ['] NOOP tInvalid TO TokenId
  THEN THEN THEN THEN
  EXECUTE
;

: Token? ( c-addr u -- flag )
\ check for the specified token
  Token COMPARE 0=
;

: TokenSkip? ( c-addr u -- flag )
\ check for the specified token and skip it, if flag=true
  Token?  DUP  IF  NextToken  THEN
;

: CheckToken ( c-addr u -- )
\ check for the specified token and fail
  Token? 0= IF  -666 THROW  THEN
;
