\ $Id$
\ Default compile options
\ Override these options in custom spf.compile.ini place near spf binary

FALSE VALUE CREATE-XML-HELP \ generate spfhelp.xml file

FALSE VALUE ARCH-P6 \ use P6 family instructions (for speed) 

TRUE VALUE BUILD-OPTIMIZER \ build optimizer into the forth system for further compilation
TRUE VALUE USE-OPTIMIZER    \ use optimizer while building to produce a better code
FALSE VALUE OPTIMIZE-BY-SIZE \ without align literals, may decrease speed, TODO short literals like in 3.75

FALSE VALUE WIDE-CHAR \ 2-byte CHARS

FALSE VALUE SMALLEST-SPF 

\ set to TRUE if you are building spf in the environment with unix line endings in files
\ it will set the default EOLN for the target system
FALSE VALUE UNIX-ENVIRONMENT

\ build posix-spf
FALSE VALUE TARGET-POSIX

S" spf.compile.ini" ' INCLUDED CATCH 
 DUP 2 = [IF] CR .( No spf.compile.ini - using defaults) DROP 2DROP [ELSE] THROW [THEN]

SMALLEST-SPF [IF]
FALSE TO BUILD-OPTIMIZER
TRUE TO USE-OPTIMIZER
TRUE TO OPTIMIZE-BY-SIZE
[THEN]

OPTIMIZE-BY-SIZE [IF]
1 CONSTANT ALIGN-BYTES-CONSTANT
[ELSE]
4 CONSTANT ALIGN-BYTES-CONSTANT
[THEN]

: O: NextWord DUP 20 SWAP - SPACES 2DUP TYPE ."  : " EVALUATE IF ." TRUE" ELSE ." FALSE" THEN CR ;

CR 
.( Build options : ) CR
O: CREATE-XML-HELP 
O: ARCH-P6
O: BUILD-OPTIMIZER
O: USE-OPTIMIZER
O: OPTIMIZE-BY-SIZE
O: WIDE-CHAR
O: UNIX-ENVIRONMENT
O: TARGET-POSIX
CR
