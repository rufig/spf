REQUIRE /TEST ~profit/lib/testing.f
REQUIRE PRO ~profit/lib/bac4th.f
REQUIRE LOCAL ~profit/lib/static.f
REQUIRE DISASSEMBLER lib/ext/disasm.f

{{ DISASSEMBLER

MODULE: move-code

: REL16/32 ( ADDR OP -- ADDR' )
        16-BIT-ADDR
        IF      W@+
        ELSE    @+
        THEN    OVER + BASE-ADDR - >MAX_R 
( jmp-addr addr )
\ ['] TYPE1 TO TYPE \ дл€ отладки, если мы хотим внутри успеха references выводить текст
OVER CELL- OVER CONT 2DROP
                          \ DUP ." {" BASE @ SWAP HEX . BASE ! ."  | " OVER BASE @ SWAP HEX . BASE ! ." }" 
\ ['] 2DROP TO TYPE
DROP \ SHOW-NAME \ смысл лишний раз копатьс€ в словаре если всЄ равно не нужно показывать?..
;

: JSR  ( ADDR OP -- ADDR' )
        .S" CALL    " DROP REL16/32 ; \ E8

: JMP  ( ADDR OP -- ADDR' )
        .S" JMP     " 2 AND IF REL8 ELSE REL16/32 THEN ; \ E9

EXPORT

\ итератор ссылок
: references=> ( xt --> jump place / <-- jump place ) PRO
['] JSR OP-TABLE 0xE8 CELLS + B!
['] JMP OP-TABLE 0xE9 CELLS + B!
['] 2DROP ['] TYPE CFL + B!
['] BL ['] KEY CFL + B!
REST ;

\ исправление всех ссылок
: correct-jumps ( xt start -- ) LOCAL delta
OVER - delta !
references=> OVER delta @ + delta @ NEGATE SWAP +! ;

: COPY-CODE ( xt -- ) \ копирование в кодофайл кода начина€ с xt до конца слова (TODO: решить не€вное указание конца)
HERE SWAP DUP DUP FIND-REST-END OVER - HERE SWAP DUP ALLOT CMOVE
SWAP correct-jumps ;

;MODULE

}}


/TEST

: source
10 DUP *
HERE
10 0 DO I LOOP
S" str" OVER + SWAP DO I C@ LOOP ;


: destination [ ' source COPY-CODE ] ;

REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES code copying
(( source       -> 10 DUP * HERE 0 1 2 3 4 5 6 7 8 9 CHAR s CHAR t CHAR r ))
(( destination  -> 10 DUP * HERE 0 1 2 3 4 5 6 7 8 9 CHAR s CHAR t CHAR r ))
END-TESTCASES

\ SEE source  SEE destination

\EOF


\ Ќеиспользованные (неиспользуемые?) инструкции из lib/ext/disasm.f :

: CIS   ( ADDR OP -- ADDR' )
        0x9A =
        IF      .S" CALL    "
        ELSE    .S" JMP     "
        THEN
        16-BIT-DATA
        IF      .S" PTR16:16 "
        ELSE    .S" PTR16:32 "
        THEN
        COUNT MOD-R/M ; \ EA


: FF.  ( ADDR OP -- ADDR' )
        DROP COUNT
        DUP 3 RSHIFT 7 AND
        CASE
                0 OF .S" INC     "      ENDOF
                1 OF .S" DEC     "      ENDOF
                2 OF .S" CALL    "      ENDOF
                3 OF .S" CALL    FAR "  ENDOF
                4 OF .S" JMP     "      ENDOF
                5 OF .S" JMP     FAR "  ENDOF
                6 OF .S" PUSH    "      ENDOF
                     .S" ???     "
        ENDCASE R/M16/32 ; \ FF