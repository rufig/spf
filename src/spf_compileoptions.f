( Compile options )

0 CONSTANT CREATE-XML-HELP \ generate spfhelp.xml file

\ TRUE = use P6 family instructions (for speed)
\ FALSE = pentium only (?) *default
FALSE CONSTANT ARCH-P6 

\ TRUE = enable SPF optimizer *default
\ FALSE = disable
TRUE CONSTANT SPF-WITH-OPT

\ TODO for 4.19
1 CONSTANT USE-OPTIMIZATOR \ use but not compile optimizator
1 CONSTANT COMPILE-OPTIMIZATOR
0 CONSTANT OPTIMIZE-BY-SIZE ( without align and short literals )
