\  онтролы Windows

REQUIRE Window  ~day\joop\win\window.f

\ from AC

USER CC_INIT \ однократна€ инициализаци€ CommonControls
CREATE   CC_INITS 8 , BASE @ HEX 3FFF , BASE !

: InitCommonControls
  CC_INIT @ IF EXIT THEN
  CC_INITS InitCommonControlsEx DROP
  S" RICHED32.DLL" DROP LoadLibraryA DROP
  S" RICHED20.DLL" DROP LoadLibraryA DROP
  TRUE CC_INIT !
;

REQUIRE Window  ~day\joop\win\window.f

<< :type
<< :goParent
<< :install
<< :create
<< :style
<< :exStyle

pvar: <style
pvar: <exStyle
pvar: <OnClick
pvar: <font

CLASS: Control <SUPER Window
        
        CELL VAR OnClick \ —обытие
        CELL VAR style 
        CELL VAR addStyle
        CELL VAR exStyle
        CELL VAR hParent

: :init self :style style !
        self :exStyle exStyle !
;

: :goParent ( addr)
    @ ?DUP IF hParent @ HANDLE>OBJ SWAP EXECUTE THEN
;

: :create { owner -- }
    InitCommonControls
    0
    HINST
    self       \ id
    owner DUP IF <handle @ THEN
    DUP hParent !
    0 0 0 0
    WS_CHILD style @ OR
    0
    self :type DROP
    exStyle @
    CreateWindow self obj!
    hParent @ HANDLE>OBJ <font @ \ ”становить фонт родител€
    <handle @ self :setFont
;

: :install ( addr u x y h w parentObj -- )
     self :create
     self :move
     self :setText
     self :show
;

: :exStyle 0 ;

: :style 0 ;

;CLASS



CLASS: Button <SUPER Control

: :type S" button" ;

: :style  BS_PUSHBUTTON ;
        
C: BN_CLICKED OnClick self :goParent ;

;CLASS

CLASS: CheckBox <SUPER Button

: :style BS_AUTOCHECKBOX ;

: :checked ( -- f)
   0 0 BM_GETCHECK
   handle @ SendMessageA
   BST_CHECKED  = ;

;CLASS

<< :checked

\ \\\\\\\\\\\\\\\\\\\\\ Edit control \\\\\\\\\\\\\\\\\\\\\\\\\\

<< :setLimit

CLASS: Edit <SUPER Control

: :type S" edit" ;

: :style  ES_AUTOHSCROLL ;

: :exStyle WS_EX_CLIENTEDGE ;

: :setLimit ( u)
    0 SWAP EM_SETLIMITTEXT handle @ SendMessageA DROP
;

;CLASS

CLASS: Static <SUPER Control

: :type S" static" ;

;CLASS

\ \\\\\\\\\ ListBox \\\\\\\\\\\\\\\\\\\\\\

<< :add

CLASS: ListBox <SUPER Control

        
: :style        
    LBS_NOTIFY WS_VSCROLL OR
;
: :exStyle WS_EX_CLIENTEDGE ;

: :type
   S" listbox"
;


: :add ( addr u -- )
    DROP 0 LB_ADDSTRING handle @ SendMessageA DROP
;

\ ≈сли нет выбранных, то возвращает -1
: :current ( -- u )
    0 0 LB_GETCURSEL handle @ SendMessageA  DUP LB_ERR =
    IF DROP -1 THEN
;

\ ¬озвращает число оставшихс€ элементов или -1 если
\ исходный индех был неправилен
: :delete ( u1 -- u2 )
    0 SWAP LB_DELETESTRING handle @ SendMessageA
    DUP LB_ERR = IF DROP -1 THEN    
;

\ ƒает индекс элемента на котором щелкнули мышью
: :itemFromPoint ( -- u )
    0. >R >R RP@
    GetCursorPos DROP RP@ handle @ ScreenToClient DROP
    R> R>  16 LSHIFT OR
    0 LB_ITEMFROMPOINT handle @ SendMessageA LOWORD
;

C: BN_CLICKED OnClick self :goParent ;

;CLASS

\ \\\\\\\\\\\\\\\\\\\ Scroll bar \\\\\\\\\\\\\\\\\\\\\\\\\\\\

CLASS: ScrollBar <SUPER Control

        CELL VAR pos

: :type S" scrollbar" ;

: :style SBS_VERT ;

: :setRange ( min max )
    TRUE ROT ROT
    SWAP SB_CTL 
    handle @
    SetScrollRange DROP
;

: :getPos ( u)
    SB_CTL handle @
    GetScrollPos
;

: :setPos ( u)
    DUP
    TRUE SWAP
    SB_CTL handle @
    SetScrollPos DROP
    pos !
;
    
;CLASS

<< :setRange
<< :getPos
<< :setPos

pvar: <pos

WM_USER 1 + CONSTANT PBM_SETRANGE        \ установить новые значени€ от и до
WM_USER 2 + CONSTANT PBM_SETPOS          \ установить новую позицию в %
WM_USER 3 + CONSTANT PBM_DELTAPOS        \ продвигает линию на n позиций
WM_USER 4 + CONSTANT PBM_SETSTEP         \ устанавливает приращение шага ѕо умолчанию = 10
WM_USER 5 + CONSTANT PBM_STEPIT          \ увеличивает на 1 текущее приращение
WM_USER 6 + CONSTANT PBM_SETRANGE32
WM_USER 7 + CONSTANT PBM_GETRANGE        \ получить значени€ от и до
WM_USER 8 + CONSTANT PBM_GETPOS          \ получить позицию

CLASS: ProgressBar <SUPER Control

: :type S" msctls_progress32" ;
: :style 0 ;

: :setRange ( min max )
     16 LSHIFT OR
     0
     PBM_SETRANGE
     handle @ SendMessageA DROP
;
: :setPos ( u )
     0 SWAP
     PBM_SETPOS
     handle @ SendMessageA DROP
;

;CLASS
