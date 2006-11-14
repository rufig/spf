( Simple modal dialog example )

REQUIRE CWindow ~day\wfl\wfl.f

101 CONSTANT lvID

CDialog SUBCLASS CTestDialog

    CListView OBJ listView

W: WM_INITDIALOG ( lpar wpar msg hwnd -- n )

    lvID SUPER getDlgItem listView set

    listView getClientRect 2DROP NIP 2/

    0 OVER S" column1" listView insertColumn
    1 SWAP S" column2" listView insertColumn

    0 S" Test string1" listView insertString
    0 S" Test string2" listView insertString

    2DROP 2DROP TRUE
;

N: lvID ( nmhdr code -- retCode )
    LVN_ITEMACTIVATE =
    IF
       S" item activated" SUPER showMessage
    THEN
    DROP 0

;

;CLASS

0 0 150 100
WS_POPUP WS_SYSMENU OR WS_CAPTION OR DS_MODALFRAME OR
DS_SETFONT OR DS_CENTER OR

DIALOG: TestDialog WM_NOTIFY test

      8 0 FONT MS Sans Serif

      -1  6  7 140  8  0 LTEXT ListView, double-click any item
    lvID  6 17 137 80 LVS_REPORT LVS_SINGLESEL  OR LISTVIEW

DIALOG;


CTestDialog NEW dialog

: test
    TestDialog 0 dialog showModal DROP
;

test