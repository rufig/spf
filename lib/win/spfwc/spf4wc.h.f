USES user32.dll
USES gdi32.dll
USES kernel32.dll
USES comdlg32.dll
USES comctl32.dll

DECIMAL
0 CONSTANT NULL

IMAGE-BASE CONSTANT HINST  \ Instance текущего приложения

TEMP-WORDLIST VALUE CONSTS
GET-CURRENT
ALSO CONSTS CONTEXT ! DEFINITIONS

  1 CONSTANT ToolBarID
  2 CONSTANT ClID
  3 CONSTANT EdID
  4 CONSTANT SBID
  5 CONSTANT SplitID

  1 CONSTANT IDB_BITMAP1
  1 CONSTANT ACCELERATORS_1
  1 CONSTANT IDM_MENU1

  3 CONSTANT split_height

  WM_USER  1 + CONSTANT TB_ENABLEBUTTON
  WM_USER  2 + CONSTANT TB_CHECKBUTTON
  WM_USER 29 + CONSTANT TB_GETITEMRECT
  WM_USER 33 + CONSTANT TB_AUTOSIZE

  WM_USER  1 + CONSTANT SB_SETTEXT
  0x0100 CONSTANT SBARS_SIZEGRIP

  0x01   CONSTANT CCS_TOP
  0x03   CONSTANT CCS_BOTTOM
  0x0100 CONSTANT TBSTYLE_TOOLTIPS
  0x0800 CONSTANT TBSTYLE_FLAT
  -520   CONSTANT TTN_NEEDTEXTA
  -530   CONSTANT TTN_NEEDTEXTW

  211 CONSTANT cmdInclude
  212 CONSTANT cmdDbgInclude
  213 CONSTANT cmdRunScript
  214 CONSTANT cmdBYE
  221 CONSTANT cmdCUT
  222 CONSTANT cmdCOPY
  223 CONSTANT cmdPASTE
  231 CONSTANT cmdDBG
  232 CONSTANT cmdGO
  233 CONSTANT cmdSTEP
  234 CONSTANT cmdOVER
  235 CONSTANT cmdOUT
  236 CONSTANT cmdSTOP
  237 CONSTANT cmdDotS
  238 CONSTANT cmdDotR
  241 CONSTANT cmdRefreshFavorites
  251 CONSTANT cmdLOG
  252 CONSTANT cmdCASEINS
  261 CONSTANT cmdHELP
  270 CONSTANT cmdRFL
  300 CONSTANT cmdFavorites
   71 CONSTANT IDS_MAIN_MENU

SET-CURRENT

 TRUE VALUE JetOut
    0 VALUE MainTlsIndex
    0 VALUE clhwnd
    0 VALUE ClWndProc
    0 VALUE cl_height
    0 VALUE edhwnd
    0 VALUE EdWndProc
    0 VALUE ed_height
    0 VALUE TBhwnd
    0 VALUE TBWndProc
    0 VALUE tb_height
    0 VALUE SBhwnd
    0 VALUE SBWndProc
    0 VALUE sb_height
    0 VALUE splithwnd
    0 VALUE SplitWndProc
    0 VALUE SplitRatio
    0 VALUE dragStart
    0 VALUE dragY
    0 VALUE Myhwnd
    0 VALUE Myhwnd_height
    0 VALUE Myhwnd_width
    0 VALUE MainMenu
    0 VALUE hFileMenu
    0 VALUE hDebugMenu
    0 VALUE hFavoritesMenu
    0 VALUE hOptionsMenu
    0 VALUE CurFocus
    0 VALUE hAccel
    0 VALUE JetBuf
    0 VALUE *JetBuf
    0 VALUE hFont
 0x64 CONSTANT OBSIZE
    0 VALUE tib
    0 VALUE >in
    0 VALUE promptbuf
    0 VALUE *promptbuf
CREATE prompt> S" >" S",
    0 VALUE KEY_EVENT_GUI       \ event на KEY
    0 VALUE START_EVENT         \ event на запуск форт системы
    0 VALUE CON_BUFFER_PREPARED \ event на ACCEPT
    0 VALUE Spf4wcIni
CREATE popstr 0 , 0 , 0 , IDS_MAIN_MENU ,

CREATE sOptions      S" Options" HERE SWAP DUP ALLOT MOVE 0 C,
CREATE sFavorites    S" Favorites" HERE SWAP DUP ALLOT MOVE 0 C,
CREATE sWindowX      S" WindowX"  HERE SWAP DUP ALLOT MOVE 0 C,
CREATE sWindowWidth  S" WindowWidth" HERE SWAP DUP ALLOT MOVE 0 C,
CREATE sWindowY      S" WindowY" HERE SWAP DUP ALLOT MOVE 0 C,
CREATE sWindowHeight S" WindowHeight" HERE SWAP DUP ALLOT MOVE 0 C,
CREATE sCaseIns      S" CaseIns" HERE SWAP DUP ALLOT MOVE 0 C,
CREATE sLog          S" Log" HERE SWAP DUP ALLOT MOVE 0 C,
CREATE sSplitRatio   S" SplitRatio" HERE SWAP DUP ALLOT MOVE 0 C,
FALSE VALUE interactive
FALSE VALUE keywait
    0 VALUE LastKey
    0 VALUE logfont
    0 VALUE MSG1
    0 VALUE CONS_
    0 VALUE cwin
    0 VALUE MenuItemInfo
    0 VALUE open_dlg
    0 VALUE strFile
CREATE strFilter
         S" *.f Forth files" HERE SWAP DUP ALLOT MOVE 0 C,
         S" *.f" HERE SWAP DUP ALLOT MOVE 0 C,
         S" *.* All files" HERE SWAP DUP ALLOT MOVE 0 C,
         S" *.*" HERE SWAP DUP ALLOT MOVE 0 C,
         0 C,
    0 VALUE strInitialDir

GET-CURRENT
TEMP-WORDLIST DUP ALSO CONTEXT ! DEFINITIONS
S" ~af\lib\toolbar.f" INCLUDED
SWAP SET-CURRENT

/TBBUTTON CONSTANT TBButtonSize
CREATE TBBUTTONS
cmdInclude       0 TB-BUTTON
cmdDbgInclude    1 TB-BUTTON
TB-SEP
cmdCASEINS       2 TB-CHECK
TB-SEP
cmdLOG           3 TB-CHECK
TB-SEP
cmdDBG           4 TB-CHECK
TB-SEP
cmdGO            5 TB-BUTTON
cmdSTEP          6 TB-BUTTON
cmdOVER          7 TB-BUTTON
cmdOUT           8 TB-BUTTON
TB-SEP
cmdDotS         10 TB-BUTTON
cmdDotR         11 TB-BUTTON
TB-SEP
cmdRunScript    12 TB-BUTTON

PREVIOUS
FREE-WORDLIST


STRUCT: WNDCLASS
4 -- style
4 -- lpfnWndProc
4 -- cbClsExtra
4 -- cbWndExtra
4 -- hInstance
4 -- hIcon
4 -- hCursor
4 -- hbrBackground
4 -- lpszMenuName
4 -- lpszClassName
;STRUCT

STRUCT: MSG
4 -- hwnd
4 -- message
4 -- wParam
4 -- lParam
4 -- time
4 -- pt
;STRUCT

STRUCT: LOGFONT
  4 -- lfHeight
  4 -- lfWidth
  4 -- lfEscapement
  4 -- lfOrientation
  4 -- lfWeight
  1 -- lfItalic
  1 -- lfUnderline
  1 -- lfStrikeOut
  1 -- lfCharSet
  1 -- lfOutPrecision
  1 -- lfClipPrecision
  1 -- lfQuality
  1 -- lfPitchAndFamily
 48 -- lfFaceName
;STRUCT

STRUCT: OPENFILENAME
  4 -- lStructSize
  4 -- hwndOwner
  4 -- hInstance
  4 -- lpstrFilter
  4 -- lpstrCustomFilter
  4 -- nMaxCustFilter
  4 -- nFilterIndex
  4 -- lpstrFile
  4 -- nMaxFile
  4 -- lpstrFileTitle
  4 -- nMaxFileTitle
  4 -- lpstrInitialDir
  4 -- lpstrTitle
  4 -- Flags
  2 -- nFileOffset
  2 -- nFileExtension
  4 -- lpstrDefExt
  4 -- lCustData
  4 -- lpfnHook
  4 -- lpTemplateName
;STRUCT

STRUCT: RECT
  4 -- left
  4 -- top
  4 -- right
  4 -- bottom
;STRUCT

STRUCT: MENUITEMINFO
  4 -- cbSize
  4 -- fMask
  4 -- fType
  4 -- fState
  4 -- wID
  4 -- hSubMenu
  4 -- hbmpChecked
  4 -- hbmpUnchecked
  4 -- dwItemData
  4 -- dwTypeData
  4 -- cch
;STRUCT

STRUCT: NMHDR
  4 -- hwndFrom
  4 -- idFrom
  4 -- code
;STRUCT

STRUCT: TOOLTIPTEXTA
  NMHDR::/SIZE -- hdr
   4 -- lpszText
  80 -- szText
   4 -- hinst
   4 -- uFlags
   4 -- lParam
;STRUCT

STRUCT: POINT
  4 -- x-point
  4 -- y-point
;STRUCT
