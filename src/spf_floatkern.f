\ Ядро float библиотеки ver. 2.33
\ Слова низкого уровня
\ [c] Dmitry Yakimov [ftech@tula.net]

\ Constants
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


HEX

CODE 2.E
       MOV  DWORD -4 [EBP], # 2
       FILD DWORD -4 [EBP]
       RET
END-CODE

CODE 10.E
       MOV  DWORD -4 [EBP], # 0A
       FILD DWORD -4 [EBP]
       RET
END-CODE

CODE FPI      \ *
       FLDPI
       RET
END-CODE

CODE FLG2
       FLDLG2
       RET
END-CODE

CODE FLN2
       FLDLN2
       RET
END-CODE

CODE FL2T
       FLDL2T
       RET
END-CODE

CODE FL2E
       FLDL2E
       RET
END-CODE

CODE .E
       FLDZ
       RET
END-CODE

CODE 1.E
       FLD1
       RET
END-CODE


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ Operations
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


CODE F0=      \ *
       LEA EBP, -4 [EBP]
       MOV [EBP], EAX
       XOR EBX, EBX
       FTST
       FFREE ST
       FINCSTP
       FSTSW EAX
       SAHF
       JNZ SHORT @@1
       MOV EBX, # -1
@@1:   MOV EAX, EBX
       RET
END-CODE

CODE F0<      \ *
       LEA EBP, -4 [EBP]
       MOV [EBP], EAX
       XOR EBX, EBX
       FTST
       FFREE ST
       FINCSTP
       FSTSW EAX
       SAHF
       JNB SHORT @@1
       MOV EBX, # -1
@@1:   MOV EAX, EBX
       RET
END-CODE

CODE F<              \ *
       LEA EBP, -4 [EBP]
       MOV [EBP], EAX
       XOR EBX, EBX
       FCOMPP
       FSTSW  EAX
       SAHF
       JB SHORT @@1
       MOV EBX, # -1
@@1:   MOV EAX, EBX
       RET
END-CODE

CODE F=             \ *
       LEA EBP, -4 [EBP]
       MOV [EBP], EAX
       XOR EBX, EBX
       FCOMPP
       FSTSW  EAX
       SAHF
       JNE  SHORT @@1
       MOV EBX, # -1
@@1:   MOV EAX, EBX
       RET
END-CODE


CODE FMAX \ *
       MOV EBX, EAX
       FCOM
       FSTSW  EAX
       SAHF
       JB  SHORT @@1
       FXCH
@@1:   FFREE  ST
       FINCSTP
       MOV EAX, EBX
       RET
END-CODE

CODE FMIN \ *
       MOV EBX, EAX
       FCOM
       FSTSW  EAX
       SAHF
       JA  SHORT @@1
       FXCH
@@1:   FFREE  ST
       FINCSTP
       MOV EAX, EBX
       RET
END-CODE

CODE FNEGATE  \ *
       FCHS
       RET
END-CODE

CODE FCOS
       FCOS
       RET
END-CODE

CODE FSIN
       FSIN
       RET
END-CODE

CODE   FSINCOS
       FSINCOS
       RET
END-CODE

CODE FABS   
       FABS
       RET
END-CODE

CODE F*     \ * DE C9
       FMULP ST(1), ST(0)
       RET
END-CODE

CODE F+      \   DE C1
       FADDP ST(1), ST
       RET
END-CODE

CODE F-       \ DE E9
       FSUBP ST(1), ST
       RET
END-CODE

CODE F/       \ DE F9
       FDIVP ST(1), ST
       RET
END-CODE

CODE FSQRT
       FSQRT
       RET
END-CODE

CODE FDROP  \ *
       FFREE ST
       FINCSTP
       RET
END-CODE

CODE FDUP   \ *
       FLD ST(0)
       RET
END-CODE

CODE FOVER  \ *
       FLD ST(1)
       RET
END-CODE

CODE FINT
       FRNDINT
       RET
END-CODE

CODE FSWAP \ *
       FXCH  
       RET
END-CODE

CODE FROT \ *
       FXCH  ST(2)
       FXCH  ST(1)
       FXCH  ST(2)
       FXCH  ST(1)
       RET
END-CODE


CODE FDEPTH  \ *
       LEA EBP, -4 [EBP]
       MOV [EBP], EAX
       FSTSW EAX
       SHR  EAX, # 0B
       AND  EAX, # 7
       JZ   SHORT @@1
       NEG  EAX
       LEA  EAX, 8 [EAX]
@@1:   RET
END-CODE

\ Стек завернут в кольцо!!!
\ Нумерация регистров в сопроцессоре, видимо, следующая (experimental)
\        0 7 6 5 4 3 2 1 , где 0 - дно стека
\ FSTSW возвращает номер регистра
\ Пришлось это обработать...

CODE F1+    \ *
       FLD1
       FADDP ST(1), ST
       RET
END-CODE

CODE D>F    \ *
       MOV EBX, [EBP]
       MOV -4 [EBP], EAX
       MOV -8 [EBP], EBX
       FILD QWORD -8 [EBP]
       MOV EAX, 4 [EBP]
       LEA EBP, 8 [EBP]
       RET
END-CODE


\ Extention words
 
CODE DF!
       FSTP  QWORD [EAX]
       MOV   EAX, [EBP]
       LEA   EBP, 4 [EBP]
       RET
END-CODE

CODE DF@
       FLD  QWORD [EAX]
       MOV   EAX, [EBP]
       LEA   EBP, 4 [EBP]
       RET
END-CODE

CODE F!
       FSTP  TBYTE [EAX]
       MOV   EAX, [EBP]
       LEA   EBP, 4 [EBP]
       RET
END-CODE

CODE FLOAT>DATA ( F: f -- D: u )
       LEA  EBP, -8 [EBP]
       FSTP  QWORD [EBP]
       XCHG  EAX, 4 [EBP]
       RET
END-CODE

CODE DATA>FLOAT ( D: f -- F: f )
       XCHG EAX, 4 [EBP]
       FLD  QWORD [EBP]
       LEA  EBP, 8 [EBP]
       RET
END-CODE

\ float takes 32 bit here

CODE FLOAT@ ( F: f -- D: f )
       LEA  EBP, -8 [EBP]
       FSTP  DWORD [EBP]
       XCHG  EAX, 4 [EBP]
       RET
END-CODE

\ float takes 32 bit here

CODE FLOAT! ( D: f -- F: f )
       XCHG EAX, 4 [EBP]
       FLD  DWORD [EBP]
       LEA  EBP, 8 [EBP]
       RET
END-CODE

CODE F@
       FLD  TBYTE [EAX]
       MOV   EAX, [EBP]
       LEA   EBP, 4 [EBP]
       RET
END-CODE

CODE SF!
       FSTP  DWORD [EAX]
       MOV   EAX, [EBP]
       LEA   EBP, 4 [EBP]
       RET
END-CODE

CODE SF@
       FLD  DWORD [EAX]
       MOV   EAX, [EBP]
       LEA   EBP, 4 [EBP]
       RET
END-CODE

CODE FLN   \ *
       FLDLN2
       FXCH
       FYL2X
       RET
END-CODE

CODE FLNP1 \ *
       FLD1
       FADDP ST(1), ST
       FLDLN2
       FXCH
       FYL2X
       RET
END-CODE

CODE FLOG ( F: r1 -- r2 ) \ *
       FLDLG2
       FXCH
       FYL2X
       RET
END-CODE

\ e^(x) = 2^(x * LOG{2}e)

CODE FEXP
       FLDL2E                \ normalize
       FMULP ST(1), ST(0)
       LEA EBP, -4 [EBP]     \ set rounding mode to truncate
       MOV [EBP], EAX
       FSTCW  DWORD -4 [EBP]
       MOV EAX, -4 [EBP]
       AND AH, # 0F3
       OR  AH, # 0C
       MOV -8 [EBP], EAX
       FLDCW DWORD -8 [EBP]
       FLD ST(0)                    \ get integer and fractional parts
       FRNDINT
       FXCH ST(1)
       FSUB ST(0), ST(1)
       F2XM1                        \ exponentiate fraction
       FLD1
       FADDP ST(1), ST(0)
       FSCALE                        \ scale in integral part
       FXCH ST(1)                    \ clean up
       FCOMP ST(1)
       FLDCW DWORD -4 [EBP]
       MOV EAX, [EBP]
       LEA EBP, 4 [EBP]
       RET
END-CODE

CODE FEXPM1
       CALL ' FEXP
       FLD1 
       FSUBP ST(1), ST
       RET
END-CODE

\ X>0
CODE F**     \ *
       FXCH
       FYL2X
       FLD1
       FLD ST(1)
       FPREM
       F2XM1
       FADD
       FSCALE
       FXCH
       FSTP ST
       RET
END-CODE

CODE FTAN \ *
     FPTAN
     FDIVP ST(1), ST
     RET
END-CODE

CODE FATAN \ *
     FLD1
     FPATAN
     RET
END-CODE

CODE FATAN2
     FPATAN
     RET
END-CODE

CODE FACOS \ *
     FLD1
     FLD ST(1)
     FMUL ST, ST
     FSUBP ST(1), ST
     FSQRT
     FXCH
     FPATAN
     RET
END-CODE

CODE FASIN
     FLD1
     FLD ST(1)
     FMUL ST, ST
     FSUBP ST(1), ST
     FSQRT
     FPATAN
     RET
END-CODE

\ My words

DECIMAL
CODE F>DEG
     MOV  DWORD -4 [EBP], # 180 
     FIMUL DWORD -4 [EBP]
     FLDPI
     FDIVP ST(1), ST
     RET
END-CODE

CODE F>RAD
     FLDPI 
     FMULP ST(1), ST
     MOV  DWORD -4 [EBP], # 180 
     FIDIV DWORD -4 [EBP]
     RET
END-CODE
HEX

CODE FINIT
       FINIT
       RET
END-CODE

CODE SETFPUCW ( u -- )
       MOV -4 [EBP], EAX
       FLDCW DWORD -4 [EBP]
       MOV EAX, [EBP]
       LEA EBP, 4 [EBP]
       RET
END-CODE

CODE GETFPUCW ( -- u )     \ *
       LEA  EBP, -4 [EBP]
       MOV  [EBP], EAX
       FSTCW DWORD -4 [EBP]
       MOV EAX, -4 [EBP]
       RET
END-CODE

CODE DS>F    \ *
       MOV -4 [EBP], EAX
       FILD DWORD -4 [EBP]
       MOV EAX, [EBP]
       LEA EBP, 4 [EBP]
       RET
END-CODE

CODE F>DS     \ *
       LEA   EBP, -4 [EBP]
       MOV   [EBP], EAX
       FISTP DWORD -4 [EBP]
       MOV   EAX, -4 [EBP]
       RET
END-CODE

CODE F--DS     \ *
       LEA   EBP, -4 [EBP]
       MOV   [EBP], EAX
       FIST  DWORD -4 [EBP]
       MOV   EAX, -4 [EBP]
       RET
END-CODE

CODE GETFPUSW
       LEA  EBP, -4 [EBP]
       MOV [EBP], EAX
       FSTSW EAX
       RET
END-CODE

: ?IE GETFPUSW 1 AND 0<> ;
: ?ZE GETFPUSW 4 AND 0<> ;
: ?OF GETFPUSW 8 AND 0<> ;

CODE FLOG2 ( F: r1 -- r2 )
       FLD1
       FXCH
       FYL2X
       RET
END-CODE


CODE F[LOG] \ *        \ исп 2 регистра
       FLDLG2
       FXCH
       FYL2X
       FRNDINT
       RET
END-CODE

CODE TRUNC-MODE  \ *
       FSTCW DWORD -4 [EBP]
       BTS   -4 [EBP], # 0A
       BTS   -4 [EBP], # 0B
       FLDCW DWORD -4 [EBP]
       RET
END-CODE

CODE ROUND-MODE  \ *
       FSTCW DWORD -4 [EBP]
       BTR   -4 [EBP], # 0A
       BTR   -4 [EBP], # 0B
       FLDCW DWORD -4 [EBP]
       RET
END-CODE

CODE UP-MODE
       FSTCW DWORD -4 [EBP]
       BTR   -4 [EBP], # 0A
       BTS   -4 [EBP], # 0B
       FLDCW DWORD -4 [EBP]
       RET
END-CODE

CODE LOW-MODE
       FSTCW DWORD -4 [EBP]
       BTS   -4 [EBP], # 0A
       BTR   -4 [EBP], # 0B
       FLDCW DWORD -4 [EBP]
       RET
END-CODE

CODE F>D     \ *
       LEA  EBP, -8 [EBP]
       FISTP  QWORD [EBP]
       XCHG   EAX, 4 [EBP]
       RET
END-CODE

: F>D
       GETFPUCW >R
       TRUNC-MODE
       F>D
       R> SETFPUCW
;

CODE F10*   \ *
       MOV  DWORD -4 [EBP], # 0A
       FIMUL  DWORD -4 [EBP]
       RET
END-CODE

CODE F10/   \ *
       MOV  DWORD -4 [EBP], # 0A
       FIDIV  DWORD -4 [EBP]
       RET
END-CODE

\ 28 байт по addr
CODE F>ENV ( addr -- )
       FSTENV [EAX]
       MOV EAX, [EBP]
       LEA EBP, 4 [EBP]
       RET
END-CODE

CODE FENV> ( addr -- )
       FLDENV [EAX]
       MOV EAX, [EBP]
       LEA EBP, 4 [EBP]
       RET
END-CODE

CODE FSAVE ( addr -- )
       FSAVE [EAX]
       MOV EAX, [EBP]
       LEA EBP, 4 [EBP]
       RET
END-CODE

CODE FRSTOR ( addr -- )
       FRSTOR [EAX]
       MOV EAX, [EBP]
       LEA EBP, 4 [EBP]
       RET
END-CODE

CODE FD<     \ *
       XOR EBX, EBX
       MOV -4 [EBP], EAX
       FICOM DWORD -4 [EBP]
       FSTSW EAX
       SAHF
       JNB  SHORT @@1
       MOV  EBX, # -1
@@1:   MOV EAX, EBX
       RET
END-CODE

: FD> FD< INVERT ;

CODE `F1+
       MOV  DWORD -4 [EBP], # 1
       FIADD DWORD -4 [EBP]
       RET
END-CODE

CODE F**2
       FMUL ST, ST
       RET
END-CODE

CODE `F1-
       MOV  DWORD -4 [EBP], # 1
       FSUB DWORD -4 [EBP]
       RET
END-CODE

CODE _FLIT-CODE8
     POP  EBX
     FLD  QWORD [EBX]  
     ADD  EBX, # 8
     JMP  EBX
END-CODE

CODE _FLIT-CODE10
     POP  EBX
     FLD  TBYTE [EBX]
     ADD  EBX, # 0A
     JMP  EBX
END-CODE


DECIMAL