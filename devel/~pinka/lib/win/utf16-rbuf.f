REQUIRE [:                      lib/include/quotations.f
REQUIRE RBUF                    ~pinka/spf/rbuf.f
REQUIRE UTF8>UTF16              ~pinka/lib/win/utf16.f

: R:UTF8>UTF16 \ Run-time ( sd.txt1 -- sd.txt2 ; R: -- i*x nest-sys )
  \ sd.txt2 is allocated on the return stack
  [: DUP 1+ 2* ;] COMPILE, \ NB: in the worst case utf16 takes 2x of utf8
  POSTPONE RBUF
  [: UTF8>UTF16  2DUP + 0 SWAP W! ;] COMPILE,
; IMMEDIATE

