.( Content-Type: text/plain) CR CR

REQUIRE :: ~yz/lib/automation.f
WARNING @ WARNING 0!
: Z" POSTPONE " ; IMMEDIATE
REQUIRE STR@ ~ac/lib/str2.f
WARNING !

: TEST { \ pits }
  COM-init THROW

  Z" ItsTrans.Kernel.2" create-object THROW -> pits
  COM-destroy
;

TEST
