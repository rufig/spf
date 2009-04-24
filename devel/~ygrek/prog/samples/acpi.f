\ $Id$
\ simple battery state watcher

REQUIRE re_match? ~ygrek/lib/re/re.f
REQUIRE cat ~ygrek/lib/cat.f
REQUIRE split-patch ~profit/lib/bac4th-str.f

0 VALUE rate
0 VALUE cap
FALSE VALUE bat

: show 
  cat DUP
  START{ STR@ byRows split-patch
  \ 2DUP TYPE CR
  2DUP RE" charging state: +discharging" re_match? bat OR TO bat
  2DUP RE" present rate: +(\d+).*" re_match? 
       IF \1 NUMBER IF TO rate EXIT THEN THEN
  2DUP RE" remaining capacity: +(\d+).*" re_match?
       IF \1 NUMBER IF TO cap EXIT THEN THEN
  }EMERGE
  STRFREE
  bat IF
  \ rate . cap . CR 
  cap 60 rate */ 60 /MOD " {n}h {n}m left" STYPE CR 
  ELSE
  ." On AC" CR
  THEN
;

S" /proc/acpi/battery/BAT0/state" show 
BYE

