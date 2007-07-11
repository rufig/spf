\ REQUIRE ���� ~profit/lib/stacks.f
REQUIRE U.R lib/include/core-ext.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE ON lib/ext/onoff.f
REQUIRE ������ ~profit/lib/collectors.f

\ �������, ����������� ����� ��������. ����� "���������" ������
\ ���� ��������� ����� �������� � 256-� ��������, ��� ������ �����
\ -- ������� �� ���� � ������� �������. �������� ����� ��������
\ � ���� � ������������ �������� � ������ ���������. ��� �����
\ �������� � ��������� ����� ���� ��������� �����-������ �������� ("��-�����:")
\ ����� ��������� �������, ����� ����������-������, ��������� �����-������ ���
\ ��������� ���������, � ������ ����� ��������� ������ "-��������-����������" �
\ ���-��� �������� �� ����� (��. ����� �������-������� � �������).
\ �������� ��� ���������� �������� ������ ����������������.

\ ����� ����, ������������ ����� ����� "�������" ��������� ������ ����
\ ���������, �� � ������������ ���-� �������. ��� ������ ������������
\ ��� ������ CASE.

MODULE: chartable

USER-VALUE �������-���������
USER-VALUE �������-���������

USER /������

EXPORT

: ������ ( -- c ) /������ @ ; \ ����� ������� ������

' NOOP CONSTANT ��������

DEFINITIONS

: ���-��-������� ( -- n ) �������-��������� CELL - @ ;

 \ n -- ����� �������, addr -- �����. ��� ������ � ���������
: �����-������� ( n -- addr ) CELLS �������-��������� + ;
\ : �����-������� ( n -- addr ) ���-��-������� MIN (�����-�������) ;

: -�-������ ( xt c -- ) �����-������� ! ;
: ����������-�������� ( xt start end  -- ) 1+ SWAP DO DUP I -�-������ LOOP DROP ;
: ���-������� ( xt -- ) 0 ���-��-������� 1+ ����������-�������� ;
: ��������-���-������� ( -- )  �������� ���-������� ;

0 VALUE ���������-�������
0 VALUE �������������-�������
: :n ( "name" -- xt ) ���������-������� TO �������������-�������  :NONAME  DUP TO ���������-������� ;

EXPORT

: ������:  ( "z" -- ) :n CHAR -�-������ ;
: ���������: ( n -- ) :n SWAP -�-������ ;
: asc: ( n -- ) ���������: ;

: ���: ( -- ) :n  ���-������� ;
: ��������: ( a b -- ) :n -ROT ����������-�������� ;

: ������: ( -- ) :n BL -�-������ ;
: �������-������: ( -- ) �������� 13 -�-������  :n 10 -�-������ ;
: �����������: ( -- ) :n 0 32 ����������-�������� ;
: �����: ( -- ) [CHAR] 0 [CHAR] 9 ��������: ;

: ���������-�����: ( -- ) [CHAR] a [CHAR] z ��������:
���������-������� [CHAR] A [CHAR] Z ����������-�������� ;

: all-asc: ( addr u -- ) :n -ROT OVER + SWAP DO DUP I C@ -�-������ LOOP DROP 	;

: �������: ( "ABCZ" -- ) ParseWord all-asc: ;

: ����-����� ( -- ) �������������-������� COMPILE, ; IMMEDIATE

USER-VALUE ������

DEFINITIONS

: ������ ( �����-������� -- addr )
DUP , \ ���-�� �������
HERE TO �������-���������
1+ 0 DO �������� , LOOP
�������� , \ �������� ��-���������, ��� ������� ������ ������� ��������� ���-�� ���������
;

: �����-������-��-����� ���-��-������� 1+ 1 + ;
: �����-������-���������-������ ���-��-������� 1+ 2 + ;

EXPORT

: ������� ( �����-������� "���" -- )
CREATE ������
DOES> DUP @ 1+ ROT DUP TO ������ MIN 1+ CELLS + @ EXECUTE ;

: ��������� ( -- )
CREATE 256 ������
�������� , \ �������� �� �����
�������� , \ ������� �� ��������� ���������� ������
DOES> CELL+ TO �������-���������
�����-������-��-����� �����-������� @ EXECUTE ;

: ��-�����: ( -- ) :n �����-������-��-����� �����-������� ! ;
: ������-���������: ( -- ) :n �����-������-���������-������ �����-������� ! ;

VECT ����������-�������-�������

: ���-���-������� ( -- xt ) ������ ���-��-������� 1+ MIN �����-������� @ ;
: ���������-������   ����������-�������-������� ���-���-������� EXECUTE ;

: ���������-����-��� ( c -- ) /������ ! ���������-������ ;
: ���������-��������� �����-������-���������-������ �����-������� @ EXECUTE ;

: �����-��-������� ( "tbl -- )
��������-���-�������
' >BODY DUP @ ���-��-������� MIN CELLS
SWAP CELL+ SWAP �������-��������� SWAP MOVE ;
\ �������� ������� ������� tbl � �������
\ ��������: ������� "��-�����" � "���������-��������-������" �� ����������!


5 ������� �����-����� ( -- c )
���: TRUE ABORT" �������� ������ �������!" ;
1 ���������: C@ ;
2 ���������: W@ ;
3 ���������: @ 0xFFFFFF AND ;
4 ���������: @ ;

VARIABLE ������-�-������
: ������ ( -- addr ) ������-�-������ @ ;
: ����������-����� ( -- ) ������-������� ������-�-������ +! ;
: ����-����� ( -- c ) ������ ������-������� �����-�����  ����������-����� ;
: �������-����� ( -- ) ������-������� NEGATE ������-�-������ +! ;
: ���������-������ ( ����� -- ) ������-�-������ ! ;

:NONAME CR ������ EMIT ."  | " ������ 10 U.R ."  | " �������-��������� WordByAddr TYPE ; CONSTANT �������-��������
: ��������-�������-��������  �������-�������� TO ����������-�������-������� ;
: ���������-�������-��������  NOOP TO ����������-�������-������� ;

VARIABLE ����������-���������
: ������������-��-������� ( -- )
����������-��������� ON
BEGIN ����������-��������� @  WHILE
����-����� ���������-����-��� REPEAT
���������-��������� ;

: ����������-�������  ( -- ) ������ 1- TO �������-��������� ;

: ��������� ( end -- )
����������-��������� ON
TO �������-���������          BEGIN
������ �������-��������� U<
����������-��������� @        AND WHILE
����-����� ���������-����-��� REPEAT
���������-��������� ;

: -��������-���������� ( n -- ) ?DUP IF ������ + ��������� THEN ;
\ ������� ����� �������� ���������� ������� �� ��������
\ ����� ����, ����� �������� �� ��������� ����� ���������� �
\ ����������-��������� OFF

\ �������� �� ��������
: state ��������� ;
: symbol: ������: ;
: all: ���: ;
: symbol ������ ;
: rollback1 �������-����� ;
: on-enter: ��-�����: ;
: current-state chartable::�������-��������� ;
: current-state! chartable::TO �������-��������� ;
: execute-one ���������-����-��� ;
: state-table ������� ;
: range: ��������: ;
: end-input: ������-���������: ;
: input-position ������ ;
: signal ������ ;

;MODULE

/TEST

REQUIRE ENUM ~nn/lib/enum.f

0
ENUM I`
ENUM II
ENUM III
ENUM IV-IX
DROP


9 ������� nine
���: IV-IX ; 
1 ���������: I` ;
2 ���������: II ;
3 ���������: III ;


REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES state-table correctness

(( 1 nine -> I` ))
(( 2 nine -> II ))
(( 3 nine -> III ))
(( 4 nine -> IV-IX ))
(( 100 nine -> IV-IX ))
(( 0 nine -> IV-IX ))

END-TESTCASES

0
ENUM unknown`
ENUM delimiter
ENUM space`
ENUM unknown
ENUM cr`
ENUM digit`
ENUM letter
DROP

256 ������� char-groups \ ������� ������������ �������� 
���: unknown` ; 
�����������: delimiter ;
������:  space` ;
�������-������: cr` ;
CHAR 0 CHAR 9 ��������: digit` ;
CHAR a CHAR z ��������: letter ;
CHAR A CHAR Z ��������: ����-����� ;
CHAR � CHAR � ��������: ����-����� ;
CHAR � CHAR � ��������: ����-����� ;


TESTCASES ranges state-table correctness

(( CHAR 2 char-groups -> digit` ))
(( CHAR � char-groups -> letter ))
(( BL char-groups -> space` ))
(( 10000 char-groups -> unknown` ))
(( 10 char-groups -> cr` ))
\ (( 13 char-groups -> cr` )) \ ���� ������������� �������� � �������-������ -- ���� ��� ��� �������?
END-TESTCASES

VARIABLE �������

��������� ��-������� 
��������� ���������� 
��������� �������� 

��-�������
������: | ��-������� ;
������: +  ���������� ;
������: -  �������� ; 

����������
�����-��-������� ��-������� \ �������� ����������� |+-
�����:  ������� 1+! ;

��������
�����-��-������� ��-�������
�����:  -1 ������� +! ;

: �������-������� ( a u � ) 
1 TO ������-������� SWAP ���������-������ 
��-������� -��������-���������� ;

\ ��������-�������-��������
: ���������� ( addr u -- n ) ������� 0!  �������-�������  ������� @ ;

TESTCASES fsa text scanner
(( S" 1234567890" ���������� -> 0 )) \ =10*0 , ���������� ��������� �����������, ������� ������ �� ���������
(( S" 12+345|67890" ���������� -> 3 )) \ =2*0+3*1+5*0
(( S" 12+345-67|90" ���������� -> 1 )) \ =2*0+3*1+2*(-1)+2*0
(( S" +12+345-6|790" ���������� -> 4 )) \ =2*1+3*1+1*(-1)+3*0
(( S" -12345+6790" ���������� -> -1 )) \ =5*(-1)+4*1
END-TESTCASES

0
ENUM all
ENUM enter
ENUM end
ENUM lastVal
DROP

300 state-table corner-values
all: all ;
300 asc: lastVal ;

TESTCASES state-table corner cases
(( 200 corner-values -> all ))
(( 260 corner-values -> all ))
(( 300 corner-values -> lastVal ))
(( 1000 corner-values -> all ))
END-TESTCASES


state corner-fsa
on-enter: enter ;
end-input: end ;
all: all ;
255 asc: lastVal ;
256 asc: lastVal ;


TESTCASES fsa state corner cases
(( corner-fsa -> enter ))
(( 1 execute-one -> all ))
(( 1000 execute-one -> all ))
(( 255 execute-one -> lastVal ))
(( 256 execute-one -> lastVal ))
(( ���������-��������� -> end ))
END-TESTCASES

state template2copy
on-enter: enter ;
end-input: end ;
10 asc: 10 ;

��������� new-state �����-��-������� template2copy

TESTCASES fsa state copying
(( template2copy -> enter ))
(( ���������-��������� -> end ))
(( new-state -> )) \ �����-��-������� �� ������ ���������� ������� ��-�����
(( 1 execute-one -> )) 
(( 10 execute-one -> 10 )) \ � ������� ������� -- ������
(( ���������-��������� -> )) \ ������� �� ��������� ������ ���������� ���� ������
END-TESTCASES