\ см. http://www.gotdotnet.ru/default.asp?wci=doc&d_no=437

REQUIRE :: ~ac/lib/win/com/samples/automation+.f

: STYPE DROP ASCIIZ> TYPE ;

\ Set Orbit = CreateObject("TestComponentLib.TestComponent")
\ MsgBox(Orbit.About)
\ Orbit.Square = 5
\ MsgBox(Orbit.Square)
\ MsgBox(Orbit.Mul(5,4))

: TEST { \ ie app }
  COM-init THROW

  Z" TestComponentLib.TestComponent" create-object THROW -> app
  app :: About @
  STYPE CR
  5 _cell app :: Square !
  app :: Square @
  DROP . CR
  arg( 5 _cell 4 _cell )arg app :: Mul >
  DROP . CR
  COM-destroy
;

TEST
