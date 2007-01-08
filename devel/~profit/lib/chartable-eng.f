0 VALUE #parsed
CREATE parsedBuf 1024 CHARS ALLOT

: flushParsed 0 TO #parsed ;
: parsed parsedBuf #parsed ;
: parsedHere parsedBuf #parsed +  ;

: inc #parsed 1+ TO #parsed  parsedHere C! ;


0 VALUE curTable

CREATE charBuf 0 ,
: curChar charBuf C@ ;

: stopScan POSTPONE RDROP POSTPONE RDROP POSTPONE RDROP ; IMMEDIATE
: incChar  curChar inc ;

:NONAME ; CONSTANT nop

: setChar ( xt c -- ) CELLS curTable + ! ;
: setRange ( xt start end  -- ) 1+ SWAP DO DUP I setChar LOOP DROP ;
: allChars ( xt -- ) 0 256 setRange ;
: emptyTable nop allChars ;


: :n POSTPONE :NONAME ; IMMEDIATE

: char:  ( "z" -- ) :n CHAR setChar ;
: asc: :n SWAP setChar ;

: all: :n  allChars ;
: range: :n -ROT setRange ;

: space: :n BL setChar ;
: cr: nop 10 setChar  :n 13 setChar ;

: charTable
CREATE
nop ,
HERE TO curTable 
256 CELLS ALLOT
emptyTable
DOES> DUP @ EXECUTE  CELL+ TO curTable ;

: tableDoes: :n curTable CELL- ! ;
: tableDoesnt nop ' >BODY ! ;

: keyCode curTable curChar CELLS + @ ;
: executeKey keyCode EXECUTE ;

: processChar ( c -- ) charBuf C!  executeKey ;

: copyFromTable ( "tbl ) ' >BODY  curTable  256 1+ CELLS MOVE ;

: startScanConsole flushParsed BEGIN KEY processChar AGAIN ;