WINAPI: LoadLibraryExA KERNEL32.DLL

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
VECT dREQUEST_METHOD
VECT dQUERY_STRING
VECT dPATH_TRANSLATED
VECT dPOST_BODY
VECT dCONTENT_TYPE

USER uSN_CNT
USER uIsapiDebug

: IsapiTYPE
  TYPE TRUE
;
' IsapiTYPE TO dIsapiWriteClient

: IsapiSetStatus
  ." <status=" TYPE ." >" CR
;
' IsapiSetStatus TO dIsapiSetStatus

: IsapiSetHeader
  ." <header=" TYPE ." >" CR
;
' IsapiSetHeader TO dIsapiSetHeader

:NONAME S" GET" ; TO dREQUEST_METHOD
:NONAME S" qqq=sss" ; TO dQUERY_STRING
:NONAME S" /wwwroot/path/info" ; TO dPATH_TRANSLATED
:NONAME S" " ; DUP TO dPOST_BODY TO dCONTENT_TYPE

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

: SCRIPT_FILENAME ecb ecb.lpszPathInfo @ ASCIIZ> ;

\ веб-сервер должен переопределить SCRIPT_NAME!
: SCRIPT_NAME SCRIPT_FILENAME ;

(
: QUERY_STRING S" qqq=sss" ; 
: REQUEST_METHOD S" GET" ; 
: PATH_TRANSLATED S" /wwwroot/path/info" ; 
: PATH_INFO S" /path/info" ; 
)
: SERVER_PROTOCOL S" HTTP/1.0" ; 
: SERVER_SOFTWARE S" acWEB/3" ; 

: IsapiMapPath ( addr u -- addr2 u2 )
  0 MAX \ PHP может передавать отрицательную длину! :-)
\  ." Map logical path:<" 2DUP TYPE ." >" CR
  2DROP
  SCRIPT_FILENAME
;
' IsapiMapPath TO dIsapiMapPath

(
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
  TlsIndex! S0 @ >R SP@ 12 + S0 !
  >R OVER R> SWAP @ 1- 0 MAX >R \ длина входного буфера для переменной
  ASCIIZ> uIsapiDebug @ IF ." >>" 2DUP TYPE ." =" THEN
  2DUP S" TZ" COMPARE 0= IF 2DROP S" TZone" THEN
  2DUP S" SCRIPT_NAME" COMPARE 0= IF uSN_CNT 1+! THEN \ хак для PHP
  SFIND IF EXECUTE uIsapiDebug @ IF 2DUP TYPE THEN
           DUP
           IF
             R> MIN \ обрежем значение переменной, если не влазит в буфер
             >R SWAP R@ 2DUP 1+ ERASE MOVE R> 1+ SWAP ! TRUE
           ELSE 2DROP RDROP DROP 0! FALSE THEN
        ELSE RDROP
             \ ENVIRONMENT?
             \ IF uIsapiDebug @ IF 2DUP TYPE THEN
             \    >R SWAP R@ 2DUP 1+ ERASE MOVE R> 1+ SWAP ! TRUE
             \ ELSE DROP 0! FALSE
             \ THEN
             2DROP DROP 0! FALSE
        THEN
  uIsapiDebug @ IF ." (F=" DUP . ." )" CR THEN
  R> S0 !
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
  TlsIndex! S0 @ >R SP@ 12 + S0 !
  SWAP @
\  uIsapiDebug @ IF ." (W=" 2DUP TYPE ." )" CR THEN
  dIsapiWriteClient ( flag )
  NIP \ 1=sync, 2=async
  R> S0 !
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
  TlsIndex! S0 @ >R SP@ 16 + S0 !
  DUP HSE_REQ_SEND_RESPONSE_HEADER_EX =
  IF DROP >R 2DROP
     R@ shei.pszStatus @ ASCIIZ> 
     uIsapiDebug @ IF ." (S=" 2DUP TYPE ." )" CR THEN
     dIsapiSetStatus
     R> shei.pszHeader @ ASCIIZ>
     uIsapiDebug @ IF ." (H=" 2DUP TYPE ." )" CR THEN
     dIsapiSetHeader
     R> S0 !
     TRUE R> TlsIndex! EXIT
  THEN
  DUP HSE_REQ_MAP_URL_TO_PATH_EX =
  IF DROP SWAP @ dIsapiMapPath 1+ ROT umi.lpszPath SWAP MOVE
     R> S0 !
     TRUE R> TlsIndex! EXIT
  THEN
  DUP HSE_REQ_MAP_URL_TO_PATH =
  IF DROP >R
     SWAP DROP \ null
     R@ SWAP >R
     ASCIIZ> dIsapiMapPath DUP R> !
     R> SWAP MOVE
     R> S0 !
     TRUE R> TlsIndex! EXIT
  THEN
  uIsapiDebug @ IF ." ServerSupportFunction:" . . . . CR THEN
  FALSE
  R> S0 !
  R> TlsIndex!
; 5 CELLS CALLBACK: IsapiServerSupportFunction

: IsapiExtension:
  CREATE 0 , 0 , S, 0 C,
;
: IsapiInitExtension ( addr -- )
  DUP @ IF DROP EXIT THEN
  DUP CELL+ CELL+
  ( LOAD_WITH_ALTERED_SEARCH_PATH) 0x00000008 0 ROT
  LoadLibraryExA DUP 0= IF DROP ." ISAPI LoadLibrary failed" CR GetLastError THROW THEN
  SWAP !
;
: IsapiCallExtension ( ecb addr -- res )
  >R
  R@ CELL+ @ ?DUP IF RDROP API-CALL EXIT THEN
  S" HttpExtensionProc" DROP R@ @ GetProcAddress ?DUP
  IF DUP R> CELL+ ! API-CALL
  ELSE R> 2DROP ." ISAPI GetProcAddress failed" CR -2011 THROW THEN
;
: IsapiAdump
  uIsapiDebug @ IF ." ::" DUP ASCIIZ> TYPE ." ::" CR THEN
;
: IsapiRunExtension ( scriptaddr scriptu addr -- code )
  DUP >R IsapiInitExtension

  /EXTENSION_CONTROL_BLOCK   ecb ecb.cbSize !
  dREQUEST_METHOD DROP  IsapiAdump  ecb ecb.lpszMethod !
  dQUERY_STRING DROP    IsapiAdump  ecb ecb.lpszQueryString !
\ Perl хочет в PATH_INFO видеть путь к скрипту!
  ( PATH_INFO) DROP     IsapiAdump  ecb ecb.lpszPathInfo !
  dPATH_TRANSLATED DROP IsapiAdump  ecb ecb.lpszPathTranslated !
  TlsIndex@                  ecb ecb.connID !
  ['] IsapiGetServerVariable ecb ecb.GetServerVariable !
  ['] IsapiWriteClient       ecb ecb.WriteClient !
  ['] IsapiReadClient        ecb ecb.ReadClient !
  ['] IsapiServerSupportFunction ecb ecb.ServerSupportFunction !
  dPOST_BODY DUP ecb ecb.cbTotalBytes ! ecb ecb.cbAvailable ! ecb ecb.lpbData !
  dCONTENT_TYPE DROP ecb ecb.lpszContentType !

  ecb R> IsapiCallExtension

  uIsapiDebug @
  IF
    ecb ecb.lpszLogData ASCIIZ> TYPE CR
    ." HttpExtensionProc() returned " DUP . CR
  THEN
\ HSE_STATUS_SUCCESS=1, HSE_STATUS_ERROR=4
;


\EOF
\ ============== benchmark ====================
\ S" D:\Perl\bin\perlis.dll" IsapiExtension: PERL
\ S" D:\PHP4\php-4.3.11-Win32\php4isapi.dll" IsapiExtension: PHP4
\ S" D:\ac\php-5.1.0b2-Win32\php5isapi.dll" IsapiExtension: PHP5

S" C:\Perl\bin\perlis.dll" IsapiExtension: PERL
S" C:\ac\dl\php-4.4.0RC2-Win32\php-4.4.0RC2-Win32\php4isapi.dll" IsapiExtension: PHP4
S" C:\ac\php-5.1.0b2-Win32\php5isapi.dll" IsapiExtension: PHP5


\ S" D:\perl3.pl" PERL IsapiRunExtension .
\ S" D:\perl3.pl" PERL IsapiRunExtension .


\ S" D:\ac\php-5.1.0b2-Win32\php3.php"  PHP4 IsapiRunExtension DROP
\ S" D:\perl3.pl" S" D:\Perl\bin\perlis.dll" IsapiRunExtension DROP

: TEST
  1000 0 DO
\ S" D:\ac\php-5.1.0b2-Win32\php3.php"  PHP4 IsapiRunExtension .
\ CR ." ============" CR
\ S" D:\perl3.pl" PERL IsapiRunExtension .

 S" C:\distr\1\php3.php"  PHP4 IsapiRunExtension .
\ CR ." ============" CR
 S" C:\distr\1\perl3.pl" PERL IsapiRunExtension .

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
15 TEST2
\ TEST
