\ Ю. Жиловец (www.forth.org.ru/~yz)
\ некоторые места написаны под впечатлением от кода Андрея Черезова 
\ (www.forth.org.ru/~ac/lib/com.f)
\ 18.12.2000

REQUIRE  " ~yz/lib/common.f

16 == clsid-len

WINAPI: CoInitialize  OLE32.DLL
WINAPI: CoUninitialize  OLE32.DLL

: COM-init ( -- ?)
  0 CoInitialize ;

: COM-destroy
  CoUninitialize DROP ;

WINAPI: CLSIDFromString  OLE32.DLL
WINAPI: CLSIDFromProgID  OLE32.DLL

: >clsid ( z a -- )
  SWAP >unicodebuf DUP >R CLSIDFromString R> FREEMEM THROW ;

: clsid, ( z --)
  HERE >clsid clsid-len ALLOT ;

: prog>clsid ( z a -- ?)
  SWAP >unicodebuf DUP >R CLSIDFromProgID R> FREEMEM ;

\ формат интерфейса
\ + 0	16	CLSID
\ +16	 4	количество методов
: interface ( род.интерфейс -- 'methods# ; ->bl)
  CREATE 
  BL WORD COUNT PAD CZMOVE  PAD clsid,
  clsid-len + @ HERE SWAP , ;

: interface-end ( 'methods# --)
  DROP ;

: invoke-method  ( ... interface method# -- ... ) CELLS OVER @ + @ API-CALL ;

: method  ( 'methods# -- 'methods#; ->bl)
  CREATE DUP @ , DUP 1+!
  DOES> @ invoke-method ;

: single-method ( method# -- ; ->bl)
  CREATE , DOES> @ invoke-method ;

CREATE IID_NULL
" {00000000-0000-0000-0000-000000000000}" clsid, 0 ,

IID_NULL interface IID_IUnknown {00000000-0000-0000-C000-000000000046}
  method ::QueryInterface   ( *interface iid_null -- hres )
  method ::AddRef           ( -- cnt )
  method ::Release          ( -- cnt )
interface-end

: release ( iunk -- ) ::Release DROP ;
