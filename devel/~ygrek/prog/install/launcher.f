
WINAPI: MessageBoxA USER32.DLL

:NONAME
S" ~ygrek/prog/install/install.f" ['] INCLUDED 
CATCH IF 
 0 
 S" Warning" DROP 
 S" install.f failed to run. Please set registry values manually. See readme for details" DROP 
 0 MessageBoxA DROP THEN 
 ;
 EXECUTE BYE

