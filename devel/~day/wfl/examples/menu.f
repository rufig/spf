\ Оформить в пример. В CWindow достаточно перегрузить createMenu

M: 101 ( -- )
   S" ура!" SUPER showMessage
;

C: 123456 ( code -- )
   BN_CLICKED =
   IF
     S" трям!" SUPER showMessage
   THEN
;
: createMenu \ -- h
    MENU
       S" test" 101 MF_GRAYED MENUITEM
       S" test2" 101 0 MENUITEM
       POPUP
          S" test" 101 0 MENUITEM
          S" test2" 101 0 MENUITEM
       S" open" END-POPUP    
    END-MENU
;    
