REQUIRE params@       ~ac/lib/win/com/variant.f 
REQUIRE {             lib/ext/locals.f

IID_IUnknown Interface: IID_IEnumVariant {00020404-0000-0000-C000-000000000046}
  Method: ::Next  ( count *var *returned -- hres )
  Method: ::Skip  ( count -- hres)
  Method: ::Reset ( -- hres )
  Method: ::Clone ( *enum )
Interface;

: EnumVariant { xt ienum \ vax1 vav vax2 var n -- n }
\ vax1 vav vax2 var - для случая, если ::Next возвращает variant.
\ тогда в var получим тип VT_* (variant.f), а в vav - значение
  BEGIN
    0 ^ var 1 ienum ::Next 0=
  WHILE
    vav var xt EXECUTE
    n 1+ -> n
  REPEAT
  n
;

