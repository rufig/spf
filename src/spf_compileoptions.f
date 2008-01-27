( Compile options )

0 CONSTANT CREATE-XML-HELP \ generate spfhelp.xml file

\ TRUE = use P6 family instructions (for speed)
\ FALSE = pentium only (?) *default
FALSE CONSTANT ARCH-P6 


TRUE CONSTANT BUILD-OPTIMIZER \ build optimizer into the forth system for further compilation
TRUE CONSTANT USE-OPTIMIZER    \ use optimizer while building to produce a better code
FALSE CONSTANT OPTIMIZE-BY-SIZE \ without align literals, may decrease speed, TODO short literals like in 3.75

FALSE CONSTANT BUILD-OPTIMIZER
FALSE CONSTANT USE-OPTIMIZER

2 CONSTANT CHAR-SIZE \ only 1 or 2

0 CONSTANT SMALLEST-SPF

\ Internal code, do not touch it

SMALLEST-SPF [IF]
FALSE CONSTANT BUILD-OPTIMIZER
TRUE CONSTANT USE-OPTIMIZER
TRUE CONSTANT OPTIMIZE-BY-SIZE
[THEN]

OPTIMIZE-BY-SIZE [IF]
1 CONSTANT ALIGN-BYTES-CONSTANT
[ELSE]
4 CONSTANT ALIGN-BYTES-CONSTANT
[THEN]
