\ OS detection mechanism

( Operating systems hierarchy research:
 win/win9x/Me
 win/winnt/Vista
 win/winnt/Windows7
 win/winnt/ReactOS
 win/wince/WinCE
 win/wince/Phone7
 nix/linux/Ubuntu
 nix/bsd/OpenBSD
 nix/bsd/MacOSX
 
 [branch]/[family]/[short-name]

 Factor approach:
   http://docs.factorcode.org/content/vocab-317f1e761f2faa8da781a4762b9dcc2c5cad209a.html
)

REQUIRE EQUAL ~pinka/lib/ext/basics.f
REQUIRE T@    ~pinka/lib/ext/basics.f

REQUIRE WORDLIST-NAMED  ~pinka/spf/compiler/native-wordlist.f
REQUIRE PUSH-DEVELOP    ~pinka/spf/compiler/native-context.f
REQUIRE AsQName         ~pinka/samples/2006/syntax/qname.f

`SUPPORT-OS-DETECTION WORDLIST-NAMED PUSH-DEVELOP


[DEFINED] WINAPI: [IF]

\ WINAPI: GetVersionExA KERNEL32.DLL
REQUIRE WinNT? ~ac/lib/win/winver.f

0 \ struct OSVERSIONINFO
  4 -- dwOSVersionInfoSize
  4 -- dwMajorVersion
  4 -- dwMinorVersion
  4 -- dwBuildNumber
  4 -- dwPlatformId
  128 -- szCSDVersion
CONSTANT /OSVERSIONINFO


BEGIN-EXPORT

: OS-API      ( -- d-txt-api    ) `windows ; \ built-in info
: OS-BRANCH   ( -- d-txt-root   ) `win ;
: OS-FAMILY   ( -- d-txt-family ) \ runtime info
  WinNT? IF `winnt ELSE `win9x THEN
;
: OS-VERSION  ( -- d-txt-version )
  \ returns varsion as major.minor.build in the PAD
  \ example: 6.0.6002
  /OSVERSIONINFO DUP >CELLS RALLOT DUP >R T!
  R@ GetVersionExA ERR THROW
  <# 
    R@ dwBuildNumber  T@ 0 #S 2DROP
    [CHAR] . HOLD
    R@ dwMinorVersion T@ 0 #S 2DROP
    [CHAR] . HOLD
    R@ dwMajorVersion T@ 0 #S 2DROP
    0.
  #>
  R> T@ >CELLS RFREE
;
: OS-NAME  ( -- d-txt-name    )
  `OS ENVIRONMENT? IF EXIT THEN 0.
;

END-EXPORT

[THEN]
PLATFORM `Linux EQUAL [IF]

BEGIN-EXPORT

: OS-API      ( -- d-txt-api    ) `posix ;
: OS-BRANCH   ( -- d-txt-root   ) `nix   ;
: OS-FAMILY   ( -- d-txt-family ) `linux ;
: OS-VERSION  ( -- d-version    ) 0 0    ; \ not implemented yet
: OS-NAME  ( -- d-txt-name    )
  `OSTYPE ENVIRONMENT? IF EXIT THEN 0.
;

END-EXPORT

[THEN]

DROP-DEVELOP

\ what about OS-ABI or OS-KERNEL ?


: IS-OS-BRANCH  ( d-txt-family -- flag )  OS-BRANCH EQUAL   ;
: IS-OS-FAMILY  ( d-txt-family -- flag )  OS-FAMILY EQUAL   ;


: OS-LINUX?    ( -- flag )  `linux IS-OS-FAMILY  ;
: OS-WINDOWS?  ( -- flag )  `win   IS-OS-BRANCH  ;
