\ 18.09.2000 Ruvim

\ - my addons:

\ распечатка стека.  вершина - в конце.
: .S ( -- )
    SP@ S0 @
    ." Stack: "
    BEGIN  2DUP <>  WHILE
        1 CELLS -  DUP @ .
    REPEAT 2DROP  ." |"
;

: S,    ( a u -- )
\ скомпилировать заданную строку в словарь в виде строки с явно заданной длиной
  DUP C,  ( a u )
  HERE OVER  ALLOT
  SWAP CMOVE
;

\ Переопределяем, чтобы описать CREATED  ( без него никак :)

: _+WORD ( A1 u1  A2 -> ) \ добавление заголовка статьи с именем,
         \ заданным строкой  A1 u1, к списку, заданному
         \ переменной A2. Формирует только поля имени и связи с
         \ отведением памяти по ALLOT. В машинном слове по
         \ адресу A2 расположен адрес поля имени статьи, с
         \ которой начинается поиск в этом списке.
         \ пример: C" SP-FORTH" CONTEXT @ +WORD
\ was:
\  HERE LAST ! ( a1 a2 )
\  HERE ROT    ( a2 here a1 )
\  ",          ( a2 here )
\  SWAP DUP @  ( here a2 a )
\  , !

\ now: 

  HERE LAST !        ( a1 u1  a2 )
  HERE 2SWAP         ( a2 here a1 u1 )
  S,                 ( a2 here )
  SWAP DUP @ ,  !
;

: _HEADER1 ( a u -- )
  2>R
  HERE 0 , ( cfa )
  0 C,     ( flags )
  2R>

\  WARNING @
\  IF 2DUP SFIND
\     IF DROP 2DUP TYPE ."  isn't unique" ( ."  Уже определен.") CR ELSE 2DROP THEN
\  THEN

  CURRENT @ _+WORD
  ALIGN
  HERE SWAP ! ( заполнили cfa )
;

: CREATED ( a u  -- )
  _HEADER1
  HERE DOES>A ! ( для DOES )
  ['] _CREATE-CODE COMPILE,
;



