\ $Id$
\ 
\ ���������� ������������ ����-������� � ��������� ���� ������� ELF
\ �. �������, 28.05.07

0x34 CONSTANT elf-header-size
0x28 CONSTANT elf-section-size
0x10 CONSTANT elf-symbol-size
0x8  CONSTANT elf-rel-size

\ 0 VALUE elf-offset
\ : offset,size, ( n -- ) elf-offset , DUP , elf-offset + TO elf-offset ;
\ This word and `ASCIIZ"` are defined in "src/tc_spf.F"


\ ����� ����� spf4.o (������ ELF)
\ �. �������, 4.05.2007

\ ������ �����:

\ ���������

\ ������� ������:
\   0. ������� ������
\   1. ������� ���� ������
\   2. ������� ���� 
\   3. ������� ��������
\   4. ������� �����������
\   5. ����-�������
\   6. ������ ����� ��� ���������� �������
\   7. ������� ������� ������� �������
\   8. ������� ����� ��� ������� ������� �������

\ ������ =============================

CREATE .shstrtab
0 C,
ASCIIZ" .shstrtab"
ASCIIZ" .strtab"
ASCIIZ" .symtab"
ASCIIZ" .rel.forth"
ASCIIZ" .space"
ASCIIZ" .dltable"
ASCIIZ" .dlstrings"
 
HERE ' .shstrtab EXECUTE - CONSTANT .shstrtab#

\ ----------------------------------- 

CREATE .strtab
0 C,
ASCIIZ" main"
ASCIIZ" dlopen"
ASCIIZ" dlsym"
ASCIIZ" realloc"
ASCIIZ" write"
ASCIIZ" calloc"
ASCIIZ" dlerror"
 
HERE ' .strtab EXECUTE - CONSTANT .strtab#

\ ----------------------------------- 

CREATE .symtab

\ #0 ������ ������ - �������
0 ,  \ ���
0 ,  \ �����
0 ,  \ ������
0 C, \ ����������
0 C, \ ������
0 W, \ ������

\ #1 ������ forth
0 ,  \ ���
0 ,  \ �����
0 ,  \ ������
3 C, \ local+section
0 C, \ ������
5 W, \ ������

\ #2 ������ space
0 ,  \ ���
0 ,  \ �����
0 ,  \ ������
3 C, \ local+section
0 C, \ ������
6 W, \ ������

\ #3 ������ .dltable
0 ,  \ ���
0 ,  \ �����
0 ,  \ ������
3 C, \ local+section
0 C, \ ������
7 W, \ ������

\ #4 ������ .dlstrings
0 ,  \ ���
0 ,  \ �����
0 ,  \ ������
3 C, \ local+section
0 C, \ ������
8 W, \ ������

\ #5 ������� ������� main
1 ,          \ ���
' INIT .forth - ,   \ �����
30 ,         \ ������ ��������
18 C,        \ global+func
0 C,         \ ������
5 W,         \ ������

\ #6 ������� ������� dlopen
6 ,   \ ���
0 ,   \ �����
0 ,   \ ������
16 C, \ global+func
0 C,  \ ������
0 W,  \ ������

\ #7 ������� ������� dlsym
13 ,  \ ���
0 ,   \ �����
0 ,   \ ������
16 C, \ global+func
0 C,  \ ������
0 W,  \ ������

\ #8 ������� ������� realloc
19 ,  \ ���
0 ,   \ �����
0 ,   \ ������
16 C, \ global+func
0 C,  \ ������
0 W,  \ ������

\ #9 ������� ������� write
27 ,  \ ���
0 ,   \ �����
0 ,   \ ������
16 C, \ global+func
0 C,  \ ������
0 W,  \ ������

\ #9 ������� ������� calloc
33 ,  \ ���
0 ,   \ �����
0 ,   \ ������
16 C, \ global+func
0 C,  \ ������
0 W,  \ ������

\ #10 ������� ������� dlerror
40 ,  \ ���
0 ,   \ �����
0 ,   \ ������
16 C, \ global+func
0 C,  \ ������
0 W,  \ ������

HERE ' .symtab EXECUTE - CONSTANT .symtab#

\ ------------------------------------

CREATE .rel.forth

\ ������ .dltable
' dl-first 5 + .forth - ,  \ �����
3 8 LSHIFT 1 OR , \ ��� r386_32

\ ������ .dlstrings
' dl-first-strtab 5 + .forth - ,  \ �����
4 8 LSHIFT 1 OR , \ ��� r386_32

\ ������ dlopen
' dlopen-adr >BODY .forth - , \ �����
6 8 LSHIFT 1 OR , \ ��� r386_32

\ ������ dlsym
' dlsym-adr EXECUTE .forth - ,  \ �����
7 8 LSHIFT 1 OR , \ ��� r386_32

\ ������ realloc
' realloc-adr EXECUTE .forth - ,  \ �����
8 8 LSHIFT 1 OR , \ ��� r386_32

\ ������ write
' write-adr EXECUTE .forth - ,  \ �����
9 8 LSHIFT 1 OR , \ ��� r386_32

\ ������ calloc
' calloc-adr EXECUTE .forth - ,  \ �����
10 8 LSHIFT 1 OR , \ ��� r386_32

\ ������ dlerror
' dlerror-adr EXECUTE .forth - ,  \ �����
11 8 LSHIFT 1 OR , \ ��� r386_32

HERE ' .rel.forth EXECUTE - CONSTANT .rel.forth#

\ ====================================

CREATE elf-header
0x7F C, CHAR E C, CHAR L C, CHAR F C,   \ ������� ELF
1 C,          \ elfclass32
1 C,          \ elfdata2lsb
1 C,          \ elfversion = ev_current
9 ALLOT       \ padding
1 W,          \ et_rel (��������� ����)
3 W,          \ em_386 (��� ������)
1 ,           \ ev_current (������� ������)
0 ,           \ ����� �����
\ �������� ������� ���������
0 ,  
\ �������� ������� ������
' elf-header-size  EXECUTE ,
0 ,     \ �����
' elf-header-size EXECUTE W,  \ ������ ���������
0x20             W,  \ ������ ������ ������� ���������
0                W,  \ ����� ������� � ������� ���������
' elf-section-size EXECUTE W,  \ ������ ������ ������� ������
9                W,  \ ����� ������� � ������� ������
1	         W,  \ ����� ������ ������� �����

' elf-header-size EXECUTE 9 ' elf-section-size EXECUTE * + (TO) elf-offset

\ ������� ������

CREATE sections
\ ������ 0: �������
0 ,    \ ���
0 ,    \ ���
0 ,    \ �����
0 ,    \ �����
0 ,    \ ��������
0 ,    \ ������
0 ,    \ ������
0 ,    \ �������������� ����������
0 ,    \ ������������
0 ,    \ ������ ������
 
 \ ������ 1: ������� ���� ������
1 ,    \ ��� .shstrtab
3 ,    \ ��� = sht_strtab
0 ,    \ �����
0 ,    \ �����
\ �������� � ������
' .shstrtab# EXECUTE offset,size,
0 ,    \ ������
0 ,    \ �������������� ����������
1 ,    \ ������������
0 ,    \ ������ ������
 
\ ������ 2: .strtab

11 ,   \ ��� .strtab
3 ,    \ ��� = sht_strtab
0 ,    \ �����
0 ,    \ �����
\ �������� � ������
' .strtab# EXECUTE offset,size,
0 ,    \ ������
0 ,    \ �������������� ����������
1 ,    \ ������������
0 ,    \ ������ ������

\ ������ 3: .symtab
19 ,   \ ��� .symtab
2 ,    \ ��� = sht_symtab
0 ,    \ �����
0 ,    \ �����
\ �������� � ������
' .symtab# EXECUTE offset,size,
2 ,    \ ������� ���� � ������ 2
5 ,    \ ��������� ��������
4 ,    \ ������������
' elf-symbol-size EXECUTE ,    \ ������ ������

\ ������ 4: .rel.forth
27 ,   \ ��� .symtab
9 ,    \ ��� = sht_rel
0 ,    \ �����
0 ,    \ �����
\ �������� � ������
' .rel.forth# EXECUTE offset,size,
3 ,    \ ���������� ������� � ������ 3
5 ,    \ ����������� ��� ������ 5 .forth
4 ,    \ ������������
' elf-rel-size EXECUTE ,    \ ������ ������

\ elf-offset TO .forth-offset

\ ������ 5: .forth
31 ,            \ ��� .forth
1 ,             \ ��� = sht_progbits
0x7 ,           \ �����: shf_write+shf_alloc+shf_exec
0 ,             \ �����
\ �������� � ������
' elf-offset EXECUTE , 0 ,
0 ,             \ ����������
0 ,             \ ��������� ��������
4 ,             \ ������������
0 ,             \ ������ ������

\ ������ 6: .space
38 ,            \ ��� .space
8 ,             \ ��� = sht_nobits
0x7 ,           \ �����: shf_write+shf_alloc+shf_exec
0 ,             \ �����
\ �������� � ������
0 , 0 ,
0 ,             \ ����������
0 ,             \ ��������� ��������
4 ,             \ ������������
0 ,             \ ������ ������

\ ������ 7: .dltable
45 ,            \ ��� .dltable
1 ,             \ ��� = sht_progbits
0x3 ,           \ �����: shf_write+shf_alloc
0 ,             \ �����
\ �������� � ������
0 , 0 ,
0 ,             \ ����������
0 ,             \ ��������� ��������
4 ,             \ ������������
0 ,             \ ������ ������

\ ������ 6: .dlstrings
54 ,            \ ��� .dlstrings
3 ,             \ ��� = sht_startab
0x2 ,           \ �����: shf_alloc
0 ,             \ �����
\ �������� � ������
0 , 0 ,
0 ,             \ ����������
0 ,             \ ��������� ��������
4 ,             \ ������������
0 ,             \ ������ ������

\ ============================================

: reloc-dl-second-strings ( off -- )
  dl-second# 0 ?DO
    dl-second I dl-rec# * +
    DUP >R @ DUP 0< IF 
      NEGATE OVER + NEGATE 
    ELSE
      OVER +
    THEN R> !
  LOOP DROP
;

: IMAGE-BASE FORTH-START ;

: (forth.ld) ( a u -- )
  ." SECTIONS" CR
  ." {" CR
  ." .forth 0x" BASE @ >R HEX IMAGE-BASE . R> BASE ! ." :" CR
  ." {" CR
  2DUP TYPE ." .o(.forth)" CR
  ." _eforth = .;" CR
  ." }" CR
  ." .space _eforth :" CR
  ." {" CR
  TYPE ." .o(.space)" CR
  ." }" CR
  ." }" CR
;

: forth.ld ( a u -- )
  H-STDOUT >R
  2DUP <# S" .ld" HOLDS HOLDS 0 0 #>
  R/W CREATE-FILE IF DROP 2DROP R> TO H-STDOUT EXIT THEN TO H-STDOUT
  ( a u ) (forth.ld)
  H-STDOUT CLOSE-FILE DROP
  R> TO H-STDOUT 
;

\ needs default.ld file placed near spf binary
: SAVE ( c-addr u -- )
  ( �������� ld ������� )
  2DUP forth.ld
  ( ���������� ������������ ����-������� � ��������� ����� ELF )
  2DUP 
  <# S" .o" HOLDS HOLDS 0 0 #>
  R/W CREATE-FILE THROW >R
  elf-header elf-header-size R@ WRITE-FILE THROW

  HERE FORTH-START - DUP 
  sections 5 elf-section-size * + 5 CELLS + !

  sections 5 elf-section-size * + 4 CELLS + @ ( �������� ������ .forth)
  + DUP

  sections 6 elf-section-size * + 4 CELLS + !
  IMAGE-SIZE sections 6 elf-section-size * + 5 CELLS + !

  DUP sections 7 elf-section-size * + 4 CELLS + !
  dl-first# dl-second# + dl-rec# * DUP
  sections 7 elf-section-size * + 5 CELLS + !
  + 

  sections 8 elf-section-size * + 4 CELLS + !
  dl-first-strtab @ dl-second-strtab @ + CELL -
  sections 8 elf-section-size * + 5 CELLS + !

  sections 9 elf-section-size * R@ WRITE-FILE THROW

  .shstrtab .shstrtab# R@ WRITE-FILE THROW
  .strtab .strtab# R@ WRITE-FILE THROW
  .symtab .symtab# R@ WRITE-FILE THROW
  .rel.forth .rel.forth# R@ WRITE-FILE THROW

  dl-first dl-first-strtab
  0 TO dl-first  0 TO dl-first-strtab

  dl-first#  DUP dl-second# + TO dl-first#

  dlopen-adr  @  dlsym-adr  @   dlerror-adr @
  realloc-adr @  calloc-adr @   write-adr @ 

  dlopen-adr  0!  dlsym-adr  0!  dlerror-adr 0!
  realloc-adr 0!  calloc-adr 0!  write-adr   0!

  R@ FORTH-START HERE OVER - 3 4 PICK C-CALL DROP

  write-adr   !  calloc-adr !  realloc-adr !
  dlerror-adr !  dlsym-adr  !  dlopen-adr  !

  TO dl-first#  TO dl-first-strtab  TO dl-first

  dl-first-strtab @ CELL- reloc-dl-second-strings

  dl-first dl-first# dl-rec# * R@ WRITE-FILE THROW
  dl-second dl-second# dl-rec# * R@ WRITE-FILE THROW

  dl-first-strtab @ dl-second-strtab @ + CELL - HERE !

  HERE CELL R@ WRITE-FILE THROW

  dl-first-strtab CELL+ dl-first-strtab @ CELL - R@ WRITE-FILE THROW
  dl-second-strtab CELL+ dl-second-strtab @ CELL - R@ WRITE-FILE THROW

  R> CLOSE-FILE THROW

  ( a u ) DROP >R
  (( 
    HERE
    S" gcc -v 2>&1 | grep -F --silent -- '--enable-default-pie' && gcc_nopie='-no-pie' ;" DROP
    S" %s gcc %s.o -Wl,%s.ld -ldl -lpthread -m32 $gcc_nopie -v -o %s" DROP
    SWAP
    R@ R@ R>
  )) sprintf DROP 
  HERE system
;
