\ Ю. Жиловец (www.forth.org.ru/~yz)
\ 21.01.2001

\ Клянусь оформить все в виде модуля, как только команда по стандартизации
\ придет к консенсусу

REQUIRE  IID_NULL ~yz/lib/combase.f
REQUIRE  {        lib/ext/locals.f

4 == CLSCTX_LOCAL_SERVER
1 == CLSCTX_INPROC_SERVER 
CLSCTX_LOCAL_SERVER CLSCTX_INPROC_SERVER OR == CLSCTX_SERVER

IID_IUnknown interface IID_IDispatch {00020400-0000-0000-C000-000000000046}
  method ::GetTypeInfoCount ( pctinfo oid -- 0 | 1 )
  method ::GetTypeInfo      ( ppTInfo lcid iTInfo oid -- hresult )
  method ::GetIDsOfNames    ( rgDispId lcid cNames rgszNames riid oid -- hresult )
  method ::Invoke           ( puArgErr pExcepInfo pVarResult pDispParams wFlags lcid riid dispIdMember oid -- hresult )
interface-end

IID_IUnknown interface IID_IEnumVariant {00020404-0000-0000-C000-000000000046}
  method ::Next  ( count *var *returned -- hres )
  method ::Skip  ( count -- hres)
  method ::Reset ( -- hres )
  method ::Clone ( *enum )
interface-end

WINAPI: CoCreateInstance   OLE32.DLL
WINAPI: GetActiveObject    OLEAUT32.DLL

: create-object ( progid -- idisp 0 / error)
  clsid-len GETMEM DUP >R prog>clsid
  ?DUP IF R> FREEMEM EXIT THEN
  R@ ( clsid)
  0 >R RP@ SWAP >R 
  IID_IDispatch CLSCTX_SERVER 0 R> CoCreateInstance
  ?DUP IF RDROP ELSE R> 0 THEN
  R> FREEMEM ;

: get-object ( progid -- idisp 0 / error )
  { \ iunk clsid idisp }
  clsid-len GETMEM -> clsid   clsid prog>clsid
  ?DUP IF clsid FREEMEM EXIT THEN
  ^ iunk 0 clsid GetActiveObject  clsid FREEMEM
  ?DUP IF EXIT THEN
  ^ idisp IID_IDispatch iunk ::QueryInterface
  iunk release
  ?DUP IF EXIT THEN
  idisp 0 ;

: ?create-object ( progid -- idisp 0 / error)
  DUP get-object
  IF create-object ELSE PRESS 0 THEN ;

WINAPI: CreateBindCtx      OLE32.DLL
WINAPI: MkParseDisplayName OLE32.DLL

8 single-method ::BindToObject

: object-from-file ( z -- idisp 0 / error )
  { fname \ context imon idisp -- }
  ^ context 0 CreateBindCtx
  ?DUP IF EXIT THEN
  fname >unicodebuf -> fname
  ^ imon 0 >R RP@ fname context MkParseDisplayName
  RDROP fname FREEMEM
  ?DUP IF context release EXIT THEN
  ^ idisp IID_IDispatch 0 context imon ::BindToObject
  imon release
  context release
  ?DUP 0= IF idisp 0 THEN ;

-1 == unknown-id
unknown-id == dispid_unknown

: name>dispid ( z idisp -- id / unknown-id ) 
  { idisp \ id }
  >unicodebuf >R RP@ >R 
  ^ id 0 ( locale_system_default) 1 R> IID_NULL
  idisp ::GetIDsOfNames IF unknown-id ELSE id THEN
  R> FREEMEM ;

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
13 == _unk

1 == dispatch_method
2 == dispatch_propertyget
4 == dispatch_propertyput

-3 == dispid_propertyput

WINAPI: VariantInit    OLEAUT32.DLL
WINAPI: VariantClear   OLEAUT32.DLL
WINAPI: SysAllocString OLEAUT32.DLL
WINAPI: SysFreeString  OLEAUT32.DLL

: make-variant ( -- var)
  variant-len GETMEM DUP VariantInit DROP ;

: drop-variant ( var -- )
  DUP VariantClear DROP FREEMEM ;

: variant@ ( var -- value/dvalue type) 
  DUP >R :var-value R@ :var-type W@ CASE
  _char   OF C@ ENDOF
  _word   OF W@ ENDOF
  _bool   OF W@ 0= 0= ENDOF
  _double OF 2@ ENDOF
  _currency OF 2@ ENDOF
  _date     OF 2@ ENDOF
  _str OF @ unicode>buf ENDOF
  _obj OF @ DUP ::AddRef DROP ENDOF
  _unk OF @ DUP ::AddRef DROP ENDOF
    DROP @
  END-CASE
  R> :var-type W@ ;

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

0
CELL -- :args
CELL -- :names
CELL -- :args#
CELL -- :names#
== arglist-len

: make-varlist ( -- varlist) 
  20 variant-len * GETMEM ;
: drop-varlist ( varlist var# -- )
  OVER >R OVER + SWAP ?DO
    I VariantClear DROP
  variant-len +LOOP
  R> FREEMEM ;

: make-namelist ( -- ) \ на самом деле создает "список" из одной ячейки
  \ именованные аргументы делать не хочу - возни много, а пользы никакой
  CELL GETMEM ;

: make-arglist ( -- arglist)
  arglist-len GETMEM DUP arglist-len ERASE ;
: drop-arglist ( arglist --)
  DUP :args# @ 0= ( пустой список аргументов?) IF DROP EXIT THEN 
  DUP :names @ ?DUP IF FREEMEM THEN
  DUP :args @ OVER :args# @ drop-varlist 
  FREEMEM ;
 
CREATE arg() 0 , 0 , 0 , 0 ,

: ?resize-varlist ( arglist -- )
  >R
  R@ :args# @ DUP 20 MOD 0= SWAP 0 <> AND IF
    R@ :args# @ 20 + variant-len * R@ :args @ SWAP RESIZE THROW
    R@ :args !
  THEN
  RDROP ;
: next-var ( arglist -- nextvar)
  >R
  R@ ?resize-varlist
  R@ :args# @ variant-len * R@ :args @ +
  R> :args# 1+! ;
: arg(  -1 ;
: )arg ( -1 ... -- arglist)
 { \ arglist }
 make-arglist -> arglist   make-varlist arglist :args !
 BEGIN
 DUP -1 <> WHILE
   arglist next-var variant!
 REPEAT DROP
 arglist ;

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

USER-CREATE excepinfo excepinfo-len USER-ALLOT

: OLE-ERROR ( -- description errcode)
\ предполагаю, что ошибка должна возвращаться сразу, без всяких извращений
\ с отложенными вызовами. Насколько я понял, отложенные вызовы работают 
\ только с объектами, находящимися в том же процессе.
  excepinfo :bstrDescription @ DUP IF unicode>buf THEN
  excepinfo :retvalue @ excepinfo :wCode W@ +
  excepinfo :bstrSource SysFreeString DROP
  excepinfo :bstrDescription SysFreeString DROP
  excepinfo :bstrHelpFile SysFreeString DROP
  excepinfo excepinfo-len ERASE
;

\ ::Invoke id,IID_NULL,locale,flags,*args,*result,*error,*errarg

0x80020006 == disp_e_unknownname

: (PROP@) ( dispid idisp -- val type 0 / errarg# error )
  { idisp \ errarg# result }
  >R  make-variant -> result 
  ^ errarg# excepinfo result arg() dispatch_propertyget dispatch_method OR 0 IID_NULL R> 
  idisp ::Invoke
  ?DUP IF result drop-variant errarg# SWAP EXIT THEN
  result variant@ 0  result drop-variant ;

: PROP@ ( z idisp -- val type 0 / errarg# error )
  SWAP OVER name>dispid ( idisp id/-1) 
  DUP -1 =  IF PRESS disp_e_unknownname EXIT THEN
  ( idisp id) SWAP (PROP@) ;

: PROP[]@ ( arglist z idisp -- val type 0 / errarg# error )
  { idisp \ errarg# arglist result }
  SWAP -> arglist  
  idisp name>dispid DUP -1 = 
  IF disp_e_unknownname EXIT THEN  >R  
  make-variant -> result
  ^ errarg# excepinfo result arglist dispatch_propertyget dispatch_method OR
  0 IID_NULL R> idisp ::Invoke  arglist drop-arglist
  ?DUP IF result drop-variant errarg# SWAP EXIT THEN
  result variant@ 0  result drop-variant ;

: PROP! ( val type z idisp -- errarg# error / 0 )
  { idisp \ errarg# arglist }
  idisp name>dispid DUP -1 = 
  IF drop-valtype disp_e_unknownname EXIT THEN  >R
  make-arglist -> arglist
  1 arglist :args# !
  make-varlist DUP arglist :args ! variant!
  1 arglist :names# !
  make-namelist DUP arglist :names !  dispid_propertyput SWAP !
  ^ errarg# excepinfo 0 arglist dispatch_propertyput 0 IID_NULL R> 
  idisp ::Invoke arglist drop-arglist
  DUP IF errarg# SWAP THEN ;

: PROP[]! ( val type arglist z idisp -- errarg# error / 0 )
  { idisp \ errarg# arglist }
  SWAP -> arglist  
  idisp name>dispid DUP -1 = 
  IF drop-valtype disp_e_unknownname EXIT THEN  >R
  arglist ?resize-varlist
  arglist :args @ DUP variant-len + arglist :args# @ variant-len * CMOVE>
  arglist :args @ variant!
  arglist :args# 1+!
  1 arglist :names# !
  make-namelist DUP arglist :names !  dispid_propertyput SWAP !
  ^ errarg# excepinfo 0 arglist dispatch_propertyput 0 IID_NULL R> 
  idisp ::Invoke  arglist drop-arglist
  DUP IF errarg# SWAP THEN ;

: METHOD ( arglist z idisp -- errarg# error / 0 )
  { idisp \ errarg# arglist }
  SWAP -> arglist
  idisp name>dispid DUP -1 =
  IF disp_e_unknownname EXIT THEN  >R
  ^ errarg# excepinfo 0 arglist dispatch_method 0 IID_NULL R>
  idisp ::Invoke  arglist drop-arglist
  DUP IF errarg# SWAP THEN ;

: METHOD> ( arglist z idisp -- val type 0 / errarg# error )
  { idisp \ errarg# arglist result }
  SWAP -> arglist
  idisp name>dispid DUP -1 =
  IF disp_e_unknownname EXIT THEN  >R
  make-variant -> result
  ^ errarg# excepinfo result arglist dispatch_method 0 IID_NULL R>
  idisp ::Invoke  arglist drop-arglist
  ?DUP IF result drop-variant errarg# SWAP EXIT THEN
  result variant@ 0  result drop-variant ;

\ --------------------------- FOREACH ... NEXT

-4 == dispid_newenum

\ на стеке возвратов во время цикла хранятся:
\ LEAVE-addr, enumerator, variant

: OBJ-I ( -- val type)
  4 RP+@ variant@ ;

: OBJ-J ( -- val type)
  16 RP+@ variant@ ;

: LEAVE-FOREACH
  RDROP  R> FREEMEM  R> release ;

: collection? ( obj -- ? )
  dispid_newenum SWAP (PROP@) PRESS
  IF FALSE ELSE release TRUE THEN ;

: (get-enumerator) ( obj -- 0 / ienum ienum)
  { \ unk enum }
  dispid_newenum SWAP (PROP@) IF DROP 0 EXIT THEN
  DROP -> unk
  ^ enum IID_IEnumVariant unk ::QueryInterface
  unk release
  IF 0 EXIT THEN
  enum DUP ; 

: (next)  ( var enum -- 0 ok / 1 no more) 
  >R >R 0 R> 1 R> ::Next ;

\ шёїюфэр  тхЁёш  ~yz
\ : FOREACH ( compile: -- a1 a2 a3 10; obj -- )
\   ?COMP
\   POSTPONE (get-enumerator)
\   HERE ?BRANCH, >MARK
\   0 LIT, HERE CELL-
\   POSTPONE >R POSTPONE >R
\   POSTPONE make-variant POSTPONE >R
\   <MARK
\   POSTPONE R@
\   4 LIT, POSTPONE RP+@
\   POSTPONE (next)
\   HERE ?BRANCH, >MARK
\   POSTPONE LEAVE-FOREACH
\   >RESOLVE1
\   10
\ ; IMMEDIATE

\ тхЁёш  ~day 22.06.2001:

: (MLIT,) R> DUP CELL+ >R @ ;
:  MLIT, POSTPONE (MLIT,) , ;

: FOREACH ( compile: -- a1 a2 a3 10; obj -- )
  ?COMP
  POSTPONE (get-enumerator)
  HERE ?BRANCH, >MARK
  0 MLIT, HERE CELL-
  POSTPONE >R POSTPONE >R
  POSTPONE make-variant POSTPONE >R
  <MARK
  POSTPONE R@
  4 LIT, POSTPONE RP+@
  POSTPONE (next)
  HERE ?BRANCH, >MARK
  POSTPONE LEAVE-FOREACH
  >RESOLVE1
  10
; IMMEDIATE


: NEXT ( compile: a1 a2 a2 10 -- ; -- )
  ?COMP
  10 <> ABORT" NEXT без FOREACH" 
  POSTPONE R@
  POSTPONE VariantClear
  POSTPONE DROP
  BRANCH,
  HERE SWAP !
  >RESOLVE1
; IMMEDIATE

\ ----------------------------------------- ::

USER object
USER location
USER call
USER-CREATE str  256 USER-ALLOT
USER-CREATE last-prop 64 USER-ALLOT
USER-CREATE token 64 USER-ALLOT
USER pos
USER indices
VECT ?OLE-ERROR

: skip-spaces ( --)
  BEGIN 
    pos @ C@ BL = 
  WHILE
    pos 1+!
  REPEAT ;

: traverse ( c -- )
  { match \ tokpos }
  token -> tokpos
  BEGIN
    pos @ C@ DUP match <> SWAP 0 <> AND
  WHILE
    pos @ C@ tokpos C!
    pos 1+!  ^ tokpos 1+!
  REPEAT 
  0 tokpos C!
  match BL <> IF pos 1+! THEN 
;

: next-token ( -- 0/-1/"[" )
  skip-spaces
  pos @ C@ CASE
  c: @ OF c: @ call ! 0 ENDOF
  c: ! OF c: ! call ! 0 ENDOF
  c: > OF c: > call ! 0 ENDOF
  0 OF 0 ENDOF
  c: [ OF pos 1+! c: ] traverse c: [ ENDOF 
  \ ]
  DROP BL traverse -1
  END-CASE ;

: ?prop@ 
  indices @ ?DUP 
  IF last-prop object @ PROP[]@ indices 0! ELSE last-prop object @ PROP@ THEN ;

: ?prop!
  indices @ ?DUP 
  IF last-prop object @ PROP[]! ELSE last-prop object @ PROP! THEN ;

: resolve-object ( -- 0 / error)
  ?prop@   object @ release
  ?DUP IF PRESS EXIT THEN
  ( idisp? _obj?) DUP _obj <> 
    IF drop-valtype 0x80020005 ( disp_e_typemismatch) EXIT THEN
  DROP object !  0
;  

: find-char ( char pos -- pos')
  SWAP >R
  BEGIN
    DUP C@ DUP R@ <> SWAP 0<> AND 
  WHILE 
    1+ 
  REPEAT RDROP ;

: parse-indices
  { \ p }
  token -> p
  BEGIN
    p C@ CASE
      c: , OF ^ p 1+! ENDOF
      0 OF EXIT ENDOF
      c: " OF 
        ^ p 1+!
        p _str
        c: " p find-char -> p
        0 p C!
      ENDOF
        DROP
        p
        c: , p find-char -> p
        p OVER - EVALUATE _int
      END-CASE
  AGAIN ;

: (::) ( [val type] idisp z -- [val type] 0 / where err)
  str ZMOVE  ( соблазнительно было бы работать с переданной строкой)
  ( никуда ее не копируя, но, увы, стандарт запрещает) 
  str pos !
  DUP ::AddRef DROP object !  -1 location !  
  call 0!  indices 0!  last-prop 0!
  BEGIN
    next-token ?DUP 
  WHILE
    c: [ = IF  \ ]
      arg(
      parse-indices
      )arg indices !
    ELSE 
      last-prop @ IF 
        resolve-object ?DUP IF location @ SWAP EXIT THEN
      THEN
      token last-prop ZMOVE
      location 1+!
    THEN
  REPEAT
  call @ CASE
  c: @ OF ?prop@ ENDOF
  c: ! OF ?prop! ENDOF
  c: > OF last-prop object @ METHOD> ENDOF
  DROP last-prop object @ METHOD
  END-CASE
  object @ release
  ( [val type] 0 / errarg@ err )
  DUP IF PRESS location @ SWAP THEN
;

: :: ( [val type] idisp -- [val type] ; ->eol )
  ?COMP
  POSTPONE ALITERAL
  1 PARSE 
  HERE DUP >R ESC-CZMOVE R> ZLEN 1+ ALLOT 
  POSTPONE (::)
  POSTPONE ?OLE-ERROR
; IMMEDIATE

: ?ole-error ( ... 0 / where err)
  ?DUP 0= IF EXIT THEN
  ." Вызов " c: " EMIT str .ansiz c: " EMIT CR
  ." Аргумент " SWAP . ."  Ошибка " 
  DUP 0x80020009 ( disp_e_exception) = IF
  DROP OLE-ERROR .H ?DUP IF DUP .ansiz FREEMEM THEN CR
  ELSE 
   .err
  THEN
  ABORT
;  

' ?ole-error TO ?OLE-ERROR
