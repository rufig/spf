( 26.01.2000 Черезов А. )

( Создание шаблонов диалогов Windows )

REQUIRE ||             ~ac/lib/temps.f
REQUIRE CW_USEDEFAULT  ~ac/lib/win/window/winconst.f

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

: L" ( "ccc" -- ) \ ******* компиляция строки в UNICODE
  [CHAR] " PARSE
  0 ?DO DUP I + C@ W, LOOP DROP 
  0 W,
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

: DIALOG_ITEM ( N id x y cx cy style class_id -- N+1 )
  || t ||
  HERE DUP -> t /DLGITEMTEMPLATE DUP ALLOT ERASE
  -1 W, W, \ class_id
  WS_VISIBLE OR WS_CHILD OR
  t DLGITEMTEMPLATE.style !
  t DLGITEMTEMPLATE.cy   W!
  t DLGITEMTEMPLATE.cx   W!
  t DLGITEMTEMPLATE.y    W!
  t DLGITEMTEMPLATE.x    W!
  t DLGITEMTEMPLATE.id   W!
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
  WS_BORDER OR WS_TABSTOP OR DI_Edit DIALOG_ITEM
;
: PUSHBUTTON ( N id x y cx cy -- N+1 )
  WS_TABSTOP DI_Button DIALOG_ITEM
;
: LTEXT ( N id x y cx cy -- N+1 )
  0 DI_Static DIALOG_ITEM
;

\ ----------------------------------------------------------------------

( Пример
0 0 102 64
WS_POPUP WS_SYSMENU OR WS_CAPTION OR DS_MODALFRAME OR
DS_SETFONT OR DS_CENTER OR

DIALOG: PasswordDialog Login

      8 0 FONT MS Sans Serif

      101 45  4 51 14 ES_AUTOHSCROLL                EDITTEXT
      102 45 25 51 14 ES_AUTOHSCROLL ES_PASSWORD OR EDITTEXT
     IDOK  5 45 40 14 PUSHBUTTON OK
 IDCANCEL 55 45 40 14 PUSHBUTTON Cancel
      105  6  7 37  8 LTEXT Name
      106  6 28 37  8 LTEXT Password

DIALOG;

\ сохранение диалога для DialogLoad
\ PasswordDialog @ HERE OVER - S" password_dialog.res" R/W CREATE-FILE THROW WRITE-FILE THROW
)
