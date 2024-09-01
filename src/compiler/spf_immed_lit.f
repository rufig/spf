\ $Id$

( ����� ������������ ����������, ������������ ��� ����������
  �������� � �������� ��������� � ���� ���������������� �����������.
  ��-����������� �����������.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  �������������� �� 16-���������� � 32-��������� ��� - 1995-96��
  ������� - �������� 1999
)

: LITERAL \ 94 CORE
\ �������������: ��������� ������������.
\ ����������: ( x -- )
\ �������� ��������� ������� ����������, ������ ����, � �������� �����������.
\ ����� ����������: ( -- x )
\ �������� x �� ����.
  STATE @ IF LIT, THEN
; IMMEDIATE

: 2LITERAL \ 94 DOUBLE
\ �������������: ��������� ������������.
\ ����������: ( x1 x2 -- )
\ �������� ��������� ������� ����������, ������ ����, � �������� �����������.
\ ����� ����������: ( -- x1 x2 )
\ �������� ���� ����� x1 x2 �� ����.
  STATE @ IF 2LIT, THEN
; IMMEDIATE

: SLITERAL  \ 94 STRING
\ �������������: ��������� �� ����������.
\ ����������: ( c-addr1 u -- )
\ �������� ��������� ������� ����������, ������ ����, � �������� �����������.
\ ����� ����������: ( -- c-addr2 u )
\ ���������� c-addr2 u, ����������� ������, ��������� �� ��������, ��������
\ c-addr1 u �� ����� ����������. ��������� �� ����� ������ ������������
\ ������.

  STATE @ IF SLIT, ELSE  2DUP CHARS + 0 SWAP C! THEN
; IMMEDIATE

: CLITERAL ( compil: true ; c-addr --  |  compil: false ; c-addr -- c-addr )
  STATE @ IF CLIT, THEN
; IMMEDIATE

: S"   \ 94+FILE
\ �������������: ( "ccc<quote>" -- c-addr u )
\ �������� ccc, ������������ " (�������� ���������). �������� ����������
\ ������ c-addr u �� ��������� �����. ������������ ����� ����������
\ ������ ������� �� ����������, �� �� ����� ���� ������ 80 ��������.
\ ��������� ������������� S" ����� ���������� ��������� �����.
\ �������������� ��� ������� ���� ����� �����.
\ ����������: ( "ccc<quote>" -- )
\ �������� ccc, ������������ " (�������� ���������). �������� ���������
\ ������� ����������, ��������� ����, � �������� �����������.
\ ����� ����������: ( -- c-addr u )
\ ������� c-addr � u, ������� ��������� ������, ��������� �� �������� ccc.
  [CHAR] " PARSE [COMPILE] SLITERAL
; IMMEDIATE

: C"   \ 94 CORE EXT
\ �������������: ��������� �� ����������.
\ ����������: ( "ccc<quote>" -- )
\ �������� ccc, ������������ " (�������� ���������) � �������� 
\ ��������� ������� ����������, ������ ����, � �������� �����������.
\ ����� ����������: ( -- c-addr )
\ ���������� c-addr, ������ �� ���������, ��������� �� �������� ccc.
\ ��������� �� ������ ������ ������������ ������.
  [CHAR] "
  PeekChar OVER = IF \ empty counted string C" "
    DROP >IN 1+!
    SYSTEM-PAD DUP 0!
  ELSE
    WORD \ it doesn't understand a token with 0-length.
  THEN 
  [COMPILE] CLITERAL
; IMMEDIATE

: ."  \ 94
\ �������������: ��������� ������������.
\ ����������: ( "ccc<quote>" -- )
\ �������� ccc, ������������ " (�������� ���������). �������� ��������� ������� 
\ ����������, ������ ����, � �������� �����������.
\ ����� ����������: ( -- )
\ ������� ccc �� �����.
  ?COMP
  ['] _CLITERAL-CODE COMPILE,
  [CHAR] " PARSE DUP C, CHARS
  HERE SWAP DUP ALLOT MOVE 0 C,
  ['] (.") COMPILE,
; IMMEDIATE

: [CHAR]  \ 94
\ �������������: ��������� ������������.
\ ����������: ( "<spaces>name" -- )
\ ���������� ������� �������. �������� name, ������������ ���������. �������� 
\ ��������� ������� ����������, ������ ����, � �������� �����������.
\ ����� ����������: ( -- char )
\ �������� char, �������� ������� ������� name, �� ����.
  ?COMP
  PARSE-NAME DROP C@ [COMPILE] LITERAL
; IMMEDIATE

: ABORT"   \ 94
\ �������������: ��������� �� ����������.
\ ����������: ( "ccc<quote>" -- )
\ �������� ccc, ������������ " (�������� ���������). �������� ���������
\ ���� ��������� ������� ���������� � ������� �����������.
\ ����������: ( i*x x1 -- | i*x )
\ ������ x1 �� �����. ���� ����� ��� x1 ���������, ������� �� ����� ccc �
\ ��������� ��������� �� ���������� ��������, ���������� ABORT.
\ : ABORT"  \ 94 EXCEPTION EXT
\ ��������� ��������� CORE ABORT" ����� ����:
\ �������������: ��������� �� ����������.
\ ����������: ( "ccc<quote>" -- )
\ �������� ccc, ������������ " (�������� ���������). �������� ���������
\ ������� ����������, ������ ����, � �������� �����������.
\ ����� ����������: ( i*x x1 -- | i*x ) ( R: j*x -- | j*x )
\ ������ x1 �� �����. ���� ����� ��� x1 ���������, ��������� �������
\ -2 THROW, ������ ccc, ���� �� ����� ���������� ��� ����� ����������.
  ?COMP
  ['] _CLITERAL-CODE COMPILE,
  [CHAR] " PARSE DUP C, CHARS
  HERE SWAP DUP ALLOT MOVE 0 C,
  ['] (ABORT") COMPILE,
; IMMEDIATE

: [']  \ 94
\ �������������: ��������� ������������.
\ ����������: ( "<spaces>name" -- )
\ ���������� ������� �������. �������� name, ������������ ��������. ����� name.
\ �������� ��������� ������� ����������, ������ ����, � �������� �����������.
\ �������������� �������� ���������, ���� name �� �������.
\ �������� ��������� ������� ����������, ������ ����, � �������� �����������,
\ ����� ����������: ( -- xt )
\ �������� ���������� ����� ����� xt �� ����. ���������� �����, ������������
\ ���������������� ������ "['] X" �������� ��� �� ���������, ��� � ������������
\ "' X" ��� ��������� ����������.
  ?COMP
  ' LIT,
; IMMEDIATE
