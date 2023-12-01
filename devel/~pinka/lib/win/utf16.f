REQUIRE [UNDEFINED]             lib/include/tools.f

[UNDEFINED] MultiByteToWideChar [IF]
WINAPI: MultiByteToWideChar     kernel32.dll
WINAPI: WideCharToMultiByte     kernel32.dll
[THEN]
\ https://docs.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-multibytetowidechar
\ https://docs.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-widechartomultibyte


\ Note:
\   - The length for strings and buffers is specified in bytes.
\   - UTF-16 character strings and buffers for such strings must be aligned on a 2-byte boundary.
\   - The input string does not have to be null-terminated.
\   - A null terminator character may be included in the length of the input string,
\     and then it is included in the length of the output string as well.
\     Otherwise, the output string is not null-terminated.
\   - If the input string is ( 0|c-addr1 0 ), the output string is ( c-addr2 0 )
\     and the output buffer remains untouched.


: ANSI>UTF16 ( sd.text-oem sd.buf -- sd.text-utf16 ) \ AKA Wide char
  OVER >R
  1 RSHIFT SWAP 2SWAP SWAP
  OVER 0= IF 2DROP 2DROP R> 0 EXIT THEN
  0 ( flags ) 0 ( CP_ACP )  MultiByteToWideChar
  DUP ERR THROW
  2* R> SWAP
;

: UTF16>ANSI ( sd.text-utf16 sd.buf -- sd.text-oem )
  2>R 0 0 2SWAP
  1 RSHIFT SWAP R> R@ 2SWAP
  OVER 0= IF 2DROP 2DROP R> 0 EXIT THEN
  0 ( flags ) 0 ( CP_ACP )  WideCharToMultiByte
  DUP ERR THROW
  R> SWAP
;


\ m.b.: ANSI>W  and  W>ANSI ?

\ see also: ~ac/lib/win/utf8.f



: UTF8>UTF16 ( sd.text-utf8 sd.buf -- sd.text-utf16 ) \ AKA Wide char
  OVER >R
  1 RSHIFT SWAP 2SWAP SWAP
  OVER 0= IF 2DROP 2DROP R> 0 EXIT THEN
  0 ( flags ) 65001 ( CP_UTF8 )  MultiByteToWideChar
  DUP ERR THROW
  2* R> SWAP
;

: UTF16>UTF8 ( sd.text-utf16 sd.buf -- sd.text-utf8 )
  2>R 0 0 2SWAP
  1 RSHIFT SWAP R> R@ 2SWAP
  OVER 0= IF 2DROP 2DROP R> 0 EXIT THEN
  0 ( flags ) 65001 ( CP_UTF8 )  WideCharToMultiByte
  DUP ERR THROW
  R> SWAP
;
