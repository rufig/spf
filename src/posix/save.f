\ $Id$
\ 
\ Сохранение наработанной Форт-системы в объектный файл формата ELF
\ Ю. Жиловец, 28.05.07

0x34 CONSTANT elf-header-size
0x28 CONSTANT elf-section-size
0x10 CONSTANT elf-symbol-size
0x8  CONSTANT elf-rel-size

\ 0 VALUE elf-offset

: ASCIIZ" ( ->" ) [CHAR] " PARSE 
 HERE OVER ALLOT SWAP CMOVE 0 C,
;

\ : offset,size, ( n -- ) elf-offset , DUP , elf-offset + TO elf-offset ;

\ Образ файла spf4.o (формат ELF)
\ Ю. Жиловец, 4.05.2007

\ Состав файла:

\ Заголовок

\ Таблица секций:
\   0. Нулевая секция
\   1. Таблица имен секций
\   2. Таблица имен 
\   3. Таблица символов
\   4. Таблица перемещений
\   5. Форт-система
\   6. Пустое место для расширения системы
\   7. Таблица вызовов внешних функций
\   8. Таблица строк для вызовов внешних функций

\ Секции =============================

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

\ #0 Первый символ - нулевой
0 ,  \ имя
0 ,  \ адрес
0 ,  \ размер
0 C, \ информация
0 C, \ резерв
0 W, \ секция

\ #1 Секция forth
0 ,  \ имя
0 ,  \ адрес
0 ,  \ размер
3 C, \ local+section
0 C, \ резерв
5 W, \ секция

\ #2 Секция space
0 ,  \ имя
0 ,  \ адрес
0 ,  \ размер
3 C, \ local+section
0 C, \ резерв
6 W, \ секция

\ #3 Секция .dltable
0 ,  \ имя
0 ,  \ адрес
0 ,  \ размер
3 C, \ local+section
0 C, \ резерв
7 W, \ секция

\ #4 Секция .dlstrings
0 ,  \ имя
0 ,  \ адрес
0 ,  \ размер
3 C, \ local+section
0 C, \ резерв
8 W, \ секция

\ #5 Главная функция main
1 ,          \ имя
' INIT .forth - ,   \ адрес
30 ,         \ размер условный
18 C,        \ global+func
0 C,         \ резерв
5 W,         \ секция

\ #6 внешняя функция dlopen
6 ,   \ имя
0 ,   \ адрес
0 ,   \ размер
16 C, \ global+func
0 C,  \ резерв
0 W,  \ секция

\ #7 внешняя функция dlsym
13 ,  \ имя
0 ,   \ адрес
0 ,   \ размер
16 C, \ global+func
0 C,  \ резерв
0 W,  \ секция

\ #8 внешняя функция realloc
19 ,  \ имя
0 ,   \ адрес
0 ,   \ размер
16 C, \ global+func
0 C,  \ резерв
0 W,  \ секция

\ #9 внешняя функция write
27 ,  \ имя
0 ,   \ адрес
0 ,   \ размер
16 C, \ global+func
0 C,  \ резерв
0 W,  \ секция

\ #9 внешняя функция calloc
33 ,  \ имя
0 ,   \ адрес
0 ,   \ размер
16 C, \ global+func
0 C,  \ резерв
0 W,  \ секция

\ #10 внешняя функция calloc
40 ,  \ имя
0 ,   \ адрес
0 ,   \ размер
16 C, \ global+func
0 C,  \ резерв
0 W,  \ секция

HERE ' .symtab EXECUTE - CONSTANT .symtab#

\ ------------------------------------

CREATE .rel.forth

\ Секция .dltable
' dl-first 5 + .forth - ,  \ адрес
3 8 LSHIFT 1 OR , \ тип r386_32

\ Секция .dlstrings
' dl-first-strtab 5 + .forth - ,  \ адрес
4 8 LSHIFT 1 OR , \ тип r386_32

\ Символ dlopen
' dlopen-adr >BODY .forth - , \ адрес
6 8 LSHIFT 1 OR , \ тип r386_32

\ Символ dlsym
' dlsym-adr EXECUTE .forth - ,  \ адрес
7 8 LSHIFT 1 OR , \ тип r386_32

\ Символ realloc
' realloc-adr EXECUTE .forth - ,  \ адрес
8 8 LSHIFT 1 OR , \ тип r386_32

\ Символ write
' write-adr EXECUTE .forth - ,  \ адрес
9 8 LSHIFT 1 OR , \ тип r386_32

\ Символ calloc
' calloc-adr EXECUTE .forth - ,  \ адрес
10 8 LSHIFT 1 OR , \ тип r386_32

\ Символ dlerror
' dlerror-adr EXECUTE .forth - ,  \ адрес
11 8 LSHIFT 1 OR , \ тип r386_32

HERE ' .rel.forth EXECUTE - CONSTANT .rel.forth#

\ ====================================

CREATE elf-header
0x7F C, CHAR E C, CHAR L C, CHAR F C,   \ подпись ELF
1 C,          \ elfclass32
1 C,          \ elfdata2lsb
1 C,          \ elfversion = ev_current
9 ALLOT       \ padding
1 W,          \ et_rel (объектный файл)
3 W,          \ em_386 (тип машины)
1 ,           \ ev_current (текущая версия)
0 ,           \ точка входа
\ смещение таблицы сегментов
0 ,  
\ смещение таблицы секций
' elf-header-size  EXECUTE ,
0 ,     \ флаги
' elf-header-size EXECUTE W,  \ размер заголовка
0x20             W,  \ размер записи таблицы сегментов
0                W,  \ число записей в таблице сегментов
' elf-section-size EXECUTE W,  \ размер записи таблицы секций
9                W,  \ число записей в таблице секций
1	         W,  \ номер секции таблицы строк

' elf-header-size EXECUTE 9 ' elf-section-size EXECUTE * + (TO) elf-offset

\ Таблица секций

CREATE sections
\ Секция 0: нулевая
0 ,    \ имя
0 ,    \ тип
0 ,    \ флаги
0 ,    \ адрес
0 ,    \ смещение
0 ,    \ размер
0 ,    \ ссылки
0 ,    \ дополнительная информация
0 ,    \ выравнивание
0 ,    \ размер записи
 
 \ Секция 1: Таблица имен секций
1 ,    \ имя .shstrtab
3 ,    \ тип = sht_strtab
0 ,    \ флаги
0 ,    \ адрес
\ смещение и размер
' .shstrtab# EXECUTE offset,size,
0 ,    \ ссылки
0 ,    \ дополнительная информация
1 ,    \ выравнивание
0 ,    \ размер записи
 
\ Секция 2: .strtab

11 ,   \ имя .strtab
3 ,    \ тип = sht_strtab
0 ,    \ флаги
0 ,    \ адрес
\ смещение и размер
' .strtab# EXECUTE offset,size,
0 ,    \ ссылки
0 ,    \ дополнительная информация
1 ,    \ выравнивание
0 ,    \ размер записи

\ Секция 3: .symtab
19 ,   \ имя .symtab
2 ,    \ тип = sht_symtab
0 ,    \ флаги
0 ,    \ адрес
\ смещение и размер
' .symtab# EXECUTE offset,size,
2 ,    \ таблица имен в секции 2
5 ,    \ локальных символов
4 ,    \ выравнивание
' elf-symbol-size EXECUTE ,    \ размер записи

\ Секция 4: .rel.forth
27 ,   \ имя .symtab
9 ,    \ тип = sht_rel
0 ,    \ флаги
0 ,    \ адрес
\ смещение и размер
' .rel.forth# EXECUTE offset,size,
3 ,    \ символьная таблица в секции 3
5 ,    \ перемещения для секции 5 .forth
4 ,    \ выравнивание
' elf-rel-size EXECUTE ,    \ размер записи

\ elf-offset TO .forth-offset

\ Секция 5: .forth
31 ,            \ имя .forth
1 ,             \ тип = sht_progbits
0x7 ,           \ флаги: shf_write+shf_alloc+shf_exec
0 ,             \ адрес
\ смещение и размер
' elf-offset EXECUTE , 0 ,
0 ,             \ информация
0 ,             \ локальных символов
4 ,             \ выравнивание
0 ,             \ размер записи

\ Секция 6: .space
38 ,            \ имя .space
8 ,             \ тип = sht_nobits
0x7 ,           \ флаги: shf_write+shf_alloc+shf_exec
0 ,             \ адрес
\ смещение и размер
0 , 0 ,
0 ,             \ информация
0 ,             \ локальных символов
4 ,             \ выравнивание
0 ,             \ размер записи

\ Секция 7: .dltable
45 ,            \ имя .dltable
1 ,             \ тип = sht_progbits
0x3 ,           \ флаги: shf_write+shf_alloc
0 ,             \ адрес
\ смещение и размер
0 , 0 ,
0 ,             \ информация
0 ,             \ локальных символов
4 ,             \ выравнивание
0 ,             \ размер записи

\ Секция 6: .dlstrings
54 ,            \ имя .dlstrings
3 ,             \ тип = sht_startab
0x2 ,           \ флаги: shf_alloc
0 ,             \ адрес
\ смещение и размер
0 , 0 ,
0 ,             \ информация
0 ,             \ локальных символов
4 ,             \ выравнивание
0 ,             \ размер записи

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

: SAVE ( c-addr u -- )
  ( сохранение наработанной форт-системы в объектном файле ELF )
  S" save/spf4.o" +ModuleDirName
  R/W CREATE-FILE THROW >R
  elf-header elf-header-size R@ WRITE-FILE THROW

  HERE FORTH-START - DUP 
  sections 5 elf-section-size * + 5 CELLS + !

  sections 5 elf-section-size * + 4 CELLS + @ ( смещение секции .forth)
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

  DROP >R
  (( HERE S" %ssave/save %ssave %x %s" DROP 
     ModuleDirName PAD CZMOVE PAD DUP
     FORTH-START
     R>
  )) sprintf DROP 
  HERE system
  BYE
;
