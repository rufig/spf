( ���������� ����� "����-����������" � ���� ��������������� �����������.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  �������������� �� 16-���������� � 32-��������� ��� - 1995-96��
  ������� - �������� 1999
)

0 CONSTANT FALSE ( -- false ) \ 94 CORE EXT
\ ������� ���� "����".

-1 CONSTANT TRUE ( -- true ) \ 94 CORE EXT
\ ������� ���� "������", ������ �� ����� �������������� ������.

4 CONSTANT CELL

: */ ( n1 n2 n3 -- n4 ) \ 94
\ �������� n1 �� n2, �������� ������������� ������� ��������� d.
\ ��������� d �� n3, �������� ������� n4.
  */MOD NIP
;
: CHAR+ ( c-addr1 -- c-addr2 ) \ 94
\ ��������� ������ ������� � c-addr1 � �������� c-addr2.
  1+
;
: CHAR- ( c-addr1 -- c-addr2 ) \ 94
\ ������� ������ ������� �� c-addr1 � �������� c-addr2.
  1-
;
: CHARS ( n1 -- n2 ) \ 94
\ n2 - ������ n1 ��������.
; IMMEDIATE

: >CHARS ( n1 -- n2 ) \ "to-chars"
\ n2 - ����� �������� � n1
; IMMEDIATE

: >CELLS ( n1 -- n2 ) \ "to-cells" [http://forth.sourceforge.net/word/to-cells/index.html]
\ Convert n1, the number of bytes, to n2, the corresponding number
\ of cells. If n1 does not correspond to a whole number of cells, the
\ rounding direction is system-defined.
  2 RSHIFT
;

: MOVE ( addr1 addr2 u -- ) \ 94
\ ���� u ������ ����, ���������� ���������� u ���� �� addr1 � addr2.
\ ����� MOVE � u ������ �� ������ addr2 ���������� � �������� �� ��,
\ ��� ���� � u ������ �� ������ addr1 �� �����������.
  >R 2DUP SWAP R@ + U< \ ���������� �������� � �������� ��������� ��� �����
  IF 2DUP U<           \ � �� �����
     IF R> CMOVE> ELSE R> CMOVE THEN
  ELSE R> CMOVE THEN
;
: ERASE ( addr u -- ) \ 94 CORE EXT
\ ���� u ������ ����, �������� ��� ���� ������� �� u ���� ������,
\ ������� � ������ addr.
  0 FILL
;

: CZMOVE ( a # z --) 2DUP + >R SWAP CMOVE R> 0 SWAP C! ;

: DABS ( d -- ud ) \ 94 DOUBLE
\ ud ���������� �������� d.
  DUP 0< IF DNEGATE THEN
;

: HASH ( addr u u1 -- u2 )
   2166136261 2SWAP
   OVER + SWAP 
   ?DO
      16777619 * I C@ XOR
   LOOP
   SWAP ?DUP IF UMOD THEN   
;


HEX

CREATE LT 0A0D , \ line terminator
CREATE LTL 2 ,   \ line terminator length

: DOS-LINES ( -- )
  0A0D LT ! 2 LTL !
;
: UNIX-LINES ( -- )
  0A0A LT ! 1 LTL !
;

DECIMAL

\ ����������� �����
: EOLN ( -- a u ) LT LTL @ ;

UNIX-ENVIRONMENT [IF]
: NATIVE-LINES UNIX-LINES ;
[ELSE]
: NATIVE-LINES DOS-LINES ;
[THEN]

