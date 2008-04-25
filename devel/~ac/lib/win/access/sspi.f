\ функции поддержки локальной и дистанционной авторизации через SSPI

REQUIRE {        lib/ext/locals.f
REQUIRE >UNICODE ~ac/lib/lin/iconv/iconv.f 

WINAPI: AcquireCredentialsHandleA  secur32.dll
WINAPI: AcquireCredentialsHandleW  secur32.dll
WINAPI: InitializeSecurityContextA secur32.dll
WINAPI: AcceptSecurityContext      secur32.dll
WINAPI: ImpersonateSecurityContext secur32.dll
WINAPI: RevertSecurityContext      secur32.dll
WINAPI: GetUserNameExA             secur32.dll

     0x200 CONSTANT SEC_WINNT_AUTH_IDENTITY_VERSION
         1 CONSTANT SEC_WINNT_AUTH_IDENTITY_ANSI
         2 CONSTANT SEC_WINNT_AUTH_IDENTITY_UNICODE
         1 CONSTANT SECPKG_CRED_INBOUND
         2 CONSTANT SECPKG_CRED_OUTBOUND
         2 CONSTANT SECBUFFER_TOKEN
0x00000800 CONSTANT ISC_REQ_CONNECTION
0x00000100 CONSTANT ISC_REQ_ALLOCATE_MEMORY
0x00000010 CONSTANT SECURITY_NATIVE_DREP
0x00000000 CONSTANT SECURITY_NETWORK_DREP
0x00090312 CONSTANT SEC_I_CONTINUE_NEEDED

0x8009030C CONSTANT SEC_E_LOGON_DENIED \ возврат из второго AcceptSecurityContext при неверном имени или пароле

USER uclientOutput
: clientOutput ( -- addr )
  8024 ALLOCATE THROW >R
  0 R@ ! \ SECBUFFER_VERSION
  1 R@ CELL+ !
  R@ 3 CELLS + R@ CELL+ CELL+ !
  8000            R@ 3 CELLS + !
  SECBUFFER_TOKEN R@ 4 CELLS + !
  R@ 6 CELLS +    R@ 5 CELLS + !
  R>
  DUP uclientOutput !
;
: readClientOutput { addr u \ r -- }
  u 6 CELLS + ALLOCATE THROW -> r
  0 r ! \ SECBUFFER_VERSION
  1 r CELL+ !
  r 3 CELLS + r CELL+ CELL+ !
  u               r 3 CELLS + !
  SECBUFFER_TOKEN r 4 CELLS + !
  r 6 CELLS +     r 5 CELLS + !
  addr r 6 CELLS + u MOVE
  r uclientOutput !
;

USER userverOutput
: serverOutput ( -- addr )
  8024 ALLOCATE THROW >R
  0 R@ ! \ SECBUFFER_VERSION
  1 R@ CELL+ !
  R@ 3 CELLS + R@ CELL+ CELL+ !
  8000            R@ 3 CELLS + !
  SECBUFFER_TOKEN R@ 4 CELLS + !
  R@ 6 CELLS +    R@ 5 CELLS + !
  R>
  DUP userverOutput !
;
: AllocAuthIdent { logina loginu passa passu doma domu -- addr }
  11 CELLS ALLOCATE THROW >R
  R@
  SEC_WINNT_AUTH_IDENTITY_VERSION OVER ! CELL+
  11 CELLS OVER ! CELL+
  DUP logina loginu ROT CELL+ ! OVER ! CELL+ CELL+
  DUP doma domu     ROT CELL+ ! OVER ! CELL+ CELL+
  DUP passa passu   ROT CELL+ ! OVER ! CELL+ CELL+
  SEC_WINNT_AUTH_IDENTITY_ANSI OVER ! CELL+
  0 OVER ! CELL+
  0!
  R>
;
: AllocAuthIdentUnicode { logina loginu passa passu doma domu -- addr }
  11 CELLS ALLOCATE THROW >R
  R@
  SEC_WINNT_AUTH_IDENTITY_VERSION OVER ! CELL+
  11 CELLS OVER ! CELL+
  DUP logina loginu >UNICODE 2 / ROT CELL+ ! OVER ! CELL+ CELL+
  DUP doma domu     >UNICODE 2 / ROT CELL+ ! OVER ! CELL+ CELL+
  DUP passa passu   >UNICODE 2 / ROT CELL+ ! OVER ! CELL+ CELL+
  SEC_WINNT_AUTH_IDENTITY_UNICODE OVER ! CELL+
  0 OVER ! CELL+
  0!
  R>
;
