\ (c) ~micro 2001

REQUIRE ON lib\ext\onoff.f

MODULE: TRACER
  H-STDOUT VALUE File
  10 VALUE MaxDEPTH
  CHAR | VALUE IndentChar
  2 VALUE IndentSize
  VARIABLE Compile  Compile ON
  VARIABLE Flush    Flush   OFF

  : File:
    NextWord DUP >R
    HEAP-COPY DUP R> R/W CREATE-FILE-SHARED THROW TO File FREE THROW
  ;

  MODULE: Private
    VARIABLE Indent
    Indent 0!
    : .S
      H-STDOUT >R File TO H-STDOUT
      DEPTH S>D <# [CHAR] ] HOLD #S [CHAR] [ HOLD #> TYPE SPACE DEPTH MaxDEPTH MIN .SN
      Flush @ IF File FLUSH-FILE THROW THEN
      R> TO H-STDOUT
    ;

    : .Indent
      Indent @ 0 ?DO
        IndentChar EMIT
        IndentSize 1- SPACES
      LOOP
    ;

    : In ( addr u caddr2 -- )
      H-STDOUT >R File TO H-STDOUT
      .Indent ." > " VOC-NAME. ."  " TYPE ."  "
      .S
      CR
      1 Indent +!
      Flush @ IF File FLUSH-FILE THROW THEN
      R> TO H-STDOUT
    ;
    
    : Out ( addr u caddr2 -- )
      H-STDOUT >R File TO H-STDOUT
      -1 Indent +!
      .Indent ." < " VOC-NAME. ."  " TYPE ."  "
      .S
      CR
      Flush @ IF File FLUSH-FILE THROW THEN
      R> TO H-STDOUT
    ;

    VECT vIn
    VECT vOut

    : _: : ;
    : _; POSTPONE ; ; IMMEDIATE

    : 3DROP 2DROP DROP ;

  ;MODULE

{{ Private  
  : TraceON    ['] In    TO vIn   ['] Out   TO vOut   ;
  : TraceOFF   ['] 3DROP TO vIn   ['] 3DROP TO vOut   ;

  : StartTrace
     S" trace.log" R/W CREATE-FILE-SHARED THROW TO File
     TraceON
  ;

}}
  EXPORT
{{ Private
    : DOES>
      Compile @ IF
        LATEST POSTPONE LITERAL POSTPONE COUNT CURRENT @ POSTPONE LITERAL
        POSTPONE vOut
      THEN
      POSTPONE DOES>
      Compile @ IF
        POSTPONE DUP POSTPONE WordByAddr CURRENT @ POSTPONE LITERAL
        POSTPONE vIn
      THEN
    ; IMMEDIATE

    _: :
      _:
      Compile @ IF
        LATEST POSTPONE LITERAL POSTPONE COUNT CURRENT @ POSTPONE LITERAL
        POSTPONE vIn
      THEN
    ;
    
    _: ;
      Compile @ IF
        LATEST POSTPONE LITERAL POSTPONE COUNT CURRENT @ POSTPONE LITERAL
        POSTPONE vOut
      THEN
      POSTPONE ;
    ; IMMEDIATE
}}
  DEFINITIONS
{{ Private
  _: T:
    >IN @ >R
    NextWord SFIND DUP 0= ABORT" not found"
    R> >IN !
    SWAP
    : COMPILE, POSTPONE ;
    1 = IF
      IMMEDIATE
    THEN
  _;
}}
;MODULE

ALSO TRACER
TraceOFF

\EOF    пример на локалсы + T:

{{ TRACER
T: *
}}

: qwe { a \ b -- c }
  a 2 * TO b a b *
;

3 qwe

\EOF    пример с мложенными вызовами

: a ;
: b a a ;
: c DUP b DROP a DROP DROP ;
: d 10 0 DO I DUP 1+ DUP 1+ c DROP LOOP ;
2 TRACER::TO MaxDEPTH
d

\EOF    пример на DOES>

: q CREATE , DOES> ." q=" @ . ;
12 q q1
34 q q2
q1 q2

\EOF    описание

Трассировщик
Размещается в словаре TRACER

NEW! понимает DOES>-слова.

Пр:
----- программа -----
: parent CREATE , DOES> DROP ;
1 parent child
child
--- трейсится как ---
> FORTH parent [1] 1
< FORTH parent [0]
> FORTH child [1] 5588940    (*)
< FORTH parent [0]           (**)
---------------------
(*) Имя порождённого слова выводится только если в него родителем что-то
    было скомпилировано, иначе "<not in image>". Имя слова определяется словом 
    WordByAddr, следовательно скорость работы невелика.
(**) При выходе из порождённого слова выводится имя слова-родителя.

NEW! понимает локалсы. Впрочем, не моя заслуга, а того, кто придумал
     S" ;" EVAL-WORD в ";". Но локалсы лучше грузить ДО трейсера, если,
     конечно, не стоит задачи трейсить сами локалсы ;)

Слова: (для переменных и VALUEs в скобках - значение по умолчанию)

VALUEs:

  File (H-STDOUT) хэндл файла, в который будет выводиться трасса
       (как ещё результат назвать ;)
  MaxDEPTH (10) максимальная выводимая глубина стека
  IndentChar ('|') символ отступа при вложенных вызовах
  IndentSize (2) величина отступа

VARIABLEs:

  Compile (ON) компилировать trace-info
  Flush (OFF) сохранять файловый буфер при каждой записи

Colons:

  File: ( "файл" -- ) создать файл, хэндл сохранить в File
  TraceON (по умолчанию) начать вывод трассы
  TraceOFF прекратить вывод трассы
  T: ("существующее слово" -- ) переопределяет существующее слово, предоставляя 
     возможность отслеживать вход в него и выход.
