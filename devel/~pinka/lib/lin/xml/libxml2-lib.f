( Provides  "lib.libxml2" clever wordlist

)

REQUIRE OS-FAMILY ~pinka/spf/os-detection.f
REQUIRE SO        ~ac/lib/ns/so-xt.f

OS-WINDOWS? [IF]

  [UNDEFINED] libxml2.dll [IF]
    ALSO SO NEW: libxml2.dll PREVIOUS
  [THEN]

  ALSO libxml2.dll CONTEXT @ PREVIOUS

  CONSTANT lib.libxml2

\EOF
[THEN]
OS-LINUX? [IF]

  [UNDEFINED] libxml2.dll [IF]
    ALSO SO NEW: libxml2.so.2 PREVIOUS
  [THEN]

  ALSO libxml2.so.2 CONTEXT @ PREVIOUS
  CONSTANT lib.libxml2

\EOF
[THEN]
