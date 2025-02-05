\ $Id$


\ Inline these words manually regardless of other options
\ (since they are not inlined automatically by the optimizer)
: R>     ?COMP  ['] C-R>    INLINE, ;   IMMEDIATE
: >R     ?COMP  ['] C->R    INLINE, ;   IMMEDIATE
: RDROP  ?COMP  ['] C-RDROP INLINE, ;   IMMEDIATE



OPTIMIZE-BY-SIZE \ turned off by default
[IF] \ Avoid manual inlining

SYNONYM 2>R (2>R)
SYNONYM 2R> (2R>)

[ELSE] \ Use manual inlining

: 2>R    ?COMP  POSTPONE SWAP   POSTPONE >R       POSTPONE >R     ; IMMEDIATE
: 2R>    ?COMP  POSTPONE R>     POSTPONE R>       POSTPONE SWAP   ; IMMEDIATE

FALSE [IF]
\ This word is defined in "lib/include/double.f"
: 2RDROP ?COMP  POSTPONE RDROP  POSTPONE RDROP                    ; IMMEDIATE
[THEN]

[THEN]
