\ Вызов методов интерфейсов
\ Ю. Жиловец, 22.03.2002

\ формат интерфейса
\ + 0	16	CLSID
\ +16	 4	количество методов
: Interface: ( род.интерфейс -- 'methods# ; ->bl)
  CREATE 
  BL WORD COUNT PAD CZMOVE  PAD clsid,
  clsid-len + @ HERE SWAP , ;

: Interface; ( 'methods# --)
  DROP ;

: Invoke  ( ... interface method# -- ... ) CELLS OVER @ + @ API-CALL ;

: Method:  ( 'methods# -- 'methods#; ->bl)
  CREATE DUP @ , DUP 1+!
  DOES> @ Invoke ;

: single-method ( method# -- ; ->bl)
  CREATE , DOES> @ Invoke ;

CREATE IID_NULL
" {00000000-0000-0000-0000-000000000000}" clsid, 0 ,

IID_NULL Interface: IID_IUnknown {00000000-0000-0000-C000-000000000046}
  Method: ::QueryInterface   ( *interface iid -- ? )
  Method: ::AddRef           ( -- cnt )
  Method: ::Release          ( -- cnt )
Interface;

: release ( iunk -- ) ::Release DROP ;

IID_IUnknown Interface: IID_IClassFactory {00000001-0000-0000-C000-000000000046}
  Method: CreateInstance ( *interface iid iunkouter -- ?) 
  Method: LockServer ( lock -- ?)
Interface;
