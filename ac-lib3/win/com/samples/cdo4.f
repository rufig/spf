.( Content-Type: text/plain) CR CR

REQUIRE :: ~yz/lib/automation.f
WARNING @ WARNING 0!
: Z" POSTPONE " ; IMMEDIATE
REQUIRE STR@ ~ac/lib/str2.f
WARNING !

: Z. DROP ASCIIZ> TYPE ;

VARIABLE ST

: TEST { \ ses mess mes rcpt store rf fldrs }
  COM-init THROW

  Z" MAPI.Session" create-object THROW -> ses
  arg() ses :: Logon

\  arg( ST _int 0 _int 0 _int )arg ses :: OpenMsgStore

  COM-destroy
;

TEST
