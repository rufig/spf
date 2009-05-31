\ $Id$
\ Exceptions registration

REQUIRE PICK-NAME ~ygrek/lib/parse.f
REQUIRE /TEST ~profit/lib/testing.f

\ 2048 VALUE next-exception
\ : (EXCEPTION) ( -- exn ) next-exception-id DUP 1+ TO next-exception-id ;

: (EXCEPTION) ( -- exn ) HERE ;

\ register new exception with description a u
: EXCEPTION ( a u -- exn ) ['] (EXCEPTION) , (EXCEPTION) >R S", R> ;

\ register new exception and assign symbolic name
: EXCEPTION: ( "name" -- ) PICK-NAME EXCEPTION CONSTANT ;

: EXCEPTION>TEXT ( exn -- a u )
  ?DUP 0 = IF S" <none>" EXIT THEN
  DUP CELL- 
  ['] @ CATCH IF 2DROP ELSE 
    \ check marker
    ['] (EXCEPTION) <> IF DROP ELSE COUNT EXIT THEN
  THEN
  S" <unknown>" ;

/TEST

S" some exception" EXCEPTION CONSTANT some
EXCEPTION: #failure

: t EXCEPTION>TEXT TYPE CR ;

some ' CREATE 0 #failure t t t t

