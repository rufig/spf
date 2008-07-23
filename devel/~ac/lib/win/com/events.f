\ COM-события.
\ Раньше использовался ~yz/comevents.f, но для несовместимых интерфейсов
\ (в частности SpamProtexx) все равно пришлось писать самодельный низкоуровневый
\ обработчик.
\ И ~day так и не докрутил в wfl привязку моего примера подключения
\ к событиям браузера (через ~yz/comevents.f). Так что пришлось опять самому ;)

\ В отличие от библиотеки ~yz эта реализация подключается не к первой точке
\ списка точек подключения, а по заданному IID. Т.е. с неизвестными объектами
\ не сработает, но оно, как выяснилось, только с MS-объектами работало,
\ остальные перечисляют точки по-своему.

\ Всю обработку входящих извещений универсально делает старый com_server2.f.

REQUIRE Class:        ~ac/lib/win/com/com_server.f 
REQUIRE SPF.IDispatch ~ac/lib/win/com/com_server2.f
REQUIRE EnumVariant   ~ac/lib/win/com/collections.f 

IID_IUnknown
Interface: IID_IConnectionPointContainer {B196B284-BAB4-101A-B69C-00AA00341D07}
  Method: ::EnumConnectionPoints ( *ienum -- ?) 
  Method: ::FindConnectionPoint  ( *ipoint iid -- ?)
Interface;

IID_IUnknown
Interface: IID_IConnectionPoint {B196B286-BAB4-101A-B69C-00AA00341D07}
  Method: ::GetConnectionInterface ( *iid -- ?)
  Method: ::GetConnectionPointContainer ( *iconnpoint -- ?)
  Method: ::Advise ( *unk *cookie -- ?)
  Method: ::Unadvise ( cookie -- ?)
  Method: ::EnumConnections ( *ienumconn -- ?)
Interface;

IID_IEnumVariant
Interface: IID_IEnumConnectionPoints {B196B285-BAB4-101A-B69C-00AA00341D07}
( то же самое, что и IID_IEnumVariant, поэтому имитируем наследование)
\  Method: ::Next (  /* [in] */ ULONG cConnections,
\            /* [length_is][size_is][out] */ LPCONNECTIONPOINT *ppCP,
\            /* [out] */ ULONG *pcFetched)
\  Method: ::Skip ( 
\            /* [in] */ ULONG cConnections)
\  Method: ::Reset ( void)
\  Method: ::Clone ( /* [out] */ IEnumConnectionPoints **ppEnum)
Interface;

: EnumConnectionPoints { xt iface \ cpointcont cpe cpoint -- n }
  ^ cpointcont IID_IConnectionPointContainer iface ::QueryInterface THROW
  COM-DEBUG @ IF ." SP: CPC OK " cpointcont . CR THEN
  ^ cpe cpointcont ::EnumConnectionPoints THROW
  COM-DEBUG @ IF ." SP: CPE OK " cpe . CR THEN
  xt cpe EnumVariant
;
: (ListConnectionPoints) ( cpv cpi -- )
  NIP
  ." cp=" PAD SWAP ::GetConnectionInterface THROW PAD 16 DUMP CR
  PAD @ HEX U. DECIMAL CR CR
;
: ListConnectionPoints ( iface -- ) \ распечатать IID всех событийных интерфейсов
  ['] (ListConnectionPoints) SWAP EnumConnectionPoints DROP
;
: ConnectInterface { idisp iid iface \ cpointcont cpe cpoint cookie -- }
\ подключить обработчик idisp к событиям с интерфейсом iid объекта iface
\ idisp - реализация интерфейса IDispatch в нашей программе
\ при возникновении событий объект будет вызывать его методы
\ Пример: SPF.IDispatch IID_IWebBrowserEvents2 bro ConnectInterface

  ^ cpointcont IID_IConnectionPointContainer iface ::QueryInterface THROW
  COM-DEBUG @ IF ." SP: CPC OK " cpointcont . CR THEN
  ^ cpoint iid cpointcont ::FindConnectionPoint THROW
  COM-DEBUG @ IF ." SP: CP OK " cpoint . CR THEN
  ^ cookie idisp cpoint ::Advise THROW
  COM-DEBUG @ IF ." SP: CP.advice OK " cookie . CR THEN
;
