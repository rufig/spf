REQUIRE EnumConnectionPoints ~ac/lib/win/com/events.f

\ COM-клиента браузер может извещать о событиях через IID_IWebBrowserEvents2
\ Хотя, если не находит интерфейса с конкретно этим IID, то без проблем
\ довольствуется обычным IID_IDispatch.

IID_IDispatch
Interface: IID_IWebBrowserEvents2 {34A715A0-6587-11D0-924A-0020AFC7AC4D}
\ методы этого интерфейса не вызываются, т.к. он "входящий" -
\ при поступлении событий ID этих событий передаются нашему IDispatch::Invoke
Interface;

IID_IWebBrowserEvents2
Class: SPF.IWebBrowserEvents2 {C6DFBA32-DF7B-4829-AA3B-EE4F90ED5961} \ свой clsid общий
Extends SPF.IDispatch
\ ORDER
Class;

: {34A715A0-6587-11D0-924A-0020AFC7AC4D} ( ppvObject iid oid -- hresult )
\ Экспортируем реализацию. См. ::QueryInterface
  COM-DEBUG @ IF ." SPF.IWebBrowserEvents2 - OK!" THEN
  2DROP SPF.IWebBrowserEvents2 SWAP ! 0
;

\ А эти интерфейсы подключения к событиям (connection points) экспортирует IE7

\ uuid(34A715A0-6587-11D0-924A-0020AFC7AC4D), // IID_DWebBrowserEvents2
\ helpstring("Web Browser Control events interface"),

\ uuid(EAB22AC2-30C1-11CF-A7EB-0000C05BAE0B), // DIID_DWebBrowserEvents
\ helpstring("Web Browser Control Events (old)"),

\ uuid(9BFBBC02-EFF1-101A-84ED-00AA00341D07),
\ interface IPropertyNotifySink : IUnknown
