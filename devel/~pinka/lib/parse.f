\ 2001

: ParseFileName ( -- a u )
\ разобрать им€ файла  из входного потока. 
\ им€ может быть в кавычках ( "filename").

    BL SKIP
    SOURCE DROP >IN @ + C@   [CHAR] " = IF [CHAR] " DUP SKIP ELSE BL THEN
    PARSE  2DUP + 0 SWAP C!
;

\ 31.Mar.2004 

: IsCharSubs ( c -- f )
  DUP [CHAR] " <> IF
  DUP [CHAR] ' <> IF
  DROP FALSE EXIT THEN 
                  THEN
  DROP TRUE
;
: NextSubstring ( <char1>ccc<char2> -- addr u)
  SkipDelimiters
  GetChar               IF
  DUP IsCharSubs IF
  >IN 1+!        ELSE
  DROP BL        THEN
  PARSE  EXIT           THEN
  0 ( -- 0 0 )
;
: NextSubstring2 ( <char1>ccc<char2> -- addr u)
\ отдает подстроку вместе с обрамл€ющими кавычками
  NextSubstring DUP IF
  OVER 1- C@
  IsCharSubs IF 
  SWAP 1- SWAP 2+ 
  THEN              THEN
;

\ 22.Apr.2004

: UnQuoted ( a u -- a1 u1 )
  DUP IF
  OVER C@ IsCharSubs IF
  SWAP 1+ SWAP 2-    THEN
  THEN
;

CHAR ;  VALUE FieldDelimiter

: NextField ( -- a u )
  SkipDelimiters
  FieldDelimiter PARSE
  -TRAILING  UnQuoted
;
: NextField2 ( -- a u )
\ в кавычках может быть и разделитель полей
  SkipDelimiters
  GetChar DROP IsCharSubs         IF
  NextSubstring
  FieldDelimiter PARSE 2DROP      ELSE
  FieldDelimiter PARSE -TRAILING  THEN
;
: SkipComma ( -- )
  SkipDelimiters
  GetChar IF  DUP [CHAR] , = IF
  >IN 1+!  THEN  THEN  DROP
;

: IsCharLike ( a u c -- flag )
  >R RP@ 1 SEARCH NIP NIP  RDROP
;
: ParseTill ( a u -- a1 u1 )
  CharAddr >IN @  2>R
  BEGIN
    2DUP
    GetChar
  WHILE
    IsCharLike 0=
  WHILE >IN 1+!
  REPEAT ELSE DROP 2DROP THEN 2DROP
  2R> NEGATE >IN @ +
;
\ i.g.:  S" ;,&=" ParseTill

