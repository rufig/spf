REQUIRE UNICODE> ~ac/lib/win/com/com.f

: S, ( addr u -- )
  HERE OVER ALLOT SWAP MOVE
;
  
WINAPI: LsaLogonUser SECUR32.DLL
\ WINAPI: GetTokenInformation SECUR32.DLL
WINAPI: LsaRegisterLogonProcess SECUR32.DLL
WINAPI: LsaNtStatusToWinError ADVAPI32.DLL
WINAPI: LsaLookupAuthenticationPackage SECUR32.DLL
WINAPI: AllocateLocallyUniqueId ADVAPI32.DLL

CREATE SubStatus 100 ALLOT
CREATE Quotas    1000 ALLOT
VARIABLE Token
CREATE LogonId ALIGN 8 ALLOT
VARIABLE ProfileBufferLength
VARIABLE pointer 1000 ALLOT
CREATE ProfileBuffer pointer , 1000 ALLOT
8 ALIGN-BYTES !
CREATE TOKEN_SOURCE ALIGN S" Source  " S,
HERE 8 ALLOT DUP 8 ERASE AllocateLocallyUniqueId 0= THROW

: US, >UNICODE 1+ DUP W, DUP W, HERE CELL + , S, 0 W, ;

CREATE DOMAIN S" cherezov" US,
CREATE NAME S" ac" US,
CREATE PASS  S" noexnoex" US,
CREATE AI 2 , 
\ S" rainbow.koenig.ru" US, S" ac" US, S" noexnoex" US,
\ DOMAIN , NAME , PASS ,
DOMAIN 2@ , ,
NAME 2@ , ,
PASS 2@ , ,

HERE AI - CONSTANT /AI
\ AI /AI DUMP


\    MsV1_0InteractiveLogon = 2,

\ typedef struct _MSV1_0_INTERACTIVE_LOGON {
\     MSV1_0_LOGON_SUBMIT_TYPE MessageType;
\     UNICODE_STRING LogonDomainName;
\     UNICODE_STRING UserName;
\     UNICODE_STRING Password;
\ } MSV1_0_INTERACTIVE_LOGON, *PMSV1_0_INTERACTIVE_LOGON;

VARIABLE SecurityMode
VARIABLE LsaHandle
CREATE LogonProcessName S" EservLogon" DUP W, DUP 1+ W, HERE CELL + , S, 0 C,
CREATE OriginName S" spf" DUP W, DUP 1+ W, HERE CELL + , S, 0 C,
CREATE PackageName S" MICROSOFT_AUTHENTICATION_PACKAGE_V1_0" DUP W, DUP 1+ W, HERE CELL + , S, 0 C,
VARIABLE gAuthPackageId
VARIABLE LocalGroups

: LogonProcessHandle
  SecurityMode LsaHandle LogonProcessName
  LsaRegisterLogonProcess LsaNtStatusToWinError THROW LsaHandle @
;
: AuthPackageId
  gAuthPackageId PackageName LogonProcessHandle
  LsaLookupAuthenticationPackage LsaNtStatusToWinError THROW
  gAuthPackageId @
;

: TEST
  SubStatus Quotas Token LogonId ALIGNED ProfileBufferLength ProfileBuffer
  TOKEN_SOURCE ALIGNED
0 \  LocalGroups
  /AI AI
  AuthPackageId \ 2 ( LOGON32_PROVIDER_WINNT40 )
  2 ( interactive )
  OriginName LsaHandle @ LsaLogonUser LsaNtStatusToWinError U.
;
TEST