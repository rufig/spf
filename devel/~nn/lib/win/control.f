\ Контролы Windows
REQUIRE CLASS:       ~nn/class/class.f
REQUIRE Window       ~nn/lib/win/window.f
REQUIRE FrameWindow  ~nn/lib/win/framewindow.f

10 VALUE row_h
10 VALUE col_w
0 VALUE 1st-row
0 VALUE 1st-col
: row ( # -- row ) row_h * 1st-row + row_h + ;
: col ( # -- col ) col_w * 1st-col + ;
: cols ( # -- cols) col_w * ;


CLASS: Control <SUPER Window
        var vOwner
        var OnClick \ Событие
        var OnDoubleClick \ Событие
        var OnRClick \ Событие
        var OnRDoubleClick \ Событие
        var OrigProc \ адрес стандартного обработчика сообщений

M: pos ( x y -- ) ToPixels pos ;
M: set_pos ( x y -- ) ToPixels vWidth @ vHeight @ MovePixels ;
M: size ( w h -- ) ToPixels size ;
M: ps ( row col w h -- )
    row_h * SWAP cols SWAP size
    col SWAP row pos ;

M: GoParent ( addr --)
    @ ?DUP IF hParent @ HANDLE>OBJ SWAP >EXT-ENTRY EXECUTE THEN
;


VM: Type ( -- a u ) S" control" ;

M: ToOrigProc ( -- )
    lparam @ wparam @ message @ hwnd @ OrigProc @ API-CALL
;

:NONAME { lparam wparam uint hwnd \ heap dep -- }
\     HEX ." WinProc: " hwnd . uint . wparam . lparam . CR DECIMAL
     DEPTH  TO dep
     THREAD-HEAP @ TO heap
     MAIN-HEAP THREAD-HEAP !

     hwnd HANDLE>OBJ ?DUP
     IF
       uint OVER [CHAR] W SearchWM
       IF
           lparam wparam uint hwnd DUP HANDLE>OBJ => FillMessage
           SWAP ExecuteMethod
       ELSE
         DROP
         lparam wparam uint hwnd DUP HANDLE>OBJ => OrigProc @ API-CALL
       THEN
     THEN
     heap THREAD-HEAP !
     dep DEPTH - 0= IF 0 THEN
;

WNDPROC: ContrProc

    USER CC-Init? \ однократная инициализация CommonControls
    CREATE   CC_INITS 8 , BASE @ HEX 3FFF , BASE !

    WINAPI: InitCommonControlsEx COMCTL32.DLL

    : InitCommonControls
      CC-Init? @ IF EXIT THEN
      CC_INITS InitCommonControlsEx DROP
      S" RICHED32.DLL" DROP LoadLibraryA DROP
      S" RICHED20.DLL" DROP LoadLibraryA DROP
      TRUE CC-Init? !
    ;

VM: AfterCreate ;
M: Create ( owner -- )
    InitCommonControls
    DUP vOwner !
\    WS_EX_CONTROLPARENT vExStyle @ OR vExStyle !
    Create
    hParent @ HANDLE>OBJ ->CLASS FrameWindow vFont @ \ Установить фонт родителя
    ->CLASS Font handle @ SetFont
    AfterCreate
;

    FrameWindow REOPEN
        : create-control this SWAP NodeValue ->CLASS Control Create ;
        M: AutoCreate ['] create-control vAutoList DoList ;
    ;CLASS

M: auto this jthis ->CLASS FrameWindow AddAuto ;
M: a auto ;
M: tabstop WS_TABSTOP vStyle @ OR vStyle ! ;

M: SetOwnProc
    ['] ContrProc GWL_WNDPROC handle @ SetWindowLongA OrigProc ! ;

M: Install ( addr u x y h w parentObj -- )
     Create
     Move
     SetText
     Show
;

;CLASS

CLASS: Button <SUPER Control

    VM: Type S" button" ;

    VM: Style  BS_PUSHBUTTON ;

    C: BN_CLICKED OnClick GoParent ;

    M: GetState ( -- state ) 0 0 BM_GETSTATE SendMessage ;
    M: SetState ( state -- ) 0 SWAP BM_SETSTATE SendMessage DROP ;

    M: SetStyle ( redraw_state style -- )  BM_SETSTYLE SendMessage DROP ;

    M: SetImage ( himg img-type -- )       BM_SETIMAGE SendMessage DROP ;
    M: GetImage ( img-type -- himg ) 0 SWAP BM_GETIMAGE  SendMessage ;

    M: GetCheck ( -- state) 0 0 BM_GETCHECK SendMessage BST_CHECKED = ;
    M: SetCheck ( state -- ) 0 SWAP BM_SETCHECK SendMessage DROP ;
    M: Checked      BST_CHECKED SetCheck ;
    M: Unchecked    BST_UNCHECKED SetCheck ;
    M: ?Check  IF Checked ELSE Unchecked THEN ;
    M: Intermediate BST_INDETERMINATE SetCheck ;
\    M: on  1 SetState ;
\    M: off 0 SetState ;
;CLASS

CLASS: GroupBox <SUPER Button
\    VM: Type S" button" ;

    VM: Style  BS_GROUPBOX ;
;CLASS

CLASS: CheckBox <SUPER Button
    VM: Style BS_AUTOCHECKBOX ;
;CLASS

CLASS: RadioButton <SUPER Button
\ << :setLimit
    VM: Style BS_AUTORADIOBUTTON ;
;CLASS

CLASS: Edit <SUPER Control
    var OnChange
    var OnLeave

VM: Type S" edit" ;

VM: Style  ES_AUTOHSCROLL WS_TABSTOP OR ;

VM: ExStyle WS_EX_CLIENTEDGE ;

M: SetLimit ( u -- )   0 SWAP EM_LIMITTEXT handle @ SendMessageA DROP ;
M: GetPos ( -- u ) 0 0 EM_GETSEL SendMessage LOWORD ;
M: SetPos ( u -- ) DUP EM_SETSEL SendMessage DROP ;
M: GetLine ( buf size idx -- a u ) >R OVER ! DUP R> EM_GETLINE SendMessage  ;
M: LineCount ( -- num) 0 0 EM_GETLINECOUNT SendMessage ;
M: TabStops ( n -- ) SP@ 1 EM_SETTABSTOPS SendMessage 2DROP ;

( : W: WM_CHAR
    BASE @ HEX
    wparam @ . BASE !
    TRUE
;
)

C: EN_CHANGE  OnChange GoParent ;
C: EN_KILLFOCUS OnLeave GoParent ;
;CLASS

CLASS: Static <SUPER Control

VM: Type S" static" ;

;CLASS

\ \\\\\\\\\ ListBox \\\\\\\\\\\\\\\\\\\\\\

CLASS: ListBox <SUPER Control

VM: Style  LBS_NOTIFY WS_VSCROLL OR ( WS_OVERLAPPED OR) ;
VM: ExStyle WS_EX_CLIENTEDGE ;

VM: Type S" listbox" ;

VM: Add ( addr u -- )  DROP 0 LB_ADDSTRING SendMessage DROP ;
M: Insert ( a u idx )  NIP LB_INSERTSTRING SendMessage  DROP ;

M: FromFile { a u \ h buf -- }
    a u R/O OPEN-FILE-SHARED THROW TO h
    256 ALLOCATE THROW TO buf
    BEGIN buf 256 h READ-LINE THROW WHILE
        buf SWAP 2DUP + 0 SWAP C! Add
    REPEAT
    h CLOSE-FILE DROP
    buf FREE DROP
;

\ Если нет выбранных, то возвращает -1
M: Current ( -- u )
    0 0 LB_GETCURSEL SendMessage  DUP LB_ERR =
    IF DROP -1 THEN
;

\ Возвращает число оставшихся элементов или -1 если
\ исходный индех был неправилен
M: Delete ( u1 -- u2 )
    0 SWAP LB_DELETESTRING SendMessage
    DUP LB_ERR = IF DROP -1 THEN
;

\ Дает индекс элемента на котором щелкнули мышью
M: ItemFromPoint ( -- u )
    0. >R >R RP@
    GetCursorPos DROP RP@ handle @ ScreenToClient DROP
    R> R>  16 LSHIFT OR
    0 LB_ITEMFROMPOINT SendMessage LOWORD
;

M: Get ( a index -- a u )  OVER SWAP LB_GETTEXT SendMessage ;

M: Length ( - u ) 0 0 LB_GETCOUNT SendMessage ;

C: LBN_DBLCLK OnDoubleClick GoParent ;
C: BN_CLICKED OnClick GoParent ;
\ C: BN_DOUBLECLICKED OnDoubleClick GoParent ;

;CLASS

CLASS: Bevel <SUPER Static
VM: Style SS_ETCHEDHORZ WS_VISIBLE OR ;
VM: ExStyle WS_EX_LEFT WS_EX_LTRREADING OR WS_EX_STATICEDGE OR
    WS_EX_RIGHTSCROLLBAR OR WS_EX_NOPARENTNOTIFY OR ;
;CLASS

CLASS: ProgressBar <SUPER Control

VM: Type S" msctls_progress32" ;
VM: Style 0 ;

M: SetRange ( min max )
     16 LSHIFT OR
     0
     PBM_SETRANGE
     handle @ SendMessageA DROP
;
M: SetPos ( u )
     0 SWAP
     PBM_SETPOS
     handle @ SendMessageA DROP
;

;CLASS
