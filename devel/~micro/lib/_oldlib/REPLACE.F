\ �������� ������ ����������� ��� ��� ���������������� ���� � ������������
\ ������ ������� �����������. ������ ��� ����, � ������� ������ ������� CALL.
\ ������� ��������: ������ ������� CALL <�����1> ���������� ��
\ JMP <�����_�����������>. ��� ������ ������� ����������� ������������
\ �������������� ������ �������.

0 VALUE INHERITED-1STCALL
\ ����� ������� CALL-�. ��������, � �� �����, �. �. � ��� ����, � ����� �� ����.
0 VALUE INHERITED-XT
\ xt ����������� �����
0 VALUE NEW-XT
\ xt ������ �����������

: (INHERITED) ( inh_xt inh_1stcall -- )
\ ����� ������� �����������
\ inh-xt - ��� xt
\ inh-1stcall - ��� ������ CALL
  OVER 1+ @ >R
\ ��������� ����� ������� ����� � ������ �����������
  OVER 0xE8 SWAP C!
\ ������������ CALL
  OVER 1+ !
\ ������������ �����
  DUP >R CATCH
\ ��������� xt ����� � ���������
  0xE9 R@ C!
\ JMP ...
  R> R> SWAP 1+ !
\ ����� �� ����� �����������
  THROW
\ �����, ������ ����? ����� ������������.
;

: INHERITED
\ ����������� ����� ������� �����������
  INHERITED-XT POSTPONE LITERAL
  INHERITED-1STCALL POSTPONE LITERAL
  POSTPONE (INHERITED)
; IMMEDIATE

: _; POSTPONE ; ; IMMEDIATE
VECT ; IMMEDIATE
' _; TO ;

: REPLACE;
\ ��������� ������������� �����������.
  ['] _; TO ;
  POSTPONE ;
\ ���, ��������, �� �������.
  INHERITED-XT
  LATEST-NAME-XT \ old new
  OVER - 5 - SWAP 1+ !
\ ������ ������ �� �����. ���� �������� ������ �� ����� ����������, ���
\ ������ ���������������� ����� ����� ������� �� ����� ���������� ������
\ �����������, ������ ��������� �� ���������. ��� ����� ������ ������ �����,
\ � �� � ������ ����������.
  0xE9 INHERITED-XT C!
\ ��������� JMP ������ CALL
; IMMEDIATE

: REPLACE:
\ �������� ������ �����������
\ REPLACE: Name [<words>] [INHERITED] [<words>] ;
  >IN @ >R
  NextWord SFIND IF
    DUP C@ 0xE8 <>
    ABORT" Bad word to REPLACE:"
    DUP TO INHERITED-XT
    1+ @ TO INHERITED-1STCALL
\ ��������� ��� �� ����� ���������� - ����� ����������� ��� INHERITED ���
\ ��� ����-������ ���.
    R> >IN !
    :
    HERE TO NEW-XT
    ['] REPLACE; TO ;
  ELSE
    RDROP
    1 ABORT" No word to REPLACE:"
  THEN
;

\ ������:
\ > REPLACE: . DUP INHERITED INHERITED ;
\ > 1 .
\   1 1  Ok
