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

\ Эти обработчики событий браузера вызываются из IDispatch::Invoke по числовому ID
\ Параметры заботливо переведены им из variant'ов к форт-виду :)

ID: DISPID_DOCUMENTCOMPLETE     259 ( urla urlu bro -- )
    ." DocumentComplete! doc=" . \ IWebBrowser2 загруженного фрейма
    TYPE CR
;
ID: DISPID_STATUSTEXTCHANGE   102 ( addr u -- )
    ." StatusTextChange:" TYPE CR
;
ID: DISPID_PROGRESSCHANGE     108  ( ProgressMax Progress -- )
    \ sent when download progress is updated
   ." ProgressChange:" . ." from " . CR
;
ID: DISPID_FILEDOWNLOAD         270 ( bool bool -- )
    \ Fired to indicate the File Download dialog is opening
   ." FileDownload:" . . CR
;
ID: DISPID_NAVIGATECOMPLETE2    252 ( urla urlu bro_win -- )
    \ UIActivate new document
   ." NavigateComplete2! win/frame=" . TYPE CR
;
ID: DISPID_COMMANDSTATECHANGE 105 ( bool command -- )
   ." CommandStateChange:" . . CR
;
ID: DISPID_DOWNLOADBEGIN      106 ( -- )
   ." DownloadBegin..." CR
;
ID: DISPID_DOWNLOADCOMPLETE   104 ( -- )
   ." DownloadComplete!" CR
;
ID: DISPID_SETSECURELOCKICON    269 ( icon -- )
    \ sent to suggest the appropriate security icon to show
   ." SetSecureLockIcon:" . CR
;
ID: DISPID_UNKNOWN:) 282 ( ... )
   ." Unknown282 depth=" DEPTH . DropXtParams CR
;
ID: DISPID_TITLECHANGE    113  ( addr u -- )
    \ sent when the document title changes
   ." Title:" TYPE CR
;
ID: DISPID_BEFORENAVIGATE2      250   \ hyperlink clicked on
(      
    IDispatch *pDisp,
    VARIANT *url,
    VARIANT *Flags,
    VARIANT *TargetFrameName,
    VARIANT *PostData,
    VARIANT *Headers,
    VARIANT_BOOL *Cancel
)
  ." BeforeNavigate2: bro_win=" .
   ."  url=" TYPE ."  flags=" . ." target_frame=" TYPE CR
  ." post=" DUP IF DUP 3 CELLS + @ SWAP 4 CELLS + @ TYPE CR ELSE . THEN
  ."  headers=" TYPE ."  cancel=" .
  ." depth=" DEPTH . DropXtParams CR
;
ID: DISPID_PROPERTYCHANGE     112 ( addr u -- )
    \ sent when the PutProperty method is called
    ." PropertyChange:" TYPE CR
;

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
