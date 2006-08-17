WINAPI: GetVersion KERNEL32.DLL

0 VALUE EXC-REGS

: EXC-INIT
  GetVersion
  DUP 0x80000000 AND IF ( not NT )
    0xFFFF AND
    DUP 3 = IF ( Win32s with Windows 3.1 )
      DROP
      -1
    ELSE
      DUP 4 = IF ( '95 )
        DROP
        184
      ELSE ( Unknown )
        DROP
        -1
      THEN
    THEN
  ELSE ( NT )
    DROP
    184
  THEN
  DUP -1 = IF
    GetVersion BASE @ HEX SWAP U. BASE !
    ." : неизвестная автору версия Windows." CR
    ." Возможна неверная работа EXC-DUMP" CR
    184
  THEN
  TO EXC-REGS
;

: EXC-DUMP1 ( exc-info -- )
  BASE @ SWAP
  HEX
  ." EXCEPTION! " 
  DUP @ ."  CODE:" U. 
  DUP 3 CELLS + @ ."  ADDRESS:" DUP U. ."  WORD:" WordByAddr TYPE SPACE
  ."  REGISTERS:"
  EXC-REGS + DUP 12 CELLS DUMP CR
  ." RETURN STACK:" CR
  6 CELLS + @
  15 >R
  BEGIN
    DUP HANDLER @ < R@ 0 > AND
  WHILE
    DUP U. ." :  "
    DUP ['] @ CATCH 
    IF DROP 
    ELSE DUP U. WordByAddr TYPE CR THEN
    CELL+ R> 1- >R
  REPEAT DROP RDROP
  BASE !
;
' EXC-DUMP1 TO <EXC-DUMP>

EXC-INIT