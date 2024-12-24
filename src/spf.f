\ $Id$

429 CONSTANT SPF-KERNEL-VERSION

WARNING 0! \ чтобы не было сообщений isn't unique

: _FLIT-CODE10 ;
: _FLIT-CODE8 ;

\ S" lib\ext\disasm.f"             INCLUDED

WARNING 0! 

S" 0 0 ' [IF] 0=  ' [DEFINED] 0=  OR THROW" ' EVALUATE CATCH NIP NIP 0<> ( flag )
S" lib/include/tools.f" ROT DUP ' INCLUDED AND  SWAP 0= ' 2DROP AND  OR EXECUTE
\ This lib is included only if these words are not provided

[UNDEFINED] UMIN        [IF] : UMIN 2DUP U< IF DROP EXIT THEN NIP   ; [THEN]
[UNDEFINED] UMAX        [IF] : UMAX 2DUP U< IF NIP  EXIT THEN DROP  ; [THEN]


[DEFINED] VERSION [IF]  VERSION 350000 500000 WITHIN [IF]
\ spf4 specific implementations (if missing)

[UNDEFINED] PARSE-NAME  [IF]
: PARSE-NAME NextWord ;
[THEN]

[UNDEFINED] LATEST-NAME [IF]
: LATEST-NAME ( -- nt ) GET-CURRENT @ ; \ It's a slightly broken implementation, but it suits the needs.
[THEN]

[UNDEFINED] XT>WID [IF]
: XT>WID ( xt-vocabulary -- wid )
  ALSO EXECUTE  CONTEXT @  PREVIOUS
;
[THEN]

[UNDEFINED] CHAIN-WORDLIST [IF]
: CHAIN-WORDLIST ( wid.tail wid-empty -- )
  DUP @ IF -12 THROW THEN  >R  @  R> !
;
[THEN]

[THEN] [THEN]


S" lib/ext/spf-asm.f"            INCLUDED
S" src/spf_compileoptions.f"     INCLUDED

ALSO ASSEMBLER DEFINITIONS
PREVIOUS DEFINITIONS

: CS-DUP 2DUP ;

C" M_WL" FIND NIP 0=
[IF] : M_WL  CS-DUP POSTPONE WHILE ; IMMEDIATE
[THEN]

\ NB: The following implementation for CASE ... ENDCASE
\ is used by "./macroopt.f" in implementation-dependent manner.
\ NB: this implementation has an environmental dependency:
\ the control-flow stack is combined with the data stack.
\ Re "SP@" -- "DEPTH" can be used instead.

USER CSP

: CASE 
  CSP @ SP@ CSP ! ; IMMEDIATE

: ?OF 
  POSTPONE IF POSTPONE DROP ; IMMEDIATE

: OF 
  POSTPONE OVER POSTPONE = POSTPONE ?OF ; IMMEDIATE

: ENDOF 
  POSTPONE ELSE ; IMMEDIATE

: DUPENDCASE
  BEGIN SP@ CSP @ <> WHILE POSTPONE THEN REPEAT
  CSP ! ; IMMEDIATE

: ENDCASE 
  POSTPONE DROP   POSTPONE DUPENDCASE 
; IMMEDIATE

: ," ( addr u -- )
    DUP C, CHARS HERE OVER ALLOT
    SWAP CMOVE 0 C, ;

512 1024 * TO IMAGE-SIZE
0x8050000 CONSTANT IMAGE-START 

0 VALUE .forth
0 VALUE .forth#

TARGET-POSIX [IF]
S" src/posix/config.auto.f" INCLUDED
[THEN]

S" src/spf_date.f"                INCLUDED
S" src/spf_xmlhelp.f"             INCLUDED
S" src/tc_spf.F"                  INCLUDED

WARNING 0! \ чтобы не было сообщений isn't unique

\ ==============================================================
\ Начало двоичного образа Форт-системы
\ в начале команда CALL подпрограммы инициализации.
\ Возврата из подпрограммы не будет - адрес на стеке
\ возвратов может использоваться для fixups.


HERE  DUP HEX .( Base address of the image 0x) U.
TARGET-POSIX [IF]
TO .forth
[ELSE]
HERE TC-CALL,
[THEN]

\ ==============================================================
\ Основные низкоуровневые слова Форта,
\ независимые от операционной системы
0x20 TO MM_SIZE
S" src/spf_defkern.f"                INCLUDED
S" src/spf_forthproc.f"              INCLUDED
S" src/spf_floatkern.f"              INCLUDED
S" src/spf_forthproc_hl.f"           INCLUDED

\ ==============================================================
\ Вектора, значения которых будут определено позже

VECT TYPE

\ ==============================================================
\ Средства вызова функций Win32 и импорт
\ функций Windows, используемых ядром SP-Forth

\ Средства вызова внешних динамических библиотек
\ и константы ОС

TARGET-POSIX [IF]
S" src/posix/api.f"                  INCLUDED
S" src/posix/dl.f"                   INCLUDED
S" src/posix/const.f"                INCLUDED
[ELSE]
S" src/win/spf_win_api.f"            INCLUDED
S" src/win/spf_win_proc.f"           INCLUDED
S" src/win/spf_win_const.f"          INCLUDED
[THEN]

\ ==============================================================
\ Управление памятью

TARGET-POSIX [IF]
S" src/posix/memory.f"               INCLUDED
[ELSE]
S" src/win/spf_win_memory.f"         INCLUDED
[THEN]

\ ==============================================================
\ Структурированная обработка исключений (см.также init)

S" src/spf_except.f"                 INCLUDED
TARGET-POSIX [IF]
S" src/posix/except.f"               INCLUDED
[ELSE]
S" src/win/spf_win_except.f"         INCLUDED
[THEN]

\ ==============================================================
\ Файловый и консольный ввод-вывод (OC-зависимые)

TARGET-POSIX [IF]
S" src/posix/io.f"                   INCLUDED
[ELSE]
S" src\win\spf_win_io.f"             INCLUDED
S" src\win\spf_win_conv.f"           INCLUDED
[THEN]

S" src/spf_con_io.f"                 INCLUDED

\ ==============================================================
\ Печать чисел
\ Имя модуля.

S" src/spf_print.f"                  INCLUDED
S" src/spf_module.f"                 INCLUDED

\ ==============================================================
\ Парсер исходного текста форт-программ
S" src/compiler/spf_parser.f"        INCLUDED
S" src/compiler/spf_read_source.f"   INCLUDED

\ ==============================================================
\ Компиляция чисел и строк в словарь.
\ Создание словарных статей.
\ Поиск слов в словарях.
\ Печать словарей.
\ Слова, к-е нельзя инлайнить.

S" src/compiler/spf_nonopt.f"        INCLUDED
S" src/compiler/spf_compile0.f"      INCLUDED

: [>T]  ; IMMEDIATE
:  >T   ; IMMEDIATE
\  Макроподстановщик-оптимизатор
BUILD-OPTIMIZER [IF]
S" src/macroopt.f"                   INCLUDED
[ELSE]
S" src/noopt.f"                      INCLUDED
[THEN]
M\ ' DROP ' DTST TC-VECT!

S" src/compiler/spf_compile.f"       INCLUDED
S" src/compiler/spf_wordlist.f"      INCLUDED
S" src/compiler/spf_find.f"          INCLUDED
S" src/compiler/spf_words.f"         INCLUDED

\ ==============================================================
\ Трансляция исходных текстов.
\ Обработка ошибок.
\ Определяющие слова.
\ Числовые литералы.
\ Управление компиляцией.
\ Компиляция управляющих структур.
\ Работа с модулями

S" src/compiler/spf_error.f"         INCLUDED
S" src/compiler/spf_translate.f"     INCLUDED
S" src/compiler/spf_defwords.f"      INCLUDED
S" src/compiler/spf_immed_transl.f"  INCLUDED
S" src/compiler/spf_immed_lit.f"     INCLUDED
S" src/compiler/spf_literal.f"       INCLUDED
S" src/compiler/spf_immed_control.f" INCLUDED
S" src/compiler/spf_immed_loop.f"    INCLUDED
S" src/compiler/spf_modules.f"       INCLUDED
S" src/compiler/spf_inline.f"        INCLUDED

\ ==============================================================
\ Окружение (environment).
\ Определяющие слова для Windows.
\ Многозадачность.
\ CGI

TARGET-POSIX [IF]
S" src/posix/envir.f"                INCLUDED
S" src/posix/defwords.f"             INCLUDED
S" src/posix/mtask.f"                INCLUDED
S" src/win/spf_win_cgi.f"            INCLUDED
[ELSE]
S" src\win\spf_win_envir.f"          INCLUDED
S" src\win\spf_win_defwords.f"       INCLUDED
S" src\win\spf_win_mtask.f"          INCLUDED
S" src\win\spf_win_cgi.f"            INCLUDED

\ Сохранение системы в exe-файле.

S" src\win\spf_pe_save.f"            INCLUDED
: DONE 
  CR ." DONE"
  S" src/done.f" INCLUDED
;
[THEN]

\ ==============================================================
\ Инициализация переменных, startup
S" src/spf_init.f"                   INCLUDED

TARGET-POSIX [IF]
\ ==============================================================
\ Сохранение системы в exe-файле.
S" src/posix/save.f"                 INCLUDED
[THEN]

\ ==============================================================

CR .( Dummy B, B@ B! and /CHAR )
: B, C, ; : B@ C@ ; : B! C! ; : /CHAR 1 ;

CR .( =============================================================)
CR .( Done. Saving the system.)
CR .( =============================================================)
CR

TC-LATEST-> FORTH-WORDLIST  \ запись созданной цепочки слов в словарь (реальный адрес)

HERE          ' (DP)      TC-ADDR! \ запись указателя пространства кода/данных
_VOC-LIST @   ' _VOC-LIST TC-ADDR! \ запись созданной цепочки словарей


TARGET-POSIX [IF]

.( VIRT offset is ) 0 >VIRT . CR

\ Перемещаем в виртуальные адреса VALUE NON-OPT-WL
' NON-OPT-WL EXECUTE      ' NON-OPT-WL      TC-VECT!

\ Перемещаем в виртуальные адреса VALUE FORTH-WORDLIST
' FORTH-WORDLIST EXECUTE  ' FORTH-WORDLIST  TC-VECT!

[T] [DEFINED] MACROOPT-WL [I] [IF] \ может отсутствовать в случе noopt.f
\ Перемещаем в виртуальные адреса VALUE MACROOPT-WL
' MACROOPT-WL    EXECUTE  ' MACROOPT-WL     TC-VECT!
\ Если уж это значение в системе есть, то должно быть корректным ;)
[THEN]

HERE .forth - TO .forth#

ONLY DEFINITIONS

S" src/xsave.f" 		  INCLUDED

[ELSE]

TC-WINAPLINK @ ' WINAPLINK TC-ADDR!

CR  
\ HERE U.
\ DUP  HERE OVER - S" spf.bin" R/W CREATE-FILE THROW WRITE-FILE THROW

\ записываем "DONE" в командную строку
S"  DONE " GetCommandLineA ASCIIZ> S"  " SEARCH 2DROP SWAP 1+ MOVE

[THEN]

CREATE-XML-HELP
[IF]
FINISH-XMLHELP
[THEN]

TARGET-POSIX [IF]
S" src/spf4.o" XSAVE
[ELSE]
\ на стеке - token слова INIT целевой системы, запускаем её для
\ того чтобы она сама себя сохранила в spf37x.exe выполнением слова DONE,
\ переданного ей в командной строке
EXECUTE
[THEN]

