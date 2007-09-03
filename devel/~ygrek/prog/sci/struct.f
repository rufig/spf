REQUIRE STRUCT: lib/ext/struct.f

STRUCT: NotifyHeader \ This matches the Win32 NMHDR structure
 CELL -- hwndFrom   \ environment specific window handle/pointer
 CELL -- idFrom     \ CtrlID of the window issuing the notification
 CELL -- code       \ The SCN_* notification code
;STRUCT

STRUCT: SCN
 CELL -- position
    \ SCN_STYLENEEDED, SCN_DOUBLECLICK, SCN_MODIFIED, SCN_DWELLSTART,
    \ SCN_DWELLEND, SCN_CALLTIPCLICK,
    \ SCN_HOTSPOTCLICK, SCN_HOTSPOTDOUBLECLICK
 CELL -- ch             \ SCN_CHARADDED, SCN_KEY
 CELL -- modifiers      \ SCN_KEY, SCN_DOUBLECLICK, SCN_HOTSPOTCLICK, SCN_HOTSPOTDOUBLECLICK
 CELL -- modificationType \ SCN_MODIFIED
 CELL -- text           \ SCN_MODIFIED, SCN_USERLISTSELECTION, SCN_AUTOCSELECTION
 CELL -- length         \ SCN_MODIFIED
 CELL -- linesAdded     \ SCN_MODIFIED
 CELL -- message        \ SCN_MACRORECORD
 CELL -- wParam         \ SCN_MACRORECORD
 CELL -- lParam         \ SCN_MACRORECORD
 CELL -- line           \ SCN_MODIFIED, SCN_DOUBLECLICK
 CELL -- foldLevelNow   \ SCN_MODIFIED
 CELL -- foldLevelPrev  \ SCN_MODIFIED
 CELL -- margin         \ SCN_MARGINCLICK
 CELL -- listType       \ SCN_USERLISTSELECTION, SCN_AUTOCSELECTION
 CELL -- x              \ SCN_DWELLSTART, SCN_DWELLEND
 CELL -- y              \ SCN_DWELLSTART, SCN_DWELLEND
;STRUCT

STRUCT: SCNotification
 NotifyHeader::/SIZE -- nmhdr
 SCN::/SIZE -- scn
;STRUCT
