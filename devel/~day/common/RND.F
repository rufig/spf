\ �������� � ������� ��������� ��������������� ������������������ �����.
\ ��������: � ���������� ������ CHOOSE �� ��������!!!

\ ������ �. �. 24.01.99 nsoft@chat.ru
\ ��� ��-���� 3.15

(  � �������� ����� ����������� � ������������, �� ����� ����������� ��.
�������: ������ ��������� ����������� � ����� ����������,
� ������ � ��� �������� � ������� ������� ����������, � ������� 
������� �����������.
������� �� ����� ������� � ���� ������-��������� �����.
����� ������� �������� �������� ��� �� ����� � ������� 1-�� 
����������.
������ 5 �����, �� ��� �� ����� :)


WINAPI: GetTickCount KERNEL32.DLL

VARIABLE RND


: RANDOMIZE GetTickCount RND ! ;
RANDOMIZE

: RANDOM  ( -- u )                          
    RND @ 69069 * 31415 + 278720333 MOD DUP RND ! ;


\ ��������������� �������� �� 0 �� u1-1
: CHOOSE  ( u1 -- u2 )                      
   278720333 SWAP U/ 
   RANDOM ABS SWAP U/
;
    
(
CREATE TestTable HERE 10 4 * ALLOT 40  ERASE

\ �������� `�����������`
\ - ������ �������� - ������� ����� ��������� ����� �� ���������
\ - ���� ����� �������� ���������������, �� ���� �����������������
\ tt ���� ������ ���������� � 2%

: tt 3000000 0 DO 10 CHOOSE 4 * TestTable + 1+! LOOP
  10 0 DO TestTable I 4 * + @ . CR LOOP ;


\ ���� CHOOSE
VARIABLE NN0
VARIABLE NN1

\ SPEED TEST
: RTEST2
     GET-SEC
     1000000 0 DO 2 CHOOSE DROP LOOP 
     GET-SEC SWAP - 1000000 SWAP / . ." per sec"
; 
)

\EOF

CREATE asd 4 ALLOT

: test
  S" data.rnd" W/O CREATE-FILE THROW DUP .
  1024 DUP * 30 * 0
  DO
   RANDOM 8 RSHIFT 0xFFFF AND
   I 1 AND 0= IF asd W!
              ELSE asd 2+ W!
                   DUP asd 4 ROT WRITE-FILE THROW
              THEN
   I 1000000 MOD 0= IF 1 . RANDOMIZE THEN
  LOOP
  CLOSE-FILE THROW
;

test