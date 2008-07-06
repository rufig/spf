REQUIRE EnumConnectionPoints ~ac/lib/win/com/events.f

\ COM-клиента браузер может извещать о событиях через IID_IWebBrowserEvents2
\ Хотя, если не находит интерфейса с конкретно этим IID, то без проблем
\ довольствуется обычным IID_IDispatch.

IID_IDispatch
Interface: IID_IWebBrowserEvents2 {34A715A0-6587-11D0-924A-0020AFC7AC4D}
Interface;

\ А эти интерфейсы подключения к событиям (connection points) экспортирует IE7

\ uuid(34A715A0-6587-11D0-924A-0020AFC7AC4D), // IID_DWebBrowserEvents2
\ helpstring("Web Browser Control events interface"),

\ uuid(EAB22AC2-30C1-11CF-A7EB-0000C05BAE0B), // DIID_DWebBrowserEvents
\ helpstring("Web Browser Control Events (old)"),

\ uuid(9BFBBC02-EFF1-101A-84ED-00AA00341D07),
\ interface IPropertyNotifySink : IUnknown
