\ Высокоуровневая поддержка меню
\ Радуйтесь фортеры, Windows укрощается...

\ Для начала описываем структуру меню с идентификаторами
\ Затем описываем методы типа M: ID_OPEN .... ;
\ cоздаем меню, WM_COMMAND обрабатывает клики

 REQUIRE RegisterClassExA  ~nn/lib/win/wfunc.f
REQUIRE Stack ~nn/class/stack.f
REQUIRE { lib/ext/locals.f
REQUIRE (WIN-SHOW-CONST) ~nn\lib\wincon.f


USER-VALUE PopupStack

WITH Stack

: MENU ( -- )
    Stack NEW TO PopupStack
    CreateMenu
    PopupStack => Push
;

: POPUPMENU
    Stack NEW TO PopupStack
    CreatePopupMenu
    PopupStack => Push
;

: POPUP
    CreateMenu
    PopupStack => Push
;

: MENUITEM { c-addr u id -- }
    c-addr id MF_STRING PopupStack => Top
    AppendMenuA DROP
;

: MENUSEPARATOR
    0 0 MF_SEPARATOR PopupStack => Top
    AppendMenuA DROP
;

: END-POPUP ( c-addr u -- )
   DROP PopupStack => Top
   MF_POPUP
   PopupStack => Drop
   PopupStack => Top
   AppendMenuA DROP
;

: END-MENU
    PopupStack => Base @
    PopupStack DELETE
;
ENDWITH

\EOF
: MakeMenu \ -- h
    MENU
       S" test" 101 MENUITEM
       S" test2" 101 MENUITEM
       POPUP
          S" test" 101 MENUITEM
          S" test2" 101 MENUITEM
       S" open" END-POPUP
    END-MENU
\    DUP menu !
;
: MakePopup \ -- h
    POPUPMENU
       S" test" 101 MENUITEM
       S" test2" 101 MENUITEM
       POPUP
          S" test" 101 MENUITEM
          S" test2" 101 MENUITEM
       S" open" END-POPUP
    END-MENU
\    DUP popupMenu !
;


 window-ac.f
\ ~nn\lib\win\trayicon.f

0 S" static" 0 0 Window 0 100 100 TPM_RETURNCMD MakePopup TrackPopupMenu .

