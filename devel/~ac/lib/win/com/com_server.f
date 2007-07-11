REQUIRE CLSID, ~ac/lib/win/com/com.f

0x80020006 CONSTANT DISP_E_UNKNOWNNAME
0x8002000E CONSTANT DISP_E_BADPARAMCOUNT
0x80020009 CONSTANT DISP_E_EXCEPTION
         4 CONSTANT DISPATCH_PROPERTYPUT

: Class. ( oid -- oid )
  CR DUP WordByAddr TYPE R@ WordByAddr TYPE SPACE
;

: Class: ( implement_interface "name" "clsid" -- current class_int )
  CREATE 
    HERE SWAP
    BL WORD COUNT CLSID, 
    DUP ,               \ предок
    Methods#            \ к-во методов предка
    DUP ,               \ свои методы (к-во)
    LATEST ,            \ своё имя
    HERE CELL+ ,        \ oid класса (указатель на Vtable)
    1+ CELLS HERE SWAP DUP ALLOT ERASE     \ VTABLE
    -1 ,
    GET-CURRENT WORDLIST SET-CURRENT SWAP
  DOES> 7 CELLS + ( oid )
;

: Class; DROP SET-CURRENT ;

: Class ( oid -- class_int ) 7 CELLS - ;

: Extends ( class_int -- class_int )
  DUP
  ' EXECUTE             \ oid класса, из которого копируем VTABLE
  DUP 2 CELLS - @ CELLS \ сколько копировать
  ( class_int class_int oid n )
  SWAP @                \ откуда копировать
  ROT 8 CELLS +         \ куда
  ROT MOVE
;

: ToVtable ( class_int xt -- class_int )
  OVER >R
  LAST @ FIND
  IF >BODY @ ( номер метода в VTABLE )
     8 + \ смещение VTABLE в определении класса
     CELLS R> + !
  ELSE -321 THROW THEN
;
: METHOD ( class_int -- class_int )
  LAST @ NAME> TASK ToVtable
;
