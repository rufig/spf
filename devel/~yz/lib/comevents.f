\ Обработка событий COM
\ Ю. Жиловец, 5.04.2002

REQUIRE [[     ~yz/lib/automate.f
REQUIRE VTABLE ~yz/lib/vtable.f

VARIABLE comevents-trace  comevents-trace 0!

MODULE: COMevents

IID_IUnknown Interface: IID_IConnectionPointContainer {B196B284-BAB4-101A-B69C-00AA00341D07}
  Method: ::EnumConnectionPoints ( *ienum -- ?) 
  Method: ::FindConnectionPoint  ( *ipoint iid -- ?)
Interface;

IID_IUnknown Interface: IID_IConnectionPoint {B196B286-BAB4-101A-B69C-00AA00341D07}
  Method: ::GetConnectionInterface ( *iid -- ?)
  Method: ::GetConnectionPointContainer ( *iconnpoint -- ?)
  Method: ::Advise ( *unk *cookie -- ?)
  Method: ::Unadvise ( cookie -- ?)
  Method: ::EnumConnections ( *ienumconn -- ?)
Interface;

\ ---------------------------------

VARIABLE oconn-chain  oconn-chain 0!

0
CELL     -- :link    \ Поле связи: должно идти первым
CELL     -- :vtable  \ Указатель на таблицу функций. Должен идти вторым
CELL     -- :obj     \ Объект, к которому мы присоединились
CELL     -- :cpoint  \ Объект присоединения IConnectionPoint
CELL     -- :advise  \ Дескриптор присоединения
16 CELLS -- :guid    \ GUID присоединения
CELL     -- :count   \ Счетчик таблицы обработчиков
\ оставляем место для 40 событий от каждого объекта. Должно хватить.
\ формат таблицы: id метода, xt вызываемого слова
40 2 CELLS * -- :events
== oconn-len

\ ---------------------------------

WINAPI: StringFromIID OLE32.DLL
WINAPI: CoAddRefServerProcess  OLE32.DLL
WINAPI: CoReleaseServerProcess OLE32.DLL

: find-dispid ( dispid oconn -- adr/0)
  DUP :events SWAP :count @ OVER + SWAP
  ?DO
    I @ OVER = IF DROP I UNLOOP EXIT THEN
  2 CELLS +LOOP DROP 0
;

: find-proc ( dispid oid -- xt/0)
  CELL- find-dispid DUP 0= IF EXIT THEN
  CELL+ @ ;

: connected? ( iid -- ?)
  oconn-chain @
  BEGIN
    DUP 
  WHILE
    2DUP :guid guid= IF 2DROP TRUE EXIT THEN
    @
  REPEAT
  2DROP FALSE ;

0 7 VTABLE sink
  METHOD \ ::QueryInterface ( *adr iid oid -- ?)
  { adr iid oid }
  comevents-trace @ IF
    ." QueryInterface: " iid .guid CR
  THEN
  oid adr !  CoAddRefServerProcess DROP
  iid IID_IUnknown guid=  IF S_OK EXIT THEN
  iid IID_IDispatch guid= IF S_OK EXIT THEN
  iid connected?          IF S_OK EXIT THEN
  adr 0!
  CoReleaseServerProcess DROP 
  E_NOINTERFACE
METHOD;

METHOD \ ::AddRef ( oid -- cnt)
  DROP CoAddRefServerProcess 
METHOD;

METHOD \ ::Release ( oid -- cnt)
  DROP CoReleaseServerProcess 
METHOD;

METHOD \ GetTypeInfoCount ( *info oid -- ?)
  2DROP E_NOTIMPL
METHOD;

METHOD \ GetTypeInfo ( *info lcid info oid -- ?)
  2DROP 2DROP E_NOTIMPL
METHOD;

METHOD \ GetIDsOfNames ( dispids lc n names iid_null oid -- ?)
  2DROP 2DROP 2DROP E_NOTIMPL
METHOD;

USER-VALUE params

METHOD \ Invoke ( argerr excepinfo result dispparams flags lcid iid_null dispid oid -- ?)
  9 PARAMS \ исправить стек, чтобы работало s.
  { dispid oid }
  2DROP DROP TO params DROP 2DROP
  comevents-trace @ IF
    ." Event " dispid .H ." (" params :args# @ . ." args) from object " oid .H CR
  THEN
  dispid oid find-proc ?DUP IF ['] EXECUTE CATCH DROP THEN
  S_OK
METHOD;

VTABLE;

\ ----------------------------------

: new-oconn ( obj -- oconn )
  oconn-len GETMEM >R
  R@ :obj !
  oconn-chain @   R@ oconn-chain !   R@ :link !
  sink @ R@ :vtable !  
  R@ :count 0!
  R> ;

: find-and-unlink { oconn -- }
  oconn-chain
  BEGIN
    DUP @ 0= IF DROP EXIT THEN
    DUP @ oconn <>
  WHILE
    @
  REPEAT
  oconn @ SWAP !
;

: del-oconn ( oconn -- )
  DUP find-and-unlink FREEMEM
;

: find-obj { obj -- oconn/0 }
  oconn-chain @
  BEGIN
    DUP 0= IF EXIT THEN
    DUP :obj @ obj <>
  WHILE
    @
  REPEAT
;

: connect-to-object { oconn \ cpointcont -- }
  ^ cpointcont IID_IConnectionPointContainer oconn :obj @ ::QueryInterface 
  ?DUP IF EXIT THEN
  oconn :cpoint oconn :guid cpointcont ::FindConnectionPoint
  cpointcont release
  ?DUP IF EXIT THEN
  oconn :advise oconn :vtable  oconn :cpoint @ ::Advise ?DUP IF EXIT THEN
  S_OK
;

: argno>var ( argno -- var)
  DUP params :args# @ > IF DISP_E_BADPARAMCOUNT THROW THEN
  \ забавно, но в обработчики событий параметры передаются в прямом
  \ порядке, а не задом наперед, как положено по интерфейсу IDispatch
  1- variant-len * params :args @ +
;

\ -----------------------------------

EXPORT

: Connect { obj \ oconn cpointcont enum cpoint -- err/0 }
  obj new-oconn TO oconn
  ^ cpointcont IID_IConnectionPointContainer obj ::QueryInterface ?DUP IF EXIT THEN
  ^ enum cpointcont ::EnumConnectionPoints DROP
  0 ^ cpoint 1 enum ::Next DROP
  oconn :guid cpoint ::GetConnectionInterface DROP
  cpoint release
  enum release
  cpointcont release
  oconn connect-to-object
;

: ConnectTo ( obj zguid -- ?)
  SWAP new-oconn >R
  R@ :guid >clsid
  R> connect-to-object
;

: Disconnect ( obj -- )
  find-obj ?DUP 0= IF EXIT THEN >R
  R@ :advise @ R@ :cpoint @ ::Unadvise DROP
  R@ :cpoint @ release
  R> del-oconn
;

: Hook ( obj memid xt -- )
  ROT find-obj ?DUP 0= IF 2DROP EXIT THEN >R
  R@ :events R@ :count @ 2 CELLS * + 
  TUCK CELL+ ! !
  R> :count 1+!
;

: Unhook ( obj memid -- )
  SWAP find-obj ?DUP 0= IF 2DROP EXIT THEN >R
  R@ find-dispid ?DUP 0= IF RDROP EXIT THEN
  ( to )
  R@ :count 1-!
  DUP 2 CELLS + SWAP DUP NEGATE R@ :events + 
  R> :count @ 2 CELLS * + CMOVE
;

: PROC: ( ->bl; -- ) CREATE :NONAME DROP ;
: PROC; ( -- ) [COMPILE] ; ; IMMEDIATE

: Arg ( argno -- val/dval)
  comevents-trace @ IF
    ." arg" DUP . ." :"
  THEN
  argno>var ( var)
  comevents-trace @ IF
    DUP 8 DUMP CR
  THEN
  variant@ TO LAST-TYPE
;
: Arg1 ( type -- val/dval) 1 Arg ;
: Arg2 ( type -- val/dval) 2 Arg ;
: Arg3 ( type -- val/dval) 3 Arg ;
: Arg4 ( type -- val/dval) 4 Arg ;
: Arg5 ( type -- val/dval) 5 Arg ;
: Arg6 ( type -- val/dval) 6 Arg ;
: Arg7 ( type -- val/dval) 7 Arg ;
: Arg8 ( type -- val/dval) 8 Arg ;
: Arg9 ( type -- val/dval) 9 Arg ;

\ Слова, возвращающие ссылочные аргументы, закомментированы, поскольку я
\ сомневаюсь в их реальной полезности. Единственным доступным мне местом,
\ где они применяются, являются события Excel типа BeforeSave и
\ BeforeClose. Но увы, изменение параметров этих событий не дает эффекта,
\ обещанного в документации :-( Думаю, что работает это только во
\ встроенном в сам Excel бейсике

\ : refarg ( argno -- var)
\  comevents-trace @ IF
\    ." argref" DUP . ." :"
\  THEN
\  argno>var ( var)
\  comevents-trace @ IF
\    DUP 8 DUMP CR
\  THEN
\ ;

\ : refarg1 ( type -- var) 1 refarg ;
\ : refarg2 ( type -- var) 2 refarg ;
\ : refarg3 ( type -- var) 3 refarg ;
\ : refarg4 ( type -- var) 4 refarg ;
\ : refarg5 ( type -- var) 5 refarg ;
\ : refarg6 ( type -- var) 6 refarg ;
\ : refarg7 ( type -- var) 7 refarg ;
\ : refarg8 ( type -- var) 8 refarg ;
\ : refarg9 ( type -- var) 9 refarg ;

;MODULE
