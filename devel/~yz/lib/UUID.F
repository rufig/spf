\ Работа с глобальными идентификаторами, общие константы
\ Ю. Жиловец, 22.03.2002

REQUIRE  " ~yz/lib/common.f

16 == clsid-len

WINAPI: CoInitializeEx  OLE32.DLL
WINAPI: CoUninitialize  OLE32.DLL

: ComInit ( -- ?)
  0 0 CoInitializeEx ;

: ComDestroy
  CoUninitialize DROP ;

WINAPI: CLSIDFromString  OLE32.DLL
WINAPI: CLSIDFromProgID  OLE32.DLL

: >clsid ( z a -- )
  SWAP >unicodebuf DUP >R CLSIDFromString R> FREEMEM THROW ;

: clsid, ( z --)
  HERE >clsid clsid-len ALLOT ;

: prog>clsid ( z a -- ?)
  SWAP >unicodebuf DUP >R CLSIDFromProgID R> FREEMEM ;

: CLSID ( z; ->bl ) CREATE clsid, ;

: guid= ( guid1 guid2 -- ?)  16 TUCK COMPARE 0= ;

0 == S_OK

4 == clsctx_local_server
1 == clsctx_inproc_server 
clsctx_local_server clsctx_inproc_server OR == clsctx_server

0x80004001 == E_NOTIMPL
0x80004002 == E_NOINTERFACE

WINAPI: StringFromGUID2 OLE32.DLL

: .guid ( a -- )
  100 PAD ROT StringFromGUID2 DROP PAD .unicode ;
	