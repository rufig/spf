( MODULE: xmlhelp-helper

: {# <# ;
: #} 0 0 #> ;
: #N S>D #S 2DROP ;

: #HOLDS 0 ?DO HOLDS LOOP ;

;MODULE)

\ : WITH-ASCIIZ ( xt a u -- )
\   HEAP-COPY >R
\   R@ ASCIIZ> ROT CATCH ( ior )
\   R> FREE THROW 
\   ( ior ) THROW ;

REQUIRE STR@ ~ac/lib/str5.f

: make: ( "dst" "src" -- )
\   PARSE-NAME S" /" PARSE-NAME 2DUP 2>R S" .xml" <# 4 0 DO HOLDS LOOP 0 0 #> START-XMLHELP

\   ['] START-XMLHELP PARSE-NAME WITH-ASCIIZ
\   PARSE-NAME TYPE
\   ['] INCLUDED      PARSE-NAME WITH-ASCIIZ
\   FINISH-XMLHELP ;

   " S{''} xmlhelp.f{''} INCLUDED{EOLN}" STYPE
   PARSE-NAME " S{''} {s}{''} START-XMLHELP{EOLN}" STYPE
   PARSE-NAME " S{''} {s}{''} INCLUDED{EOLN}" STYPE
   " FINISH-XMLHELP{EOLN}" STYPE ;

( S" xmlhelp.f" INCLUDED
S" source/~ygrek/lib/list/core.f.xml" START-XMLHELP
S" ~ygrek/lib/list/core.f" INCLUDED
FINISH-XMLHELP)

\ make: source ~ygrek/lib/list/core.f
