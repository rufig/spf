\ ���������� ������������ ����-������� � ��������� ���� ������� ELF
\ �����-���������� SPF/Windows -> ELF object file
\ �. �������, 15.04.07

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
\ see-also: `elf-offset` and `+elf-offset` in "./tc_spf.F"

: '' ALSO TC-TRG ' PREVIOUS ;

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


: ?VIRT! ( addr -- )
  DUP @ 0= IF DROP EXIT THEN >VIRT!
;

: ENUM-VOCS ( xt -- )  \ will works with target chain
\ xt ( wid -- )
  >R VOC-LIST @ BEGIN DUP WHILE
    DUP CELL+ ( a wid ) R@ ROT @ >R  \ allow change link
    EXECUTE R>
  REPEAT DROP RDROP
;
: reloc-wordlist-chain ( wl-last -- )
  BEGIN
    ?DUP
  WHILE
    DUP NAME>C >VIRT!
    DUP NAME>NEXT-NAME SWAP
    NAME>L ?VIRT!
  REPEAT
;
: reloc-wordlist ( wid -- )
  DUP @ reloc-wordlist-chain
  DUP       ?VIRT! \ words chain
  DUP CELL+ ?VIRT! \ wordlist's name
  DUP 2 CELLS + ?VIRT! \ parent  (see PAR@   )
  DUP 3 CELLS + ?VIRT! \ class   (see CLASS@ )
\ DUP CELL- ?VIRT! \ link to the next voc
\ (the link will be fixed by reloc-voclist)
  DROP
;
: reloc-wordlists-all ( -- )
  ['] reloc-wordlist ENUM-VOCS
;
: reloc-voclist ( -- )
  VOC-LIST @
  BEGIN DUP WHILE
    DUP @ SWAP ?VIRT!
  REPEAT DROP
;


: >elf ( a n -- )
  h WRITE-FILE THROW
;


: XSAVE ( c-addr u -- )
  ( ���������� ������������ ����-������� � ��������� ����� ELF )
  R/W CREATE-FILE THROW TO h
  elf-header header-size >elf

  reloc-sections-offsets

  reloc-wordlists-all
  reloc-voclist

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
