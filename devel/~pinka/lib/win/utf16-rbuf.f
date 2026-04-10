\ 2021-02-17 -- initial version

REQUIRE [:                      lib/include/quotations.f
REQUIRE RBUF                    ~pinka/spf/rbuf.f
REQUIRE UTF8>UTF16              ~pinka/lib/win/utf16.f


\ Note:
\   - The length for input and output character strings is specified in bytes.
\   - A UTF-16 input character string must be aligned on a 2-byte (even address) boundary.
\   - The output character string is always null-terminated (a null-character is not included to the length).
\   - The lifetime of the output string ends when the cointaining definition completes.

: R:UTF8>UTF16 \ Run-time ( sd.txt1 -- sd.txt2 ; R: -- i*x nest-sys )
  \ Only for compilation.
  [: DUP 1+ 2* ;] COMPILE, \ NB: in the worst case utf16 takes 2x of utf8
  POSTPONE RBUF
  [: UTF8>UTF16  2DUP + 0 SWAP W! ;] COMPILE,
; IMMEDIATE

: R:UTF16>UTF8 \ Run-time ( sd.txt1 -- sd.txt2 ; R: -- i*x nest-sys )
  \ Only for compilation.
  \ sd.txt1 must be align on a 2-byte boundary.
  \ NB: the length of sd.txt1 is always an even number.
  [: DUP DUP 2/ + 1+ ;] COMPILE, \ NB: in the worst case utf8 takes 1+1/2 of utf16
  POSTPONE RBUF
  [: UTF16>UTF8  2DUP + 0 SWAP C! ;] COMPILE,
; IMMEDIATE

