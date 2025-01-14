\ $Id$

( ������������ �����, ��������� ��������� ������ � �������.
  ��-����������� �����������.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  �������������� �� 16-���������� � 32-��������� ��� - 1995-96��
  ������� - �������� 1999
)

USER LAST-CFA
USER-VALUE LAST-NON

VECT SHEADER

: SHEADER1 ( addr u -- )
  HERE 0 , ( cfa )
  DUP LAST-CFA !
  \ NB: "LAST-CFA" is not used anywhere and is left only for system-dependent backward compatibility
  0 C,     ( flags )
  -ROT WARNING @
  IF 2DUP GET-CURRENT SEARCH-WORDLIST
     IF DROP 2DUP TYPE ."  isn't unique (" SOURCE-NAME TYPE ." )" CR THEN
  THEN
  CURRENT @ +SWORD

  ALIGN
  ( �������� ��������� ���� ���, ����� ��� ���������� ���������� � �������� )
  ( ��������� ������ ������, ����������� ����� CALL *-CODE ���� ���������:  )
  ALIGN-BYTES @ DUP 4 >
  IF 5 - ALLOT
  ELSE 1 - ALLOT
  THEN

  HERE SWAP ! ( ��������� cfa )
;
' SHEADER1 ' SHEADER TC-VECT!

: HEADER ( "name" -- )
  PARSE-NAME SHEADER
;

: CREATED ( addr u -- )
\ ������� ����������� ��� c-addr u � ���������� ����������, ��������� ����.
\ ���� ��������� ������������ ������ �� ��������, ��������������� �����
\ ��� ������������. ����� ��������� ������������ ������ ����������
\ ���� ������ name. CREATE �� ����������� ����� � ���� ������ name.
\ name ����������: ( -- a-addr )
\ a-addr - ����� ���� ������ name. ��������� ���������� name �����
\ ���� ��������� � ������� DOES>.
  SHEADER

  HERE DUP  LATEST-NAME NAME>C !
  DOES>A ! ( ��� DOES )
  ['] _CREATE-CODE COMPILE,
;

: CREATE ( "<spaces>name" -- ) \ 94
   PARSE-NAME CREATED
;

: (DOES1) \ �� �����, ������� �������� ������������ � CREATE (������)
  R> DOES>A @ CFL + -
  DOES>A @ 1+ !
;

CODE (DOES2)
   LEA  EBP, -4 [EBP]
   MOV  [EBP], EAX
   MOV  EAX, 4 [ESP]
   MOV  EBX, [ESP]
   LEA  ESP, 8 [ESP]
   JMP  EBX
END-CODE

' (DOES2) ' DOES-CODE TC-VECT! \ NB: "TC-VECT!" also applies to a word created with "VALUE"

: DOES>  \ 94
\ �������������: ��������� ������������.
\ ����������: ( C: clon-sys1 -- colon-sys2 )
\ �������� ��������� ������� ����������, ������ ����, � ��������
\ �����������. ����� ��� ��� ������� ����������� ������� ������
\ ��� ������ � ������� ��� ���������� DOES>, ������� �� ����������.
\ ��������� colon-sys1 � ���������� colon-sys2. ��������� ���������
\ �������������, ������ ����, � �������� �����������.
\ ����� ����������: ( -- ) ( R: nest-sys1 -- )
\ �������� ��������� ���������� ���������� ����������� name, �� ���������
\ ���������� name, ������ ����. ���������� ���������� � ���������� ������-
\ �����, �������� nest-sys1. �������������� �������� ���������, ���� name
\ �� ���� ���������� ����� CREATE ��� ������������ ������������� �����,
\ ���������� CREATE.
\ �������������: ( i*x -- i*x a-addr ) ( R: -- nest-sys2 )
\ ��������� ��������� �� ���������� ���������� nest-sys2 � ����������
\ �����������. �������� ����� ���� ������ name �� ����. �������� �����
\ i*x ������������ ��������� name.
\ name ����������: ( i*x -- j*x )
\ ��������� ����� �����������, ������� ���������� � ��������� �������������,
\ ����������� DOES>, ������� �������������� name. �������� ����� i*x � j*x
\ ������������ ��������� � ���������� ����� name, ��������������.
  ['] (DOES1) COMPILE,
  ['] (DOES2) COMPILE,
; IMMEDIATE

: VOCABULARY ( "<spaces>name" -- )
\ ������� ������ ���� � ������ name. ���������� name ������� ������ ������
\ � ������� ������ �� ������ � ������ name.
  WORDLIST DUP
  CREATE
  ,
  LATEST-NAME NAME>CSTRING OVER VOC-NAME! ( ������ �� ��� ������� )
  GET-CURRENT SWAP PAR! ( �������-������ )
\  FORTH-WORDLIST SWAP CLASS! ( ����� )
  VOC
  ( DOES> �� �������� � ���� ��)
  (DOES1) (DOES2) \ ��� ������ �� DOES>, ������������ ����
  @  SET-ORDER-TOP \ to check the search-order underflow (if any)
;

: XT>WID ( xt-vocabulary -- wid )
  \ xt-vocabulary is the xt of a word created with `VOCABULARY`
  DUP ['] FORTH = IF DROP FORTH-WORDLIST EXIT THEN
  >BODY DUP -64 + SWAP DUP @ DUP >R WITHIN IF \ several heuristics
    R@ VOC-NAME@  DUP IF C@ 1 64 WITHIN IF R> EXIT THEN THEN
  THEN -12 THROW \ "argument type mismatch"
;

: VARIABLE ( "<spaces>name" -- ) \ 94
\ ���������� ������� �������. �������� name, ������������ ��������.
\ ������� ����������� ��� name � ���������� ����������, ������ ����.
\ ��������������� ���� ������ ������������ ������ � ����������� �������.
\ name ������������ ��� "����������".
\ name ����������: ( -- a-addr )
\ a-addr - ����� ����������������� ������. �� ������������� ������ �������� 
\ ���������
  CREATE
  0 ,
;
: CONSTANT ( x "<spaces>name" -- ) \ 94
\ ���������� ������� �������. �������� name, ������������ ��������.
\ ������� ����������� ��� name � ���������� ����������, ������ ����.
\ name ������������ ��� "���������".
\ name ����������: ( -- x )
\ �������� x �� ����.
  HEADER
\  LIT, RET,
  ['] _CONSTANT-CODE COMPILE, ,
;
: VALUE ( x "<spaces>name" -- ) \ 94 CORE EXT
\ ���������� ������� �������. �������� name, ������������ ��������. ������� 
\ ����������� ��� name � ���������� ����������, ������������ ����, � ��������� 
\ ��������� ������ x.
\ name ������������ ��� "��������".
\ ����������: ( -- x )
\ �������� x �� ����. �������� x - ��, ������� ���� ����, ����� ��� �����������,
\ ���� �� ���������� ����� x TO name, ����� ����� �������� x, 
\ ��������������� � name.
  HEADER
  ['] _CONSTANT-CODE COMPILE, ,
  ['] _TOVALUE-CODE COMPILE,
;
: VECT ( -> )
  ( ������� �����, ��������� ���������� �������� ����� ������,
    ��������� � ���� ����� xt �� TO)
  HEADER
  ['] _VECT-CODE COMPILE, ['] NOOP ,
  ['] _TOVALUE-CODE COMPILE,
;


: ->VARIABLE ( x "<spaces>name" -- ) \ 94
  HEADER
  ['] _CREATE-CODE COMPILE,
  ,
;

: USER-ALIGNED ( -- a-addr n )
   USER-HERE 3 + 2 RSHIFT ( 4 / ) 4 * DUP
   USER-HERE -
;

: USER-CREATE ( "<spaces>name" -- )
  HEADER
  HERE DOES>A ! ( ��� DOES )
  ['] _USER-CODE COMPILE,
  USER-ALIGNED SWAP ,
  USER-ALLOT
;
: USER ( "<spaces>name" -- ) \ ��������� ���������� ������
  USER-CREATE
  4 USER-ALLOT
;
: USER-VALUE ( "<spaces>name" -- ) \ 94 CORE EXT
  HEADER
  ['] _USER-VALUE-CODE COMPILE,
  USER-ALIGNED SWAP ,
  CELL+ USER-ALLOT
  ['] _TOUSER-VALUE-CODE COMPILE,
;
: USER-VECT ( "<spaces>name" -- ) 
  HEADER
  ['] _USER-VECT-CODE COMPILE,
  USER-ALIGNED SWAP ,
  CELL+ USER-ALLOT
  ['] _TOUSER-VALUE-CODE COMPILE,
;
: ->VECT ( x -> )
  HEADER
  ['] _VECT-CODE COMPILE, ,
  ['] _TOVALUE-CODE COMPILE,
;

: BEHAVIOR ( vect-xt -- assigned-xt )
\ ���������� xt ���������, ����������� VECT-����������.
  CFL + @
;
: BEHAVIOR! ( xt1 xt2 -- )
  CFL + !
;
\ � ������ ���������� ����� BEHAVIOR � BEHAVIOR! 
\ �� ��������� � USER-��������, � ������ � �������.


USER C-SMUDGE \ 12 C,

\ smudge ���������� ~nemnick 29.11.2000
: SMUDGE ( -- )
  LATEST
  IF C-SMUDGE C@
     LATEST NAME>CSTRING CHAR+ C@ C-SMUDGE C!
     LATEST NAME>CSTRING CHAR+ C!
  THEN
;

: HIDE
  12 C-SMUDGE C! SMUDGE
;

\ :NONAME ���������� ~nemnick 28.11.2000

: :NONAME ( C: -- colon-sys ) ( S: -- xt ) \ 94 CORE EXT
\ ������� ���������� ����� xt, ���������� ��������� ���������� � 
\ ������ ������� �����������, ��������� colon-sys. �������� ���������
\ ������������� � �������� �����������.
\ ��������� ���������� xt ����� ������ �������, ����������������� 
\ � ���� �����������. ��� ����������� ����� ���� ����� ��������� ��
\ xt EXECUTE.
\ ���� ����������� ���� ���������� � �������������� ����� ������,
\ colon-sys ����� ������� ��������� �� ����� ������.
\ �������������: ( i*x -- i*x ) ( R: -- nest-sys )
\ ��������� ��������� �� ���������� ���������� nest-sys � ������ 
\ �����������. �������� ����� i*x ������������ ��������� xt.
\ xt ����������: ( i*x -- j*x )
\ ��������� �����������, �������� xt. �������� ����� i*x � j*x 
\ ������������ ��������� � ���������� xt ��������������.
  LATEST ?DUP IF 1+ C@ C-SMUDGE C! SMUDGE THEN
  HERE DUP TO LAST-NON [COMPILE] ]
;


: : ( C: "<spaces>name" -- colon-sys ) \ 94
\ ���������� ������� �����������. �������� ���, ������������ ��������.
\ ������� ����������� ��� �����, ���������� "����������� ����� ���������".
\ ���������� ��������� ���������� � ������ ������� �����������, �������
\ colon-sys. �������� ��������� �������������, ��������� ����, � �������
\ �����������. ��������� ���������� ����� ���������� �������, ����������-
\ ������� � ���� �����������. ������� ����������� ������ ���� ��������
\ ��� ������ � ������� �� ��� ���, ���� �� ����� ���������.
\ �������������: ( i*x -- i*x ) ( R: -- nest-sys )
\ ��������� ���������� nest-sys � ������ �����������. ��������� �����
\ i*x ������������ ��������� �����.
\ ��� ����������: ( i*x -- j*x )
\ ��������� ����������� �����. ��������� ����� i*x � j*x ������������
\ ��������� � ���������� ����� ��������������.
  HEADER
  ]
  HIDE
;
