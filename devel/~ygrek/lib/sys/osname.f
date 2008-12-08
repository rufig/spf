\ $Id$
\ 
\ OSNAME-STR ( -- s )
\ OS name and version as a single string

REQUIRE [DEFINED] lib/include/tools.f
REQUIRE cat ~ygrek/lib/cat.f
REQUIRE replace-str- ~pinka/samples/2005/lib/replace-str.f

[DEFINED] WINAPI: [IF]

REQUIRE /OSVERSIONINFO lib/win/osver.f

: OSVER_INFO ( -- build minor major )
   /OSVERSIONINFO ALLOCATE THROW DUP >R
   /OSVERSIONINFO R@ !
   GetVersionExA DROP
   R@ dwBuildNumber @
   R@ dwMinorVersion @
   R@ dwMajorVersion @
   R> FREE THROW
;

: OSNAME-STR ( -- s ) OSVER_INFO " Microsoft Windows {n}.{n}.{n}" ;

[ELSE]

: uname ( ? -- s )
  S" /proc/sys/kernel/ostype" cat 
  S" /proc/sys/kernel/osrelease" cat OVER S+
  SWAP IF S" /proc/sys/kernel/version" cat OVER S+ THEN
  DUP " {EOLN}" "  " replace-str- ;

: OSNAME-STR FALSE uname ;

[THEN]

