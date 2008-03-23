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

\ Таблица сегментов:

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
 
HERE .shstrtab - CONSTANT .shstrtab#

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
 
HERE .strtab - CONSTANT .strtab#

\ ----------------------------------- 

CREATE .symtab

\ ------------------------------------

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
'' INIT .forth - ,   \ адрес
30 ,         \ размер !!!
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

HERE .symtab - CONSTANT .symtab#

\ ------------------------------------

CREATE .rel.forth

\ Секция .dltable
'' dl-first 5 + .forth - ,  \ адрес
3 8 LSHIFT 1 OR , \ тип r386_32

\ Секция .dlstrings
'' dl-first-strtab 5 + .forth - ,  \ адрес
4 8 LSHIFT 1 OR , \ тип r386_32

\ Символ dlopen
[T] dlopen-adr [I] .forth - , \ адрес
6 8 LSHIFT 1 OR , \ тип r386_32

\ Символ dlsym
[T] dlsym-adr [I] .forth - ,  \ адрес
7 8 LSHIFT 1 OR , \ тип r386_32

\ Символ realloc
[T] realloc-adr [I] .forth - ,  \ адрес
8 8 LSHIFT 1 OR , \ тип r386_32

\ Символ write
[T] write-adr [I] .forth - ,  \ адрес
9 8 LSHIFT 1 OR , \ тип r386_32

\ Символ calloc
[T] calloc-adr [I] .forth - ,  \ адрес
10 8 LSHIFT 1 OR , \ тип r386_32

\ Символ dlerror
[T] dlerror-adr [I] .forth - ,  \ адрес
11 8 LSHIFT 1 OR , \ тип r386_32

HERE .rel.forth - CONSTANT .rel.forth#

dl-second-strtab @ CONSTANT .dlstrings#
dl-second# dl-rec# * CONSTANT .dltable#

dl-second# '' dl-first# 5 + !

\ ====================================
 
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
.shstrtab# offset,size,
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
.strtab# offset,size,
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
.symtab# offset,size,
2 ,    \ таблица имен в секции 2
5 ,    \ локальных символов
4 ,    \ выравнивание
symbol-size ,    \ размер записи

\ Секция 4: .rel.forth
27 ,   \ имя .symtab
9 ,    \ тип = sht_rel
0 ,    \ флаги
0 ,    \ адрес
\ смещение и размер
.rel.forth# offset,size,
3 ,    \ символьная таблица в секции 3
5 ,    \ перемещения для секции 5 .forth
4 ,    \ выравнивание
rel-size ,    \ размер записи

offset TO .forth-offset

\ Секция 5: .forth
31 ,            \ имя .forth
1 ,             \ тип = sht_progbits
0x7 ,           \ флаги: shf_write+shf_alloc+shf_exec
0 ,             \ адрес
\ смещение и размер
.forth# offset,size,
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
offset ,
IMAGE-SIZE ,
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
.dltable# offset,size,
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
.dlstrings# offset,size,
0 ,             \ информация
0 ,             \ локальных символов
4 ,             \ выравнивание
0 ,             \ размер записи

HERE sections - CONSTANT total-sections-size
 
total-sections-size section-size / CONSTANT sections#

CREATE segments
( \ Сегмент 0: нулевой
0 ,       \ тип
0 ,       \ смещение
0 ,       \ виртуальный адрес
0 ,       \ физический адрес
0 ,       \ размер в файле
0 ,       \ размер в памяти
0 ,       \ флаги
0 ,       \ выравнивание

\ Сегмент 1: .forth
1 ,               \ тип: pt_load
.forth-offset ,   \ смещение в файле
IMAGE-START ,     \ виртуальный адрес
0 ,               \ физический адрес
.forth# ,         \ размер в файле
IMAGE-SIZE ,      \ размер в памяти
7 ,               \ флаги: pf_x pf_r pf_w
0 ,               \ выравнивание
)
 
HERE segments - CONSTANT total-segments-size
 
total-segments-size segment-size / CONSTANT segments#
 
header-size total-sections-size + total-segments-size + CONSTANT data-offset

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
header-size  ,
0 ,     \ флаги
header-size  W,  \ размер заголовка
segment-size W,  \ размер записи таблицы сегментов
segments#    W,  \ число записей в таблице сегментов
section-size W,  \ размер записи таблицы секций
sections#    W,  \ число записей в таблице секций
1	     W,  \ номер секции таблицы строк