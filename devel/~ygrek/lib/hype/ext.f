\ $Id$
\ hype3 extension

REQUIRE WL-MODULES ~day/lib/includemodule.f

REQUIRE [IF] lib/include/tools.f
REQUIRE CLASS ~day/hype3/hype3.f
REQUIRE /TEST ~profit/lib/testing.f

MODULE: HYPE
EXPORT
\ append more methods (and only methods) to the class
\ end with ;CLASS
: +METHODS ( ta -- )
   GET-CURRENT PREVIOUS-CURRENT ! \ should be factored out from (CLASS)
   ( ta ) METHODS ;
;MODULE

/TEST

CLASS cls
 CELL DEFS _x
 : set _x ! ;
 : print _x @ . CR ;
;CLASS

cls NEW obj
123 obj set
obj print

cls +METHODS
: boast ." boast: " _x @ 2 * . CR ;
;CLASS

obj boast
