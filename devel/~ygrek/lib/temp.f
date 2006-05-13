
MODULE: vocTEMP

USER-VALUE wid
USER-VALUE Current

: Init
   TEMP-WORDLIST TO wid
   GET-CURRENT TO Current
   ALSO vocTEMP
   ALSO wid CONTEXT ! DEFINITIONS
;

: Destroy
   PREVIOUS
   PREVIOUS
   wid FREE-WORDLIST
;

: ;TEMP
  Current SET-CURRENT
; IMMEDIATE

: ;; POSTPONE ; ; IMMEDIATE

: ; Destroy S" ;" EVAL-WORD ; IMMEDIATE

EXPORT

: TEMP
    Init
;; IMMEDIATE 

;MODULE

\EOF

REQUIRE TPluginStartupInfo ~ygrek/prog/farplugin/plugin.f
REQUIRE VAR ~ygrek/lib/var.f
REQUIRE { lib/ext/locals.f

: zz { a \ -- zz }
   TEMPVAR TPluginStartupInfo a

   a. StructSize @
;

DEFSTRUCT TPluginStartupInfo psi

: test
  psi. /SIZE@ psi. StructSize !
  TPluginStartupInfo::/SIZE psi zz <> ABORT" Test failed"
  ." Test passed" ;   

test

\ lib/ext/disasm.f SEE zz

BYE 






