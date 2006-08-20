\ Инcталлятор для SPF
\ Прописывает значения в реестре или удаляет их оттуда
\
\ ~ygrek
\ 14.Jan.2006

DIS-OPT

REQUIRE  RG_CreateKey  ~ac/lib/win/registry2.f
REQUIRE  ENUM  ~ygrek/lib/enum.f
REQUIRE  >ASCIIZ ~ygrek/lib/string.f
REQUIRE  tabcontrol ~ygrek/~yz/lib/wincc.f

MODULE: A-STR
 REQUIRE STR@ ~ac/lib/str5.f
EXPORT
 : A" POSTPONE " ; IMMEDIATE
 : STR@ STR@ ;
 : '' '' ;
 : A"" POSTPONE "" ; IMMEDIATE
 : STRFREE STRFREE ;
;MODULE

VECT onClick-install
VECT vect-generate

STARTLOG 

: ON-WINDOW-INIT ... ;

:NONAME 0 VALUE ; ENUM values
values  spf ntype TypeNstr ;

REQUIRE gui ~ygrek/prog/install/gui.f

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
   spf gui::path@ ;

: install

 get-user-path

 HKEY_LOCAL_MACHINE EK !

 gui::explorer -state@  gui::farmanager -state@ OR  gui::scriptmap -state@ OR IF
   \ [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\spf.exe]
   \ @="C:\\spf\\spf4.exe"
   path S" " S" SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\spf.exe" StrValue!
 ELSE
   S" SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\spf.exe" RG_DeleteKey DROP
 THEN

 HKEY_CLASSES_ROOT EK !

 gui::explorer -state@ IF
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

 gui::scriptmap -state@ IF
 
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


 gui::farmanager -state@ IF

  FindSPFType

  S" sp-forth files" S" Description" TypeN StrValue!
  S" " S" Edit" TypeN StrValue!
  A" {path} !.!" STR@ S" Execute" TypeN StrValue!
  S" *.f,*.spf" S" Mask" TypeN StrValue!
  S" " S" View" TypeN StrValue!
 THEN

 " Registry values updated successfully" gui::set-main-status

;

' install TO onClick-install

\ double the slashes
: DOUBLE-SLASHES ( buf a u -- )
 BOUNDS DO
  I C@ [CHAR] \ = IF 
    [CHAR] \ OVER C! 1+
    [CHAR] \ OVER C! 1+
  ELSE
    I C@ OVER C! 1+ 
  THEN
 LOOP
 0 SWAP C! ;

HERE
 ModuleDirName A" {s}devel/~ygrek/prog/install/spf_install.template" STR@ 
 2DUP FILE-EXIST 0= [IF] ." Template not found : " TYPE BYE [THEN]
 A-STR::FILE 2DUP S, 0 C, SWAP FREE THROW SWAP 
 VALUE @template
 VALUE #template

:NONAME { a u \ h orig -- }

 get-user-path

 spf ASCIIZ> + 2+ TO orig
 spf orig orig spf - CMOVE

 spf orig ASCIIZ> DOUBLE-SLASHES

 FindSPFType
 a u R/W CREATE-FILE THROW TO h

 @template #template A-STR::S@ h WRITE-FILE THROW

 h CLOSE-FILE THROW

 a u A" File {s} written successfully" STR@ DROP gui::set-main-status
; TO vect-generate

PROC: quit
  W: wm_close winmain send DROP
PROC;

: initial-check ( -- )
 S" " S" SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\spf.exe" StrValue DUP
 IF
  A" Present : {s}" STR@ DROP 0 winmain set-status 
 ELSE
  2DROP
  " No registry values present" 0 winmain set-status
 THEN
;

: main
  1024 ALLOCATE THROW TO spf

  WINDOWS...

  gui::show

  ModuleName >ASCIIZ gui::edit-path -text!
  TRUE gui::explorer -state!
  TRUE gui::farmanager -state!
  FALSE gui::scriptmap -state!
  initial-check

  ON-WINDOW-INIT

  ...WINDOWS

  gui::cvs-stop EXECUTE

  spf FREE THROW 
;


main
CR .( Clean exit)

BYE

