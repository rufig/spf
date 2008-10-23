REQUIRE WalcProcXT ~nn/lib/proc.f
REQUIRE AddPair ~nn/lib/lisp.f
REQUIRE N>S ~nn/lib/num2s.f

USER FP-XT
USER FP-NAME
USER FP-FND-PID
USER FP-FND-NAME
USER FP-LIST

: FOUND-PROC ( -- a u) FP-FND-NAME @AZ ;
: FOUND-PID ( -- n)  FP-FND-PID @ ;
: (FOR-PROC) ( a u xt -- )
    FP-XT !
    2DUP ?SET-PROC-FULLPATH
    S>ZALLOC FP-NAME !
    FP-LIST 0!
    [NONAME ( a u id -- ?)
        >R
        2DUP FP-NAME @AZ WC|RE-COMPARE
        R@ N>S FP-NAME @AZ WC|RE-COMPARE OR
        IF
            S>ZALLOC R@ FP-LIST AppendPair
        ELSE 2DROP THEN
        RDROP
        TRUE
    NONAME] WalcProcXT CATCH IF DROP THEN

    [NONAME
        NodeValue
        DUP @ FP-FND-NAME !
        CELL+ @ FP-FND-PID !
        FP-XT @ CATCH DROP
    NONAME]
    FP-LIST DoList

    [NONAME NodeValue @ FREE THROW NONAME] FP-LIST DoList
    FP-LIST FreePairList
    FP-NAME @ FREE THROW
;

: FOR-PROCS \ compile: ( -- )
            \ execute: ( a u --)
    POSTPONE [NONAME
; IMMEDIATE

: ;FOR-PROCS
    POSTPONE NONAME]
    POSTPONE (FOR-PROC)
; IMMEDIATE

\EOF

: test
     S" jrun.exe" FOR-PROCS
        FOUND-PID . FOUND-PROC TYPE CR
    ;FOR-PROCS
;

test
