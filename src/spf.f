\ $Id$

430 CONSTANT SPF-KERNEL-VERSION

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

[UNDEFINED] NAME>NEXT-NAME [IF]
: NAME>NEXT-NAME ( nt -- nt|0 )  CDR  ;
[THEN]

[UNDEFINED] CS-DUP  [IF]
: CS-DUP 2DUP ;
[THEN]

[UNDEFINED] SET-XT-COMPILER  [IF]
: SET-XT-COMPILER ( xt.xt-compiler -- )
  \ Make the execution semantics of `COMPILE,` equivalent
  \ to the execution semantics identified by xt.xt-compiler
  0xE9 ['] COMPILE, C!
  ['] COMPILE, 1+ CELL+ - ['] COMPILE, 1+ !
;
[THEN]

[UNDEFINED] PARSE-NAME  [IF]
: PARSE-NAME NextWord ;
[THEN]

[UNDEFINED] PLUCK-LEXEME  [IF]
: PLUCK-LEXEME ( -- sd ) PARSE-NAME ;
[THEN]

[UNDEFINED] TAKE-LEXEME  [IF]
: TAKE-LEXEME ( -- sd.lexeme ) PLUCK-LEXEME DUP IF EXIT THEN -16 THROW ;
[THEN]

[UNDEFINED] LATEST-NAME [IF]
: LATEST-NAME ( -- nt ) GET-CURRENT @ ; \ It's a slightly broken implementation, but it suits the needs.
[THEN]

[UNDEFINED] SYNONYM [IF]
: SYNONYM ( "<spaces>name.new" "<spaces>name.old" -- ) \ 2012 TOOLS-EXT
  >IN @ >R TAKE-LEXEME 2DROP TAKE-LEXEME >IN @ >R
  SFIND DUP 0= -13 AND THROW  1 =  ( xt flag.imm )
  R> R> >IN ! HEADER >IN !  IF IMMEDIATE THEN
  \ NB: there is no `SHEADER` word in spf3 and jpf3
  LATEST-NAME NAME>C !
;
[THEN]

[UNDEFINED] CHAIN-WORDLIST [IF]
: CHAIN-WORDLIST ( wid.tail wid-empty -- )
  DUP @ IF -12 THROW THEN  >R  @  R> !
;
[THEN]

[UNDEFINED] SOURCE-FILE-LN [IF]
: SOURCE-FILE-LN ( -- u ) CURSTR @ ;
[THEN]

[UNDEFINED] SOURCE-FILE-PATH [IF]
: SOURCE-FILE-PATH ( -- sd.path ) CURFILE @ DUP IF ASCIIZ> ELSE 0 THEN ;
[THEN]


[THEN] [THEN] \ End of spf4 specific implementations


\ -----
\ Portable implementations

[UNDEFINED] SET-ORDER-TOP [IF]
  S" lib/compat/the-search-order.f" INCLUDED
[THEN]

[UNDEFINED] XTVOC>WID [IF]
: XTVOC>WID ( xt-vocabulary -- wid )
  ALSO  EXECUTE  ORDER-TOP  PREVIOUS
;
[THEN]

[UNDEFINED] -ROT [IF]
: -ROT ( x1 x2 x3 -- x3 x1 x2 ) \ a non-standard word
    SWAP ROT SWAP
;
[THEN]

[UNDEFINED] UNROT [IF]
SYNONYM UNROT -ROT \ 2025 Proposal
[THEN]

[UNDEFINED] C>S [IF]
\ see-also: https://forth-standard.org/proposals/special-memory-access-words?hideDiff#reply-1531
\ Sign-extend the low-order 8 bits in x to the full cell width.
: C>S ( char.signed -- n )  0xFF AND [ 0x7F INVERT ] LITERAL XOR 0x80 + ;
[THEN]

[UNDEFINED] CHAR- [IF]
: CHAR- 1- ;
[THEN]

[UNDEFINED] SLIT,  [IF]
: SLIT, POSTPONE SLITERAL ;
[THEN]

[UNDEFINED] EXTRACT-LEXEME [IF]
: EXTRACT-LEXEME ( -- sd.lexeme\zl-sd )
  BEGIN PLUCK-LEXEME DUP IF EXIT THEN 2DROP REFILL 0= UNTIL
  -39 THROW \ "unexpected end of input source"
;
[THEN]

[UNDEFINED] /STRING [IF]
: /STRING ( sd1 n -- sd2 ) TUCK - >R + R> ;
[THEN]

[UNDEFINED] SOURCE-FOLLOWING [IF]
: SOURCE-FOLLOWING ( -- sd ) SOURCE >IN @  OVER UMIN  /STRING ;
\ `OVER UMIN` is a workaround for a known bug in old versions of spf3/spf4
[THEN]

[UNDEFINED] \EOF [IF]
: \EOF  BEGIN REFILL 0= UNTIL POSTPONE \ ;
[THEN]

\ : H. ( n -- ) BASE @ >R HEX . R> BASE ! ;

\ End of portable implementations
\ -----



S" lib/ext/spf-asm.f"            INCLUDED
S" src/spf_compileoptions.f"     INCLUDED

ALSO ASSEMBLER DEFINITIONS
PREVIOUS DEFINITIONS


C" M_WL" FIND NIP 0=
[IF] : M_WL  CS-DUP POSTPONE WHILE ; IMMEDIATE
[THEN]


\ An implementation for COND ... THENS
\ This control-flow structure was suggested by Wil Baden in 1997
\ https://groups.google.com/g/comp.lang.forth/c/iQBnN-Dp_2I/m/YbSAzG__ZVYJ
\
\ (at the moment, it is used by "./macroopt.f" only).

USER (CS-FENCE)

: COND ( C: -- cond-sys )
  (CS-FENCE) @  DEPTH (CS-FENCE) !
; IMMEDIATE

: THENS ( C: cond-sys i*orig -- )
  BEGIN DEPTH (CS-FENCE) @ <> WHILE POSTPONE THEN REPEAT
  (CS-FENCE) !
; IMMEDIATE


: ," ( addr u -- )
    DUP C, CHARS HERE OVER ALLOT
    SWAP CMOVE 0 C, ;



0 VALUE TC-IMAGE-SIZE \ it includes the unused dictionary space
0 VALUE TC-IMAGE-BASE \ actual memory address
0 VALUE TC-IMAGE-START \ virtual address

: SET-TC-IMAGE-START ( u.virtual-address -- ) TO TC-IMAGE-START ;
: SET-TC-IMAGE-SIZE ( u.size -- ) TO TC-IMAGE-SIZE ;


512 1024 *  SET-TC-IMAGE-SIZE ( -- u.size ) \ it includes the unused dictionary space

TARGET-POSIX [IF]
  0x8050000 SET-TC-IMAGE-START ( -- u.virtual-address ) \ it is used only in POSIX target
[ELSE]
  TC-IMAGE-BASE SET-TC-IMAGE-START
[THEN]


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
.forth >VIRT TC-IMAGE-START <> [IF] .( #Error, assertion failed: `.forth` does not match `TC-IMAGE-START` ) CR ABORT [THEN]
[ELSE]
DUP TO .forth
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

: SAVE-WITH-RESERVE ( u.target-dict-unused  sd.filename-executable )
  \ Save the running system to a new executable file.
  \ When starting from the new executable, the system has
  \ at least u bytes of unused dictionary space.
  IMAGE-SIZE >R  2>R
  HERE IMAGE-BASE - ( u.dict-used )
  ( u.target-dict-unused u.dict-used ) + TO IMAGE-SIZE
  2R> SAVE
  R> TO IMAGE-SIZE
;

\ ==============================================================

CR .( Dummy B, B@ B! and /CHAR )
: B, C, ; : B@ C@ ; : B! C! ; : /CHAR 1 ;

CR .( =============================================================)
CR .( Done. Saving the system.)
CR .( =============================================================)
CR

\ ( Order: wid.host.forth wid.host.tc )
\ Note: Tick "'" from TC searches TC-TRG at the first, regardless of the search order.

\ Fix FORTH-WORDLIST wid in the target system image.
\ Note: target:datatype:wid is a subtype of host:datatype:wid
TC-TRG-WL  ' FORTH-WORDLIST EXECUTE  CHAIN-WORDLIST \ real address

HERE          ' (DP)      TC-ADDR! \ запись указателя пространства кода/данных
_VOC-LIST @   ' _VOC-LIST TC-ADDR! \ запись созданной цепочки словарей


TARGET-POSIX [IF]

.( VIRT offset is ) 0 >VIRT . CR

\ Перемещаем в виртуальные адреса VALUE FORTH-WORDLIST
' FORTH-WORDLIST EXECUTE   >VIRT TC-TO( FORTH-WORDLIST )

S" MACROOPT-WL" TC-TRG-WL SEARCH-WORDLIST DUP [IF] NIP [THEN] ( 0|xt )
[IF] \ может отсутствовать в случе noopt.f
\ Перемещаем в виртуальные адреса VALUE MACROOPT-WL
' MACROOPT-WL    EXECUTE   >VIRT TC-TO( MACROOPT-WL )
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

