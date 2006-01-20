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

;MODULE

REQUIRE  RG_CreateKey  ~ac/lib/win/registry2.f
REQUIRE  button  ~yz/lib/winctl.f
REQUIRE  ENUM  ~ygrek/lib/enum.f

:NONAME 0 VALUE ; ENUM values

: >ASCIIZ ( addr u -- z ) OVER + 0 SWAP C! ;

values  edit-path spf ntype farmanager scriptmap explorer ;

WINAPI: RegDeleteKeyA    ADVAPI32.DLL

: RG_DeleteKey ( addr u -- ior )
  >ASCIIZ EK @ RegDeleteKeyA ;

: CheckSPFType ( addr u -- )
  S" Description" 2SWAP StrValue
  S" sp-forth files" COMPARE 0= IF DROP TRUE EXIT THEN
  ntype 1+ TO ntype
;

: TypeN A" Type{ntype}" STR@ ;

: FindSPFType
  S" SOFTWARE\Far\Associations" HKEY_CURRENT_USER RG_OpenKey THROW EK !

  0 TO ntype
  ['] CheckSPFType EK @ RG_ForEachKey
;

: path spf ASCIIZ> ;

PROC: install

 spf 1024 ERASE
 spf edit-path -text@

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

 " Registry values installed successfully" 0 winmain set-status

PROC;

PROC: generate { \ h orig -- }

 spf 1024 ERASE
 spf edit-path -text@

 spf ASCIIZ> + 2+ TO orig
 spf orig orig spf - CMOVE

 spf
 orig ASCIIZ> OVER + SWAP DO
  I C@ [CHAR] \ = 
  IF [CHAR] \  OVER C! 1+ [CHAR] \ OVER C! 1+
  ELSE I C@ OVER C! 1+ THEN
 LOOP
 0 SWAP C!

 FindSPFType
 S" spf_install.reg" R/W CREATE-FILE THROW TO h
 A" {A-STR::S' spf_install.template' A-STR::EVAL-FILE}" STR@ h WRITE-FILE THROW
 h CLOSE-FILE THROW

 " File spf_install.reg written successfully" 0 winmain set-status
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

: main { \ win -- }
  1024 ALLOCATE THROW TO spf

  WINDOWS...
  0 dialog-window TO win
  " Arial Cyr" 10 create-font default-font
  win TO winmain
  " SP-Forth registry installer" win -text!

  GRID
    " Path to spf.exe : " label |
    ===
    edit  200 this limit-edit -xspan  this TO edit-path  |
    ===
    GRID
    " Associate spf.exe, .spf and .f file types within: " label |
    ===
    " Explorer" checkbox  this TO explorer |
    ===
    " FAR Manager" checkbox  this TO farmanager |
    ===
    " Script Map" checkbox  this TO scriptmap |
    -bevel
    GRID; -xspan |
    ===
    "   Apply  " button   install this -command! |
    " Generate .reg file" button  generate this -command! |
    "    Quit    " button      quit this -command! |
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

