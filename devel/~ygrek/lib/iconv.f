\ $Id$
\ Обёртка к iconv
\ more to do

REQUIRE CAPI: ~af/lib/c/capi.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE /TEST ~profit/lib/testing.f

5 CAPI: libiconv       iconv.dll
2 CAPI: libiconv_open  iconv.dll
1 CAPI: libiconv_close iconv.dll

WINAPI: _errno MSVCRT.DLL

7 CONSTANT E2BIG
22 CONSTANT EINVAL
84 CONSTANT EILSEQ

MODULE: iconv

: convert { a u cd | buf addr size u2 s -- s }
   u 10 MAX -> size \ для слишком короткой входной строки гарантируем достаточный размер буфера
   size ALLOCATE THROW -> buf
   "" -> s
   0 0 0 0 cd libiconv DROP \ set to initial state
   BEGIN
    size -> u2
    buf -> addr
    ^ u2 ^ addr ^ u ^ a cd libiconv -1 = 
    buf addr OVER - s STR+ \ 
   WHILE
    _errno @ E2BIG <> ABORT" iconv cant convert"
   REPEAT 
   buf FREE THROW 
   s ;

EXPORT

: iconv: ( a1 u1 a2 u2 "name" -- ) 
\ name ( a u -- s )
  CREATE
    2SWAP S", 0 C, S", 0 C,
   DOES> ( a u addr -- s )
    >R R@ COUNT R> + 2 + COUNT DROP libiconv_open DUP -1 = ABORT" No such conversion"
    >R 
    R@ convert
    R> libiconv_close ABORT" iconv close failed"
   ;

;MODULE   

S" UTF-8" S" CP1251" iconv: UTF>WIN
S" CP1251" S" UTF-8" iconv: WIN>UTF

\ -------------------------------------------------

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES UTF>WIN and back                                                                                          
(( S" ����" WIN>UTF DUP STR@ S" Тест" TEST-ARRAY STRFREE -> ))                                                      
(( S" Тест" UTF>WIN DUP STR@ S" ����" TEST-ARRAY STRFREE -> ))                                                      
END-TESTCASES

