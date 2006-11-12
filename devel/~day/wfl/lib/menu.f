\ Высокоуровневая поддержка меню

\ Для начала описываем структуру меню с идентификаторами
\ Затем описываем методы типа M: ID_OPEN .... ;
\ cоздаем меню, WM_COMMAND обрабатывает клики

REQUIRE CStack ~day\hype3\lib\stack.f
REQUIRE { lib\ext\locals.f
REQUIRE WFUNC ~day\winfactory\lib\wfunc.f

USER-VALUE PopupStack

: MENU ( -- )
    CStack NewObj TO PopupStack
    CreateMenu
    PopupStack :: CStack.push
;

: POPUPMENU
    CStack NewObj TO PopupStack
    CreatePopupMenu
    PopupStack :: CStack.push
;

: POPUP
    CreateMenu
    PopupStack :: CStack.push    
;

: MENUITEM { c-addr u id flag -- }
    c-addr id MF_STRING flag OR PopupStack :: CStack.top
    AppendMenuA -WIN-THROW
;

: MENUSEPARATOR
    0 0 MF_SEPARATOR PopupStack :: CStack.top
    AppendMenuA -WIN-THROW
;

: MENUOWNERDRAW ( item-data id )
    MF_OWNERDRAW  PopupStack :: CStack.top
    AppendMenuA -WIN-THROW
;

: END-POPUP ( c-addr u -- )
   DROP PopupStack :: CStack.pop
   MF_POPUP
   PopupStack :: CStack.top
   AppendMenuA -WIN-THROW
;

: END-MENU
    PopupStack :: CStack.pop
    PopupStack ^ dispose
;

\EOF Тесты

: menu \ -- h
    MENU
       S" test" 101 MF_GRAYED MENUITEM
       S" test2" 101 0 MENUITEM
       POPUP
          S" test" 101 0 MENUITEM
          S" test2" 101 0 MENUITEM
       S" open" END-POPUP    
    END-MENU .
;    
: popup \ -- h
    POPUPMENU
       S" test" 101 0 MENUITEM
       S" test2" 101 0 MENUITEM
       POPUP
          S" test" 101 0 MENUITEM
          S" test2" 101 0 MENUITEM
       S" open" END-POPUP    
    END-MENU .
;

menu
popup