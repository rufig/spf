\ Float-библиотека для spf375.exe ver. 2.33
\ Слова высокого уровня
\ [c] Dmitry Yakimov [ftech@tula.net]
\ 80 битная арифметика по умолчанию!
\ Либа оставлена для совместимости...

\ Hi level words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ ~day\float\floatkern.f
USER-CREATE FLOAT-PAD ( -- c-addr ) \ 94 CORE EXT
 \ c-addr - адрес области для формирования строкового представления float 
 \ числа 
0xFF USER-ALLOT

USER FFORM
USER FFORM-EXP
USER ?PRINT-EXP       \ печать с экспонентой или без нее
USER F-SIZE
USER PAST-COMMA \ число знаков после точки
USER ?IS-COMMA  \ появилась точка или нет
USER CountBuf \ счетчик в буфере


: 2e 2.E ;
: 1e 1.E ;
: .e .E ;

VARIABLE FCON-E

: PRECISION ( -- u )
    FFORM @
;
: SET-PRECISION ( u -- )
   1 MAX 17 MIN FFORM !
;

: PRINT-EXP TRUE ?PRINT-EXP ! ;
: PRINT-FIX FALSE ?PRINT-EXP ! ;

: FSINGLE 4 F-SIZE ! ;
: FDOUBLE 8 F-SIZE ! ;
: FLONG 10  F-SIZE ! ;

: FLOATS F-SIZE @ * ;
: FLOAT+ F-SIZE @ + ;


: FSTATE  \ *
  FLOAT-PAD DUP F>ENV
  8 + W@ 
  ." FPU registers usage:" CR
  8 0 DO
        ." reg " 8 I - . ." :" 
        DUP DUP 1 AND 
        SWAP 2 AND 
        0= IF 1 = IF ."  zero" ELSE ."  valid number" THEN
           ELSE 1 = IF ."  empty" ELSE ."  invalid or infinity" THEN
           THEN
        2 RSHIFT
        CR
      LOOP
  DROP
;
: stackIsEmpty
   ." FPU: Float stack is empty!"
;
HEX
: F, ( F: r -- )
     FDEPTH 0= IF
                 C0000092 THROW
              ELSE
                 HERE F-SIZE @ ALLOT F!   
              THEN
;

: DF, ( F: r -- )
     FDEPTH 0= IF
                  C0000092 THROW
              ELSE
                 HERE 8 ALLOT  DF! 
              THEN
;

: SF, ( F: r -- )
     FDEPTH 0= IF
                 C0000092 THROW
              ELSE
                 HERE 4 ALLOT   SF! 
              THEN
;

CREATE FINF-ADDR 0 , 80 , FF7F0000 ,  \ Infinity

DECIMAL

: FINF FINF-ADDR F@ ;

: TNUM ( addr u -- d )       \ *
   0. 2SWAP >NUMBER 2DROP
;

: F10X ( u -- R: 10^u )
   1.E
   DUP 0 > IF    0 DO F10* LOOP
           ELSE  NEGATE 0 ?DO F10/ LOOP
           THEN
;

: FACOSH   FDUP FDUP F* 1.E F- FSQRT F+ FLN ;    

: SEARCH-EXP ( c-addr1 u -- c-addr2 u flag )
    BEGIN
      OVER C@ -1
      OVER [CHAR] e <> AND
      OVER [CHAR] E <> AND
      OVER [CHAR] d <> AND
      SWAP [CHAR] D <> AND
      OVER AND
    WHILE
      1- SWAP 1+ SWAP
    REPEAT
;


: GET-EXP ( addr u -- d )    \ *
  SEARCH-EXP DUP
  IF                    \ addr u
    >R 1+ DUP C@        \ addr1 c
    DUP [CHAR] - =
    IF DROP 1+ R> 2 - TNUM DNEGATE   
    ELSE [CHAR] + = IF 1+ R> 2 - TNUM ELSE R> 1- TNUM THEN
    THEN
  ELSE
    2DROP 0.
  THEN
;

\ Идем до первой не цифры, точку пропускаем

: FRAC>F ( addr u -- F: r )              \ использует 2 регистра FPU
  .e
  OVER + SWAP
  DO
    ?IS-COMMA @ IF PAST-COMMA 1+! THEN
    I C@ DUP 47 > 
    OVER 58 < AND
    IF 48 - DS>F F+ F10* 
    ELSE [CHAR] . = IF TRUE ?IS-COMMA ! 
                         ELSE LEAVE
                         THEN
    THEN
  LOOP
;

: >FLOAT-ABS  ( addr u -- F: r D:  bool )
   BASE @ >R DECIMAL
   GETFPUCW >R UP-MODE 
   2DUP GET-EXP DROP         \  addr u u2 - экспонента
   ROT ROT FRAC>F             \ u2
   ?IS-COMMA @ 0= IF PAST-COMMA 1+! THEN
   PAST-COMMA @ - F10X  F*  ?OF ?IE OR 
   DUP IF FDROP THEN INVERT
   R> SETFPUCW
   R> BASE !
;

( : SKIP1
   1- SWAP 1+ SWAP 
;)

\ Simple BNF parser ( ver. 2.2)

\ Сдвинуть позицию в строке вправо на число присутствующих символов, но не
\ больше чем MIN(u, max)

\ Если сдвигов было меньше чем min то выдаем 0, иначе -1.

: CHECK-SET ( addr u max min addr2 u2 -- addr2 u2 bool )
    >R >R >R OVER MIN >R SWAP R>
    0 >R \ D: addr u1 R: u2 addr2 min 0
    BEGIN
      DUP R@ >
    WHILE
      OVER R@ + C@
      2 CELLS RP+@
      3 CELLS RP+@       
      ROT 
      >R RP@ 1 SEARCH RDROP NIP NIP
      0= IF     \ первый несовпавший символ
           DROP SWAP
           R@ - SWAP R@ + SWAP 
           2R> 1+ < RDROP RDROP EXIT
         THEN
      R> 1+ >R
    REPEAT
    + SWAP R@ -
    2R> 1+ < RDROP RDROP
;

: <SIGN> ( addr u max min -- addr2 u2 bool )
    S" -+" CHECK-SET
;

: <EXP> ( addr u max min -- addr2 u2 bool )
    S" EeDd" CHECK-SET
;

: <DOT> ( addr u max min -- addr2 u2 bool )
    S" ." CHECK-SET
;

: <DIGITS> ( addr u max min -- addr2 u2 bool )
    S" 0123456789" CHECK-SET
;

: ?FLOAT ( addr u -- bool )
    1   0 <SIGN>    >R
    16  0 <DIGITS>  >R
    1   0 <DOT>     >R
    16  0 <DIGITS>  >R
    1   1 <EXP>     >R
    1   0 <SIGN>    >R
    4   0 <DIGITS>  >R
    NIP 0= \ После всего этого должен быть конец строки
    2R> 2R> 2R> R> AND
    AND AND AND AND AND
    AND
;

: >FLOAT ( addr u -- F: r true | false )
  2DUP ?FLOAT
  IF
    PAST-COMMA 0! FALSE ?IS-COMMA !
    OVER C@ DUP [CHAR] - =    \ addr u c flag
    IF DROP SKIP1 >FLOAT-ABS FNEGATE
    ELSE [CHAR] + = IF SKIP1 THEN
                    >FLOAT-ABS
    THEN
  ELSE
   2DROP 0
  THEN
;

HEX

: FABORT
      ?IE IF FINIT C0000090  THROW THEN    \ invalid operation
      ?OF IF FINIT C0000091 THROW THEN     \ overflow
      ?ZE IF FINIT C000008E THROW THEN     \ divide by zero
;
DECIMAL

: FLOOR ( F: r1 -- r2 )
    GETFPUCW >R
    LOW-MODE
    FINT
    R> SETFPUCW
;
: FROUND ( F: r1 -- r2 )
    GETFPUCW >R
    ROUND-MODE
    FINT
    R> SETFPUCW
;

\ Дает размер строки знаков после запятой float числа
: #EXP ( -- n ) ( r -- r )  FDUP F0=  IF PRECISION  ELSE
   FDUP FABS FLOG FLOOR F>D DROP THEN
;

\ r1=r*n^10

: FN^10 ( n --) ( r -- r1 )
   DUP 0 >
   IF
     0 ?DO
       F10*
     LOOP 
   ELSE
      ABS 0 ?DO
         F10/
      LOOP
   THEN
;

: REPRESENT ( c-addr u -- n f1 f2 )
   BASE @ >R DECIMAL
   2DUP 1+ [CHAR] 0 FILL 2DUP FDUP F0< >R FABS
   #EXP DUP >R - FN^10
   DROP F>D <# #S #> DUP
   1 = IF
     2DROP 2DROP RDROP RDROP 1 0 -1
   ELSE
     ROT 2DUP - >R MIN ROT SWAP 1+ MOVE 2R> +  R> -1
   THEN
   R> BASE !
;


: Buf+word ( addr u )
    CountBuf @ 256 <
    IF
     2DUP FLOAT-PAD CountBuf @ + SWAP CMOVE
     NIP CountBuf +!
    ELSE
     2DROP
    THEN      
;

: +Count ( char -- )
    CountBuf @ 256 <
    IF
      CountBuf @ FLOAT-PAD + C!
      CountBuf 1+!
    ELSE
      DROP
    THEN
;

: FDISPLAY ( n -- )
   FLOAT-PAD OVER 0 MAX TYPE [CHAR] . EMIT
   DUP FLOAT-PAD + PRECISION ROT - 1+ TYPE  ;

: format-exp ( ud1 -- ud2 ) \ *
  UP-MODE
  2DUP 2DUP D0= IF 2DROP 0 ELSE D>F F[LOG] F>DS THEN
  FFORM-EXP @ MAX
  0
  DO # LOOP
;

HEX 

: .EXP
     BASE @ >R DECIMAL
     S>D
     DUP >R DABS <# format-exp R> SIGN FCON-E @ HOLD #>
     TYPE
     R> BASE !
;

: FS. ( r -- )
   FDEPTH 0<>
   IF
     FLOAT-PAD PRECISION REPRESENT DROP
     IF  [CHAR] - TYPE  THEN
     1 FDISPLAY 1-  .EXP
   ELSE
     C0000092 THROW
   THEN
;
   
: Adjust ( n - n' 1|2|3 )
   S>D 3 FM/MOD 3 * SWAP 1+  ;

: FE. ( r)
   FDEPTH 0<>
   IF
      FLOAT-PAD PRECISION REPRESENT DROP IF  [CHAR] - EMIT  THEN
      1- Adjust FDISPLAY .EXP
   ELSE
      C0000092 THROW
   THEN
;

DECIMAL

: fnormalize-big ( F: r -- F: r1 u ) \ *
\ на выходе: x.xxxxxx
   UP-MODE
   FDUP F[LOG]
   F>DS DUP 0<> IF DUP 1- F10X F/ ELSE 1+ THEN
;

\ на выходе: x.xxxxxx
: fnormalize-small ( F: r -- r1 u ) \ *
  0 
  BEGIN
    F--DS 0=
  WHILE
    F10* 1+
  REPEAT 
;

: FLOAT<1 ( -- f )
      1 FD< DUP
      IF
         [CHAR] 0 +Count
         [CHAR] . +Count
      THEN
;         

\ выводим число, пришедшее как x.xxxxxx
\ Если <1 то выводим точку

: fprint-frac ( F: r D: u -- )
  TRUNC-MODE 
  0
  ?DO
    I 15 >
    IF 
      [CHAR] 0 +Count
    ELSE  
      F--DS DUP 10 =
      IF
        [CHAR] 1 +Count
        [CHAR] 0 +Count
      ELSE  
        DUP 48 + +Count
      THEN  
      DS>F F- F10*
    THEN
  LOOP
  FDROP
;

\ Вывести целую часть числа
: fprint-high ( F: r -- )
    fnormalize-big
    fprint-frac
;

\ выводим число в формате без экспоненты
: fprint-noexp ( F: r -- )
    TRUNC-MODE
    FLOAT<1
    IF
      FDUP F0= IF FDROP EXIT THEN
      F10* PRECISION fprint-frac
    ELSE
      FDUP FLOAT>DATA fprint-high DATA>FLOAT
      [CHAR] . +Count
      FDUP FINT F- F10*
      1 FD< ?PRINT-EXP @ INVERT AND
      IF
        FDROP
      ELSE
        PRECISION fprint-frac
      THEN
    THEN
;

\ выводим число в формате с экспонентой
: fprint-exp ( F: r -- )
   1 FD< 
   IF FDUP F0= IF 0 ELSE fnormalize-small -1 * THEN
   ELSE fnormalize-big 1- 10 FD> IF F10/ 1+ THEN
   THEN                       
   fprint-noexp 
   S>D
   DUP >R DABS <# format-exp R> SIGN FCON-E @ HOLD #>
   Buf+word
;
HEX

: >FNUM ( F: r  -- addr u )
      FABORT FDEPTH 0= IF C0000092 THROW THEN
      0 CountBuf ! 
      FDUP FINF F= 
      IF
         FDROP S" +Infinity" Buf+word
      ELSE 
        FDUP FINF FNEGATE F= 
          IF FDROP S" -Infinity" Buf+word
          ELSE
            GETFPUCW >R
            BASE @ DECIMAL 
            FDUP F0< IF FABS [CHAR] - +Count THEN
            ?PRINT-EXP @
            IF fprint-exp
            ELSE fprint-noexp 
            THEN
            BASE !
            R> SETFPUCW
          THEN
      THEN  
      FLOAT-PAD CountBuf @
;

: F. ( F: r -- )
   FDEPTH 0<>
      IF  
        >FNUM TYPE
       ELSE  
           C0000092 THROW
      THEN     
;   
DECIMAL

\ DB 2D - TBYTE
\ DD 05 - QWORD
\ D9 05 - DWORD

\ : FS. ( F: r -- )
\    ?PRINT-EXP @
\    PRINT-EXP
\    F.
\    ?PRINT-EXP !
\ ;

: DFLOAT+ ( addr1 -- addr2 )
    8 +
;
: DFLOATS ( n1 -- n2 )
    3 LSHIFT
;
: SFLOAT+ ( addr1 -- addr2 )
    CELL+
;
: SFLOATS ( n1 -- n2 )
    2 LSHIFT
;

: FLIT,
    ['] _FLIT-CODE10 COMPILE,
    HERE 10 ALLOT F!
;

: FLITERAL ( F: r -- )
      STATE @ IF FLIT, THEN
; IMMEDIATE


: F~ ( F1 F2 F3 -- FLAG ) \ FLOAT-EXT
    FDUP F0=
    IF
      FDROP F= EXIT
    THEN
    FDUP FDUP F0< F0= OR INVERT
    IF
      FROT FROT F- FABS FSWAP
    ELSE
      FNEGATE FROT FROT FOVER FABS FOVER FABS F+ FROT FROT
      F- FABS FROT FROT F*
    THEN
    F<
;

: FALOG  \ *
         10.E FSWAP F** 
;

: FSINH \ *
         FEXP FDUP 1.E FSWAP F/ F- 2.E F/ 
;

: FCOSH    FEXP FDUP 1.E FSWAP F/ F+ 2.E F/ ;

: FTANH    2.E F* FEXPM1 FDUP 2.E F+ F/ ;

: FATANH   FDUP F0< >R FABS 1.E FOVER F- F/  2.E F* FLNP1 2.E F/
           R> IF FNEGATE THEN ;


: FASINH   FDUP FDUP F* 1.E F+ FSQRT F/ FATANH ;


: FTO 
   BL WORD FIND
   IF
     STATE @ 
     IF   >BODY LIT, ['] F! COMPILE,
     ELSE >BODY F!
     THEN
   ELSE -321 THROW
   THEN
; IMMEDIATE

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

(
: FHYPTMP \ *
   F1+ FLOG2 FLN2 F*
;

)
: HIGH-FINIT
     8 SET-PRECISION
     2 FFORM-EXP !
     FLONG
     FINIT
     PRINT-FIX
     [CHAR] e FCON-E !
;

: FALIGN
; IMMEDIATE
: FALIGNED 
; IMMEDIATE
: SFALIGN
; IMMEDIATE
: SFALIGNED
; IMMEDIATE
: DFALIGN
; IMMEDIATE
: DFALIGNED
; IMMEDIATE

: FVARIABLE 
      CREATE .e F,
;

: FCONSTANT   \ *
      CREATE F,
      DOES>  F@
;

: FVALUE FCONSTANT ;

WARNING @ FALSE WARNING !
: NOTFOUND ( c-addr u -- )
  2DUP 2>R ['] NOTFOUND CATCH ?DUP
  IF
    NIP NIP 2R>
    FABORT
    >FLOAT
    IF [COMPILE] FLITERAL DROP
    ELSE
       THROW
    THEN
  ELSE 2R> 2DROP
  THEN
;
WARNING !

..: AT-THREAD-STARTING HIGH-FINIT ;..

HIGH-FINIT
