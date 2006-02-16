( 
    Защита стека возвратов от повреждения стеком данных в SPF4
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Поскольку в SPF4 стек данных и стек возвратов расположенные в
  одном адресном пространстве стека возвратов операционной системы,
  то существует опасность порча стека возвратов возврастающим стеком 
  данных. 
    Предлагаю защитить стек возвратов от стека данных 
  средствами защиты виртуальной памяти ОС. 
    А также устанавливать корректный номер ошибки в случае переполнения 
  стека, анализируя регистры в ContextRecord во время исключения 
  "0xC0000005L ACCESS_VIOLATION".

     В SPF4 стек имеет такой вид:
  xxxxFFFF-StackReserved   --- макс. глубина стека зарезервированная ОС.
                           } стек возвратов [где-то здесь RP@]
  xxxxFFFF-r-ST_RES        --- R0 @ = [*]
                           } стек данных [где-то здесь SP@]
  xxxxFFFF-r               --- S0 @ =
                           } стек возратов для callback
  xxxxFFFF                 --- дно стека

    После внедрения stack-guard.f стек имеет такой вид:
  xxxxFFFF-StackReserved   --- макс. глубина стека зарезервированная ОС.
                           } стек возвратов [где-то здесь RP@]
  xxxxFFFF-r-ST_RES        --- R0 @ =
                           } неиспользуемый участок из-за выравнивания на PAGE-SIZE
  xxxxFFFF-r-ST_RES+unused --- переменная "SP-PROTECTED" содержит адрес участка,
                               который выровнен на 4Кб.  
                           } участок защищённый с помощью VirtualProtect/PAGE_READONLY
                             [READONLY в полне достаточно, чтоб защитить
                             стек возратов от повреждения и своевременно 
                             получить ошибку -3.]
  xxxxFFFF-r-ST_RES+unused+PAGE_SIZE --- макс. глубина стека данных.
                           } стек данных [где-то здесь SP@]
  xxxxFFFF-r               --- S0 @ =
                           } стек возратов для callback
  xxxxFFFF                 --- дно стека

    [*] В приведённых именах символ '-' заменён на '_', 
        чтоб не перепутать с вычитанием.

  Шишминцев Сергей [mailto:ss@forth.org.ru]
  2006.02.15
  PS: Кстати, а защита от исчерпание стека нужна? 

    История
    ~~~~~~~
  2006.02.16 
  ~~~~~~~~~~
    Заработало под Win98. Почему-то несрабатывал PAGE_NOACCESS.
  Будем довольствоваться PAGE_READONLY.
    Предположение: поскольку под Win98 нету PAGE_GUARD, то сама ОС 
  перехватывает PAGE_NOACCESS и при обращении к "SP-PROTECTED"
  думает что нужно закоммитить стек. [1,2]
    Действительно, после обращения к защищённой странице её защита 
  молча становится PAGE_READWRITE. ;( Если попытаться установить 
  PAGE_GUARD+PAGE_READWRITE на стеке, то WindowsXP ведёт себя аналогично.
  [а PAGE_GUARD+PAGE_READONLY дасть "0xC0000005L ACCESS_VIOLATION"]
    Кому интересно вот программа на C с протоколами под Win98 и WinXP:
  http://forth.org.ru/~ss/stack-guard-test.zip
  http://bookmania.com.ru/stack-guard-test.zip
    
    Литература
    ~~~~~~~~~~
  [1] MSDN "Thread Stack Size" 
      http://msdn.microsoft.com/library/en-us/dllproc/base/thread_stack_size.asp
  [2] Что нибудь про PAGE_GUARD, EXCEPTION_GUARD_PAGE  и стек.
      Например, "Как подменить стек?" http://www.rsdn.ru/article/baseserv/stack.xml#EBPA
)

WINAPI: VirtualProtect  KERNEL32.DLL 
\ BOOL VirtualProtect(
\   LPVOID lpAddress,       // region of committed pages
\   SIZE_T dwSize,          // size of the region
\   DWORD flNewProtect,     // desired access protection
\   PDWORD lpflOldProtect   // old protection
\ );

0x1000 CONSTANT PAGE-SIZE
1 CONSTANT PAGE_NOACCESS
2 CONSTANT PAGE_READONLY
0x100 CONSTANT PAGE_GUARD

: VIRTUAL-PROTECT-PAGE ( addr new-prot -- old-prot 0|err )
  2>R 
  0 SP@ R> PAGE-SIZE R> VirtualProtect 
  0= IF DROP GetLastError  ELSE 0 THEN 
;

USER-VALUE SP-PROTECTED    \ адрес защищённой страницы стека в текущеи потоке
USER-VALUE SP-OLD-PROTECT  \ исходный флаг защиты

: xTHROW ?DUP IF >R 0 @ THEN ; \ обычный THROW не срабатывеет
                               \ попробуйте вместо PAGE_READONLY - PAGE_GUARD
                               \ а потом обычный THROW 
                               \ и наконец, обычный THROW в AT-THREAD-FINISHING

: PROTECT-RETURN-STACK
  R0 @ PAGE-SIZE + PAGE-SIZE / PAGE-SIZE * DUP TO SP-PROTECTED
  ." Protecting at "  DUP HEX . DECIMAL CR
  ." Unused stack space: " SP-PROTECTED R0 @ - . ." bytes" CR
  PAGE_READONLY VIRTUAL-PROTECT-PAGE xTHROW TO SP-OLD-PROTECT \ . . OK
  ." Old protection: " SP-OLD-PROTECT . CR
;

: EXC-DUMP-20060215 ( exc-info -- ) 
  \ Вывод корректных сообщений в случае переполнения стека.
  IN-EXCEPTION @ IF DROP EXIT THEN
  TRUE IN-EXCEPTION !
  \ достаём ContextRecord->Ebp
  3 PICK 180 + @ SP-PROTECTED PAGE-SIZE + = IF -3 OVER ! ( Переполнение стека) THEN
  3 PICK 180 + @ S0 @ > IF -4 OVER ! ( Исчерпание стека) THEN
  \ достаём ContextRecord->Esp
  3 PICK 196 + @ R0 @ > IF -6 OVER ! ( Исчерпание стека возвратов!) THEN
  \ 3 PICK 196 + @ S0 @ 0x100000 < IF -5 OVER ! ( Переполнение стека возвратов) THEN
  FALSE IN-EXCEPTION !
  [ ' <EXC-DUMP> BEHAVIOR BRANCH, ]
;
' EXC-DUMP-20060215 TO <EXC-DUMP>
 
..: AT-THREAD-STARTING SP-PROTECTED 0= IF PROTECT-RETURN-STACK THEN ;..
..: AT-PROCESS-STARTING PROTECT-RETURN-STACK ;..
..: AT-THREAD-FINISHING
    SP-PROTECTED SP-OLD-PROTECT VIRTUAL-PROTECT-PAGE xTHROW DROP ;.. 
\ ST-RES содержит адрес на длину форт-стека в байтах
\ для всех CALLBACK:
0x7000 ST-RES ! \ меньше (PAGE-SIZE*3) нельзя.
                \ больше 0x8000 нельзя (см. StackCommitSize в spf-stub.f, [1])

\ А чтоб подействовало на основной поток нужно сделать SAVE
\ S" spf4_guarded.exe" SAVE
\ и попробуйте:
\  spf4_guarded.exe : tt 10000 0 DO I LOOP ; tt
\                                            ^  -3 Переполнение стека

\EOF

: sp-pre-overflow
  HEX 
  0x5F00 CELL /  0 DO I LOOP 
  SP@ .
  0x5F00 CELL /  0 DO DROP LOOP 
;
: sp-overflow
  HEX 
  0x7000 CELL /  0 DO I LOOP 
  SP@ .
  0x7000 CELL /  0 DO DROP LOOP 
;

:NONAME
  10 PAUSE
  100000 MIN
  DUP RALLOT DROP RFREE 
  S0 @ R0 @ - . CR
  ." S0-R0=" S0 @ R0 @ - . CR
  HEX
  ." SP@=" SP@ . CR
  ." S0=" S0 @ . CR
  ." RP@="  RP@ . CR
  ." R0="  R0 @ . CR
  DECIMAL
  sp-pre-overflow
  \ sp-overflow 
  \ SP-PROTECTED DUP HEX .  @ .
  1 PAUSE
  ." task done." OK
  0 
; 
TASK: test
.( S0-R0=) S0 @ R0 @ - . .( ST-RES=) ST-RES @ . CR
123 test START 150 PAUSE CloseHandle DROP CR OK \ QUIT
123 test START 1 PAUSE CloseHandle DROP CR OK 
123 test START 0 PAUSE CloseHandle DROP CR OK 
123 test START 1 PAUSE CloseHandle DROP CR OK 
123 test START 0 PAUSE CloseHandle DROP CR OK 
123 test START 1 PAUSE CloseHandle DROP CR OK 
123 test START 0 PAUSE CloseHandle DROP CR OK 
123 test START 1 PAUSE CloseHandle DROP CR OK 
123 test START 0 PAUSE CloseHandle DROP CR OK 
123 test START 1 PAUSE CloseHandle DROP CR OK 
123 test START 0 PAUSE CloseHandle DROP CR OK 
123 test START 1 PAUSE CloseHandle DROP CR OK 
123 test START 0 PAUSE CloseHandle DROP CR OK 
123 test START 1 PAUSE CloseHandle DROP CR OK 
123 test START 0 PAUSE CloseHandle DROP CR OK 
123 test START 1 PAUSE CloseHandle DROP CR OK 
123 test START 0 PAUSE CloseHandle DROP CR OK 
123 test START 1 PAUSE CloseHandle DROP CR OK 
: stress-test
  60 2 * 150 *  0 DO  
    I 10 + test START CloseHandle DROP
    I 150 UMOD 0= IF 
      500 PAUSE 
      ." ===========================================" CR
    THEN
  LOOP
;
stress-test
1000 PAUSE
OK
BYE
\EOF

: sp-overflow1
  ST-RES @ CELL / 10 + 0 DO I LOOP 
;
: test
  sp-overflow1
  ." good!"
;
test
DEPTH .
