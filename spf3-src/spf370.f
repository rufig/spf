WARNING 0! \ чтобы не было сообщений isn't unique

S" lib\ext\spf-asm.f"                INCLUDED
S" src\tc_spf370.f"                  INCLUDED

\ ==============================================================
\ Начало двоичного образа Форт-системы
\ в начале команда CALL подпрограммы инициализации.
\ Возврата из подпрограммы не будет - адрес на стеке
\ возвратов может использоваться для fixups.

HERE
HERE TC-CALL,

\ ==============================================================
\ Основные низкоуровневые слова Форта,
\ независимые от операционной системы

S" src\spf_forthproc.f"              INCLUDED
S" src\spf_defkern.f"                INCLUDED
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

S" src\compiler\spf_error.f"         INCLUDED
S" src\compiler\spf_translate.f"     INCLUDED
S" src\compiler\spf_defwords.f"      INCLUDED
S" src\compiler\spf_immed_transl.f"  INCLUDED
S" src\compiler\spf_immed_lit.f"     INCLUDED
S" src\compiler\spf_literal.f"       INCLUDED
S" src\compiler\spf_immed_control.f" INCLUDED
S" src\compiler\spf_immed_loop.f"    INCLUDED

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

: DONE
  S" src\done.f" INCLUDED
;

TC-LATEST-> FORTH-WORDLIST
HERE ' (DP) ( целевой DP) EXECUTE !
TC-WINAPLINK @ ' WINAPLINK EXECUTE !

CR .( =============================================================)
CR .( Done. Saving the system.)
CR .( =============================================================)
CR
\ DUP  HERE OVER - S" spf.bin" R/W CREATE-FILE THROW WRITE-FILE THROW

\ записываем "DONE" в командную строку
S"  DONE " GetCommandLineA ASCIIZ> S"  " SEARCH 2DROP SWAP 1+ MOVE

\ на стеке - token слова INIT целевой системы, запускаем её для
\ того чтобы она сама себя сохранила в spf37x.exe выполнением слова DONE,
\ переданного ей в командной строке
EXECUTE
