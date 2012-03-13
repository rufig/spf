( Provides  "lib.libxml2" clever wordlist

)

GET-ORDER GET-CURRENT ONLY FORTH DEFINITIONS

REQUIRE OS-FAMILY ~pinka/spf/os-detection.f
REQUIRE SO        ~ac/lib/ns/so-xt.f

  \ SP-Forth/4 extensions should be in the root vocabulary.
SET-CURRENT SET-ORDER

ALSO SO
  1
  DUP OS-WINDOWS? AND [IF] ?NEW: libxml2.dll    DROP 0  [THEN]
  DUP OS-LINUX?   AND [IF] ?NEW: libxml2.so.2   DROP 0  [THEN]
  [IF] .( libxml2-lib.f -- unsupported OS ) CR ABORT    [THEN]

CONTEXT @ PREVIOUS

  CONSTANT lib.libxml2
