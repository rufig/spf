( Originally created by ~ac in ~ac\lib\win\window\dialog_creating.f )

REQUIRE WL-MODULES ~day\lib\includemodule.f

NEEDS ~day\wincons\wc.f

\ Классы DialogBoxControls
BASE @ HEX
0080 CONSTANT DI_Button 
0081 CONSTANT DI_Edit 
0082 CONSTANT DI_Static 
0083 CONSTANT DI_Listbox 
0084 CONSTANT DI_Scrollbar 
0085 CONSTANT DI_Combobox
BASE !

\ --------------------------------------------------------
\ ******* процедура для создания шаблона диалога в памяти
0
4 -- DLGTEMPLATE.style
4 -- DLGTEMPLATE.dwExtendedStyle
2 -- DLGTEMPLATE.cdit
2 -- DLGTEMPLATE.x
2 -- DLGTEMPLATE.y
2 -- DLGTEMPLATE.cx
2 -- DLGTEMPLATE.cy
CONSTANT /DLGTEMPLATE

0
4 -- DLGITEMTEMPLATE.style
4 -- DLGITEMTEMPLATE.dwExtendedStyle
2 -- DLGITEMTEMPLATE.x
2 -- DLGITEMTEMPLATE.y
2 -- DLGITEMTEMPLATE.cx
2 -- DLGITEMTEMPLATE.cy
2 -- DLGITEMTEMPLATE.id
CONSTANT /DLGITEMTEMPLATE

: L, ( addr u )
   0 ?DO DUP I + C@ W, LOOP DROP 
   0 W,
;

: L" ( "ccc" -- ) \ ******* компиляция строки в UNICODE
  [CHAR] " PARSE L,
;

: DIALOG: ( x y cx cy style "name" -- dlg 0 )
  CREATE HERE 0 ,
  HERE 7 + 8 / 8 * HERE - ALLOT
  HERE SWAP !
  HERE DUP >R /DLGTEMPLATE DUP ALLOT ERASE
  R@ DLGTEMPLATE.style !
  0 R@ DLGTEMPLATE.cdit W!
  R@ DLGTEMPLATE.cy W!
  R@ DLGTEMPLATE.cx W!
  R@ DLGTEMPLATE.y W!
  R@ DLGTEMPLATE.x W!
  R> 0
  0 W, \ menu  (no menu)
  0 W, \ class (def)
  >IN @ #TIB @ <
  IF L" HERE 4 MOD 2 = IF -2 ALLOT BL , THEN
  ELSE 0 W, THEN  \ title
;
: DIALOG; ( dlg n -- )
  SWAP DLGTEMPLATE.cdit W!
;

: DIALOG_ITEM ( N id x y cx cy style class_id predefined? -- N+1 )
  HERE DUP >R /DLGITEMTEMPLATE DUP ALLOT ERASE

  IF -1 W, W, \ class_id
  ELSE L, 
  THEN

  WS_VISIBLE OR WS_CHILD OR
  R@ DLGITEMTEMPLATE.style !
  R@ DLGITEMTEMPLATE.cy   W!
  R@ DLGITEMTEMPLATE.cx   W!
  R@ DLGITEMTEMPLATE.y    W!
  R@ DLGITEMTEMPLATE.x    W!
  R> DLGITEMTEMPLATE.id   W!
  >IN @ #TIB @ <
  IF L" ELSE 0 W, THEN  \ title (initial text)
  HERE 4 MOD 2 = IF -2 ALLOT BL W, 0 W, THEN \ эх, MS, MS ... :)
  0 ,                   \ creation data
  1+
;
: FONT ( size codepage "typeface")
  SWAP W, L" W,
;

: EDITTEXT ( N id x y cx cy style -- N+1 )
   WS_TABSTOP OR WS_BORDER OR DI_Edit TRUE DIALOG_ITEM
;

: PUSHBUTTON ( N id x y cx cy -- N+1 )
   WS_TABSTOP OR DI_Button TRUE DIALOG_ITEM
;
: LTEXT ( N id x y cx cy style -- N+1 )
   WS_TABSTOP OR DI_Static TRUE DIALOG_ITEM
;

: LISTVIEW ( N id x y cx cy style -- N+1 )
  WS_TABSTOP OR WS_BORDER OR S" SysListView32" FALSE DIALOG_ITEM
;