\ Инcталлятор для SPF
\ Прописывает значения в реестре или удаляет их оттуда
\
\ ~ygrek
\ 14.Jan.2006

REQUIRE button  ~yz/lib/wincc.f
REQUIRE ENUM  ~ygrek/lib/enum.f
MODULE: BAC4TH \ START conflicts
REQUIRE PRO ~profit/lib/bac4th.f
;MODULE
REQUIRE >ASCIIZ ~ygrek/lib/string.f
REQUIRE /STRING lib/include/string.f
REQUIRE winlib-icons ~ygrek/~yz/lib/icons.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE load-bitmap ~vsp/lib/images.f
REQUIRE ChildApp ~ac/lib/win/process/child_app.f
REQUIRE kill ~ac/lib/win/process/kill.f
REQUIRE DUP-HANDLE-INHERITED ~ac/lib/win/process/pipes.f
REQUIRE CREATE-ANON-PIPE ~ygrek/lib/win/pipes.f
ALSO A-STR
REQUIRE FIND-FILES-R ~ac/lib/win/file/findfile-r.f
PREVIOUS
REQUIRE ULIKE ~pinka/lib/like.f
REQUIRE ShellGetDir ~ygrek/lib/win/shell.f


MODULE: joopwin \ W: и M: начинают конфликтовать

REQUIRE OpenDialog ~day/joop/win/filedialogs.f

<< :initial!

CLASS: MyOpenDialog <SUPER OpenDialog

: :initial! ( path -- )
   lpstrInitialDir ! 
;
;CLASS


<< :defExt!

CLASS: MySaveDialog <SUPER SaveDialog

: :defExt! ( path -- )
   lpstrDefExt ! 
;

;CLASS

;MODULE

MODULE: gui

:NONAME 0 VALUE ; ENUM values

values  edit-path farmanager scriptmap explorer ;

100 VALUE anime-step-ms
ALSO BAC4TH
: anim-strings PRO "  \\" CONT "  |" CONT "  /" CONT "  -" CONT ;
PREVIOUS
: anime-status-main ( -- ) 
  anim-strings ( a u )
  0 winmain set-status 
  anime-step-ms PAUSE ;
: set-main-status ( z -- ) 2 0 DO anime-status-main LOOP  0 winmain set-status ;

HERE 0 , VALUE pNULL
: s0 pNULL 1 ;

ALSO joopwin

FILTER: reg-file-filter
 NAME" Registry files" EXT" *.reg"
 NAME" All files" EXT" *.*"
;FILTER

PROC: generate { | fdlg -- }
  MySaveDialog :new -> fdlg
  " reg" fdlg :defExt!
  reg-file-filter fdlg :setFilter
  S" Select the file to save SPF registry settings to." fdlg :setTitle
  fdlg :execute IF
    fdlg :fileName vect-generate
  THEN
  fdlg :free
PROC;

PREVIOUS

: path@ ( buf -- )
  edit-path -text@ ;

: reg-grid ( -- g )
  GRID
    " Path to spf.exe : " label 
    -yfixed |
    ===
    edit  200 this limit-edit -xspan  this TO edit-path  
        " Path to the SPF executable" this -tooltip! 
    -yfixed |
    ===
    GRID
    " Associate .spf and .f file types with spf.exe in : " label |
    ===
    " Explorer" checkbox  this TO explorer  
        " Check to associate forth files with spf.exe in Explorer. You will be able to run them by simply double-clicking. Uncheck to delete the current association" 
        this -tooltip! 
        \ ttp this -notify!
\        this W: ttm_getmaxtipwidth ?send .
\        50 this W: ttm_setmaxtipwidth common-tooltip-op
 \       this W: ttm_getmaxtipwidth ?send .
         |
    ===
    " FAR Manager" checkbox  this TO farmanager 
        " Check to associate *.f and *.spf files with spf.exe in FAR manager" this -tooltip! |
    ===
    " Script Map" checkbox  this TO scriptmap 
        " Check to add forth files to the W3SVC script map" this -tooltip! |
    -bevel
    GRID; -xspan -yfixed |
    ===
    "   Apply  " button -xspan
    ['] onClick-install this -command! 
    " Checked boxes will result in setting the corresponding value in the registry. Cleared boxes will delete the setting from the registry" 
    this -tooltip! |

    " Generate .reg file" button -xspan
    generate this -command! 
    " Save the current settings to the .reg file so that you can manually incorporate it in the registry later" 
    this -tooltip! |
  GRID;
  ;


MODULE: fhlp
S" ~ygrek/prog/fhlp/convert.f" INCLUDED
;MODULE

0 VALUE listf

: match { a1 u1 a2 u2 \ -- -1 | 0 }
   u1 u2 < IF FALSE EXIT THEN
   a1 u2 a2 u2 COMPARE 0= ;

: pass { a1 u1 a2 u2 \ -- a u -1 | 0 }
   a1 u1 a2 u2 match IF a1 u1 u2 /STRING TRUE ELSE a1 u1 FALSE THEN ;

ALSO joopwin

FILTER: fhlp-files-filter
  NAME" fhlp files" EXT" *.fhlp"
  NAME" all files" EXT" *.*"
;FILTER

: lb-searchstring { a u lb | -- pos } \ -1 если не найдено
   lb lb-count 0 ?DO
    PAD I lb fromlist
    PAD ASCIIZ> a u COMPARE 0= IF I UNLOOP EXIT THEN
   LOOP
   -1
;

: add-to-listf ( a u -- )
   ModuleDirName pass DROP 
   ( a u)
   2DUP listf lb-searchstring -1 <> IF 2DROP EXIT THEN
   DROP listf lb-addstring
;

PROC: add-file { | fdlg -- }
  MyOpenDialog :new -> fdlg
  ModuleDirName >ASCIIZ fdlg :initial!
  fhlp-files-filter fdlg :setFilter
  S" Select fhlp file to convert" fdlg :setTitle
  fdlg :execute IF
    fdlg :fileName add-to-listf
  THEN
  fdlg :free
PROC;

PREVIOUS 

: add-dir-files ( a u -- )
   LAMBDA{ ( a u data flag -- )
     NIP
     IF 2DROP EXIT THEN
     2DUP S" *.fhlp" ULIKE 0= IF 2DROP EXIT THEN
     add-to-listf 
   }
   FIND-FILES-R ;

PROC: add-dir
  " Select folder with *.fhlp files" winmain -hwnd@ 
  LAMBDA{ ( a u -- )
    2DUP TYPE CR
    add-dir-files
  }
  ShellGetDir
PROC;

PROC: remove-file
  listf -selected@ 
  DUP -1 = IF DROP EXIT THEN
      listf lb-deletestring
PROC;

: CUT-NAME ( a u -- a2 u2 )
   2DUP 
   CUT-PATH NIP
   /STRING ;

..: ON-WINDOW-INIT 
     ModuleDirName A" {s}docs/help" STR@ add-dir-files ;..

PROC: convert-all { | buf name -- }

   1024 ALLOCATE THROW -> buf
   1024 ALLOCATE THROW -> name

   listf lb-count 0 ?DO
    name 1024 ERASE
    buf 1024 ERASE

    name I listf fromlist

    buf 0 name ASCIIZ> CUT-NAME STR-APPEND 
    buf ASCIIZ> S" .html" STR-APPEND
    name ASCIIZ> buf ASCIIZ> S" fhlp.css"
    fhlp::['] convert CATCH IF ['] TYPE1 TO TYPE 2DROP 2DROP 2DROP I . ." error" THEN
   LOOP

   buf FREE THROW
   name FREE THROW
PROC;


: doc-grid
   GRID
    " Files to convert" label -yfixed |
    ===
    listbox -xspan -yspan
    this TO listf |
    GRID
      " Add" button 
      \ " add.bmp" load-bitmap bitmap-button \ this -image!
      add-file this -command!
      -xspan |
      ===
      " Add folder" button 
      add-dir this -command!
      -xspan |
      ===
      " Remove" button 
      remove-file this -command!
      -xspan |
      ===
      " Remove All" button
      LAMBDA{ listf lb-clear } this -command!
      -xspan |
      ===
    GRID; -xfixed |
    ===
    " Convert" button 
    convert-all this -command! |
   GRID;
   ;


0 VALUE hProcess \ handle of the running process
0 VALUE hWrite
0 VALUE hRead
0 VALUE thread

 0x00000100 CONSTANT FILE_ATTRIBUTE_TEMPORARY
 0x04000000 CONSTANT FILE_FLAG_DELETE_ON_CLOSE

: CREATE-FILE-MEMORY ( c-addr u fam -- fileid ior )
  NIP SWAP >R >R
  0  \ template
  FILE_ATTRIBUTE_TEMPORARY FILE_FLAG_DELETE_ON_CLOSE OR 
  CREATE_ALWAYS
  SA \ secur
  3 \ share
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;

0 VALUE loglist

: add-to-log ( z -- )
   BEGIN
    loglist lb-count 100 >
   WHILE
    0 loglist lb-deletestring
   REPEAT

   loglist lb-addstring
;

:NONAME { | buf sz ch -- }
  DROP
  1024 ALLOCATE THROW -> buf
  16 ALLOCATE THROW -> ch
  0 -> sz
  BEGIN
    hProcess
  WHILE
    ch 1 hRead READ-FILE THROW 
    IF
      ch C@ 0x0A = sz 1000 > OR 
      IF
        buf sz >ASCIIZ add-to-log 
        0 -> sz
      ELSE
        ch C@ 0x0D <> 
        IF 
          buf sz ch C@ CHAR-APPEND 
          sz 1+ -> sz
        THEN
      THEN
    THEN
\    10 PAUSE
  REPEAT
  buf FREE THROW
  ch FREE THROW
; TASK: cvs-output-watcher  

PROC: cvs-stop
 hProcess 
 IF
   0 hProcess TerminateProcess ERR THROW  
   hProcess CLOSE-FILE THROW  0 TO hProcess 
 THEN
 thread IF thread STOP 0 TO thread THEN \ force thread kill
 hWrite IF hWrite CLOSE-FILE THROW  0 TO hWrite THEN
 hRead IF hRead CLOSE-FILE THROW  0 TO hRead THEN
PROC;

PROC: cvs-update
 cvs-stop EXECUTE
 \ S" out.log" R/W CREATE-FILE THROW DUP TO hFile DUP-HANDLE-INHERITED THROW
 CREATE-ANON-PIPE THROW TO hWrite TO hRead

 H-STDIN \ DUP-HANDLE-INHERITED THROW
 hWrite DUP-HANDLE-INHERITED THROW 
 S" cmd" ChildApp THROW TO hProcess

 0 cvs-output-watcher START TO thread
PROC;

: cvs-grid
  GRID
   GRID
    " Update" button 
    cvs-update this -command!
    -xspan |
    " Stop" button 
    cvs-stop this -command!
    -xspan |
   GRID; -xspan -yfixed |
   ===
   listbox
   DUP TO loglist
   -xspan -yspan |
   ===
  GRID;
;

0 VALUE tab1
0 VALUE list1

MESSAGES: list1-notify
  M: LBN_SELCHANGE
   list1 -selected@ 
   0 MAX 2 MIN 
   tab1 switch-tab 
  M;
MESSAGES;

: ctlxresize ( x ctl -- )
   DUP -ysize@ SWAP ctlresize ; 

: create-tabs ( -- ctl )
  0 tabcontrol
  this TO tab1
  this add-default-icon
  reg-grid " Registry" 0 0 this add-item
  doc-grid " Documentation" 0 1 this add-item
  cvs-grid " Source control" 0 2 this add-item
  -xspan
  -yspan
;

: create-list ( -- ctl )
  GRID
     ( filler -yfixed
     100 1 this ctlresize |)
     " Settings" label -yfixed
     100 this ctlxresize |
     ===
     listbox
     DUP TO list1
     list1-notify this -notify!
     " Registry" this lb-addstring
     " Documentation" this lb-addstring
     " Source control" this lb-addstring 
      -yspan -xspan |
  GRID; -yspan -xfixed
;

: show

  0 create-window TO winmain
  W: COLOR_3DFACE syscolor winmain -bgcolor!
  0 create-tooltip
  0 300 W: TTM_SETMAXTIPWIDTH common-tooltip send DROP \ MultiLine tooltips
  75 3000 30 common-tooltip set-tooltip-delay

  " Arial Cyr" 10 create-font default-font
  " SP-Forth post-install manager" winmain -text!

  GRID
   create-list |
   create-tabs |
   ===
    "    Quit    " button
    LAMBDA{ 
     cvs-stop EXECUTE
     W: wm_close winmain send DROP 
    } this -command! |
  GRID;

  winmain create-status

  winmain -grid!

  winmain wincenter
  winmain winshow

;

;MODULE
