\ Интерфейс IDispatch, структуры и константы
\ Ю. Жиловец, 23.02.2002

REQUIRE IID_IUnknown ~yz/lib/interfaces.f

IID_IUnknown Interface: IID_IDispatch {00020400-0000-0000-C000-000000000046}
  Method: ::GetTypeInfoCount ( pctinfo oid -- ? )
  Method: ::GetTypeInfo      ( ppTInfo lcid iTInfo oid -- ? )
  Method: ::GetIDsOfNames    ( dispIds lcid # names iid_null -- ? )
  Method: ::Invoke           ( puArgErr pExcepInfo pVarResult pDispParams wFlags lcid riid dispIdMember oid -- ? )
Interface;

IID_IUnknown Interface: IID_IEnumVariant {00020404-0000-0000-C000-000000000046}
  Method: ::Next  ( count *var *returned -- hres )
  Method: ::Skip  ( count -- hres)
  Method: ::Reset ( -- hres )
  Method: ::Clone ( *enum )
Interface;

0x80020003 == DISP_E_MEMBERNOTFOUND
0x80020004 == DISP_E_PARAMNOTFOUND
0x80020005 == DISP_E_TYPEMISMATCH
0x80020006 == DISP_E_UNKNOWNNAME
0x80020007 == DISP_E_NONAMEDARGS
0x80020008 == DISP_E_BADVARTYPE
0x80020009 == DISP_E_EXCEPTION
0x8002000E == DISP_E_BADPARAMCOUNT
0x8002000F == DISP_E_PARAMNOTOPTIONAL

1 == dispatch_method
2 == dispatch_propertyget
4 == dispatch_propertyput

-1 == dispid_unknown
-3 == dispid_propertyput
-4 == dispid_newenum
-5 == dispid_evaluate

0
CELL -- :args
CELL -- :names
CELL -- :args#
CELL -- :names#
== arglist-len

0 
2    -- :wCode	 	 \ An error code describing the error.
2    -- :wReserved
CELL -- :bstrSource	 \ Source of the exception.
CELL -- :bstrDescription \ Textual description of the error.
CELL -- :bstrHelpFile	 \ Help file path.
CELL --	:dwHelpContext 	 \ Help context ID.
CELL -- :pvReserved	 
CELL -- :pfnDeferredFillIn
CELL -- :retvalue
== excepinfo-len
