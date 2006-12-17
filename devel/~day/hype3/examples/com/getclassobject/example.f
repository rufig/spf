( Example of COM server that exists in the same apartment that a client is
  so there is no need to register typelib, custom interface and so on )

REQUIRE WL-MODULES ~day\lib\includemodule.f

NEEDS   ~day\hype3\com.f
WARNING 0!
NEEDS   ~ac\lib\win\com\com.f

\ TRUE TO COM-TRACE

IUnknown ISUBCLASS IForth {9F7A5561-8BD8-4B0D-93EC-A79A19C99330}

: Test ." Test method called" S_OK ; METHOD

;ICLASS

UUID:: ComInit COM-THROW

IForth AppClassFactory setClass

AppClassFactory registerLocalServer COM-THROW
.( Local com server registered OK ) CR

VARIABLE vClass

: GetClassObject ( -- ior )
    vClass
    AppClassFactory clsid
    0
    CLSCTX_LOCAL_SERVER
    IForth ^ clsid
    CoGetClassObject
;

IID_IUnknown Interface: IID_Forth {9F7A5561-8BD8-4B0D-93EC-A79A19C99330}
    Method: ::Test ( -- hresult )
Interface;

VARIABLE vForth

CR 
.( Create instance of IForth manually ) CR
GetClassObject COM-THROW

.( Got class ) vClass @ . .( AppClassFactory object is ) AppClassFactory iself . CR

vForth IForth ^ clsid 0 vClass @ ::CreateInstance COM-THROW

.( Call test method: )
vForth @ ::Test COM-THROW

CR .( Delete created object )
vForth @ ::Release COM-THROW
vForth 0!

AppClassFactory revokeLocalServer COM-THROW .( Local server destroyed OK )

UUID:: ComDestroy