.( Content-Type: text/plain) CR CR

REQUIRE :: ~yz/lib/automation.f
WARNING @ WARNING 0!
: Z" POSTPONE " ; IMMEDIATE
REQUIRE STR@ ~ac/lib/str2.f
WARNING !

: Z. DROP ASCIIZ> TYPE ;

VARIABLE SI
VARIABLE II

: TEST { \ ses mess mes rcpt store rf fldrs }
  COM-init THROW

  Z" MAPI.Session" create-object THROW -> ses
  arg() ses :: Logon

  ses :: CurrentUser @
  DROP DUP :: Address @
  Z. CR
  :: Name @
  Z. CR

  arg() ses :: GetInfoStore >
  DROP -> store
  store :: Name @
  Z. CR
  store :: RootFolder @
  DROP -> rf

  rf :: Messages @
  DROP -> mess
  rf :: Folders @
  DROP -> fldrs

  fldrs FOREACH 
      OBJ-I DROP :: Name @
      OVER ASCIIZ> S" Sent Items" COMPARE 0= IF OBJ-I DROP SI ! THEN
      Z. CR
  NEXT

  SI @ :: Messages @
  DROP FOREACH
      OBJ-I DROP :: Sender @
      ." From: " DROP DUP :: Name @
      Z. ."  <" :: Address @
      Z. ." >" CR
\      OBJ-I DROP :: Recipients @
\      ." To: " DROP DUP :: Name @
\      Z. ."  <" :: Address @
\      Z. ." >" CR
      OBJ-I DROP :: Subject @
      Z. CR

      OBJ-I DROP :: Text @
      Z. CR
      OBJ-I DROP release
      II 1+! II @ 10 = IF LEAVE-FOREACH THEN
  NEXT

\  ses :: Outbox @ 
\  DROP :: Messages @
\  DROP -> mess
\  arg(  Z" Это тестовая тема" _str Z" Тестовое сообщение" _str )arg  mess :: Add >
\  DROP -> mes
\  mes :: Recipients @
\  DROP -> rcpt
\  arg( Z" Andrey Cherezov" _str Z" SMTP:ac@eserv.ru" _str )arg rcpt :: Add
\  arg( TRUE _bool TRUE _bool )arg mes :: Send
  COM-destroy
;

TEST
