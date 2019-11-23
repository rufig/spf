REQUIRE [UNDEFINED]             lib/include/tools.f

[UNDEFINED] MultiByteToWideChar [IF]
WINAPI: MultiByteToWideChar     kernel32.dll
WINAPI: WideCharToMultiByte     kernel32.dll
[THEN]
\ https://docs.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-multibytetowidechar
\ https://docs.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-widechartomultibyte


: ANSI>UTF16 ( d-txt1 d-buf1 -- d-buf2 ) \ AKA Wide char
  OVER >R
  1 RSHIFT SWAP 2SWAP SWAP
  OVER 0= IF 2DROP 2DROP R> 0 EXIT THEN
  0 ( flags ) 0 ( CP_ACP )  MultiByteToWideChar
  DUP ERR THROW
  2* R> SWAP
;

: UTF16>ANSI ( d-txt1 d-buf1 -- d-buf2 )
  2>R 0 0 2SWAP
  1 RSHIFT SWAP R> R@ 2SWAP
  OVER 0= IF 2DROP 2DROP R> 0 EXIT THEN
  0 ( flags ) 0 ( CP_ACP )  WideCharToMultiByte
  DUP ERR THROW
  R> SWAP
;


\ m.b.: ANSI>W  and  W>ANSI ?

\ see also: ~ac/lib/win/utf8.f



: UTF8>UTF16 ( d-txt1 d-buf1 -- d-buf2 ) \ AKA Wide char
  OVER >R
  1 RSHIFT SWAP 2SWAP SWAP
  OVER 0= IF 2DROP 2DROP R> 0 EXIT THEN
  0 ( flags ) 65001 ( CP_UTF8 )  MultiByteToWideChar
  DUP ERR THROW
  2* R> SWAP
;

: UTF16>UTF8 ( d-txt1 d-buf1 -- d-buf2 )
  2>R 0 0 2SWAP
  1 RSHIFT SWAP R> R@ 2SWAP
  OVER 0= IF 2DROP 2DROP R> 0 EXIT THEN
  0 ( flags ) 65001 ( CP_UTF8 )  WideCharToMultiByte
  DUP ERR THROW
  R> SWAP
;
