REQUIRE :: ~ac/lib/win/com/samples/automation+.f

: STYPE DROP ASCIIZ> TYPE ;

: TEST { \ ie app }
  COM-init THROW

  Z" SPF.Test" create-object THROW -> app
  arg( )arg app :: WORDS
  arg( 5 _word )arg app :: NEGATE >
  DROP .
  arg( 5 _word 6 _word )arg app :: * >
  DROP .
  arg( Z" VARIABLE TESTVAR" _str )arg app :: EVALUATE
  777 _word app :: TESTVAR !
  app :: TESTVAR @
  . .
  arg( )arg app :: TESTVAR >
  . .
  COM-destroy
;

TEST
