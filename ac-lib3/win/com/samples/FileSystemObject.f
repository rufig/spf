REQUIRE CreateObject ~ac/lib/win/com/com.f

\ bool true 0B 00 xx xx  xx xx xx xx  FF FF 00 00  00 00 00 00

 0 CONSTANT LOCALE_USER_DEFAULT
 1 CONSTANT DISPATCH_METHOD
11 CONSTANT VT_BOOL
 8 CONSTANT VT_BSTR

VARIABLE FSO
: L",
  0 ?DO DUP I + C@ W, LOOP DROP 0 W,
;
: L" ( "ccc" -- )
  [CHAR] " PARSE L",
;
(
CREATE NAMES HERE 2 CELLS + , 0 , L" CreateTextFile"
CREATE DispParams HERE 4 CELLS + , 0 , 2 , 0 , 
VT_BSTR , 0 , HERE 4 CELLS + ,  
\ VT_BOOL , 0 , TRUE , 
VT_BOOL , 0 , TRUE ,
\ L" TestFile.txt"
CHAR A C, CHAR B C, 0 C,
\ HERE 3 CELLS + , TRUE , 0 , L" TestFile.txt"
)
(
CREATE NAMES HERE 2 CELLS + , 0 , L" GetTempName"
CREATE DispParams HERE 4 CELLS + , 0 , 0 , 0 ,    0 ,
)
(
CREATE NAMES HERE 2 CELLS + , 0 , L" CreateTextFile"
CREATE DispParams HERE 4 CELLS + , 0 , 1 , 0 , 
VT_BSTR , 0 , HERE 1 CELLS + ,
\ VT_BOOL , 0 , 0 ,
L" TestFile.txt" 
VT_BOOL , 0 , 0 , 0 ,
)


WINAPI: SysAllocString OLEAUT32.DLL

CREATE CreateTextFile L" CreateTextFile"
CREATE TestFile L" TestFile.txt"
CREATE TestFile2 L" TestFile2.txt"

(
CREATE NAMES1 \ HERE 2 CELLS + , 0 , L" AppShow"
              CreateTextFile SysAllocString , 0 ,
CREATE DispParams1 HERE 4 CELLS + , 0 , 2 , 0 , 
VT_BSTR , 0 , TestFile2 SysAllocString , 0 ,
VT_BSTR , 0 , TestFile SysAllocString , 0 ,
)

(
CREATE GetTempName L" GetTempName"
CREATE NAMES1 \ HERE 2 CELLS + , 0 , L" AppShow"
              GetTempName SysAllocString , 0 ,
CREATE DispParams1 0 , 0 , 0 , 0 , 
\ VT_BSTR , 0 , TestFile SysAllocString ,
\ VT_BSTR , 0 , TestFile2 SysAllocString , 0 ,
)

CREATE NAMES1 \ HERE 2 CELLS + , 0 , L" AppShow"
              CreateTextFile SysAllocString , 0 ,
CREATE DispParams1 HERE 4 CELLS + , 0 , 2 , 0 , 
VT_BOOL , 0 , TRUE W, 0 W, 0 ,
VT_BSTR , 0 , TestFile2 SysAllocString , 0 ,

CREATE AppShow L" AppShow"
CREATE NAMES2 \ HERE 2 CELLS + , 0 , L" AppShow"
              AppShow SysAllocString , 0 ,
CREATE DispParams2 0 , 0 , 0 , 0 , 
\ VT_BSTR , 0 , TestFile SysAllocString ,
\ VT_BSTR , 0 , TestFile2 SysAllocString , 0 ,


: InvokeNamedMethod ( params oid addr u -- result ior )
\ выполнить метод с заданным addr u именем
\ работает только для классов, поддерживающих dual interface (IDispatch)
  ROT GetIDispatch ?DUP IF 2SWAP 2DROP EXIT THEN \ нет интерфейса IDispatch
  >R
  >UNICODE DROP SysAllocString >R
  0 >R RP@ LOCALE_USER_DEFAULT 1 RP@ CELL+ IID_NULL RP@ CELL+ CELL+ @
  ::GetIDsOfNames .
  0 0  ROT PAD 100 + SWAP DISPATCH_METHOD 0 IID_NULL
  R> RDROP R> ::Invoke PAD 100 + SWAP
;
: TEST
  ComInit .
  S" Scripting.FileSystemObject" CreateObject THROW DUP . GetIDispatch THROW DUP . FSO !
  PAD LOCALE_USER_DEFAULT 1 NAMES1 IID_NULL FSO @ ::GetIDsOfNames .
  0 0 PAD 100 + DispParams1 DISPATCH_METHOD 0 IID_NULL PAD @ FSO @ ::Invoke
;
: TEST7
  ComInit .
  DispParams2 S" Scripting.FileSystemObject" CreateObject THROW DUP ." obj:" .
  S" GetTempName" InvokeNamedMethod . .
;
VARIABLE FSI
: TEST2
  ComInit .
  S" Word.Basic" CreateObject THROW DUP . DUP FSO ! GetIDispatch THROW DUP . FSI !
  PAD LOCALE_USER_DEFAULT 1 NAMES2 IID_NULL FSI @ ::GetIDsOfNames ." ==" .
  0 0 PAD 100 + DispParams2 DISPATCH_METHOD 0 IID_NULL PAD @ DUP . FSI @ ::Invoke
;
: TEST3
  ComInit .
  S" WordPad.Document.1" CreateObject THROW DUP . DUP FSO ! GetIDispatch THROW DUP . FSI !
  PAD LOCALE_USER_DEFAULT 1 NAMES2 IID_NULL FSI @ ::GetIDsOfNames ." ==" .
  0 0 PAD 100 + DispParams2 DISPATCH_METHOD 0 IID_NULL PAD @ DUP . FSI @ ::Invoke
;
: TEST4
  ComInit .
  S" WScript" CreateObject THROW DUP . DUP FSO ! GetIDispatch THROW DUP . FSI !
  PAD LOCALE_USER_DEFAULT 1 NAMES2 IID_NULL FSI @ ::GetIDsOfNames ." ==" .
  0 0 PAD 100 + DispParams2 DISPATCH_METHOD 0 IID_NULL PAD @ DUP . FSI @ ::Invoke
;
