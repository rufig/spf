( Авторизация пользователей на сервере WinNT/2000 А.Ч. 
  07.Mar.1997, дополнения 24.Mar.2000 )

WINAPI: LogonUserA              ADVAPI32.DLL
WINAPI: ImpersonateLoggedOnUser ADVAPI32.DLL
WINAPI: RevertToSelf            ADVAPI32.DLL

0 CONSTANT LOGON32_PROVIDER_DEFAULT
4 CONSTANT LOGON32_LOGON_BATCH
3 CONSTANT LOGON32_LOGON_NETWORK
USER TOKEN
USER uAuthServer

: AuthServer uAuthServer @ ?DUP IF EXECUTE ELSE S" ." THEN ;

: Logon ( S"user" S"password" S"domain" -- token ior )
  DROP >R DROP >R DROP >R
  TOKEN LOGON32_PROVIDER_DEFAULT LOGON32_LOGON_NETWORK
  R> R> SWAP R> SWAP LogonUserA
  IF TOKEN @ FALSE ELSE 0 GetLastError THEN
;
: LoginUser ( addr-name u-name addr-passw u-passw -- uid )
  AuthServer Logon 
\ ?DUP IF ." Auth failed: " . EXIT ( 0) THEN
  IF EXIT ( 0) THEN
  DUP ImpersonateLoggedOnUser DROP
;
: LogoutUser ( -- )
  RevertToSelf DROP
;
