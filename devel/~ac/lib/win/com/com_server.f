REQUIRE CLSID, ~ac/lib/win/com/com.f

0x80020006 CONSTANT DISP_E_UNKNOWNNAME
0x8002000E CONSTANT DISP_E_BADPARAMCOUNT
0x80020009 CONSTANT DISP_E_EXCEPTION
         4 CONSTANT DISPATCH_PROPERTYPUT

: Class. ( oid -- oid )
  CR DUP @ WordByAddr TYPE R@ WordByAddr TYPE SPACE
;

: Class: ( implement_interface "name" "clsid" -- current class_int )
  CREATE 
    HERE SWAP
    BL WORD COUNT CLSID, 
    DUP ,               \ предок (точнее IID реализуемого интерфейса)
    Methods#            \ к-во методов предка
    DUP ,               \ свои методы (к-во)
    LATEST ,            \ своё имя
    HERE CELL+ ,        \ oid класса (указатель на Vtable)
    1+ CELLS HERE SWAP DUP ALLOT ERASE     \ VTABLE
    -1 ,
    GET-CURRENT WORDLIST
    LATEST OVER CELL+ ! \ для осмысленного представления в ORDER
    SET-CURRENT SWAP
  DOES> 7 CELLS + ( oid )
;

: Class; DROP SET-CURRENT ;

: Class ( oid -- class_int ) 7 CELLS - ;

: SpfClassName ( oid -- addr u )
  \ здесь oid - com'овский указатель на указатель vtable
  \ т.е. тот, что первым параметром в вызовах
  @ 2 CELLS - @ COUNT
;
: SpfClassWid ( oid -- wid )
  @ DUP 3 CELLS - @ \ methods#
  1+ CELLS + \ пропустили vtable
  CELL+ \ пропустили -1 в структуре Class: выше
  CELL+ \ пропустили voc-list
;
: ComClassIID ( oid -- addr u )
  @ 4 CELLS - @
;

0
CELL -- c.VTBL
CELL -- c.MAGIC  \ SPFR
CELL -- c.REFCNT \ счетчик ссылок AddRef/Release
CONSTANT /COM_OBJ \ вдруг когда-нибудь придется добавлять служ.инф.

: NewComObj ( extra_size class_oid -- oid )
\ Создать объект заданного класса с дополнительной памятью размера size.
\ Минимально рабочий COM-объект (extra_size=0) требует память только
\ для указателя на vmt (который тот же что и у нашего объекта "класс").
\ Наример: /BROWSER SPF.IWebBrowserEvents2 NewComObj
( Мы можем создавать подобные объекты только для классов, интерфейсы которых
  реализуем в своей программе, т.е. для которых являемся COM-сервером.)
  @ SWAP /COM_OBJ + ALLOCATE THROW DUP >R c.VTBL !
  S" SPFR" DROP @ R@ c.MAGIC !
  R>
;
: IsMyComObject? ( oid -- flag )
  c.MAGIC @ S" SPFR" DROP @ =
;
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
