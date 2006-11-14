( Support of ActiveX controls )

WINAPI: AtlAxCreateControl ATL.DLL
WINAPI: AtlAxGetControl    ATL.DLL

WINAPI: CoInitializeEx  OLE32.DLL
WINAPI: CoUninitialize    OLE32.DLL

2 CONSTANT COINIT_APARTMENTTHREADED

: StartCOM
   COINIT_APARTMENTTHREADED
   0 CoInitializeEx ABORT" Cannot initialize COM"
;

: EndCOM
   CoUninitialize DROP
;

CChildWindow SUBCLASS CAxControl

     CWinClass OBJ class
               VAR control \ idispatch interface

init:
    WS_CHILD WS_VISIBLE OR SUPER style !
;

: createClass ( -- atom )
    class register
;

( addr u - may be 
   * A ProgID such as "MediaPlayer.MediaPlayer.1"
   * A CLSID such as "{8E27C92B-1264-101C-8A2F-040224009C02}"
   * A URL such as "http://forth.org.ru"
   * A reference to an Active document such as "file://\\Documents\MyDoc.doc"
   * A fragment of HTML such as "MSHTML:<HTML><BODY>This is a line of text</BODY></HTML>" 
)

: createControl ( addr u )
     DROP COM::>unicodebuf
     DUP >R
     SUPER checkWindow SWAP
     0 0 2SWAP
     AtlAxCreateControl
     S" Unable to create activex control" SUPER abort
     R> FREE THROW

     control SUPER checkWindow AtlAxGetControl
     S" Unable to get activex control" SUPER abort

     control COM::IID_IDispatch control @ COM:: ::QueryInterface
     S" Control does not support IDispatch" SUPER abort
;

: create ( addr u id parent-obj )
     SUPER create DROP
     createControl
;

: attach ( addr u hwnd )
     SUPER attach
     createControl
;

;CLASS
