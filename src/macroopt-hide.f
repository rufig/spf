\ Hide macroopt words into MACROOPT-WL wordlist, and export requred words.
\ 2014-04 ruv

[DEFINED] HIDE-MACROOPT-WORDS [IF]
  INIT-MACROOPT-HIDING
  \EOF
[THEN]

USE-OPTIMIZER 0= [IF]
  \ Если сюда попали, то тут уже идет трансляция в целевую систему
  .( Warning: Can't hide macroopt words since USE-OPTIMIZER is 0 ) CR
[ELSE]



BASE @ DECIMAL  \ since macroopt.f use HEX (!!!)


\ Нижеследующий код транслируется один раз, и только в инструментальную систему!


[UNDEFINED] \EOF [IF]
: \EOF  BEGIN REFILL 0= UNTIL POSTPONE \ ;
[THEN]


VOCABULARY MACROOPT-HIDING-SUPPORT
GET-CURRENT ALSO MACROOPT-HIDING-SUPPORT DEFINITIONS

\ **********
\ common API

: S", ( addr u -- ) \ компиляция строки, заданной addr u, в виде строки со счетчиком
  DUP C, DP @ SWAP DUP ALLOT CMOVE
;
  \ -- не определено на этапе подключения macroopt.f


\ src: ~pinka/spf/compiler/native-wordlist.f
: RELATE-NAME ( xt  c-addr u  wid -- )
\ поставить имя (заданное c-addr u) в отношение к xt в списке wid
  >R
  \ HERE LAST-CFA !
  ROT , \ ссылка на xt
  0 C,                  \ flags
  \ +SWORD was here
  HERE LAST ! S",       \ само имя
  \ (формат SPF4)
  LAST @  R> DUP @ , !  \ связали в список wid
;

\ src: ~pinka/spf/compiler/native-context.f
: (NODE-PRECEDING-FROM) ( node1 node9 -- node2|0 ) \ node9--> ... -->node2-->node1
  SWAP >R
  BEGIN DUP WHILE \ ( node4 )
  DUP CDR DUP R@ = IF ( node4 node3 ) DROP RDROP EXIT THEN
  NIP REPEAT RDROP
;
: (CONCAT-WORDLIST) ( node1 node9 wid -- )
  DUP @ >R ! NAME>L R> SWAP !
;
: DISPLACE-SUBWORDLIST ( wid-src node-boundary wid-dst -- )
  >R SWAP
  2DUP @ (NODE-PRECEDING-FROM) DUP 0= IF DROP 2DROP RDROP EXIT THEN
  ( node-boundary wid-src pnode )
  >R DUP @ >R ! \ node-boundary wid-src !  ( R: wid-dst pnode last-node )
  2R> R> (CONCAT-WORDLIST)
;

: & ( d-txt-name -- xt )
  SFIND IF EXIT THEN
  CR TYPE SPACE -321 THROW
;
: OBEY-SURE ( i*x c-addr u wid -- j*x )
  0 2OVER 2>R DROP
  SEARCH-WORDLIST IF RDROP RDROP EXECUTE EXIT THEN 
  2R> CR TYPE SPACE -321 THROW
;



\ **********
\ Specific implementation

0 VALUE TC-FORTH-WL
0 VALUE TC-MACROOPT-WL
\ Note that word 'TC-WL' has vocabulary behaviour, not wordlist behaviour

VARIABLE BORDER

\ EXPORT
DUP SET-CURRENT

: INIT-MACROOPT-HIDING ( -- )
  CONTEXT @ FORTH-WORDLIST = IF \ в инструментальной системе
    FORTH-WORDLIST  TO TC-FORTH-WL
  ELSE \ в целевой системе
    ALSO S" TC-WL" & EXECUTE \ it is vocabulary in real!
      CONTEXT @     TO TC-FORTH-WL
    PREVIOUS
  THEN
  TC-FORTH-WL @  BORDER !
;

DEFINITIONS

: EXPORT-NAME ( addr u -- )
  2DUP 2>R
  TC-MACROOPT-WL SEARCH-WORDLIST
  DUP 0= IF DROP 2R> TYPE SPACE -321 THROW THEN
  ( xt flag )
  2R> ROT >R TC-FORTH-WL RELATE-NAME
  R> 1 = IF IMMEDIATE THEN
;
: E: ( -- )
  NextWord  [COMPILE] SLITERAL  POSTPONE EXPORT-NAME
; IMMEDIATE

: HIDE-WORDS
  S" MACROOPT-WL" TC-FORTH-WL OBEY-SURE TO TC-MACROOPT-WL
  TC-FORTH-WL  BORDER @  TC-MACROOPT-WL  DISPLACE-SUBWORDLIST
;

: EXPORT-WORDS
  \ see also:
  \    noopt.f
  \    http://spf.sourceforge.net/docs/intro.en.html#opt

  E: MACROOPT-WL
  E: VECT-INLINE?
  E: SHORT?

  E: OPT?
  E: J_COD
  E: MM_SIZE
  E: :-SET
  E: J-SET
  E: LAST-HERE
  E: OpBuffSize
  E: OP0
  E: SetOP
  E: ClearJpBuff
  E: SetJP
  E: ?SET
  E: ?C-JMP
  E: INLINE?
  E: OPT_CLOSE
  E: OPT_INIT
  E: INLINE,
  E: ???BR-OPT
  E: OPT
  E: CON>LIT
  E: J_OPT?
  E: RESOLVE_OPT
  E: INIT-MACROOPT-LIGHT
  E: MACRO,
  E: SET-OPT
  E: DIS-OPT
;

\ EXPORT
DUP SET-CURRENT

: HIDE-MACROOPT-WORDS ( -- )
  HIDE-WORDS
  EXPORT-WORDS
;

PREVIOUS SET-CURRENT

BASE !

  INIT-MACROOPT-HIDING  \ (!!!)

  WORDLIST VALUE MACROOPT-WL  \ после INIT, т.к должно попасть в перемещаемую цепочку слов
  \ Создаем тут, т.к. этот список не создается в macroopt.f при трансляции в инструментальную систему,
  \ см. macroopt.f # [DEFINED] [TTO]

[THEN] \ for skipping if USE-OPTIMIZER is 0
