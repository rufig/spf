
REQUIRE button  ~yz/lib/wincc.f
REQUIRE ENUM  ~ygrek/lib/enum.f
MODULE: BAC4TH \ START conflict
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

: CVScmd S" cvs update -d -P" ;

MODULE: joopwin \ иначе W: и M: начинают конфликтовать

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
: anim-strings PRO "  \\" CONT "  |" CONT "  /" CONT "  -" CONT RDROP ;
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
    GRID
       "   Apply  " button
       ['] onClick-install this -command! 
       " Checked boxes will result in setting the corresponding value in the registry. Cleared boxes will delete the setting from the registry" 
       this -tooltip! 
        -xspan |

       " Save .reg file" button
       generate this -command! 
       " Save the current settings to the .reg file so that you can manually incorporate them in the registry later" 
       this -tooltip! 
       -xspan |

       "    Quit    " button
       LAMBDA{ 
         W: wm_close winmain send DROP 
       } this -command! 
       -xspan |

       "  About  " button
       -xspan |

    GRID; -xfixed |
    ===
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

" Times New Roman Cyr" 10 underline create-font VALUE font-href

: -href font-href this -font!  blue this -color! ;

: LINE GRID; -yfixed 0 -ymargin -center | === ;

: text label -bottom ;

: shell-open ( z ctl -- )
   >R >R
   W: SW_SHOW \ nShowCmd
   "" \ directory path empty
   0 \ no parameters for 'open'
   R> \ document path
   " open" \ open action
   R> \ window handle
   ShellExecuteA 33 < IF ." ShellExecute error" THEN ;

: href text -href LAMBDA{ PAD thisctl -text@ PAD thisctl shell-open } this -command! ;

: T" [CHAR] " PARSE ['] " EVALUATE-WITH POSTPONE text POSTPONE | ; IMMEDIATE
: L" [CHAR] " PARSE ['] " EVALUATE-WITH POSTPONE href POSTPONE | ; IMMEDIATE


: about-grid
 GRID
   GRID
    GRID T" SP-Forth post install manager" LINE
    GRID T" Visit" L" http://spf.sf.net" LINE
    GRID T" RuFIG at" L" http://www.forth.org.ru" LINE
    GRID T" 20.Aug.2006" LINE
   GRID; -middle -center |
 GRID;
;

: ctlxresize ( x ctl -- )
   DUP -ysize@ SWAP ctlresize ; 

: show

  0 create-window TO winmain
  W: COLOR_3DFACE syscolor winmain -bgcolor!
  0 create-tooltip
  0 300 W: TTM_SETMAXTIPWIDTH common-tooltip send DROP \ MultiLine tooltips
  75 3000 30 common-tooltip set-tooltip-delay

  " Arial Cyr" 10 create-font default-font
  " SP-Forth post-install manager" winmain -text!

  GRID
   reg-grid |
   ===
  GRID;

  winmain create-status

  winmain -grid!

  winmain wincenter
  winmain winshow
;

;MODULE
