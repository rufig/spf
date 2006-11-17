REQUIRE CWindow        ~day\wfl\wfl.f
REQUIRE CScintillaEdit ~day\wfl\controls\scintilla\scintilla.f
REQUIRE CurrentTimeSql ~ac\lib\win\date\unixtime.f

\ TODO: на пробеле и enter setUndoPoint
\ TODO: внизу вывод после запуска со сплиттером
\ TODO: подсветка синтаксиса

: ID: CREATE DUP , 1+ DOES> @ ;

201

ID: ID_OPEN
ID: ID_CLOSE
ID: ID_EXIT
ID: ID_UNDO
ID: ID_REDO
ID: ID_CUT
ID: ID_COPY
ID: ID_PASTE
ID: ID_DELETE
ID: ID_SELECTALL
ID: ID_TIMEDATE
ID: ID_NEW
ID: ID_SAVE
ID: ID_SAVEAS
ID: ID_PAGESETUP
ID: ID_PRINT
DROP

CFrameWindow SUBCLASS CScintillaNotepad

        CScintillaForthEdit OBJ edit
        CString OBJ fileName
        CString OBJ commandLine

123 CONSTANT editID


: appName S" FORTH notepad" ;

: setFileName ( addr u )
    2DUP fileName @ STR!
    <# HOLDS appName S"  - " HOLDS HOLDS 0. #>
    SUPER setText
;

W: WM_CREATE ( lpar wpar msg hwnd -- n )
    2DROP 2DROP
    editID SELF edit create DROP
    edit setFocus

    edit setLineNumbers
    edit setForthLexer

    S" new.f" setFileName
    FALSE
;

W: WM_DESTROY ( lpar wpar msg hwnd -- n )
   2DROP 2DROP 0
   0 PostQuitMessage DROP
;

W: WM_SIZE ( lpar wpar msg hwnd -- n )
   0 SUPER getClientRect Rect>Width 
   edit moveWindow
   2DROP 2DROP 0
;

FILTER: fn
   NAME" Forth files" EXT" *.f"
   NAME" Text files"  EXT" *.txt"
   NAME" All files"   EXT" *.*"
;FILTER


: saveText ( addr u )
     TYPE BYE
;

: saveFileName ( addr u -- )
     || CSaveFileDialog of ||
     S" Select FORTH file" of setTitle
     fn of setFilter
     SELF of showModal
     IF 
        of fileName saveText
        edit setSavePoint
        of fileName DROP setFileName
     THEN
;

: saveFileAs ( -- )
;

: saveFile (  -- )
   fileName @ STR@ saveFileName
;

: run
   saveFile
   \ TODO
;

: checkSave
    edit getModify
    IF
       MB_YESNO MB_ICONQUESTION OR
       S" FORTH notepad" DROP
       S" Would you like to save the file?" DROP
       SUPER checkWindow
       MessageBoxA IDYES =
       IF
          saveFile
       THEN
    THEN
;

M: ID_EXIT ( -- )
   checkSave
   SUPER destroyWindow
   0 PostQuitMessage DROP
;

M: ID_OPEN
   || COpenFileDialog of ||
   fn of setFilter
   S" Open FORTH source file" of setTitle
   SELF of showModal
   IF
      of fileName 
      IF 
         edit loadFile DROP 
         of fileName DROP setFileName
      THEN
   THEN
;

M: ID_UNDO   edit undo ;
M: ID_REDO   edit redo ;
M: ID_CUT    edit cut  ;
M: ID_COPY   edit copy  ;
M: ID_DELETE edit clear  ;
M: ID_PASTE  edit paste  ;
M: ID_SELECTALL  edit selectAll  ;
M: ID_TIMEDATE CurrentTimeSql -1 edit pasteText ;

M: ID_SAVE
    saveFile
;

M: ID_SAVEAS
    saveFileAs
;

M: ID_NEW
    checkSave
    edit clearAll
    edit setSavePoint
;

: createMenu ( -- h )
    MENU
       POPUP
          S" &New" ID_NEW   0 MENUITEM
          S" &Open" ID_OPEN 0 MENUITEM
          S" &Save" ID_SAVE   0 MENUITEM
          S" &Save As" ID_SAVEAS 0 MENUITEM
          MENUSEPARATOR
          S" &Page Setup..." ID_OPEN   0 MENUITEM
          S" &Print..." ID_CLOSE 0 MENUITEM
          MENUSEPARATOR
          S" &Exit" ID_EXIT   0 MENUITEM
       S" &File" END-POPUP

       POPUP
          S" Undo" ID_UNDO 0 MENUITEM
          S" Redo" ID_REDO 0 MENUITEM
          MENUSEPARATOR
          S" Cut" ID_CUT 0 MENUITEM
          S" Copy" ID_COPY 0 MENUITEM
          S" Paste" ID_PASTE 0 MENUITEM
          S" Delete" ID_DELETE 0 MENUITEM
          MENUSEPARATOR
          S" Find..." 0 0 MENUITEM
          S" Find Next" 0 0 MENUITEM
          S" Replace..." 0 0 MENUITEM
          S" Go To..." 0 0 MENUITEM
          MENUSEPARATOR
          S" Select All" ID_SELECTALL 0 MENUITEM
          S" Time/Date" ID_TIMEDATE 0 MENUITEM
       S" &Edit" END-POPUP

       POPUP 
          S" Font" 0 0 MENUITEM
       S" F&ormat" END-POPUP

       POPUP 
          S" &Run" 0 0 MENUITEM
          S" &Set command line" 0 0 MENUITEM
       S" &Run" END-POPUP

       POPUP 
          S" About" 0 0 MENUITEM
       S" &Help" END-POPUP

    END-MENU
;

;CLASS

: winTest ( -- n )
  || CScintillaNotepad wnd CMessageLoop loop ||

  0 wnd create DROP
  SW_SHOW wnd showWindow

  loop run
;

winTest
