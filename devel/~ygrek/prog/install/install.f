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

: >ASCIIZ ( addr u -- z ) OVER + 0 SWAP C! ;

0 VALUE path
0 VALUE spf

WINAPI: RegDeleteKeyA    ADVAPI32.DLL

: RG_DeleteKey ( addr u -- ior )
  >ASCIIZ EK @ RegDeleteKeyA ;

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

 HKEY_LOCAL_MACHINE EK !

\ [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Script Map]
\ ".spf"="c:\\spf\\spf4.exe %s"

 spf ASCIIZ>
 A" {s} %s" STR@  S" .spf" S" SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Script Map" StrValue!

\ [HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\W3SVC\Parameters\Script Map]
\ ".spf"="c:\\spf\\spf4.exe %s"
 spf ASCIIZ>
 A" {s} %s" STR@ S" .spf" S" SYSTEM\ControlSet001\Services\W3SVC\Parameters\Script Map" StrValue!

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
  " SP-Forth Installer" win -text!

  GRID
    GRID
    " Path to spf.exe : " label |
    ===
    edit  200 this limit-edit -xspan  this TO path  |
    -bevel
    GRID; -xspan |
    ===
    "  Install  " button install this -command! |
    " Uninstall "  button uninstall this -command! |
    "   Quit  " button   quit this -command! |
  GRID;

    winmain create-status

  winmain -grid!

  ModuleName >ASCIIZ path -text!
  check

  win wincenter
  win winshow

  ...WINDOWS

  spf FREE THROW 
;


main

BYE

