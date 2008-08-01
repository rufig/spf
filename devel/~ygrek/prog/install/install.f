\ $Id$
\ Инcталлятор для SPF
\ Прописывает значения в реестре или удаляет их оттуда

\ DIS-OPT
\ STARTLOG 

REQUIRE RG_CreateKey  ~ac/lib/win/registry2.f
REQUIRE ENUM  ~ygrek/lib/enum.f
REQUIRE >ASCIIZ ~ygrek/lib/string.f
REQUIRE tabcontrol ~ygrek/~yz/lib/wincc.f
REQUIRE 2VALUE ~ygrek/lib/2value.f
REQUIRE $Revision: ~ygrek/lib/fun/kkv.f

\ : StrValue 2OVER 2OVER CR ." Read Key :" TYPE CR ." Value: " TYPE StrValue ;
\ : RG_OpenKey >R 2DUP CR ." Open Key : " TYPE R> RG_OpenKey ;

: CVS-REVISION $Revision$ SLITERAL ;

MODULE: A-STR
 REQUIRE STR@ ~ac/lib/str5.f
 REQUIRE replace-str- ~pinka/samples/2005/lib/replace-str.f
EXPORT
 : replace-str- replace-str- ;
 : A" POSTPONE " ; IMMEDIATE
 : STR@ STR@ ;
 : '' '' ;
 : A"" POSTPONE "" ; IMMEDIATE
 : STRFREE STRFREE ;
 : STR! STR! ;
;MODULE

VECT onClick-install
VECT vect-generate

: ON-WINDOW-INIT ... ;

:NONAME 0 VALUE ; ENUM values
values spf ntype TypeNstr ;

REQUIRE gui ~ygrek/prog/install/gui.f

WINAPI: RegDeleteKeyA    ADVAPI32.DLL

: RG_DeleteKey ( addr u -- ior ) >ASCIIZ EK @ RegDeleteKeyA ;

: TypeN TypeNstr STR@ ;

: ?FARManagerPresent ( -- ? ) S" SOFTWARE\Far\Associations" HKEY_CURRENT_USER RG_OpenKey NIP 0= ;

: CheckSPFType ( a u -- )
  TypeNstr STRFREE
  2DUP A" {s}" TO TypeNstr \ remember the key
\  CR TypeNstr STR@ TYPE
  S" Mask" 2SWAP StrValue
\  CR ntype . 2DUP TYPE
\  2DUP TYPE CR
  ( a1 u1)
  S" *.spf" SEARCH IF 2DROP -1 TO ntype DROP TRUE EXIT THEN \ DROP TRUE is a hack!!
  2DROP
  ntype 1+ TO ntype ;

: FindSPFType ( -- )
  A"" TO TypeNstr
  0 TO ntype

  S" SOFTWARE\Far\Associations" HKEY_CURRENT_USER RG_OpenKey IF DROP EXIT THEN EK !

  ['] CheckSPFType EK @ RG_ForEachKey
  ntype -1 <> IF \ it means there was no key found
    A" Type{ntype}" TO TypeNstr THEN \ else the key name is already set
  \ CR ." CHECK IT " TypeN TYPE
;

: path spf STR@ ;

: edit>s { ctl | mem s -- s }
   A"" TO s
   ctl -text# 1+ ALLOCATE THROW TO mem
   mem ctl -text@ 
   mem ASCIIZ> s STR! 
   mem FREE THROW
   s ;

: get-user-path gui::edit-path edit>s TO spf ;

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
     S" SP-Forth file" S" " S" spf" StrValue!

    \ [HKEY_CLASSES_ROOT\spf\DefaultIcon]
    \ @="c:\\spf\\spf4.exe,0"
      path A" {s},0" STR@ S" " S" spf\DefaultIcon"  StrValue!

    (
    [HKEY_CLASSES_ROOT\spf\Shell]
    [HKEY_CLASSES_ROOT\spf\Shell\Open]
    [HKEY_CLASSES_ROOT\spf\Shell\Open\Command])

    \ [HKEY_CLASSES_ROOT\spf\Shell\Open\Command]
    \ @="\"c:\\spf\\spf4.exe\" S\" %1\" INCLUDED"

     path A" {''}{s}{''} S{''} %1{''} INCLUDED" STR@ S" " S" spf\Shell\Open\Command" StrValue!
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
   \ ".spf"="\"c:\\spf\\spf4.exe\" S\" %s\" INCLUDED"
   path
   A" {''}{s}{''} S{''} %s{''} INCLUDED" STR@ S" .spf" S" SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Script Map" StrValue!

   \ [HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\W3SVC\Parameters\Script Map]
   \ ".spf"="\"c:\\spf\\spf4.exe\" S\" %s\" INCLUDED"
   path 
   A" {''}{s}{''} S{''} %s{''} INCLUDED" STR@ S" .spf" S" SYSTEM\ControlSet001\Services\W3SVC\Parameters\Script Map" StrValue!
 ELSE
   S" " S" .spf" S" SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Script Map" StrValue!
   S" " S" .spf" S" SYSTEM\ControlSet001\Services\W3SVC\Parameters\Script Map" StrValue!
 THEN


 gui::farmanager -state@ ?FARManagerPresent AND IF

  FindSPFType

  S" sp-forth files" S" Description" TypeN StrValue!
  S" " S" Edit" TypeN StrValue!
  A" {''}{path}{''} S{''} !.!{''} INCLUDED" STR@ S" Execute" TypeN StrValue!
  S" *.f,*.spf" S" Mask" TypeN StrValue!
  S" " S" View" TypeN StrValue!
 THEN

 " Registry values updated successfully" gui::set-main-status

;

' install TO onClick-install

HERE
 ModuleDirName A" {s}devel/~ygrek/prog/install/spf_install.template" STR@ 
 2DUP FILE-EXIST 0= [IF] ." Template not found : " TYPE BYE [THEN]
 A-STR::FILE 2DUP S, 0 C, SWAP FREE THROW SWAP 
 VALUE @template
 VALUE #template

:NONAME { a u \ h orig err -- }

 get-user-path

 spf A" \" A" \\" replace-str-

 0 TO err

 FindSPFType
 a u R/W CREATE-FILE err OR TO err TO h

 @template #template A-STR::S@ h WRITE-FILE err OR TO err

 h CLOSE-FILE err OR TO err

 err IF a u A" Error writing file {s}" ELSE a u A" File {s} written successfully" THEN
 STR@ DROP gui::set-main-status
; TO vect-generate


: initial-check ( -- )
 S" " S" SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\spf.exe" StrValue DUP
 IF
  A" Present : {s}" STR@ DROP 0 winmain set-status 
 ELSE
  2DROP
  " No registry values present" 0 winmain set-status
 THEN
 ?FARManagerPresent 0= IF
   gui::farmanager-notice >R
   R@ windisable
   gui::farmanager windisable
   " (not installed)" R@ -text!
   " FAR manager settings were not found in the registry" R@ -tooltip!
   RDROP
 ELSE
   FindSPFType
   ntype -1 = IF
     \ gui::farmanager windisable
     gui::farmanager-notice >R
     " (already present)" R@ -text!
     " FAR manager *.spf association is set in the registry" R@ -tooltip!
     \ red R@ -color!
     RDROP
   THEN
 THEN
;

: main
  A"" TO spf

  WINDOWS...

  gui::show

  ModuleName >ASCIIZ gui::edit-path -text!
  TRUE gui::explorer -state!
  FALSE gui::farmanager -state!
  FALSE gui::scriptmap -state!
  initial-check

  ON-WINDOW-INIT

  ...WINDOWS
;


main BYE
