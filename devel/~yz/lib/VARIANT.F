\ Работа с вариантами
\ Ю. Жиловец, 27.03.2002

0
2 -- :var-type
6 -- :var-reserved
8 -- :var-value
== variant-len

( значения позаимствованы из wintypes.h)
 0 == _empty
 1 == _null
17 == _char     _char   == _ui1
 2 == _word     _word   == _i2
 3 == _cell     _cell   == _int
 4 == _float    _float  == _r4
 5 == _double   _double == _r8
11 == _bool
 6 == _currency
 7 == _date
 8 == _str
 9 == _obj
10 == _err
13 == _unk

: byref  0x4000 OR ;

WINAPI: VariantInit       OLEAUT32.DLL
WINAPI: VariantClear      OLEAUT32.DLL
WINAPI: VariantChangeType OLEAUT32.DLL
WINAPI: VariantCopy       OLEAUT32.DLL
WINAPI: SysAllocString    OLEAUT32.DLL
WINAPI: SysFreeString     OLEAUT32.DLL

: init-variant ( var -- ) VariantInit DROP ;
: clear-variant ( var -- ) VariantClear DROP ;

: variant@ ( var -- value/dvalue type) 
  DUP >R :var-value R@ :var-type W@ 0xFF AND CASE
  _char   OF C@ ENDOF
  _word   OF W@ ENDOF
  _bool   OF W@ 0= 0= ENDOF
  _double OF 2@ ENDOF
  _currency OF 2@ ENDOF
  _date     OF 2@ ENDOF
  _str OF @ unicode>buf ENDOF
  _obj OF @ DUP IF DUP ::AddRef DROP THEN ENDOF
  _unk OF @ DUP ::AddRef DROP ENDOF
    DROP @
  END-CASE
  R> :var-type W@ 0xFF AND 
;

: variant! ( value/dvalue type var -- ) 
  DUP VariantInit DROP
  2DUP :var-type W!
  :var-value SWAP CASE
  _char OF C! ENDOF
  _word OF W! ENDOF
  _bool OF W! ENDOF
  _double OF 2! ENDOF
  _currency OF 2! ENDOF
  _date OF 2! ENDOF
  _str OF >R >unicodebuf DUP SysAllocString SWAP FREEMEM R> ! ENDOF
     DROP !
  END-CASE ;

: drop-valtype ( value type --)
  CASE
  _double OF 2DROP ENDOF
  _currency OF 2DROP ENDOF
  _date OF 2DROP ENDOF
  2DROP
  END-CASE ;

: coerce-variant ( var newtype -- ?)
  SWAP 0 SWAP DUP VariantChangeType ;

: copy-variant ( var1 var2 -- )
  VariantCopy DROP ;

: >bstr ( z -- bstr) >unicodebuf DUP SysAllocString SWAP FREEMEM ;
