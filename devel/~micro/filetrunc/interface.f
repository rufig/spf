S" ~micro/filetrunc/core.f" INCLUDED

: trunc
  NextWord POSTPONE SLITERAL
  POSTPONE TruncFile
; IMMEDIATE

\EOF

: qwe
 10 0 DO
   200 trunc d:\out.log
   10 PAUSE
 LOOP
;