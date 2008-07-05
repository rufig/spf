\ Простейшие оконные и контекстные меню.
\ От popupmenu.f отличаются наличием иконок.
\ Примеры в конце.
\ Связывать с пунктом меню XT вместо ID можно только в NT.

REQUIRE Window         ~ac/lib/win/window/window.f
REQUIRE TrackMenu      ~ac/lib/win/window/popupmenu.f
REQUIRE LoadBitmap     ~ac/lib/win/window/IMAGE.f 

WINAPI: InsertMenuItemA USER32.DLL
WINAPI: CreateMenu      USER32.DLL
WINAPI: SetMenu         USER32.DLL

0
CELL -- mi.cbSize
CELL -- mi.fMask
CELL -- mi.fType
CELL -- mi.fState
CELL -- mi.wID
CELL -- mi.hSubMenu
CELL -- mi.hbmpChecked
CELL -- mi.hbmpUnchecked
CELL -- mi.dwItemData
CELL -- mi.dwTypeData
CELL -- mi.cch
CELL -- mi.hbmpItem
CONSTANT /MENUITEMINFO

#define MIIM_ID          0x00000002
#define MIIM_SUBMENU     0x00000004
#define MIIM_DATA        0x00000020

#define MIIM_STRING      0x00000040
#define MIIM_BITMAP      0x00000080
#define MIIM_FTYPE       0x00000100

#define MF_STRING        0x00000000
MF_STRING CONSTANT MFT_STRING

: AppendMenuItem ( h id submenu ima imu addr u -- h )
  /MENUITEMINFO ALLOCATE THROW >R
  /MENUITEMINFO R@ mi.cbSize !
  MIIM_STRING MIIM_ID OR MIIM_BITMAP OR R@ mi.fMask !
  MFT_STRING R@ mi.fType !
  ( h id sm ima imu id h addr u )
  R@ mi.cch ! R@ mi.dwTypeData !
  ( h id sm ima imu )
\  10 ( HBMMENU_POPUP_MAXIMIZE) R@ mi.hbmpItem !
  LoadBitmap R@ mi.hbmpItem !
  ( h id sm )
\  OVER R@ mi.dwItemData !
  ?DUP IF R@ mi.hSubMenu ! R@ mi.fMask @ MIIM_SUBMENU OR R@ mi.fMask ! THEN
  R@ mi.wID !
  DUP ( h h )
  R> 0 ROT 0 SWAP InsertMenuItemA DROP
;

\EOF

CreatePopupMenu
' NOOP 0 S" 111.bmp" S" test&1" AppendMenuItem
' NOOP 0 S" 111.bmp" S" tes&t2" AppendMenuItem
:NONAME ." Thanks!" CR ; 0 S" 111.bmp" S" &Нажми меня!" AppendMenuItem
\  0 0 ROT TrackMenu EXECUTE
\ EOF

CreateMenu
4 0 S" 111.bmp" S" &File" AppendMenuItem
5 ROT S" 111.bmp" S" &Edit" AppendMenuItem
6 0 S" 111.bmp" S" &View" AppendMenuItem

: TEST ( menu -- )
  || h ||
  S" RichEdit20A" SPF_STDEDIT 0 Window -> h
  ( menu ) h SetMenu DROP
  S" Это редактор" DROP h SetWindowTextA DROP
  h WindowShow
  h MessageLoop
  h WindowDelete
;
TEST
