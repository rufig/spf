\ A wrapper for "lib/asm/486asm.f"


VOCABULARY ASSEMBLER
GET-CURRENT ALSO ASSEMBLER DEFINITIONS

: DEFER CREATE ['] NOOP , DOES> @ EXECUTE ;
: DEFER@ ' >BODY STATE @ IF POSTPONE LITERAL POSTPONE @ ELSE @ THEN ; IMMEDIATE
: IS '  >BODY STATE @ IF POSTPONE LITERAL POSTPONE ! ELSE ! THEN ; IMMEDIATE

: +TO ' >BODY STATE @ IF POSTPONE LITERAL POSTPONE +! ELSE +! THEN ; IMMEDIATE

: REVEAL SMUDGE ;
: COMPILE ' POSTPONE LITERAL POSTPONE COMPILE, ; IMMEDIATE
: (;CODE) R> LATEST-NAME NAME>C ! ; \ NB: the header shall be finished and revealed

VECT EXIT-ASSEMBLER


REQUIRE !CSP lib/ext/case.f

: -IF POSTPONE DUP POSTPONE IF ; IMMEDIATE

PREVIOUS SET-CURRENT


S" lib/asm/486asm.f" INCLUDED

( FORTH HEADER CREATION WORDS )
ALSO ASSEMBLER ALSO ASM-HIDDEN
IN-HIDDEN
WARNING @ FALSE WARNING !
: _CODE ( START A NATIVE CODE DEFINITION )
        HEADER HIDE !CSP INIT-ASM ;

: _;CODE ( CREATE THE [;CODE] PART OF A LOW LEVEL DEFINING WORD )
        ?CSP !CSP COMPILE (;CODE) POSTPONE [ INIT-ASM ;
WARNING !

IN-FORTH
' _CODE IS CODE
' _;CODE IS ;CODE

: FCALL A; [COMPILE] ' COMPILE, ;
    FORTH.IMMEDIATE

ONLY FORTH DEFINITIONS


S" lib/asm/asmmac.f" INCLUDED
