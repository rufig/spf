WARNING 0! \ чтобы не было сообщений isn't unique

: _FLIT-CODE10 ;
: _FLIT-CODE8 ;

\ S" lib\ext\disasm.f"             INCLUDED

WARNING 0! 

S" lib\ext\spf-asm.f"            INCLUDED
S" lib\include\tools.f"          INCLUDED

ALSO ASSEMBLER DEFINITIONS
PREVIOUS DEFINITIONS

: CS-DUP 2DUP ;

C" M_WL" FIND NIP 0=
[IF] : M_WL  CS-DUP POSTPONE WHILE ; IMMEDIATE
[THEN]

: PARSE-WORD NextWord ;

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

C" LAST-HERE" FIND NIP 0= VALUE INLINEVAR


: ," ( addr u -- )
    DUP C, HERE OVER ALLOT
    SWAP CMOVE 0 C, ;

S" src\spf_date.f"                INCLUDED
S" src\tc_spf.f"                  INCLUDED

WARNING 0! \ чтобы не было сообщений isn't unique

\ ==============================================================
\ Начало двоичного образа Форт-системы
\ в начале команда CALL подпрограммы инициализации.
\ Возврата из подпрограммы не будет - адрес на стеке
\ возвратов может использоваться для fixups.

HERE  DUP HEX U. \ KEY DROP
HERE TC-CALL,
\ ==============================================================
\ Основные низкоуровневые слова Форта,
\ независимые от операционной системы
0x20 TO MM_SIZE
S" src\spf_defkern.f"                INCLUDED
S" src\spf_forthproc.f"              INCLUDED
S" src\spf_floatkern.f"              INCLUDED
S" src\spf_forthproc_hl.f"           INCLUDED

\ ==============================================================
\ Средства вызова функций Win32 и импорт
\ функций Windows, используемых ядром SP-Forth

S" src\win\spf_win_api.f"            INCLUDED
S" src\win\spf_win_proc.f"           INCLUDED
S" src\win\spf_win_const.f"          INCLUDED

\ ==============================================================
\ Управление памятью

S" src\win\spf_win_memory.f"         INCLUDED

\ ==============================================================
\ Структурированная обработка исключений (см.также init)

S" src\spf_except.f"                 INCLUDED
S" src\win\spf_win_except.f"         INCLUDED

\ ==============================================================
\ Файловый и консольный ввод-вывод (Windows-зависимые)

S" src\win\spf_win_io.f"             INCLUDED
S" src\win\spf_win_conv.f"           INCLUDED
S" src\win\spf_win_con_io.f"         INCLUDED
S" src\spf_con_io.f"                 INCLUDED

\ ==============================================================
\ Печать чисел
\ Имя модуля.

S" src\spf_print.f"                  INCLUDED
S" src\win\spf_win_module.f"         INCLUDED

\ ==============================================================
\ Парсер исходного текста форт-программ
S" src\compiler\spf_parser.f"        INCLUDED
S" src\compiler\spf_read_source.f"   INCLUDED

\ ==============================================================
\ Компиляция чисел и строк в словарь.
\ Создание словарных статей.
\ Поиск слов в словарях.
\ Печать словарей.
\ Слова, к-е нельзя инлайнить.

S" src\compiler\spf_nonopt.f"        INCLUDED
S" src\compiler\spf_compile0.f"      INCLUDED
\  Макроподстановщик-оптимизатор
TRUE TO INLINEVAR

S" src\macroopt.f"                    INCLUDED

S" src\compiler\spf_compile.f"       INCLUDED
S" src\compiler\spf_wordlist.f"      INCLUDED
S" src\compiler\spf_find.f"          INCLUDED
S" src\compiler\spf_words.f"         INCLUDED

\ ==============================================================
\ Трансляция исходных текстов.
\ Обработка ошибок.
\ Определяющие слова.
\ Числовые литералы.
\ Управление компиляцией.
\ Компиляция управляющих структур.
\ Работа с модулями

S" src\compiler\spf_error.f"         INCLUDED
S" src\compiler\spf_translate.f"     INCLUDED
S" src\compiler\spf_defwords.f"      INCLUDED
S" src\compiler\spf_immed_transl.f"  INCLUDED
S" src\compiler\spf_immed_lit.f"     INCLUDED
S" src\compiler\spf_literal.f"       INCLUDED
S" src\compiler\spf_immed_control.f" INCLUDED
S" src\compiler\spf_immed_loop.f"    INCLUDED
S" src\compiler\spf_modules.f"       INCLUDED
S" src\compiler\spf_inline.f"        INCLUDED

\ ==============================================================
\ Окружение (environment).
\ Определяющие слова для Windows.
\ Многозадачность.
\ CGI

S" src\win\spf_win_envir.f"          INCLUDED
S" src\win\spf_win_defwords.f"       INCLUDED
S" src\win\spf_win_mtask.f"          INCLUDED
S" src\win\spf_win_cgi.f"            INCLUDED

\ ==============================================================
\ Сохранение системы в exe-файле.

S" src\win\spf_pe_save.f"            INCLUDED

\ ==============================================================
\ Инициализация переменных, startup
S" src\spf_init.f"                   INCLUDED

\ ==============================================================

: DONE CR ." DONE"
  S" src\done.f" INCLUDED
;


TC-LATEST-> FORTH-WORDLIST
HERE ' (DP) ( целевой DP) EXECUTE !
TC-WINAPLINK @ ' WINAPLINK EXECUTE !

CR .( =============================================================)
CR .( Done. Saving the system.)
CR .( =============================================================)
CR  
\ HERE U.
\ DUP  HERE OVER - S" spf.bin" R/W CREATE-FILE THROW WRITE-FILE THROW

\ записываем "DONE" в командную строку
S"  DONE " GetCommandLineA ASCIIZ> S"  " SEARCH 2DROP SWAP 1+ MOVE

\ на стеке - token слова INIT целевой системы, запускаем её для
\ того чтобы она сама себя сохранила в spf37x.exe выполнением слова DONE,
\ переданного ей в командной строке

\ SEE CATCH
EXECUTE
