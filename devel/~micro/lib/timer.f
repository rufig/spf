MODULE: Timer
  CREATE MarkedTime 2 CELLS ALLOT
  WINAPI: GetSystemTimeAsFileTime kernel32.dll
  : GetSystemTime ( -- d )   0 0 SP@ GetSystemTimeAsFileTime DROP SWAP ;
  : D- DNEGATE D+ ;
  : Mark GetSystemTime MarkedTime 2! ;
  : Elapsed ( -- s )
    GetSystemTime MarkedTime 2@ D-
    DUP IF
      2DROP 0x7FFFFFFF
    ELSE
      10000000 UM/MOD NIP
    THEN
  ;
  : ElapsedMs ( -- s )
    GetSystemTime MarkedTime 2@ D-
    DUP IF
      2DROP 0x7FFFFFFF
    ELSE
      10000 UM/MOD NIP
    THEN
  ;
;MODULE
