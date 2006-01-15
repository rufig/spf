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

values  path spf cnt farmanager scriptmap ;

WINAPI: RegDeleteKeyA    ADVAPI32.DLL

: RG_DeleteKey ( addr u -- ior )
  >ASCIIZ EK @ RegDeleteKeyA ;

: FindN ( addr u -- )
  S" Description" 2SWAP StrValue
  S" sp-forth files" COMPARE 0= IF DROP TRUE EXIT THEN
  cnt 1+ TO cnt
;

: TypeN A" Type{cnt}" STR@ ;


PROC: install

 spf 512 ERASE
 spf path -text@

 HKEY_LOCAL_MACHINE EK !

\ [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\spf.exe]
\ @="C:\\spf\\spf4.exe"
 spf ASCIIZ> S" " S" SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\spf.exe" StrValue!


 HKEY_CLASSES_ROOT EK !

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
  spf ASCIIZ> A" {s},0" STR@ S" " S" spf\DefaultIcon"  StrValue!

(
[HKEY_CLASSES_ROOT\spf\Shell]
[HKEY_CLASSES_ROOT\spf\Shell\Open]
[HKEY_CLASSES_ROOT\spf\Shell\Open\Command])

\ [HKEY_CLASSES_ROOT\spf\Shell\Open\Command]
\ @="c:\\spf\\spf4.exe \"%1\" %*"

 spf ASCIIZ> A" {s} {''}%1{''} %*" STR@ S" " S" spf\Shell\Open\Command" StrValue!


 scriptmap -state@ IF

   HKEY_LOCAL_MACHINE EK !

   \ [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Script Map]
   \ ".spf"="c:\\spf\\spf4.exe %s"
   spf ASCIIZ>
   A" {s} %s" STR@  S" .spf" S" SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Script Map" StrValue!

   \ [HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\W3SVC\Parameters\Script Map]
   \ ".spf"="c:\\spf\\spf4.exe %s"
   spf ASCIIZ> 
   A" {s} %s" STR@ S" .spf" S" SYSTEM\ControlSet001\Services\W3SVC\Parameters\Script Map" StrValue!
 THEN



 farmanager -state@ IF

  S" SOFTWARE\Far\Associations" HKEY_CURRENT_USER RG_OpenKey THROW EK !

  0 TO cnt
  ['] FindN EK @ RG_ForEachKey

  S" sp-forth files" S" Description" TypeN StrValue!
  S" " S" Edit" TypeN StrValue!
  A" {spf ASCIIZ>} !.!" STR@ S" Execute" TypeN StrValue!
  S" *.f,*.spf" S" Mask" TypeN StrValue!
  S" " S" View" TypeN StrValue!
 THEN

 " Registry values installed successfully" 0 winmain set-status

PROC;

PROC: uninstall

 HKEY_LOCAL_MACHINE EK !
 S" SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\spf.exe" RG_DeleteKey THROW

 HKEY_CLASSES_ROOT EK ! 
 S" .spf" RG_DeleteKey THROW
 S" .f"   RG_DeleteKey THROW
 S" spf\DefaultIcon"  RG_DeleteKey THROW
 S" spf\Shell\Open\Command" RG_DeleteKey THROW
 S" spf\Shell\Open" RG_DeleteKey THROW
 S" spf\Shell" RG_DeleteKey THROW
 S" spf" RG_DeleteKey THROW

 HKEY_LOCAL_MACHINE EK !
 S" " S" .spf" S" SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Script Map" StrValue!
 S" " S" .spf" S" SYSTEM\ControlSet001\Services\W3SVC\Parameters\Script Map" StrValue!

 " Registry values uninstalled successfully" 0 winmain set-status

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
  " SP-Forth Registrator" win -text!

  GRID
    GRID
    " Path to spf.exe : " label |
    ===
    edit  200 this limit-edit -xspan  this TO path  |
    ===
    " Associate FAR Manager" checkbox  this TO farmanager |
    ===
    " Associate Script Map" checkbox  this TO scriptmap |
    -bevel
    GRID; -xspan |
    ===
    "  Register  " button install this -command! |
    " Unregister "  button uninstall this -command! |
    "    Quit    " button   quit this -command! |
  GRID;

    winmain create-status

  winmain -grid!

  ModuleName >ASCIIZ path -text!
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

