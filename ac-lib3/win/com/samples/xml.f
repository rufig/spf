.( Content-Type: text/plain) CR CR

REQUIRE :: ~yz/lib/automation.f
WARNING @ WARNING 0!
: Z" POSTPONE " ; IMMEDIATE
REQUIRE STR@ ~ac/lib/str2.f
WARNING !

: TEST { \ xml }
  COM-init THROW

  Z" Microsoft.XMLHTTP" create-object THROW -> xml

arg( Z" GET" _str Z" http://ac/" _str FALSE _bool )arg xml :: Open
arg() xml :: Send
xml :: ResponseText @
. 100 TYPE

\    xmlhttp.Send(xmldoc);
\    return xmlhttp.responseXML;
  COM-destroy
;

TEST
