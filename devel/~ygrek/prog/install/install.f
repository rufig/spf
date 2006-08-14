\ Инcталлятор для SPF
\ Прописывает значения в реестре или удаляет их оттуда
\
\ ~ygrek
\ 14.Jan.2006

MODULE: A-STR

REQUIRE " ~ac/lib/str5.f

EXPORT

: A" POSTPONE " ; IMMEDIATE
: STR@ STR@ ;
: '' '' ;
: A"" POSTPONE "" ; IMMEDIATE
: STRFREE STRFREE ;

;MODULE

\ REQUIRE  load-bitmap   ~vsp/lib/images.f
REQUIRE  RG_CreateKey  ~ac/lib/win/registry2.f
REQUIRE  button  ~yz/lib/wincc.f
REQUIRE  ENUM  ~ygrek/lib/enum.f
REQUIRE  PRO ~profit/lib/bac4th.f
REQUIRE  >ASCIIZ ~ygrek/lib/string.f

:NONAME 0 VALUE ; ENUM values

values  edit-path spf ntype farmanager scriptmap explorer TypeNstr ;

100 VALUE anime-step-ms
: anim-strings PRO "  \\" CONT "  |" CONT "  /" CONT "  -" CONT ;
: anime-status-main ( -- ) 
  anim-strings ( a u )
  0 winmain set-status 
  anime-step-ms PAUSE ;

: set-main-status ( z -- ) 2 0 DO anime-status-main LOOP  0 winmain set-status ;

WINAPI: RegDeleteKeyA    ADVAPI32.DLL

: RG_DeleteKey ( addr u -- ior )
  >ASCIIZ EK @ RegDeleteKeyA ;

: CheckSPFType ( addr u -- )
  TypeNstr STRFREE
  2DUP A" {s}" TO TypeNstr \ remember the key
  \ CR TypeNstr STR@ TYPE
  S" Description" 2SWAP StrValue
  \ CR ntype . 2DUP TYPE
  S" sp-forth files" COMPARE 0= IF -1 TO ntype DROP TRUE EXIT THEN \ DROP TRUE is a hack!!
  ntype 1+ TO ntype
;

: TypeN TypeNstr STR@ ;

: FindSPFType
  S" SOFTWARE\Far\Associations" HKEY_CURRENT_USER RG_OpenKey THROW EK !

  A"" TO TypeNstr
  0 TO ntype
  ['] CheckSPFType EK @ RG_ForEachKey
  ntype -1 <> IF \ it means there was no key found
    A" Type{ntype}" TO TypeNstr THEN \ else the key name is already set
  \ CR ." CHECK IT " TypeN TYPE
;

: path spf ASCIIZ> ;
: get-user-path
   spf 1024 ERASE
   spf edit-path -text@ ;

PROC: install

 get-user-path

 HKEY_LOCAL_MACHINE EK !

 explorer -state@  farmanager -state@ OR  scriptmap -state@ OR IF
   \ [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\spf.exe]
   \ @="C:\\spf\\spf4.exe"
   path S" " S" SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\spf.exe" StrValue!
 ELSE
   S" SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\spf.exe" RG_DeleteKey DROP
 THEN

 HKEY_CLASSES_ROOT EK !

 explorer -state@ IF
    \ [HKEY_CLASSES_ROOT\.spf]
    \ @="spf"
    \ "Content Type"="text/plain"
    S" spf" S" " S" .spf" StrValue!
    S" text/plain" S" Content Type" S" .spf" StrValue!

    \ [HKEY_CLASSES_ROOT\.f]
    \ @="spf"
    \ "Content Type"="text/plain"
    S" spf" S" " S" .f" StrValue!
    S" text/plain" S" Content Type" S" .f" StrValue!
  
    \ [HKEY_CLASSES_ROOT\spf]
    \ @="Forth File"
     S" Forth file" S" " S" spf" StrValue!

    \ [HKEY_CLASSES_ROOT\spf\DefaultIcon]
    \ @="c:\\spf\\spf4.exe,0"
      path A" {s},0" STR@ S" " S" spf\DefaultIcon"  StrValue!

    (
    [HKEY_CLASSES_ROOT\spf\Shell]
    [HKEY_CLASSES_ROOT\spf\Shell\Open]
    [HKEY_CLASSES_ROOT\spf\Shell\Open\Command])

    \ [HKEY_CLASSES_ROOT\spf\Shell\Open\Command]
    \ @="c:\\spf\\spf4.exe \"%1\" %*"

     path A" {s} {''}%1{''} %*" STR@ S" " S" spf\Shell\Open\Command" StrValue!
 ELSE
    S" .spf" RG_DeleteKey DROP 
    S" .f"   RG_DeleteKey DROP
    S" spf\DefaultIcon"  RG_DeleteKey DROP
    S" spf\Shell\Open\Command" RG_DeleteKey DROP
    S" spf\Shell\Open" RG_DeleteKey DROP
    S" spf\Shell" RG_DeleteKey DROP
    S" spf" RG_DeleteKey DROP
 THEN


 HKEY_LOCAL_MACHINE EK !

 scriptmap -state@ IF
 
   \ [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Script Map]
   \ ".spf"="c:\\spf\\spf4.exe %s"
   path
   A" {s} %s" STR@  S" .spf" S" SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Script Map" StrValue!

   \ [HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\W3SVC\Parameters\Script Map]
   \ ".spf"="c:\\spf\\spf4.exe %s"
   path 
   A" {s} %s" STR@ S" .spf" S" SYSTEM\ControlSet001\Services\W3SVC\Parameters\Script Map" StrValue!
 ELSE
   S" " S" .spf" S" SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Script Map" StrValue!
   S" " S" .spf" S" SYSTEM\ControlSet001\Services\W3SVC\Parameters\Script Map" StrValue!
 THEN


 farmanager -state@ IF

  FindSPFType

  S" sp-forth files" S" Description" TypeN StrValue!
  S" " S" Edit" TypeN StrValue!
  A" {path} !.!" STR@ S" Execute" TypeN StrValue!
  S" *.f,*.spf" S" Mask" TypeN StrValue!
  S" " S" View" TypeN StrValue!
 THEN

 " Registry values updated successfully" set-main-status

PROC;

\ double the slashes
: DOUBLE-SLASHES ( buf a u -- )
 BOUNDS DO
  I C@ [CHAR] \ = IF 
    [CHAR] \  OVER C! 1+ [CHAR] \ OVER C! 1+
  ELSE 
    I C@ OVER C! 1+ 
  THEN
 LOOP
 0 SWAP C! ;

PROC: generate { \ h orig -- }

 get-user-path

 spf ASCIIZ> + 2+ TO orig
 spf orig orig spf - CMOVE

 spf orig ASCIIZ> DOUBLE-SLASHES

 FindSPFType
 S" spf_install.reg" R/W CREATE-FILE THROW TO h

\ A" {S' spf_install.template' DEPTH . EVAL-FILE}" STR@ h WRITE-FILE THROW
 S" spf_install.template" A-STR::EVAL-FILE
 A" {s}" STR@ h WRITE-FILE THROW

 h CLOSE-FILE THROW

 " File spf_install.reg written successfully" set-main-status
PROC;


PROC: quit
  W: wm_close winmain send DROP
PROC;

: check ( -- )
 S" " S" SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\spf.exe" StrValue DUP
 IF
  A" Present : {s}" STR@ DROP 0 winmain set-status 
 ELSE
  2DROP
  " No registry values present" 0 winmain set-status
 THEN
;

MESSAGES: ttp
520 :M  ." dsds" M;
MESSAGES;

: main { \ win -- }
  1024 ALLOCATE THROW TO spf

  WINDOWS...
  0 dialog-window TO win
  0 create-tooltip
  " Arial Cyr" 10 create-font default-font
  win TO winmain
  " SP-Forth registry settings manager" win -text!

  GRID
    " Path to spf.exe : " label |
    ===
    edit  200 this limit-edit -xspan  this TO edit-path  
        " Path to the SPF executable" this -tooltip! |
    ===
    GRID
    " Associate .spf and .f file types with spf.exe in : " label |
    ===
    " Explorer" checkbox  this TO explorer  
        " Check to associate forth files with spf.exe in Explorer. You will be able to run them by simply double-clicking. Uncheck to delete the current association" 
        this -tooltip! 
        ttp this -notify!
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
    GRID; -xspan |
    ===
    "   Apply  " button   install this -command! 
      " Checked boxes will result in setting the corresponding value in the registry. Cleared boxes will delete the setting from the registry" 
      this -tooltip! |
    " Generate .reg file" button  generate this -command! 
      " Save the current settings to the .reg file so that you can manually incorporate it in the registry later" 
      this -tooltip! |
    "    Quit    " button      quit this -command! 
      " Quit" this -tooltip! |
  GRID;

    winmain create-status

  winmain -grid!

  ModuleName >ASCIIZ edit-path -text!
  TRUE explorer -state!
  TRUE farmanager -state!
  FALSE scriptmap -state!
  check

  win wincenter
  win winshow

  ...WINDOWS

  spf FREE THROW 
;


main

BYE

