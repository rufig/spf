\ Scattering a Colon Definition  for SPF3/SPF4
\ see for details: http://www.forth.org.ru/~mlg/ScatColn/ScatteredColonDef.html

: ... 0 BRANCH, >MARK DUP , 1 >RESOLVE ; IMMEDIATE 
: ..: '  >BODY DUP @  1 >RESOLVE ] ;
: ;..  DUP CELL+ BRANCH, >MARK SWAP ! [COMPILE] [ ; IMMEDIATE

