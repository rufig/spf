REQUIRE { ~ac/lib/locals.f

WINAPI: AllocateAndInitializeSid ADVAPI32.DLL
WINAPI: LookupAccountSidA        ADVAPI32.DLL

CREATE SID_IDENTIFIER_AUTHORITY 0 , 0 C, 1 C,

: EveryoneSid ( -- sid ) { \ psid }
  ^ psid 0 0 0 0 0 0 0 0 1 SID_IDENTIFIER_AUTHORITY AllocateAndInitializeSid
  ERR THROW psid
;
: EveryoneName ( -- addr u ) { \ pszName pszDomain pcbName pcbDomain peUse }
  256 ALLOCATE THROW -> pszName
  256 ALLOCATE THROW -> pszDomain
  256 -> pcbName
  256 -> pcbDomain
  ^ peUse ^ pcbDomain pszDomain ^ pcbName pszName EveryoneSid 0
  LookupAccountSidA ERR THROW
  pszName ASCIIZ>
;
