.( Content-Type: text/plain) CR CR

REQUIRE :: ~yz/lib/automation.f
WARNING @ WARNING 0!
: Z" POSTPONE " ; IMMEDIATE
REQUIRE STR@ ~ac/lib/str2.f
WARNING !

: TEST { \ ses mess mes rcpt }
  COM-init THROW

  Z" MAPI.Session" create-object THROW -> ses
  arg() ses :: Logon
  ses :: Outbox @ 
  DROP :: Messages @
  DROP -> mess
  arg(  Z" Это тестовая тема" _str Z" Тестовое сообщение" _str )arg  mess :: Add >
  DROP -> mes
  mes :: Recipients @
  DROP -> rcpt
  arg( Z" Andrey Cherezov" _str Z" SMTP:ac@eserv.ru" _str )arg rcpt :: Add
  arg( TRUE _bool TRUE _bool )arg mes :: Send
  COM-destroy
;

TEST
