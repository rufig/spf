\ $Id$
\ Высокоуровневая поддержка меню

REQUIRE WinNT?	~ac\lib\win\winver.f
REQUIRE :M	~af\lib\nwordlist.f
REQUIRE USES	~af\lib\api-func.f
USES user32.dll
USES kernel32.dll
0 CONSTANT CP_ACP
REQUIRE S>UNICODE	~nn\lib\unicode.f

USER-VALUE MENU-WID
VECT AppMenu

: AppMenuA ( lpNewItem uIDNewItem uFlags hMenu -- )
  >R >R >R
  UASCIIZ> UNICODE>S DROP
  R> R> R>
  AppendMenuA DROP
;

: AppMenuW ( lpNewItem uIDNewItem uFlags hMenu -- )
  AppendMenuW DROP
;

: MENU ( menu-wid id_menu -- id_menu hmenu )
  WinNT? IF ['] AppMenuW TO AppMenu ELSE ['] AppMenuA TO AppMenu THEN
  SWAP TO MENU-WID
  CreateMenu
;

: END-MENU ( id_menu+n hmenu -- )
  NIP
;

: POPUP ( id_menu -- id_menu hmenu )
  CreatePopupMenu
;

: END-POPUP ( id_menu1 hmenu1 id_menu2 hmenu2 -- id_menu1+1 hmenu1 )
  NIP 2>R DUP
  MENU-WID SEARCH-NLIST DROP R>
  MF_POPUP R@ AppMenu
  1+ R>
;

: MENUITEM ( id_menu hmenu id_item -- id_menu+1 hmenu )
  SWAP >R
  DUP MENU-WID SEARCH-NLIST DROP SWAP
  MF_STRING R@ AppMenu
  1+ R>
;

: MENUSEPARATOR ( id_menu hmenu -- hmenu )
  >R 0 0
  MF_SEPARATOR R@ AppendMenu DROP
  1+ R>
;
