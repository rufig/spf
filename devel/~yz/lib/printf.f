\ Форматный вывод а ля printf()
\ Ю. Жиловец, http://www.forth.org.ru/~yz

WINAPI: wvsprintfA   USER32.DLL

\ (| 65 2 " str" " %c-%d-%s" |) -> " A-2-str"
USER-CREATE print-buffer 1024 USER-ALLOT
USER-CREATE print-array  64 CELLS USER-ALLOT
USER (|-depth

: (|  DEPTH (|-depth ! ;  : <| ( n--) DEPTH SWAP - 1- (|-depth ! ;
: |)  ( ... z -- z) >R 
  DEPTH (|-depth @ -
  DUP 0 > IF
    1- CELLS print-array SWAP OVER + DO 
      I !
    CELL NEGATE +LOOP
  ELSE DROP THEN
  print-array R> print-buffer wvsprintfA DROP
  print-buffer ;
