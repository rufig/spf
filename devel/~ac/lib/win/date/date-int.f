REQUIRE >Дата         ~ac/lib/win/date/date.f
REQUIRE GET-TIME-ZONE ~ac/lib/win/date/timezone.f
REQUIRE {             ~ac/lib/locals.f

\ WINAPI: GetTickCount KERNEL32.DLL
1 1 1998 >Дата CONSTANT d01011998

VARIABLE W-DATEA
VARIABLE M-DATEA

: W-DATE
  HERE W-DATEA !
  7 0 DO BL WORD ", LOOP
;
: M-DATE
  HERE M-DATEA !
  12 0 DO BL WORD ", LOOP
;
W-DATE Sun Mon Tue Wed Thu Fri Sat
M-DATE Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec

: >Date>W ( d m y -- w )
  >Дата d01011998 - 4 + 7 MOD
  DUP 0< IF 7 + THEN
;
: DateW>S ( w -- addr u )
  0 MAX 6 MIN
  W-DATEA @ SWAP 0 ?DO COUNT + LOOP COUNT
;
: DateM>S ( m -- addr u )
  1 MAX 12 MIN
  1- M-DATEA @ SWAP 0 ?DO COUNT + LOOP COUNT
;
: #: ( -- ) [CHAR] : HOLD ;
: #N ( n -- ) ( S>D) 0 #S 2DROP ;
: #N## ( n -- ) ( S>D) 0 # # 2DROP ;
: #SG ( n -- )
  DUP >R ABS 0 #S 2DROP R> SIGN
;
: <<# ( -- 0 0 )
  PAD 0!
  0 0 <#
;
: <#N ( n -- xd )
  >R <<# R> #SG
;
\ : HOLDS ( addr u -- )
\   1024 MIN
\   SWAP OVER + SWAP 0 ?DO DUP I - 1- C@ HOLD LOOP DROP
\ ;

: Date# { d m y -- }
  y #N BL HOLD m DateM>S HOLDS BL HOLD d #N## S" , " HOLDS
  d m y >Date>W DateW>S HOLDS
;
: Time# { h m s -- }
  s #N## #: m #N## #: h #N##
;
: DateTime# { s m h d m1 y -- }
  TZ @ 0= IF GET-TIME-ZONE THEN
  TZ @ 60 / NEGATE DUP #SG 0 > IF [CHAR] + HOLD THEN
  S"  GMT" HOLDS h m s Time# BL HOLD d m1 y Date#
;
: DateTime#GMT { s m h d m1 y -- }
  S"  GMT" HOLDS h m s Time# BL HOLD d m1 y Date#
;
: Zone# ( -- )
  TZ @ 0= IF GET-TIME-ZONE THEN
  TZ @ 60 / NEGATE DUP >R ABS 100 * 0 # # # # 2DROP
  R> 0 > IF [CHAR] + ELSE [CHAR] - THEN HOLD
;
: DateTime#Z { s m h d m1 y -- }
  Zone# BL HOLD
  h m s Time# BL HOLD d m1 y Date#
;
: CurrentDateTime#
  TIME&DATE DateTime#
;
: CurrentDateTime#Z
  TIME&DATE DateTime#Z
;
