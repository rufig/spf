\ LocalLogon - локальная (если компьютер входит в домен, то и доменная)
\ авторизация по имени и паролю, не требующая сервисных прав процесса
\ в отличие от LogonUser в nt_logon.f

REQUIRE {                     lib/ext/locals.f
REQUIRE AllocAuthIdentUnicode ~ac/lib/win/access/sspi.f 

USER expiryClient
USER expiryClient2
USER hcredClient
USER hcredClient2

USER expiryServer
USER expiryServer2
USER hcredServer
USER hcredServer2

USER expiryClientCtx
USER expiryClientCtx2
USER grfCtxAttrsClient

USER expiryServerCtx
USER expiryServerCtx2
USER grfCtxAttrsServer

USER clientCtxHandleOut
USER clientCtxHandleOut2

USER serverCtxHandleOut
USER serverCtxHandleOut2

\ в ANSI-режиме не работают русские имена и пароли :(

: LocalLogon { logina loginu passa passu -- flag }
  expiryClient hcredClient 0 0 
  logina loginu passa passu S" ." AllocAuthIdentUnicode 
  0 SECPKG_CRED_OUTBOUND 
  S" NTLM" >UNICODE DROP 0 AcquireCredentialsHandleW THROW
\  ." Client:AcquireCredentialsHandle OK:" expiryClient @ U. hcredClient @ . CR


  expiryClientCtx grfCtxAttrsClient clientOutput clientCtxHandleOut 0
  0 SECURITY_NATIVE_DREP 0 ISC_REQ_CONNECTION \ ISC_REQ_ALLOCATE_MEMORY OR
  logina 0 hcredClient InitializeSecurityContextA
\  uclientOutput @ DUP 3 CELLS + @ SWAP 6 CELLS + SWAP DUMP CR

  DUP SEC_I_CONTINUE_NEEDED =
  IF DROP

  expiryServer hcredServer 0 0 0 0 SECPKG_CRED_INBOUND 
  S" NTLM" DROP 0 AcquireCredentialsHandleA THROW
\  ." Server:AcquireCredentialsHandle OK:" expiryServer @ U. hcredServer @ . CR

     expiryServerCtx grfCtxAttrsServer serverOutput serverCtxHandleOut
     SECURITY_NATIVE_DREP ISC_REQ_CONNECTION uclientOutput @
     0 hcredServer AcceptSecurityContext
\     userverOutput @ DUP 3 CELLS + @ SWAP 6 CELLS + SWAP DUMP CR
 
     DUP SEC_I_CONTINUE_NEEDED =
     IF DROP
        expiryClientCtx grfCtxAttrsClient clientOutput clientCtxHandleOut 0
        userverOutput @ SECURITY_NATIVE_DREP 0 ISC_REQ_CONNECTION
        logina clientCtxHandleOut hcredClient InitializeSecurityContextA
\        ." client:" HEX U. CR
\        uclientOutput @ DUP 3 CELLS + @ SWAP 6 CELLS + SWAP DUMP CR
        DUP 0=
        IF DROP
           expiryServerCtx grfCtxAttrsServer serverOutput serverCtxHandleOut
           SECURITY_NATIVE_DREP ISC_REQ_CONNECTION uclientOutput @
           serverCtxHandleOut hcredServer AcceptSecurityContext
\           ." server:" DUP HEX U. CR THROW
\           userverOutput @ DUP 3 CELLS + @ SWAP 6 CELLS + SWAP DUMP CR
           0=
        ELSE ." NTLM unknown return 3:" HEX U. 0 THEN
     ELSE ." NTLM unknown return 2:" HEX U. 0 THEN
  ELSE ." NTLM unknown return 1:" HEX U. 0 THEN
;
\ S" тест11" S" test11" LocalLogon .
