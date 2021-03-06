( 24.09.1997 ������� �. )

( ������� ���������� ��-����� ���������� �����������.
  ����������� ��� ������������� LOCALS ��������� 94.

  ���������� ��������� ����������, ������� ������ ������
  �������� ����� � ������������ �������� ������ �������
  ����� ����������� � ������� ����� "|" ����������
  ���������: ������ ����������� ����� ������������
  �����������
  | ������ ��������� ���������� ����� ������ |

  ��� ���������� ��-���� ������������� �������� ����� �
  ����� ��������� ��� ���� ���������� � ������ ������ �����
  � ������������� ����������� ����� ��� ������ �� ����.

  ��������� � ����� ��������� ���������� - ��� � �������
  ���������� �� ����� � ���������� @ � !
  ����� ��������� ���������� ���������� � ������������
  ������� TEMP-NAMES ������ � ������ ���������� �����, �
  ����� ����� ���������� � ����� ����������.
)
\ ������������� ��������� ���������� ����������, �������� ��
\ ����� (��������, �������� �����������), �������� "�������"
\ � ������� �����������
\ (( ����� ���������������� ��������� ���������� ))
\ ����� ������ ���� ����� ��������� � ����� � ������� | ... |

( ������������� ��������� ���������� ������ ������ DO LOOP
  ���������� �� �������, ��������� � ��������� 94.

  ��� ������� ������������ ��������� ���������� � ����� VALUE-����������
  ����� ������������ �����������
  || ������ ��������� ���������� ����� ������ ||
  ����� ���� ���������� ����� ������ �� �����, � ���� ��������.
  �������������� ���������� �������� ����� �������������� ������������
  -> ���
  �� �������� � ����������� �������� VALUE-���������� ������ TO.
)


WORDLIST CONSTANT TEMP-NAMES
VARIABLE TEMP-CNT

: INIT-TEMP-NAMES
  ALSO TEMP-NAMES CONTEXT !
  TEMP-CNT 0!
;
: DEL-NAMES ( A -- )
  DUP >R
  @
  BEGIN
    DUP 0<>
  WHILE
    DUP CDR SWAP 5 - FREE THROW
  REPEAT DROP
  R> 0!
;
: DEL-TEMP-NAMES
  TEMP-NAMES DEL-NAMES
;
HEX
: COMPIL, ( A -- )
  0E8 DOES>A @ C! DOES>A 1+!              \ �������� ������� CALL
  DOES>A @ CELL+ - DOES>A @ !
  DOES>A @ 1- DOES>A !
;
DECIMAL

: TEMP-DOES ( N -- ADDR )
  R> SWAP 2 + CELLS RP@ + SWAP >R
;
: |TEMP-DOES ( N -- VALUE )
  R> SWAP 2 + CELLS RP@ + @ SWAP >R
;
: |TEMP-DOES! ( X N --  )
  R> SWAP 2 + CELLS RP@ + ROT SWAP ! >R
;
: TEMP-CREATE ( addr u -- )
  DUP 20 + ALLOCATE THROW >R
  R@ CELL+ CHAR+ 2DUP C!
  CHAR+ SWAP MOVE ( name )
  TEMP-NAMES @
  R@ CELL+ CHAR+ TEMP-NAMES ! ( latest )
  R@ CELL+ CHAR+ COUNT + DUP >R ! ( link )
  R> CELL+ DUP DOES>A ! R@ ! ( cfa )
  &IMMEDIATE R> CELL+ C! ( flags )
  ['] _CREATE-CODE COMPIL,
  TEMP-CNT @ DOES>A @ 5 + !
  TEMP-CNT 1+!
  DOES> @ LIT, POSTPONE TEMP-DOES
;
: |TEMP-CREATE ( addr u -- )
  DUP 20 + ALLOCATE THROW >R
  R@ CELL+ CHAR+ 2DUP C!
  CHAR+ SWAP MOVE ( name )
  TEMP-NAMES @
  R@ CELL+ CHAR+ TEMP-NAMES ! ( latest )
  R@ CELL+ CHAR+ COUNT + DUP >R ! ( link )
  R> CELL+ DUP DOES>A ! R@ ! ( cfa )
  &IMMEDIATE R> CELL+ C! ( flags )
  ['] _CREATE-CODE COMPIL,
  TEMP-CNT @ DOES>A @ 5 + !
  TEMP-CNT 1+!
  DOES> @ LIT, POSTPONE |TEMP-DOES
;
: ->
  ' 5 + @ LIT, POSTPONE |TEMP-DOES!
; IMMEDIATE

: |DROP
  R>
  BEGIN
    DUP 0<>
  WHILE
    R> DROP 1-
  REPEAT DROP
;
: |DOES ( N -- )
  R> SWAP DUP
  BEGIN
    DUP 0<>
  WHILE
    0 >R 1-
  REPEAT DROP >R ['] |DROP >R
  >R
;
: |
  BEGIN
    BL WORD COUNT 2DUP S" |" COMPARE 0<>
  WHILE
    TEMP-CREATE
  REPEAT 2DROP
  TEMP-CNT @ LIT, POSTPONE |DOES
; IMMEDIATE

: ||
  BEGIN
    BL WORD COUNT 2DUP S" ||" COMPARE 0<>
  WHILE
    |TEMP-CREATE
  REPEAT 2DROP
  TEMP-CNT @ LIT, POSTPONE |DOES
; IMMEDIATE

: ((
  0
  BEGIN
    BL WORD DUP COUNT S" ))" COMPARE 0<>
  WHILE
    FIND IF >R 1+ ELSE 5012 THROW THEN
  REPEAT DROP
  BEGIN
    DUP 0<>
  WHILE
\    R> EXECUTE POSTPONE !
    R> 5 + @ LIT, POSTPONE TEMP-DOES POSTPONE ! ( ���������� ��� ��������� ||)
    1-
  REPEAT DROP
; IMMEDIATE


: :: : ;

WARNING @ WARNING 0!
: : ( -- )
  : INIT-TEMP-NAMES
;
:: :NONAME ( -- )
  :NONAME INIT-TEMP-NAMES
;
:: ; ( -- )
  DEL-TEMP-NAMES PREVIOUS
  POSTPONE ;
; IMMEDIATE

WARNING !
