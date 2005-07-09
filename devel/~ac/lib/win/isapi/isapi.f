WINAPI: LoadLibraryExA KERNEL32.DLL
WINAPI: FreeLibrary    KERNEL32.DLL

\ WINAPI: GetExtensionVersion php5isapi.dll
\ WINAPI: HttpExtensionProc   php5isapi.dll
\ WINAPI: GetExtensionVersion perlis.dll
\ WINAPI: HttpExtensionProc   perlis.dll

\ такой нет! WINAPI: TerminateExtension  php5isapi.dll
\ такой нет! WINAPI: TerminateExtension  perlis.dll

VECT dIsapiSetStatus
VECT dIsapiSetHeader
VECT dIsapiWriteClient
VECT dIsapiMapPath

' TYPE TO dIsapiWriteClient

: IsapiSetStatus
  ." <status=" TYPE ." >" CR
;
' IsapiSetStatus TO dIsapiSetStatus

: IsapiSetHeader
  ." <header=" TYPE ." >" CR
;
' IsapiSetHeader TO dIsapiSetHeader


0
4 -- ecb.cbSize
4 -- ecb.dwVersion
4 -- ecb.connID
4 -- ecb.dwHttpStatusCode
80 -- ecb.lpszLogData
4 -- ecb.lpszMethod
4 -- ecb.lpszQueryString
4 -- ecb.lpszPathInfo
4 -- ecb.lpszPathTranslated
4 -- ecb.cbTotalBytes
4 -- ecb.cbAvailable
4 -- ecb.lpbData
4 -- ecb.lpszContentType
4 -- ecb.GetServerVariable
4 -- ecb.WriteClient
4 -- ecb.ReadClient
4 -- ecb.ServerSupportFunction
CONSTANT /EXTENSION_CONTROL_BLOCK

1016 CONSTANT HSE_REQ_SEND_RESPONSE_HEADER_EX
1012 CONSTANT HSE_REQ_MAP_URL_TO_PATH_EX
1001 CONSTANT HSE_REQ_MAP_URL_TO_PATH
   1 CONSTANT HSE_TERM_MUST_UNLOAD

0
CELL -- shei.pszStatus
CELL -- shei.pszHeader
CELL -- shei.cchStatus
CELL -- shei.cchHeader
CELL -- shei.fKeepConn
CONSTANT /HSE_SEND_HEADER_EX_INFO

0
 260 -- umi.lpszPath
CELL -- umi.dwFlags
CELL -- umi.cchMatchingPath
CELL -- umi.cchMatchingURL
CELL -- umi.dwReserved1
CELL -- umi.dwReserved2
CONSTANT /HSE_URL_MAPEX_INFO
 

USER-CREATE ecb ecb /EXTENSION_CONTROL_BLOCK DUP USER-ALLOT ERASE

: SCRIPT_NAME ecb ecb.lpszPathInfo @ ASCIIZ> ;
: QUERY_STRING S" qqq=sss" ; 
: REQUEST_METHOD S" GET" ; 
: PATH_TRANSLATED S" /wwwroot/path/info" ; 
: PATH_INFO S" /path/info" ; 

: IsapiMapPath ( addr u -- addr2 u2 )
  0 MAX \ PHP может передавать отрицательную длину! :-)
\  ." Map logical path:<" TYPE ." >" CR
  2DROP
  SCRIPT_NAME
;
' IsapiMapPath TO dIsapiMapPath

: HTTP_COOKIE S" _HTTP_COOKIE_" ; 
: ALL_HTTP S" _ALL_HTTP_" ; 
: HTTPS S" _HTTPS_" ; 
: AUTH_PASSWORD S" _AUTH_PASSWORD_" ; 
: AUTH_TYPE S" _AUTH_TYPE_" ; 
: AUTH_USER S" _AUTH_USER_" ; 
: CONTENT_LENGTH S" _CONTENT_LENGTH_" ; 
: CONTENT_TYPE S" _CONTENT_TYPE_" ; 
: REMOTE_ADDR S" _REMOTE_ADDR_" ; 
: REMOTE_HOST S" _REMOTE_HOST_" ; 
: REMOTE_USER S" _REMOTE_USER_" ; 
: SERVER_NAME S" _SERVER_NAME_" ; 
: SERVER_PORT S" _SERVER_PORT_" ; 
: SERVER_PROTOCOL S" _SERVER_PROTOCOL_" ; 
: SERVER_SOFTWARE S" _SERVER_SOFTWARE_" ; 
: APPL_MD_PATH S" _APPL_MD_PATH_" ; 
: APPL_PHYSICAL_PATH S" _APPL_PHYSICAL_PATH_" ; 
: INSTANCE_ID S" _INSTANCE_ID_" ; 
: INSTANCE_META_PATH S" _INSTANCE_META_PATH_" ; 
: LOGON_USER S" _LOGON_USER_" ; 
: REQUEST_URI S" _REQUEST_URI_" ; 
: URL S" _URL_" ; 


: CERT_COOKIE S" _CERT_COOKIE_" ; 
: CERT_FLAGS S" _CERT_FLAGS_" ; 
: CERT_ISSUER S" _CERT_ISSUER_" ; 
: CERT_KEYSIZE S" _CERT_KEYSIZE_" ; 
: CERT_SECRETKEYSIZE S" _CERT_SECRETKEYSIZE_" ; 
: CERT_SERIALNUMBER S" _CERT_SERIALNUMBER_" ; 
: CERT_SERVER_ISSUER S" _CERT_SERVER_ISSUER_" ; 
: CERT_SERVER_SUBJECT S" _CERT_SERVER_SUBJECT_" ; 
: CERT_SUBJECT S" _CERT_SUBJECT_" ; 
: HTTPS_KEYSIZE S" _HTTPS_KEYSIZE_" ; 
: HTTPS_SECRETKEYSIZE S" _HTTPS_SECRETKEYSIZE_" ; 
: HTTPS_SERVER_ISSUER S" _HTTPS_SERVER_ISSUER_" ; 
: HTTPS_SERVER_SUBJECT S" _HTTPS_SERVER_SUBJECT_" ; 
: SERVER_PORT_SECURE S" _SERVER_PORT_SECURE_" ; 

(
: LC_ALL S" _LC_ALL_" ; 
: LANG S" _LANG_" ; 
: PERL_UNICODE S" _PERL_UNICODE_" ; 
: PERL5OPT S" _PERL5OPT_" ; 
: PERL5LIB S" _PERL5LIB_" ; 
: PERLLIB S" _PERLLIB_" ; 
: PERLIO S" _PERLIO_" ; 
: PERLIO_DEBUG S" _PERLIO_DEBUG_" ; 
: PERL_SIGNALS S" _PERL_SIGNALS_" ; 
: SERVER_PORT S" _SERVER_PORT_" ; 
: MOD_PERL S" _MOD_PERL_" ; 

: GATEWAY_INTERFACE S" _GATEWAY_INTERFACE_" ; 
: TMPDIR S" _TMPDIR_" ; 

\ perlinfo
: PWD S" _PWD_" ;
: COMPUTERNAME S" _COMPUTERNAME_" ;
: LOCALDOMAIN S" _LOCALDOMAIN_" ;
: DOMAIN S" _DOMAIN_" ;
: HTTP_HOST S" _HTTP_HOST_" ; 
: HTTP_USER_AGENT S" _HTTP_USER_AGENT_" ; 
: HTTP_ACCEPT_ENCODING S" _HTTP_ACCEPT_ENCODING_" ; 
: HTTP_ACCEPT_LANGUAGE S" _HTTP_ACCEPT_LANGUAGE_" ; 
: HTTP_ACCEPT_CHARSET S" _HTTP_ACCEPT_CHARSET_" ; 
: HTTP_KEEP_ALIVE S" _HTTP_KEEP_ALIVE_" ; 
: HTTP_CONNECTION S" _HTTP_CONNECTION_" ;

)

\ BOOL WINAPI GetServerVariable(
\    HCONN hConn,
\    LPSTR lpszVariableName,
\    LPVOID lpvBuffer,
\    LPDWORD lpdwSizeofBuffer
\ );

:NONAME ( lpdwSizeofBuffer lpvBuffer lpszVariableName hConn -- flag )
  TlsIndex@ >R
  TlsIndex! 
  ASCIIZ> \ 2DUP 2>R
  SFIND IF EXECUTE ( 2R> TYPE ." =" 2DUP TYPE CR) >R SWAP R@ 1+ MOVE R> SWAP ! TRUE
        ELSE ENVIRONMENT?
             IF ( 2R> TYPE ." =" 2DUP TYPE CR) >R SWAP R@ 1+ MOVE R> SWAP ! TRUE
             ELSE ( 2R> 2DROP) 2DROP FALSE
             THEN
        THEN
  R> TlsIndex!
; WNDPROC: IsapiGetServerVariable


\ BOOL WriteClient(
\       HCONN ConnID,
\       LPVOID Buffer,
\       LPDWORD lpdwSizeofBuffer,
\       DWORD dwSync
\ );

:NONAME ( dwSync lpdwSizeofBuffer Buffer ConnID -- flag )
  TlsIndex@ >R
  TlsIndex!
  SWAP @ dIsapiWriteClient
  DROP \ 1=sync, 2=async
  TRUE
  R> TlsIndex!
; WNDPROC: IsapiWriteClient

\ BOOL ReadClient(
\       HCONN hConn,
\       LPVOID lpvBuffer,
\       LPDWORD lpdwSize
\ );

:NONAME ( lpdwSize lpvBuffer hConn -- flag )
  TlsIndex@ >R
  TlsIndex!
  ." ReadClient:" . . . FALSE
  R> TlsIndex!
; 3 CELLS CALLBACK: IsapiReadClient

\ BOOL WINAPI ServerSupportFunction(
\       HCONN ConnID,
\       DWORD dwServerSupportFunction,
\       LPVOID lpvBuffer,
\       LPDWORD lpdwSizeofBuffer,
\       LPDWORD lpdwDataType
\ );

:NONAME ( lpdwDataType lpdwSizeofBuffer lpvBuffer dwServerSupportFunction ConnID -- flag )
  TlsIndex@ >R
  TlsIndex!
  DUP HSE_REQ_SEND_RESPONSE_HEADER_EX =
  IF DROP >R 2DROP
     R@ shei.pszStatus @ ASCIIZ> dIsapiSetStatus
     R> shei.pszHeader @ ASCIIZ> dIsapiSetHeader
     TRUE R> TlsIndex! EXIT
  THEN
  DUP HSE_REQ_MAP_URL_TO_PATH_EX =
  IF DROP SWAP @ dIsapiMapPath 1+ ROT umi.lpszPath SWAP MOVE
     TRUE R> TlsIndex! EXIT
  THEN
  DUP HSE_REQ_MAP_URL_TO_PATH =
  IF DROP >R
     SWAP DROP \ null
     R@ SWAP >R
     ASCIIZ> dIsapiMapPath DUP R> !
     R> SWAP MOVE
     TRUE R> TlsIndex! EXIT
  THEN
  ." ServerSupportFunction:" . . . . CR FALSE
  R> TlsIndex!
; 5 CELLS CALLBACK: IsapiServerSupportFunction

: IsapiRunExtension ( scriptaddr scriptu addr u -- code )
  DROP 
  ( LOAD_WITH_ALTERED_SEARCH_PATH) 0x00000008 0 ROT
  LoadLibraryExA DUP 0= IF DROP ." ISAPI LoadLibrary failed" CR EXIT THEN
  >R

  /EXTENSION_CONTROL_BLOCK   ecb ecb.cbSize !
  REQUEST_METHOD DROP  ecb   ecb.lpszMethod !
  QUERY_STRING DROP    ecb   ecb.lpszQueryString !
\ Perl хочет в PATH_INFO видеть путь к скрипту!
  ( PATH_INFO) DROP          ecb ecb.lpszPathInfo !
  PATH_TRANSLATED DROP       ecb ecb.lpszPathTranslated !
  TlsIndex@                  ecb ecb.connID !
  ['] IsapiGetServerVariable ecb ecb.GetServerVariable !
  ['] IsapiWriteClient       ecb ecb.WriteClient !
  ['] IsapiReadClient        ecb ecb.ReadClient !
  ['] IsapiServerSupportFunction ecb ecb.ServerSupportFunction !

  ecb S" HttpExtensionProc" DROP R@ GetProcAddress ?DUP
  IF API-CALL
  ELSE 2DROP ." ISAPI GetProcAddress failed" CR THEN
  R> FreeLibrary 1 <> THROW

\  CR ecb ecb.lpszLogData ASCIIZ> TYPE CR
\  DUP 1 > IF CR ." HttpExtensionProc() returned " . CR ELSE DROP THEN
\ HSE_STATUS_SUCCESS=1, HSE_STATUS_ERROR=4
;
: TEST
  100 0 DO
 S" C:\distr\1\php3.php"  S" C:\ac\dl\php-4.4.0RC2-Win32\php-4.4.0RC2-Win32\php4isapi.dll" IsapiRunExtension .
\ CR ." ============" CR
 S" C:\distr\1\perl3.pl" S" c:\Perl\bin\perlis.dll" IsapiRunExtension .
\ I . DEPTH .
  LOOP
;
WINAPI: GetTickCount KERNEL32.DLL
:NONAME
  >R ['] TEST CATCH DUP .
  CR R> . ." !!!finished!!!) " GetTickCount . CR 
; TASK: TEST1

: TEST2 ( n -- )
  ." (" GetTickCount . CR
  100 MIN 0 ?DO
    I TEST1 START DROP
  LOOP
;
5 TEST2
\ TEST
