S" lib/ext/case.f" INCLUDED
S" ~micro/lib/ras/typedef.f" INCLUDED
S" ~micro/lib/ras/proc.f" INCLUDED
S" ~micro/lib/massdownloader.f" INCLUDED

S" ~micro/lib/timer.f" INCLUDED

WINAPI: RasEnumConnectionsA rasapi32.dll
WINAPI: RasGetConnectStatusA rasapi32.dll
WINAPI: FlushFileBuffers kernel32.dll

{{ RASCONN
  CREATE rasconn structsize 10 * ALLOT
}}

VARIABLE s
VARIABLE c
VARIABLE count

: enum ( -- n ior )
  0 s !
  0 c !
  0 count !
  {{ RASCONN structsize
    rasconn OVER ERASE
    DUP s !
        rasconn dwSize !
  }}
  c s rasconn RasEnumConnectionsA DROP
  c @ 1 > ABORT" More then one connection detected"
  c @ 0 > IF
    {{ RASCONN structsize
          rasconn OVER c @ * ERASE
          rasconn dwSize !
    }}
    c s rasconn RasEnumConnectionsA
  ELSE
    0
  THEN
  c @ SWAP
;

: connection ( -- h )
  enum THROW
  IF
    rasconn RASCONN::hrasconn @
  ELSE
    0
  THEN
;

: HangUp
  connection HangUp
;

VARIABLE S
VARIABLE lastS
VARIABLE AddMins

: ~ DUP CONSTANT 1+ ;

MODULE: ConnectStatus
  0
  ~ NoConnect
  ~ Connecting
  ~ Authenticate
  ~ Connected
  ~ Unknown
  ~ Error
  DROP

  CREATE status RASCONNSTATUS::structsize ALLOT
  
  : initstatus
    {{ RASCONNSTATUS
      status structsize ERASE
      structsize status dwSize !
    }}
  ;
  
  : GetAll
  \ May return Unknown and THROW exception
    connection
    ?DUP IF
      initstatus
      status SWAP
      RasGetConnectStatusA DUP 6 = IF
        DROP
        NoConnect
      ELSE
        ?DUP IF
          ABORT
        THEN
          {{ RASCONNSTATUS status rasconnstate @ }}
        CASE
          {{ RASCONNSTATE
            RASCS_ConnectDevice OF Connecting ENDOF
            RASCS_Authenticate OF Authenticate ENDOF
            RASCS_Connected OF Connected ENDOF
            RASCS_Disconnected OF NoConnect ENDOF
          }}
          Unknown SWAP
        ENDCASE
      THEN
    ELSE
      NoConnect
    THEN
  ;

  : Get
    GetAll
    DUP Unknown = IF
      DROP
      300 PAUSE
      GetAll
      DUP Unknown = IF
        DROP
        Error
      THEN
    THEN
  ;
;MODULE

MODULE: Files
  VARIABLE log
  VARIABLE graph
  VARIABLE curr
  
  : init
\    S" graph" R/W CREATE-FILE-SHARED THROW graph !
  ;
  
  : flush
    curr @ FlushFileBuffers DROP
  ;
  
  : output ( file -- )
    @
      DUP curr !
          TO H-STDOUT
  ;
;MODULE

VECT AfterConnect
VECT BeforeDisconnect

MODULE: EventHandlers
  : Dial      Timer::Mark  AddMins 0! ;
  : Connect   Download AfterConnect ;
  : DialTO    HangUp ;
  : AuthTO    HangUp ;
  : ConnectTO Stop BeforeDisconnect
              HangUp ;
;MODULE

MODULE: Timeouts
  35 VALUE Dial
  40 VALUE Auth
  70 VALUE Connect
;MODULE

MODULE: Events
  : BecomeState ( -- state )
    S @ lastS @ = IF
      -1
    ELSE
      S @
    THEN
  ;
  {{ ConnectStatus
    : Dial      BecomeState Connecting =    ;
    : Connect   BecomeState Connected  =    ;
    {{ Timer
      : DialTO
        S @ Connecting =
        Timeouts::Dial Elapsed <
          AND
      ;

      : AuthTO
        S @ Authenticate =
        Timeouts::Auth Elapsed <
          AND
      ;

      : ConnectTO
        S @ Connected =
        Timeouts::Connect AddMins @ 60 * + Elapsed <
          AND
      ;
    }}
  }}
;MODULE

: init
  Timer::Mark
  AddMins 0!
  ConnectStatus::Get lastS !
  Files::init
\  {{ Files  graph output }}
\  80 0 DO I 10 MOD 0x30 + EMIT LOOP
\  80 0 DO I 10 / 0x30 + EMIT LOOP
  ['] NOOP
    DUP TO BeforeDisconnect
        TO AfterConnect
  1000 PAUSE
;

: gs S" .->!?@" DROP ;

S" lib/include/facil.f" INCLUDED
S" lib/include/core-ext.f" INCLUDED

: .. 2 .0 ;
: :: ." :" ;

: .time
  TIME&DATE DROP DROP DROP .. :: .. :: ..
;

: EachSecond
    S @ lastS !
    ConnectStatus::Get S !
    {{ Events
      Dial IF EventHandlers::Dial THEN
      Connect IF EventHandlers::Connect THEN
      DialTO IF EventHandlers::DialTO THEN
      AuthTO IF EventHandlers::AuthTO THEN
      ConnectTO IF EventHandlers::ConnectTO THEN
    }}
\    {{ Files graph output }}
\    {{ Events {{ ConnectStatus
\      BecomeState Connecting = IF CR .time CR THEN
\      S @
\      DUP ConnectStatus::NoConnect <> IF  gs + C@ EMIT ELSE DROP THEN
\    }} }}
;

S" ~day\joop\win\winclass.f" INCLUDED
REQUIRE FrameWindow ~day\joop\win\framewindow.f
REQUIRE TIME&DATE lib\include\facil.f
REQUIRE MENUITEM ~day\joop\win\menu.f
REQUIRE Font    ~day\win\font.f

REQUIRE Button ~day\joop\win\control.f
<< :setStrings
<< :b1Click

CLASS: AboutWindow <SUPER FrameWindow
	CELL VAR ver
	CELL VAR name
	Button OBJ b1
	Button OBJ frame
	Static OBJ stName
	Static OBJ stVer
	Static OBJ stCompany
	Static OBJ stURL

: :init
    own :init
    WS_DLGFRAME WS_CAPTION OR WS_SYSMENU OR vStyle !
;

: :b1Click 0 self :modalResult! ;

W: WM_CHAR wparam @ 13 = IF self :b1Click THEN ;

: :setStrings
    DROP ver !
    DROP name !
;

: :create
   own :create
   BS_GROUPBOX frame <style !
   S" Ok" 40 64 40 13 self b1 :install
   0 0 5 2 107 60 self frame :install
   ['] :b1Click b1 <OnClick !
   name @ 0 10 10 97 10 self stName :install
   ver @ 0 10 20 97 10 self stVer :install
   S" Dmitry Zyryanov [c] 2001" 10 27 97 10 self stCompany :install
   S" Powered with sp-forth and jOOP, see http://www.forth.org.ru" 10 35 97 24 self stURL :install
;

;CLASS

\ Сначала имя приложения, затем версия
: ShowAbout ( c-addr1 u1 c-addr2-u2 hwnd)
   >R AboutWindow :new >R
   R@ :setStrings
   R> R> SWAP >R R@ :create
   140 100 120 92 R@ :move
   S" About..." R@ :setText
   R@ :showModal DROP
   R> :free
;

101 CONSTANT ID_ABOUT
102 CONSTANT ID_CLOSE

CLASS: DisconnectorWinClass <SUPER WinClass

: :init
     own :init
     S" Disconnector Class" DROP lpszClassName !
     style @ CS_SAVEBITS OR style !     
;
     
;CLASS

DisconnectorWinClass :newLit VALUE iDisconnectorClass

CLASS: DisconnectorWindow <SUPER FrameWindow

        Font OBJ iFont
        
M: ID_ABOUT
    S" Disconnector" S" Version 2.0" self ShowAbout
;

M: ID_CLOSE BYE ;
 
: :createPopup
   POPUPMENU
     S" About" ID_ABOUT MENUITEM
     S" Close" ID_CLOSE MENUITEM
   END-MENU
;

: :init
   own :init
   BLACK_BRUSH GetStockObject iDisconnectorClass <hbrBackground !
   WS_DLGFRAME WS_POPUP OR vStyle !
   WS_EX_TOPMOST vExStyle !    
   iDisconnectorClass vClass !
   S" Arial" DROP iFont <lpszFace !
   18 iFont <height !
   FW_BOLD iFont <weight !   
;

W: WM_CREATE
    0 1000 1 handle @ SetTimer DROP
    0 220 0 rgb handle @ GetDC DUP >R SetTextColor DROP    
    TRANSPARENT R@ SetBkMode DROP
    iFont :create
    iFont <handle @ R> SelectObject DROP    
    0
;

W: WM_TIMER
     EachSecond
     TRUE 0 handle @ InvalidateRect DROP 0
;

: :onPaint
   S @ ConnectStatus::NoConnect <> IF
     Timeouts::Connect AddMins @ 60 * + Timer::Elapsed -
     DUP 0< IF DROP S" TO" ELSE S>D <# #S #> THEN
   ELSE
     S" ##"
   THEN
   SWAP 2 6 ToPixels dc TextOutA DROP   
;


W: WM_NCHITTEST
    HTCAPTION
;

W: WM_NCLBUTTONDBLCLK
   WM_CONTEXTMENU self WM:
;

W: WM_NCRBUTTONDOWN
  HangUp
  1
;

\ W: WM_NCLBUTTONDOWN
\   1 AddMins +!
\   1
\ ;

;CLASS

MODULE: Options
  : dial Timeouts::TO Dial ;
  : auth Timeouts::TO Auth ;
  : connect Timeouts::TO Connect ;
;MODULE

: test { \ w wpar -- }
    init
    ALSO Options S" disc.cfg" ['] INCLUDED CATCH DROP PREVIOUS
    Files::log @
    FrameWindow :new -> wpar
    0 wpar :create
    wpar :hide
    DisconnectorWindow :new -> w 
    wpar w :create 
    -4 -4 23 15 w :move
    S" Disconnector" w :setText
    w :show
    w :run
    w :free
    wpar :free
    BYE
;

HERE IMAGE-BASE - 10000 + TO IMAGE-SIZE
' test MAINX !
TRUE TO ?GUI
S" disc.exe" SAVE
BYE