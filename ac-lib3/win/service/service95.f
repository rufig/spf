REQUIRE StrValue!     ~ac/lib/win/registry2.f
WINAPI: RegDeleteValueA ADVAPI32.DLL
VARIABLE S95_TEMP1

: InstallService95 ( S" service_name" -- ior )
  HKEY_LOCAL_MACHINE EK !
  ModuleName 2SWAP
  S" SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 
  ['] StrValue! CATCH DUP
  IF >R 2DROP 2DROP 2DROP R> THEN
;
: UninstallService95 ( S" service_name" -- ior )
  2>R
  S95_TEMP1 S" SOFTWARE\Microsoft\Windows\CurrentVersion\Run" DROP HKEY_LOCAL_MACHINE RegOpenKeyA
  DUP 0=
  IF DROP 2R> DROP S95_TEMP1 @ RegDeleteValueA
  ELSE 2R> 2DROP THEN
;
