REQUIRE WinNT? ~nn/lib/winver.f
REQUIRE { lib/ext/locals.f

WINAPI: GetFileSecurityA ADVAPI32.DLL
WINAPI: SetFileSecurityA ADVAPI32.DLL

\ BOOL GetFileSecurity(
\   LPCTSTR lpFileName,       // address of string for file name
\   SECURITY_INFORMATION RequestedInformation, // requested information
\   PSECURITY_DESCRIPTOR pSecurityDescriptor, // address of security descriptor
\   DWORD nLength,            // size of security descriptor buffer
\   LPDWORD lpnLengthNeeded   // address of required size of buffer
\ );

: SEC-INFO
    DACL_SECURITY_INFORMATION
\    [ DACL_SECURITY_INFORMATION OWNER_SECURITY_INFORMATION OR
\      GROUP_SECURITY_INFORMATION OR ] LITERAL
;

: GetFileSD { a u \ sd lneed -- sd }
    WinNT? 0= IF 0 EXIT THEN
    0 SP@
    AT lneed 4 ROT
    SEC-INFO  a GetFileSecurityA 2DROP
    lneed ?DUP
    IF
        ALLOCATE THROW TO sd
        AT lneed lneed sd
        SEC-INFO  a GetFileSecurityA
        IF sd ELSE 0 ERR  sd FREE THROW THROW THEN
    ELSE
        0
    THEN
;

CREATE fsa 3 CELLS , 0 , 0 ,

: GetFileSA { a u - sa }
    WinNT? 0= IF 0 EXIT THEN
    fsa CELL+ @ ?DUP IF FREE DROP THEN
    fsa CELL+ 0!
    a u GetFileSD ?DUP
    IF fsa CELL+ !  fsa  ELSE  0  THEN
;

: SetFileSA { a u sa -- ior }
    WinNT? 0= IF 0 EXIT THEN
    sa IF
         sa CELL+ @ SEC-INFO a SetFileSecurityA ERR
       ELSE 0 THEN
;
\ S" file.f" GetFileSA . CR


\  AK\    Имеются два дисковых файла A и B, необходимо файлу B установить
\  AK\ такиеже пpава доступа как у файла A. Также это касается папок, если
\  AK\ есть какие то pазличия между pаботой с файлами и папками.
\
\ DWORD needed; void *SD;
\ if(!GetFileSecurity(src,DACL_SECURITY_INFORMATION,NULL,0,&needed))
\   if(GetLastError()==ERROR_INSUFFICIENT_BUFFER)
\   {
\     SD=malloc(needed);
\     if(SD)
\       {
\       if(GetFileSecurity(src,DACL_SECURITY_INFORMATION,SD,needed,&needed))
\         SetFileSecurity(dest,DACL_SECURITY_INFORMATION,SD);
\         free(SD);
\       }
\   }
