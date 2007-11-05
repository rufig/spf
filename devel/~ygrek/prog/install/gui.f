
REQUIRE button  ~ygrek/~yz/lib/wincc.f
REQUIRE ENUM  ~ygrek/lib/enum.f
REQUIRE PRO ~profit/lib/bac4th.f
REQUIRE >ASCIIZ ~ygrek/lib/string.f
REQUIRE /STRING lib/include/string.f
REQUIRE winlib-icons ~ygrek/~yz/lib/icons.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f

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

values  edit-path farmanager scriptmap explorer farmanager-notice ;

100 VALUE anime-step-ms
: anim-strings PRO "  \\" CONT "  |" CONT "  /" CONT "  -" CONT ;
: anime-status-main ( -- ) 
  anim-strings ( a u )
  0 winmain set-status 
  anime-step-ms PAUSE ;
: set-main-status ( z -- ) 2 0 DO anime-status-main LOOP  0 winmain set-status ;

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

\ : path@ ( buf -- ) edit-path -text@ ;
\ : path# ( -- n ) edit-path -text# ;

PROC: quit 
  winmain W: wm_close ?send DROP 
PROC;

: reg-grid ( -- g )
  GRID
    " Path to spf.exe : " label 
    -yfixed |
    ===
    edit  200 this limit-edit -xspan  this TO edit-path  
        " Path to the SPF executable that executed this script" this -tooltip! 
    -yfixed |
    ===
    GRID
    " Associate .spf and .f file types with SPF in : " label |
    ===
    " Explorer" checkbox  this TO explorer  
        " Check to associate forth files with SPF in Explorer. You will be able to run them by simply double-clicking. Uncheck to delete the current association" 
        this -tooltip! 
        \ ttp this -notify!
\        this W: ttm_getmaxtipwidth ?send .
\        50 this W: ttm_setmaxtipwidth common-tooltip-op
 \       this W: ttm_getmaxtipwidth ?send .
         |
    ===
    " FAR Manager" checkbox  this TO farmanager 
        " Check to associate *.f and *.spf files with SPF in FAR manager. Cleared box will do nothing." this -tooltip! 
    -xfixed |
    "                        " label  this TO farmanager-notice 
    -xspan |
    ===
    " Script Map" checkbox  this TO scriptmap 
        " Check to add forth files to the W3SVC script map. Uncheck to delete." this -tooltip! |
    -bevel
    GRID; -xspan -yfixed |
    ===
    GRID
       "   Apply  " button
       ['] onClick-install this -command! 
       " Checked boxes will result in setting the corresponding value in the registry. Cleared boxes will delete the setting from the registry. You must have administrative privilegies."
       this -tooltip! 
        -xspan |

       " Save .reg file" button
       generate this -command! 
       " Save the current settings to the .reg file so that you can manually incorporate them in the registry later." 
       this -tooltip! 
       -xspan |

       "    Quit    " button
       quit this -command! 
       " Quit" this -tooltip!
       -xspan |

    GRID; -xfixed |
    ===
  GRID;
  ;


: show

  0 dialog-window TO winmain
  W: COLOR_3DFACE syscolor winmain -bgcolor!
  0 create-tooltip
  0 300 W: TTM_SETMAXTIPWIDTH common-tooltip send DROP \ MultiLine tooltips
  75 3000 30 common-tooltip set-tooltip-delay

  " Arial Cyr" 10 create-font default-font
  CVS-REVISION A" SP-Forth registry settings (rev. {s})" STR@ DROP winmain -text!

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
