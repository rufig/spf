\ Сохранение наработанной Форт-системы в объектный файл формата ELF
\ кросс-компиляция SPF/Windows -> ELF object file
\ Ю. Жиловец, 15.04.07

DECIMAL

0x34 CONSTANT header-size
0x28 CONSTANT section-size
0x20 CONSTANT segment-size
0x10 CONSTANT symbol-size
0x8  CONSTANT rel-size

0 VALUE h
0 VALUE offset
0 VALUE .forth-offset

: +offset ( n -- ) offset + TO offset ;
: offset,size, ( n -- ) offset , DUP , +offset ;

: '' ALSO TC-WL ' PREVIOUS ;

S" src/elf.f" INCLUDED

: reloc-sections-offsets
  sections section-size + sections# 1- section-size * OVER + SWAP ?DO
     data-offset I 4 CELLS + +!
  section-size +LOOP
;

\ : reloc-segments-offsets
\  segments segment-size + segments# 1- segment-size * OVER + SWAP ?DO
\     data-offset I 1 CELLS + +!
\  segment-size +LOOP
\ ;

: reloc-wordlist ( wl-last -- )
  BEGIN
    ?DUP
  WHILE
    DUP NAME>C >VIRT!
    DUP CDR SWAP
    NAME>L DUP @ IF >VIRT! ELSE DROP THEN 
  REPEAT
;

: >elf ( a n -- )
  h WRITE-FILE THROW
;


0 VALUE NON-OPT-WL-adr

'' NON-OPT-WL EXECUTE TO NON-OPT-WL-adr

: XSAVE ( c-addr u -- )
  ( сохранение наработанной форт-системы в объектном файле ELF )
  R/W CREATE-FILE THROW TO h
  elf-header header-size >elf

  reloc-sections-offsets

  ALSO TC-WL CONTEXT @ PREVIOUS @ reloc-wordlist
  NON-OPT-WL-adr VIRT> @ VIRT> reloc-wordlist

  sections total-sections-size >elf
  segments total-segments-size >elf
  .shstrtab .shstrtab# >elf
  .strtab .strtab# >elf
  .symtab .symtab# >elf
  .rel.forth .rel.forth# >elf
  .forth .forth# >elf
  dl-second .dltable# >elf
  dl-second-strtab .dlstrings# >elf
  h CLOSE-FILE THROW
  BYE
;
