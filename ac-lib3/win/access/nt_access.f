REQUIRE EveryoneName ~ac/lib/win/access/everyone.f

WINAPI: GetCurrentProcess            KERNEL32.DLL
WINAPI: GetSecurityInfo              ADVAPI32.DLL
WINAPI: SetSecurityInfo              ADVAPI32.DLL
WINAPI: BuildExplicitAccessWithNameA ADVAPI32.DLL
WINAPI: SetEntriesInAclA             ADVAPI32.DLL

0 CONSTANT NO_INHERITANCE
1 CONSTANT GRANT_ACCESS
4 CONSTANT DACL_SECURITY_INFORMATION
6 CONSTANT SE_KERNEL_OBJECT
\ 1 CONSTANT SE_FILE_OBJECT

HEX
1FFFFF CONSTANT RIGHTS_ALL
DECIMAL

USER-CREATE EXPL_ACCESS 8 CELLS USER-ALLOT


: GetProcessACL ( handle -- dacl ior )
  0 >R RP@
  0 
  0 >R RP@ ( dacl ) 
  0 0 DACL_SECURITY_INFORMATION SE_KERNEL_OBJECT GetCurrentProcess 
  GetSecurityInfo R> SWAP R> FREE DROP
;
: CreateEveryoneACE ( -- )
  NO_INHERITANCE GRANT_ACCESS RIGHTS_ALL EveryoneName ( S" EVERYONE") DROP
  EXPL_ACCESS BuildExplicitAccessWithNameA DROP
;
: CreateEveryoneACL ( -- acl ior )
  CreateEveryoneACE
  0 >R RP@
  0 EXPL_ACCESS 1 SetEntriesInAclA
  R> SWAP
;
: SetObjectACL ( acl h -- ior )
  >R 0 SWAP 0 0 DACL_SECURITY_INFORMATION SE_KERNEL_OBJECT
  R> SetSecurityInfo
;
\ CreateEveryoneACL THROW S" test_semaphore" SemCreate SetObjectACL
