\  лиент автоматизации. ¬торой вариант.
\ ё. ∆иловец, 27.03.2002

\ –азногласи€ с оптимизатором в слове FOREACH
\ устранены ћ. √аcсаненко и ƒ. якимовым

\ + строки - имена свойств и методов { }

REQUIRE {          lib/ext/locals.f
REQUIRE IID_NULL   ~yz/lib/uuid.f
REQUIRE IDispatch  ~yz/lib/idispatch.f
REQUIRE variant!   ~yz/lib/variant.f

\ -----------------------------------------------

WINAPI: CoCreateInstance   OLE32.DLL
WINAPI: GetActiveObject    OLEAUT32.DLL

: CreateObject ( progid -- idisp 0 / error)
  clsid-len GETMEM DUP >R prog>clsid
  ?DUP IF R> FREEMEM EXIT THEN
  R@ ( clsid)
  0 >R RP@ SWAP >R 
  IID_IDispatch clsctx_server 0 R> CoCreateInstance
  ?DUP IF RDROP ELSE R> 0 THEN
  R> FREEMEM ;

: GetObject ( progid -- idisp 0 / error )
  { \ iunk clsid idisp }
  clsid-len GETMEM -> clsid   clsid prog>clsid
  ?DUP IF clsid FREEMEM EXIT THEN
  ^ iunk 0 clsid GetActiveObject  clsid FREEMEM
  ?DUP IF EXIT THEN
  ^ idisp IID_IDispatch iunk ::QueryInterface
  iunk release
  ?DUP IF EXIT THEN
  idisp 0 ;

: ?CreateObject ( progid -- idisp 0 / error)
  DUP GetObject
  IF CreateObject ELSE PRESS 0 THEN ;

WINAPI: CreateBindCtx      OLE32.DLL
WINAPI: MkParseDisplayName OLE32.DLL

8 single-method ::BindToObject

: ObjectFromFile ( z -- idisp 0 / error )
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

\ --------------------------------------------
: name>dispid ( zname idisp -- id 0 / error ) 
  { idisp \ id }
  >unicodebuf >R RP@ >R 
  ^ id 0 ( locale_system_default) 1 R> IID_NULL
  idisp ::GetIDsOfNames DUP 0= IF id SWAP THEN
  R> FREEMEM ;


VECT ?AUERROR
\ -------------------------------------

WORDLIST == [[wordlist]]
WORDLIST == (wordlist)

USER-CREATE last-name 100 USER-ALLOT
USER first-object
USER last-object

USER-CREATE result variant-len USER-ALLOT
USER errarg
USER arglist  arglist 0!
USER mark
USER this-var
USER only-method  only-method 0!

CREATE arg() 0 , 0 , 0 , 0 ,
CREATE one-name dispid_propertyput ,

USER-CREATE excepinfo excepinfo-len USER-ALLOT

USER-VALUE LAST-TYPE

\ ќтводим место под arglist, потом дл€ 30 вариантов
\ Ќе верю, что какой-нибудь метод требует больше, чем 30 аргументов
30 variant-len * arglist-len + == alist-len

: new-arglist ( -- )
  alist-len GETMEM arglist !
  arglist @ arglist-len ERASE
  arglist @ alist-len + variant-len - this-var !
  this-var @ init-variant
;

: next-var ( -- )
  variant-len this-var -!
  this-var @ init-variant
  arglist @ :args# 1+! ;

: end-arglist ( -- )
  this-var @ variant-len + arglist @ :args !
;

: ?move-to-var ( -- )
  DEPTH mark @ -
  DUP 0 4 WITHIN 0= IF DROP DISP_E_BADVARTYPE ?AUERROR THEN
  DUP 1 = IF _cell SWAP THEN
  IF this-var @ variant! THEN
;  

: free-arglist ( -- )
  { \ alist }
  arglist @ 0= IF EXIT THEN
  arglist @ TO alist
  alist :args# @ 0 ?DO
    I variant-len * alist :args @ + clear-variant
  LOOP
  alist FREEMEM
  arglist 0! ;

: mark-stack  DEPTH mark ! ;

: (prop@) ( id obj -- errcode)
  { id obj }
  errarg 0!
  excepinfo excepinfo-len ERASE
  result init-variant
  errarg excepinfo result
  arglist @ IF arglist @ ELSE arg() THEN
  dispatch_method only-method @ 0= IF dispatch_propertyget OR THEN
  0 ( lc_system_default) IID_NULL id obj ::Invoke
  free-arglist
  only-method 0!
;

: PROP@ ( name obj -- res / )
  { id obj }
  id obj name>dispid ?AUERROR TO id
  id obj (prop@) ?AUERROR
  result :var-type W@ _empty <> IF result variant@ ELSE _empty THEN TO LAST-TYPE
  result clear-variant
;

: PROP! ( name obj -- )
  { id obj }
  id obj name>dispid ?AUERROR TO id
  errarg 0!
  excepinfo excepinfo-len ERASE
  errarg excepinfo 0
  arglist @ dispatch_propertyput
  0 ( lc_system_default) IID_NULL id obj ::Invoke ?AUERROR
  free-arglist
;
  
: resolve-last-name
  last-name last-object @ PROP@ ( new-obj)
  last-object @ first-object @ <> IF last-object @ release THEN
  last-object !
  LAST-TYPE _obj <> IF DISP_E_TYPEMISMATCH ?AUERROR THEN
;

: new-name ( a n --)
  last-name C@ IF resolve-last-name THEN
  last-name CZMOVE
;


\ ---- компилируем в словарь [[wordlist]]

ALSO [[wordlist]] CONTEXT ! DEFINITIONS

: (]]) ( -- val/dval)
  last-name last-object @ PROP@
;

\ это слово выполн€етс€, если не было =
: ]] ( order... / -- val/dval / )
  SET-ORDER
  STATE @ IF
    POSTPONE (]])
  ELSE
    (]])
  THEN
; IMMEDIATE

: NOTFOUND ( a n -- )
  STATE @ IF
    [COMPILE] SLITERAL
    POSTPONE new-name
  ELSE
    new-name
  THEN
; IMMEDIATE

: { ( ... -- )
  \ временно вернем старый пор€док поиска, но добавим к нему словарь [[wordlist]]
  SET-ORDER ALSO [[wordlist]] CONTEXT !
; IMMEDIATE

: } ( a n -- ... )
  STATE @ IF
    POSTPONE new-name
  ELSE
    new-name
  THEN
  PREVIOUS GET-ORDER [[wordlist]] CONTEXT !
; IMMEDIATE


: (() 
  new-arglist
  mark-stack
;

: ( ( order... -- )
  \ вернем старый пор€док поиска, но добавим к нему словарь (wordlist)
  SET-ORDER ALSO (wordlist) CONTEXT !
  STATE @ IF
    POSTPONE (()
  ELSE
    (()
  THEN
; IMMEDIATE

: (=) \ -- 
  arglist @ 0= IF new-arglist THEN
  arglist @ :names# 1+!
  one-name arglist @ :names !
;
: = \ order... -- 
  \ вернем старый пор€док поиска, но добавим к нему словарь (wordlist)
  SET-ORDER ALSO (wordlist) CONTEXT !
  STATE @ IF
    POSTPONE (=)
  ELSE
    (=)
  THEN
; IMMEDIATE

: *  \ --
  TRUE only-method ! ;

PREVIOUS DEFINITIONS

\ ---- кончили компилировать в [[wordlist]]

\ ---- компилируем в словарь (wordlist)

ALSO (wordlist) CONTEXT ! DEFINITIONS

: ())
  ?move-to-var
  next-var end-arglist
;

: ) ( -- order...)
  STATE @ IF
    POSTPONE ())
  ELSE
    ())
  THEN
  PREVIOUS GET-ORDER
  \ сделаем видимым только [[wordlist]]
  [[wordlist]] CONTEXT !
; IMMEDIATE

: , ( ... -- )
  ?move-to-var  next-var  mark-stack
;

: TRUE ( -- val type)  -1 _bool ;
: FALSE ( -- val type)  0 _bool ;

: NIL ( -- val type) DISP_E_PARAMNOTFOUND _err ;

: " ( -- val type )
  [COMPILE] "
  STATE @ IF
    POSTPONE _str
  ELSE
    _str
  THEN
; IMMEDIATE

: STRING ( a n -- )
  { \ [ 256 ] buf }
  buf CZMOVE buf _str this-var @ variant! ;

: ASCIIZ ( z -- )
  _str this-var @ variant! ;

: "" ( -- val/dval )  "" _str ;

: $ ( n -- )
  _cell this-var @ variant!
  this-var @ _currency coerce-variant ?AUERROR
;

: >DATE ( z _str -- )
  this-var @ variant!
  this-var @ _date coerce-variant ?AUERROR
;

: OBJECT ( obj -- )
  DUP ::AddRef DROP _obj this-var @ variant!
;

: (=]]) ( ... -- )
  ?move-to-var  next-var
  end-arglist
  last-name last-object @ PROP!
  _empty TO LAST-TYPE
;

\ это слово выполн€етс€, если было =
: ]] 
  STATE @ IF
    POSTPONE (=]])
  ELSE
    (=]])
  THEN
  PREVIOUS
; IMMEDIATE

PREVIOUS DEFINITIONS

\ ---- кончили компилировать в (wordlist)

: ([[) ( obj -- )
  DUP first-object ! last-object !
  last-name 0!
;  
: [[ ( -- order... )
  STATE @ IF
    POSTPONE ([[)
  ELSE
    ([[)
  THEN
  \ сделаем видимым только [[wordlist]]
  GET-ORDER  [[wordlist]] CONTEXT !
; IMMEDIATE

\ --------------------------- FOREACH ... NEXT

: collection? ( obj -- ? )
  dispid_newenum SWAP (prop@) IF FALSE EXIT THEN
  result :var-type @ _unk =
  result clear-variant ;

\ на стеке возвратов во врем€ цикла хран€тс€:
\ LEAVE-addr, enumerator, variant

: (get-enumerator) ( obj -- 0 / ienum ienum)
  { \ unk enum }
  dispid_newenum SWAP (prop@) IF FALSE EXIT THEN
  result :var-value @ TO unk
  ^ enum IID_IEnumVariant unk ::QueryInterface
  unk release
  IF FALSE EXIT THEN
  enum DUP ; 

: (next)  ( var enum -- 0 ok / 1 no more) 
  >R >R 0 R> 1 R> ::Next ;

: (MLIT,)   R> DUP @ >R CELL+ >R ;

: make-variant ( -- var)
  variant-len GETMEM DUP init-variant ;

: OBJ-I ( -- val )
  4 RP+@ variant@ TO LAST-TYPE ;

: OBJ-J ( -- val )
  16 RP+@ variant@ TO LAST-TYPE ;

: LEAVE-FOREACH
  RDROP  R> FREEMEM  R> release ;

: FOREACH ( compile: -- adr1 adr2 adr3 "fore"; obj -- )
  ?COMP
  POSTPONE (get-enumerator)
  HERE ?BRANCH, >MARK
  POSTPONE (MLIT,) 0 , HERE CELL-
  POSTPONE >R
  POSTPONE make-variant POSTPONE >R
  <MARK
  POSTPONE R@
  4 LIT, POSTPONE RP+@
  POSTPONE (next)
  HERE ?BRANCH, >MARK
  POSTPONE LEAVE-FOREACH
  >RESOLVE1
  CELL" FORE"
; IMMEDIATE


: NEXT ( compile: adr1 adr2 adr3 " fore" -- ; -- )
  ?COMP
  CELL" FORE" <> ABORT" NEXT без FOREACH"
  POSTPONE R@
  POSTPONE clear-variant
  BRANCH,
  HERE SWAP !
  >RESOLVE1
; IMMEDIATE

\ -----------------------------------------
: ?type-error ( 0/error -- )
  ?DUP 0= IF EXIT THEN
  CR ." Error: " DUP .err
  ." call: " c: " EMIT last-name .ansiz c: " EMIT ." , argument: " errarg  @ . CR
  DISP_E_EXCEPTION = IF
    ." Error code: " excepinfo :wCode @ excepinfo :retvalue @ + .H CR
    excepinfo :bstrSource @ ?DUP IF ." Source: " DUP .unicode SysFreeString CR DROP THEN
    excepinfo :bstrDescription @ ?DUP IF ." Description: " DUP .unicode SysFreeString DROP CR THEN
    excepinfo :bstrHelpFile @ ?DUP IF SysFreeString DROP THEN
  THEN
  ABORT
;

' ?type-error TO ?AUERROR
