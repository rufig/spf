.( Content-Type: text/plain) CR CR

REQUIRE :: ~yz/lib/automation.f
WARNING @ WARNING 0!
: Z" POSTPONE " ; IMMEDIATE
REQUIRE STR@ ~ac/lib/str2.f
WARNING !

: TEST { \ ie app }
  COM-init THROW

\  Z" SHDocVw.InternetExplorer" create-object THROW -> ie
  Z" InternetExplorer.Application" create-object THROW -> app
  TRUE _bool app :: Visible !
  arg() app :: GoHome
\  arg( Z" http://www.eserv.ru/" _str )arg app :: Navigate
  KEY DROP
  Z" Удивительная вещь :)" _str app :: StatusText !
  COM-destroy
;

TEST
