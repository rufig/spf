\ $Id$

DIS-OPT
0 TO MM_SIZE
STARTLOG

\ Resolving conflicts first

S" ~yz/lib/common.f" INCLUDED \ Root of all evils..
REQUIRE tabcontrol ~ygrek/~yz/lib/wincc.f

WARNING @
WARNING OFF
 S" ~ac/lib/str5.f" INCLUDED \ " and "" conflicts
 S" ~profit/lib/logic.f" INCLUDED \ NOT conflicts
WARNING !

REQUIRE ACCERT-LEVEL lib/ext/debug/accert.f
1 ACCERT-LEVEL !

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f
REQUIRE replace-str- ~pinka/samples/2005/lib/replace-str.f
CREATE a\CR 0x0D C,
: \CR a\CR 1 ;

REQUIRE Z" ~af/lib/c/zstring.f
REQUIRE COMPARE-U ~ac/lib/string/compare-u.f
REQUIRE [IF] lib/include/tools.f
REQUIRE v[] ~ygrek/lib/vector.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE MGETMEM ~yz/lib/gmem.f
REQUIRE def-small-icon-il ~ygrek/~yz/lib/icons.f
REQUIRE LOAD-CONSTANTS ~yz/lib/const.f

S" ~ygrek/lib/data/scintilla.const" LOAD-CONSTANTS

REQUIRE AUS ~ygrek/lib/aus.f
REQUIRE SCN ~ygrek/prog/sci/struct.f
REQUIRE ENUM ~ygrek/lib/enum.f
REQUIRE NFA=> ~ygrek/lib/wid.f
REQUIRE >ASCIIZ ~ygrek/lib/string.f
REQUIRE /STRING lib/include/string.f

REQUIRE HEAP-ID ~pinka/spf/mem.f

MODULE: JOOP
REQUIRE OpenDialog ~day/joop/win/filedialogs.f
;MODULE

\ S" options.f" INCLUDED
S" help.f" INCLUDED

0 VALUE cur-ed
0 VALUE ed-tabs
4 svector VALUE parse-buf

: cur-ed-hwnd cur-ed -hwnd@ ;

: cur! TO cur-ed ;

S" options.f" INCLUDED

S" editors.f" INCLUDED

: scintilla-edit ( -- ctl )
  ACCERT( CR ." scintilla-edit "  DEPTH . )
  control ACCERT( DEPTH . )
  Z" Scintilla" (* ws_tabstop *) W: ws_ex_clientedge
  ACCERT( ." !!! " DEPTH . CR .S )
  create-control-exstyle 
  ACCERT( CR .S )
  DUP 0= IF ." scintilla-edit FAILED. This is a bug %)" CR ABORT THEN
  ACCERT( CR DUP . DEPTH . ) >R 
  ['] set-editfont -font R@ storeset
  0xFFFFFF R@ -bgcolor!
  R@ adjust-height
  R> 
  ACCERT( CR ." scintilla-edit done" ) ;

:NONAME 1+ DUP CONSTANT ; ENUM consts

MODULE: style
0 consts word-imm word-nrm notfound number parsed ; DROP
;MODULE

: FIND-CONST 2DUP FIND-CONSTANT 0= IF CR TYPE CR ABORT" Bad const" ELSE >R 2DROP R> THEN  ;

: SCI-CONST-CREATE
   PARSE-NAME 
   2DUP CREATED
   " SCI_{s}" STR@
   FIND-CONST , ;

C" SendMessageA" FIND NIP 0= [IF] WINAPI: SendMessageA USER32.DLL [THEN]

: send-message ( wparam lparam msg hwnd -- result) 2>R SWAP 2R> SendMessageA ;

: 0SCI: SCI-CONST-CREATE DOES> @ 0 0 ROT cur-ed-hwnd send-message ;
: 1SCI: SCI-CONST-CREATE DOES> @ 0 SWAP  cur-ed-hwnd send-message ;
: 2SCI: SCI-CONST-CREATE DOES> @         cur-ed-hwnd send-message ;

\ Использовать
\ 0SCI: f       f .
\ 1SCI: f     w f .
\ 2SCI: f   w l f .

' 0SCI: ENUM: 
    GetLexer 
    GetLineCount GetEndStyled GetCurrentPos 
    AutoCComplete AutoCCancel 
    CallTipCancel 
    GetSelectionStart GetSelectionEnd 
    GetLength 
    ClearDocumentStyle ;
' 1SCI: ENUM: 
    SetHScrollBar SetLexer 
    GetLineEndPosition LineFromPosition PositionFromLine 
    AutoCSetIgnoreCase SetMouseDwellTime 
    GetMarginWidthN 
    CallTipUseStyle 
    UsePopup ;
' 2SCI: ENUM: 
    Colourise SetKeywords GetTextRange 
    StartStyling SetStyling StyleSetFore StyleSetBack
    SetWordChars WordStartPosition WordEndPosition 
    AutoCShow CallTipShow 
    SetSel GetSelText ReplaceSel 
    InsertText SetText GetText 
    GetLine 
    SetMarginWidthN ;

0 VALUE styled

0 VALUE dexite

: (DEXIT) ." DEXIT " . ." DEPTH " DEPTH . RDROP EXIT ;

: DEXIT
   dexite LIT, dexite 1+ TO dexite POSTPONE (DEXIT) ; IMMEDIATE

: my-literal?
   DEPTH 2- >R 
    ['] ?SLITERAL1 CATCH
    IF RDROP 2DROP FALSE EXIT
    ELSE R> DEPTH 1- SWAP - 0 ?DO DROP LOOP TRUE EXIT THEN ;

: literal? ( a u -- ? )
   DUP 1 > IF OVER W@ 0x7830 ( 0x) = IF HEX-SLITERAL IF DROP TRUE EXIT ELSE FALSE EXIT THEN THEN THEN
    my-literal? ;

: select-style ( a u -- n )
   SFIND
   DUP 0 = IF DROP literal? IF style::number ELSE style::notfound THEN EXIT THEN
   DUP 1 = IF 2DROP style::word-imm EXIT THEN
   DUP -1 = IF 2DROP style::word-nrm EXIT THEN
   ABORT
;

: apply-style ( style -- )
   >IN @ styled - DUP 0 < IF 2DROP EXIT THEN 
   SWAP SetStyling DROP 
   >IN @ TO styled
;

\ EOF
: colorer
\   CR DEPTH .
   BEGIN
 \   ." B " DEPTH .
    >IN @ TO styled
    PARSE-NAME
    DUP
   WHILE
    2DUP select-style apply-style
    2DROP
  \  ." W " DEPTH .
    \ eval-word-in-box style::parsed apply-style
   REPEAT
   2DROP
   \ CR ." IN TIB " >IN @ . #TIB @ .
   \ >IN @ 2 + >IN !
   0 apply-style
   \ HERE .
\   DEPTH .
  ;

: MyStyle ( a u -- ) ['] colorer EVALUATE-WITH ;

: get-text ( start end -- s )
   ACCERT( CR ." get-text " 2DUP SWAP . . )
   2DUP - ABS 1+ ACCERT( DUP . ) ALLOCATE THROW { buf | [ 3 CELLS ] tr }
   tr init->>
   SWAP >>
   >>
   buf >>
   0 tr GetTextRange buf SWAP >STR
   buf FREE THROW
   ACCERT( DUP . ." get-text done" ) ;

MODULE: match_impl

USER-VALUE match-a
USER-VALUE match-u

EXPORT

: //au ( a u // )
   PRO
   DUP
   match-u < IF 2DROP EXIT THEN
   OVER
   match-u match-a match-u COMPARE-U 0= IF CONT THEN 2DROP ;

: MATCH=> ( a u -- )
   TO match-u TO match-a
   PRO CONTEXT @ NFA=> DUP COUNT //au CONT ;

: matching ( a u -- s ) LAMBDA{ START{ MATCH=> 2DUP TYPE SPACE }EMERGE } TYPE>STR ;

;MODULE

: get-help ( a u -- s )
   { | s }
   ACCERT( CR ." get-help " DEPTH . )
   " HELP {s}" -> s
   s STR@ ['] EVALUATE TYPE>STR-CATCH IF ( a u str-result ) STRFREE 2DROP " no help" THEN
   s STRFREE
   -> s
   \ remove linefeeds
   s STR@ 10 + DUMP
   s " {\CR}" "" replace-str-
   s STR@ 10 + DUMP
   s STR@ OEM>ANSI 2DROP \ HELP uses CP866 encoded files
   s STR@ 10 + DUMP
   s
   ACCERT( CR ." get help done " DEPTH . )
;

: get-line ( i -- parse-buf u )
   DUP 0 GetLine 1+ \ bytes needed
   parse-buf vresize
   parse-buf vptr GetLine parse-buf vptr SWAP ;

: update-status
   GetLength " {n}" DUP STR@ DROP 0 winmain set-status STRFREE 
   ed-tabs -selected@ editors-path@ 1 winmain set-status
;

\ EOF

MESSAGES: my

\ colour the text based on the SFIND and SLITERAL info
M: SCN_STYLENEEDED { | scn }
   TEMPAUS SCN scn

   lparam TO scn

   GetEndStyled LineFromPosition 0 MAX
   scn. position @ LineFromPosition 0 MAX
   ( l1 l2 ) \ 2DUP SWAP CR ." l1 l2 " . .
   2DUP < IF SWAP THEN
   SWAP 1+ SWAP
   ?DO 
    ACCERT( CR ." Styling line: " I . DEPTH . )
    I PositionFromLine 0x1F StartStyling DROP
    I get-line MyStyle
    ACCERT( CR ." Done line " I . DEPTH . )
   LOOP
   ACCERT( CR ." STYLENEDED DONE" )
M;

\ monitor chars from the user
\ and display the list of the words suitable for completion
M: SCN_CHARADDED 
    { | scn s sauto }
    TEMPAUS SCN scn
    lparam TO scn
    scn. ch @ BL = IF EXIT THEN

    GetCurrentPos 
    DUP TRUE WordStartPosition

    ( end start )
    2DUP - DUP 3 < IF DROP 2DROP EXIT THEN
    >R
    SWAP   ( start end )
    get-text -> s

    s STR@ matching -> sauto
    s STR@ TYPE
    sauto STR@ TYPE
    s STRFREE
    sauto STR@ 0= IF DROP RDROP AutoCCancel DROP EXIT THEN
    R> SWAP AutoCShow DROP
M;

\ display a calltip if the mouse has stopped for a while
\ search the word under the cursor (or selection if present) in the help system
M: SCN_DWELLSTART
   DEPTH .
   CR ." heap : " HEAP-ID .
   lparam { scn | pos s }
   TEMPAUS SCN scn

   scn. position @ -> pos

   ACCERT( CR ." dwell : " pos . )

   GetSelectionStart GetSelectionEnd 
   2DUP <> 
   IF
    DUP -> pos
   ELSE
    2DROP
    pos TRUE WordStartPosition
    pos TRUE WordEndPosition
    2DUP = IF ACCERT( ." no" ) 2DROP EXIT THEN
   THEN
   get-text DUP STR@ get-help -> s STRFREE
   s STRLEN IF
     pos s STRA CallTipShow DROP
   THEN
   s STRFREE
   ACCERT( DEPTH . ." ok")
M;

\ mouse moved - kill calltip
M: SCN_DWELLEND
   ACCERT( ." DWELLEND" )
   CallTipCancel DROP
M;

\ clicking mouse on the call tip will reset it
M: SCN_CALLTIPCLICK
   CallTipCancel DROP
M;

: H. BASE @ >R HEX . R> BASE ! ;

\ User selected autocompletion
\ Insert the text manually and append space character
M: SCN_AUTOCSELECTION
   lparam { scn } TEMPAUS SCN scn

   scn. lParam @ 
   GetCurrentPos SetSel DROP

   scn. text @ ASCIIZ> " {s} " >R
   0 R@ STR@ DROP ReplaceSel DROP
   R> STRFREE

   AutoCCancel DROP
M;

\ useless info - the size of the text in the status bar
M: SCN_MODIFIED
   update-status
M;

MESSAGES;

0 VALUE menu-rclick

MESSAGES: my-wnd

M: wm_contextmenu
  menu-rclick lparam LOWORD lparam HIWORD show-menu
  TRUE
M;

MESSAGES;

: edit-grid
   ACCERT( CR ." edit-grid " DEPTH . )
   GRID 
     scintilla-edit
     this TO cur-ed
     -xspan -yspan | 
   GRID; 
   ACCERT( CR ." edit-grid done " DEPTH . )
  ;

\ 0xFF0000 = 0 0 255 RGB
\ 0xbbggrr = rr gg bb RGB
\
: RGB ( r g b -- u )
 0xFF AND 16 LSHIFT -ROT
 0xFF AND  8 LSHIFT -ROT
 0xFF AND  OR OR ;

: get-all-word-chars ( -- z ) 
  256 parse-buf vresize
  parse-buf vptr init->> 
  255 0 DO I IsDelimiter 0= IF I C>> THEN LOOP 
  0>>
  parse-buf vptr ;

: prepare 
   FALSE SetHScrollBar DROP
   \ CR ." lexer: " GetLexer .
   W: SCLEX_CONTAINER SetLexer DROP
   \ CR ." lexer: " GetLexer .
   my cur-ed -notify!
   my-wnd winmain -wndproc!
   style::word-nrm 0xFF0000 StyleSetFore DROP  
   style::notfound 0x000000 StyleSetFore DROP
   style::word-imm 0x0000FF StyleSetFore DROP
   style::number 0x00FF00 StyleSetFore DROP
   style::parsed 0xFF00FF StyleSetFore DROP
   0 get-all-word-chars SetWordChars DROP
   TRUE AutoCSetIgnoreCase DROP
   600 SetMouseDwellTime DROP
   5 0 DO I 0 SetMarginWidthN DROP LOOP
   \ W: STYLE_CALLTIP 0x00FF00 StyleSetFore DROP
   \ W: STYLE_CALLTIP 0xFFFFFF StyleSetBack DROP
   \ 0 CallTipUseStyle .
   \ 0 20 SetMarginWidthN DROP
   0 UsePopup DROP
   ;

: sci-dll=>
    PRO 
    Z" Scintilla.dll" CONT 
    Z" SciLexer.dll" CONT
   ;

: Scintilla-init
    PREDICATE sci-dll=> LoadLibraryA ONTRUE DROP SUCCEEDS 0= ABORT" Failed to load scintilla dll" ;

: load-file ( a u -- )
   ClearDocumentStyle DROP
   2DUP FILE DUP 0= IF 2DROP " Cant open file {s}" DUP STR@ DROP msg STRFREE EXIT THEN
   2SWAP 2DROP
   >ASCIIZ \ we have extra CELL there, so dont worry
   0 OVER SetText DROP
   FREE THROW ;

: TO-FILE ( a u name name-u -- ior ) 
   R/W CREATE-FILE ?DUP IF >R DROP 2DROP R> EXIT THEN
   DUP >R WRITE-FILE ?DUP IF RDROP EXIT THEN
   R> CLOSE-FILE ;

: save-file { a u | m l -- }
  GetLength -> l
  l 1+ ALLOCATE THROW -> m
  l m GetText DROP
  m l a u TO-FILE IF a u " Cant save to file {s}" DUP STR@ DROP msg STRFREE THEN
  m FREE THROW ;

: CUT-NAME ( a u -- a2 u2 )
  2DUP 
  CUT-PATH NIP
  /STRING ;

: new-editor { a u | ed z }
    ACCERT( CR ." New editor" )
    edit-grid
    ACCERT( CR ." here 1" )
    a u CZMGETMEM -> z
    ACCERT( CR ." here 2" )
    z cur-ed editors-add -> ed
    ACCERT( CR ." HERE" )
    ( grid) z ASCIIZ> CUT-NAME DROP 0 ed ed-tabs add-item
    ed ed-tabs switch-tab 
    prepare
    ACCERT( CR ." New editor done" )
  ;

ALSO JOOP
  FILTER: filter-all-files
    NAME" all files" EXT" *.*"
  ;FILTER

  PROC: menu-file-load { | tt }
    ACCERT( CR ." menu-file-load " DEPTH . )
    OpenDialog :new -> tt
    filter-all-files tt :setFilter
    tt :execute 0= IF EXIT THEN
    tt :fileName new-editor
    winmain resize-window-grid 
    tt :fileName load-file
    cur-ed winfocus
    tt :free
    ACCERT( CR ." menu-file-load done" DEPTH . )
  PROC;

  PROC: menu-file-save { | tt }
    SaveDialog :new -> tt
    filter-all-files tt :setFilter
    tt :execute 0= IF EXIT THEN
    tt :fileName save-file
    tt :free
  PROC;

PREVIOUS

PROC: menu-quit
  W: wm_close winmain send DROP
PROC;

MENU: menu-file
  menu-file-load MENUITEM &Open
  menu-file-save MENUITEM &Save
  menu-quit MENUITEM E&xit
MENU;

PROC: menu-options1
  F.Options::my-dlg EXECUTE
PROC;

MENU: menu-options
  menu-options1 MENUITEM &Options
MENU;

MENU: menu-main
  menu-file SUBMENU &File
\  menu-options SUBMENU &Options
MENU;

PROC: menu-check
  Z" check passed" msg
PROC;

MENU: menu-rclick1
  menu-check MENUITEM &Check
MENU;

menu-rclick1 TO menu-rclick

: create-tabs ( -- ctl )
  0 tabcontrol
  LAMBDA{ 
    thisctl -selected@ editors-ctl@ TO cur-ed 
    cur-ed winfocus
    update-status
    }
  this -command!
  this TO ed-tabs
  def-small-icon-il this -imagelist!
  S" empty" new-editor
  -xspan
  -yspan
;

: run
   Scintilla-init

   CR ." heap : " HEAP-ID .

   WINDOWS...
     0 create-window TO winmain
     Z" Arial Cyr" 10 create-font default-font
     Z" Scintilla Forth Editor ;)" winmain -text!
     GRID
       create-tabs |
     GRID;
     winmain -grid!

     winmain create-status
     DATA[ 40 , -1 , ]DATA 2 winmain split-status
     update-status

     menu-main winmain attach-menubar

     600 400 winmain winresize
     winmain wincenter
     winmain winshow
     cur-ed winfocus
   ...WINDOWS
   BYE
   ;

run \EOF 
0 TO SPF-INIT? 
:NONAME run BYE ; MAINX ! 
S" sciforthed.exe" " {ModuleDirName}src/spf.fres" STR@ devel\~af\lib\save.f BYE
