REQUIRE TEMP ~ygrek/lib/temp.f

MODULE: vocVAR

: (VAR) 
 DOES> >R R@ CELL+ COUNT EVALUATE
 NextWord R> @ ( a u wid) SEARCH-WORDLIST 0= IF ABORT" No such word here." THEN
 STATE @ IF COMPILE, ELSE EXECUTE THEN ;

\ append dot "name" => "name.")
: dotted ( a u -- a' u') 
  2DUP PAD SWAP CMOVE
  NIP PAD SWAP ( a' u)
  2DUP + [CHAR] . SWAP C! 1+
;

EXPORT

: VAR ( "type" "name" -- )
  ALSO ' EXECUTE
  CONTEXT @ ( wid)
  PREVIOUS
  NextWord \ get var name
  2DUP dotted ( wid name-a name-u name.-a name.-u )
  CREATED
  ROT
  ( a u wid) , S",
  (VAR)
  IMMEDIATE
; IMMEDIATE

: DEFSTRUCT ( "type" "name" -- )
   >IN @
   ALSO NextWord EVALUATE
    CREATE
    S" /SIZE" EVALUATE ALLOT
    GET-CURRENT DEFINITIONS S" : /SIZE@ /SIZE NIP ;" EVALUATE SET-CURRENT
   >IN !
   PREVIOUS
   POSTPONE VAR
;

;MODULE

\EOF

REQUIRE SEE lib/ext/disasm.f
REQUIRE TPluginStartupInfo ~ygrek/prog/farplugin/plugin.f

\ CREATE a TPluginStartupInfo::/SIZE ALLOT
\ VAR TPluginStartupInfo a
DEFSTRUCT TPluginStartupInfo a

: aMN a. ModuleName ;
: amn a TPluginStartupInfo::ModuleName ;

SEE aMN
SEE amn

: chk 0 aMN amn <> ABORT" Error!" DROP ;
chk

: ss. a. StructSize @ . ;

CR .( 0 = ) ss.
a. /SIZE@ a. StructSize !
CR TPluginStartupInfo::/SIZE . .( = ) ss.

BYE

