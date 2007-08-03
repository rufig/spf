\ ��������/����� ��� "�����������" ����������:
\ ������ ����������� ���� � ������������ ������ 
\ ���������, ����������� ����. ��� "����������"
\ ������� ���������� �������� LITERAL � ����:
\ S" LITERAL LITERAL + LITERAL *" axt=>
\ �� ���� ����� ���� ������������������ ���� �� �����
\ 10 3 5 �� ������ �������� �� ������ xt ���������
\ � ����� "10 3 + 5 *"

REQUIRE correct-jumps ~profit/misc/movecode2.f
REQUIRE CREATE-VC ~profit/lib/compile2Heap.f

\ ������ ��� ���������� �������������� �����������
\ ������ ������� �� ��� ������ ������ � ��� ������� �����������
\ ����� ������ ��� ��� ���� � ��� ����� ������

VARIABLE n1
VARIABLE n2
VARIABLE n3

OPT? DIS-OPT \ ��������� ����������� -- �������� �� �����

: expr [ HERE ] 0 [ HERE ] 0 + [ HERE ] 0 * ; \ ����������� ���������
\ ����������� ����� �������� HERE

\ �� ����������������� ������������:
' expr - 4 + n3 !
' expr - 4 + n2 !
' expr - 4 + n1 !

TO OPT?

\ SEE expr

: }expr{ ( n1 n2 n3 -- xt ) HERE >R
['] expr COPY-CODE RET,
R@ n3 @ + !
R@ n2 @ + !
R@ n1 @ + !
R> ;

1 2 3 }expr{ REST

\ ���, ��������. ������ �� �������� ��� ������ �������� �� ����� run-time
\ �������� ������������ � compile-time, ����� ������� ������������ �������
\ ������� ��������?..

64334 CONSTANT dumm4 \ ���������-������������ �������������� �����������

: dummy ( -- ) ?COMP
OPT? DIS-OPT \ ��������� �����������: ����� ��������� ��������, ����� ���� ��� ��������
CREATE-VC    \ ������ ����������� �������� ���� ����� ������ �������� �� ����������� ������ � ��������
0 BRANCH, >MARK \ ������� �� ������ �����
HERE -ROT \ ������� ���� ����� �������� �����
dumm4 ; IMMEDIATE

\ �� CS-����� � compile-time �������������� ����� ������������������:
\ ... opt here vc source dumm4 ... 

: l ?COMP DEPTH 1- 0 DO \ ���� �� ����� CS-�����, ����� ��������� ����������� � ������ ���������
I PICK dumm4 = IF \ ����� ������� dumm4
I 4 + PICK TO OPT? \ ����������� �������� OPT?
I 2 + PICK DUP HERE 4 + SWAP VC-LIT,
['] ! SWAP VC-COMPILE,
DIS-OPT
0 LIT,
UNLOOP EXIT THEN LOOP
-2007 THROW \ ���� dumm4 �� �����, �� �������� ������ ����������
; IMMEDIATE

: end ( --) ?COMP
dumm4 <> IF -2007 THROW THEN
RET, >RESOLVE1
DUP XT-VC \ ������ ���� � vc
OVER START{ VC- HERE }EMERGE \ ������� HERE � vc
( vc-xt vc-here ) COPY-CODE-END \ ��� �� ���������� �� �� ��� vc �� �������� � ��� ������ ���� ������
\ TODO: ���������� ��� �� _����_ �������� vc � ������� ��������
DESTROY-VC \ DROP
[COMPILE] LITERAL
TO OPT? ; IMMEDIATE

: r dummy l l + end ;
SEE r
3 10 r REST

\ ���� ��� �� �������� ����������� dummy ... l  ... end
\ ������� ��������� ��� �������� ��� ��������� ����� dummy � end
\ ��� ���� ������ l ������������ � ����� ������ �� ����� � run-time
\ ����������� ���� ���, �� ���� ���������� ������ ������ � ����� �
\ ��� �� ������� ����



\ � ������ ��� ����� ����������� ��������� ����� ��� �����������:

\ ������ ������ ������� ���������� �������� �� CS-����� (��� �����
\ ������������� ��������� � �������� ������ -- "}template" ):
\ ... vc here opt source dumm4 ...

: template{ ( -- ) ?COMP
CREATE-VC    \ ������ ����������� �������� ���� ����� ������ �������� �� ����������� ������ � ��������
OPT? DIS-OPT \ ��������� �����������: ����� ��������� ��������, ����� ���� ��� ��������
0 BRANCH, >MARK \ ������� �� ������ �����
HERE -ROT \ ������� ���� ����� �������� �����
dumm4 ; IMMEDIATE


: }{ ?COMP DEPTH 1- 0 DO \ ���� �� ����� CS-�����, ����� ��������� ����������� � ������ ���������
I PICK dumm4 = IF \ ����� ������� dumm4
I 4 + PICK \ ������������� vc ���������
HERE \ ����� ������ ��� ����� �������� ������� � ����������� ���� (������ ��� �� ����� HERE � �� HERE+4 ???)
I 3 + PICK - \ ��������� �������� �� ������ ������������ ����
I 2 + PICK TO OPT? \ ����������� �������� OPT?
OVER VC-LIT, \ ���������� ���
['] R@ OVER VC-COMPILE,
['] + OVER VC-COMPILE,
['] ! SWAP VC-COMPILE,
DIS-OPT
0 LIT, \ ������ �������
UNLOOP EXIT THEN LOOP
-2007 THROW \ ���� dumm4 �� �����, �� �������� ������ ����������
; IMMEDIATE

: }template ( --) ?COMP
dumm4 <> IF -2007 THROW THEN
RET, >RESOLVE1 \ ��������� ���-"��������"
TO OPT? \ ������ ����������� ��� ����
HERE SWAP ( ... end begin )
2DUP - LIT, \ �������������� ����� -- ����� ���������
POSTPONE ALLOCATE POSTPONE THROW POSTPONE >R \ ����������� �������� �������� �� ���� ����� ��� ���
DUP LIT,
POSTPONE R@
2DUP - LIT,
POSTPONE CMOVE \ ��������� ��� �� ��������� � ����
LIT, LIT,
POSTPONE R@ POSTPONE correct-jumps \ ���������� ���. ������� ���������

\ ������ ���������������� � vc �������� ����������� �������� � "������"
DUP XT-VC \ ������ ���� � vc
OVER START{ VC- HERE }EMERGE \ ������� HERE � vc
( ... vc-xt vc-here )
2DUP <> IF COPY-CODE-END \ ��� �� ���������� �� �� ��� vc �� �������� � ��� ������ ���� ������ 
ELSE 2DROP THEN 
\ TODO: ���������� ��� �� _����_ �������� vc � ������� ��������
DESTROY-VC \ DROP
POSTPONE R>
; IMMEDIATE

: r2 template{ }{ }{ * }template EXECUTE ;
' r2 HERE REST-AREA

12 10 r2 \ ��� �� ����� ������� � ���� ������ ����������� ��� �����, �� � ���� ������...