REQUIRE ENSURE-ASCIIZ-R         ~pinka/spf/rbuf.f
REQUIRE UTF8>UTF16              ~pinka/lib/win/utf16.f

: R:UTF8>UTF16 \ Run-time ( sd.txt1 -- sd.txt2 )
  \ sd.txt2 is allocated on the return stack
  POSTPONE ENSURE-ASCIIZ-R POSTPONE 1+ POSTPONE DUP POSTPONE 2* POSTPONE RBUF POSTPONE UTF8>UTF16
; IMMEDIATE

