REQUIRE :: ~ac/lib/win/com/samples/automation+.f

: TEST { \ ie app }
  COM-init THROW

  Z" InternetExplorer.Application" create-object THROW -> app
  FALSE _bool app :: AddressBar !
  FALSE _bool app :: ToolBar !
  FALSE _bool app :: MenuBar !
\  TRUE  _bool app :: TheaterMode !
  600 _cell app :: Width !
  500 _cell app :: Height !
\  FALSE _bool app :: Resizable !
\  arg( FALSE _bool Z" {EFA24E61-B078-11D0-89E4-00C04FC9E26E}" _str )arg app :: ShowBrowserBar
\  arg() app :: GoHome
  arg( Z" http://www.eserv.ru/" _str )arg app :: Navigate
  TRUE  _bool app :: Visible !
  KEY DROP
  Z" Удивительная вещь :)" _str app :: StatusText !
  COM-destroy
;

TEST
