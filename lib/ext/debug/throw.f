\ (c) ~day 2001
\ Отладочные версии THROW и CATCH.
\ Автоматически начинает лог. файл при запуске программы (или компиляции)
\ При возникновении исключения пишет в лог. файл сл. информацию:
\ - номер исключения
\ - реальную строку в которой произошло исключение
\ - подключенный файл при компиляции, в котором произошло исключение

..: AT-PROCESS-STARTING STARTLOG ;.. \ Отличная вещь Scattered colons!

: (DEBUG-EXC) ( u1 u2 c-addr u3 f -- u1 )
\ u1 - номер exeption
\ u2 - номер строки, где оно произошло
  IF S" exeption(throw): "
  ELSE S" exeption(catch): "
  THEN TO-LOG
  BASE @ >R DECIMAL
  2>R
  OVER IF
   OVER DUP >R ABS 0
   <# #S R> SIGN #> TO-LOG
   0 <# #S S"  line: " HOLDS 2R> HOLDS S"  file: " HOLDS #> TO-LOG
   LT 2 TO-LOG
       ELSE
           2R> 2DROP DROP      
       THEN
  R> BASE !
;

: THROW STATE @ IF
                  CURSTR @ LIT, CURFILE @ ?DUP
                  IF
                    ASCIIZ> 
                  ELSE PAD 0
                  THEN [COMPILE] SLITERAL
                  -1 LIT,
                  POSTPONE (DEBUG-EXC)
                  POSTPONE THROW
                ELSE THROW
                THEN
; IMMEDIATE

: CATCH STATE @ IF
                  POSTPONE CATCH
                  CURSTR @ LIT, CURFILE @ ?DUP
                  IF
                    ASCIIZ> 
                  ELSE PAD 0
                  THEN [COMPILE] SLITERAL
                  0 LIT,
                  POSTPONE (DEBUG-EXC)
                ELSE CATCH
                THEN

; IMMEDIATE

: ABORT"
  STATE  @
  IF
     CURSTR @ LIT, CURFILE @ ?DUP
     IF
       ASCIIZ> 
     ELSE PAD 0
     THEN [COMPILE] SLITERAL
     POSTPONE TYPE
  THEN 
  POSTPONE ABORT"
; IMMEDIATE

STARTLOG