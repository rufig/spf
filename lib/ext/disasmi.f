\ $Id$
\ 
\ Interactive part of disassembler

REQUIRE NEXT-INST lib/ext/disasm.f
REQUIRE [IF] lib/include/tools.f

[UNDEFINED] WINAPI: [IF]
REQUIRE termios lib/posix/key.f
[THEN]

MODULE: DISASSEMBLER

EXPORT

: DIS  ( ADR -- )
        BEGIN
                DUP
                CR INST
                KEY UPC DUP 0x1B = OVER [CHAR] Q = OR 0=
        WHILE
                CASE
                  [CHAR] Q OF DROP DIS-DB ENDOF
                  [CHAR] W OF DROP DIS-DW ENDOF
                  [CHAR] D OF DROP DIS-DD ENDOF
                  [CHAR] S OF DROP DIS-DS ENDOF
                         ROT DROP
                ENDCASE

        REPEAT 2DROP DROP ;

DEFINITIONS

0 VALUE SHOW-NEXT?      \ DEFAULT TO NOT SHOWING NEXT INSTRUCTIONS


TRUE VALUE SEE-KET-FL

VARIABLE  COUNT-LINE

: REST-AREA-KEY ( addr1 addr2 -- )
\ if addr2 = 0 continue till RET instruction
                20    COUNT-LINE !
                0 TO MAX_REFERENCE
                SWAP DUP TO NEXT-INST
                BEGIN
                        \ We do not look for JMP's because there may be
                         \ a jump in a forth word
                        CR
                        OVER 0= IF  NEXT-INST C@ 0xC3 <> 
                                ELSE 2DUP < INVERT
                                THEN
                WHILE   INST
                        COUNT-LINE @ 1- DUP 0=  SEE-KET-FL AND
                           IF 9 EMIT ." \ Press <enter> | q | any" KEY UPC
                            DUP   0xD = IF 2DROP 1  ELSE
                              DUP [CHAR] Q = SWAP 0x1B =
                              OR IF DROP 2DROP CR EXIT    THEN
                                DROP 20    THEN
                           THEN
                        COUNT-LINE !
                REPEAT  2DROP ." END-CODE  "
                ;

' REST-AREA-KEY TO REST-AREA

;MODULE

