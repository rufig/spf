\ $Id$
\ Заглушка/отключение оптимизатора
\ http://www.fforum.winglion.ru/viewtopic.php?p=1929#1929


[BUILDING-TARGET] [IF] \ loading noopt in the target system
\ Define `'DUP' and `'DROP` using `DUP` and `DROP` from the target system
' DUP  >VIRT CONSTANT  'DUP
' DROP >VIRT CONSTANT 'DROP
[ELSE] \ loading noopt for TC in the host system
\ Use `'DUP` and `'DROP` from TC
[THEN]


: SHORT? ( n -- -129 < n < 128 )
  0x80 + 0x100 U< ;

BASE @ HEX

FALSE VALUE OPT?
084 VALUE J_COD
0 VALUE MM_SIZE
0 VALUE :-SET
0 VALUE J-SET
0 VALUE LAST-HERE
0x4 CELLS DUP CONSTANT OpBuffSize
CREATE OP0 HERE >T  , 0 ,  ALLOT
: SetOP ; IMMEDIATE
: ClearJpBuff ; IMMEDIATE
: SetJP ; IMMEDIATE
: ?SET ; IMMEDIATE
FALSE VALUE ?C-JMP

: INLINE? ( xt1 -- xt2 true | xt1 false )
  [BUILDING-TARGET] [IF] \ loading noopt in the target system
    \ When calling external functions from DLL or SO using these words
    \ (like in "devel/~ac/lib/ns/ns.f"),
    \ these words must be inlined to comply with the ABI.
    \ Do not blindly redefined them. TODO: introduce special methods.
    ['] EXECUTE     OVER = IF DROP ['] C-EXECUTE    TRUE EXIT THEN
    ['] EXECUTE2    OVER = IF DROP ['] C-EXECUTE2   TRUE EXIT THEN
  [THEN]
  FALSE
;

: OPT_CLOSE ; IMMEDIATE
: OPT_INIT ; IMMEDIATE
: INLINE,
 BEGIN COUNT DUP C3 <>
 WHILE C,
 REPEAT 2DROP ;
: ???BR-OPT
  C00B W,    \ OR EAX, EAX
  'DROP INLINE, ;
: OPT ; IMMEDIATE
TRUE CONSTANT CON>LIT
 FALSE VALUE J_OPT?
: RESOLVE_OPT DROP ;

: INIT-MACROOPT-LIGHT ;

: MACRO, INLINE, ;
: SET-OPT TRUE TO OPT? ;
: DIS-OPT FALSE TO OPT? ;

 BASE !
