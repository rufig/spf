\ �������������� ������������ ���������, ����. 
\ 14-10-2006 written by mOleg for SPF4.17 
\ -- �����, ������� �� ������� � ��� 

\ �� �� ��� � : ������ ��� �������� �� ������� ����� ������ � ���� ������ 
\ �� ���������:   S" name" S: ��� ����� ; 
: S: ( asc # --> ) SHEADER ] HIDE ; 

\ ����� ��������� ������� �� ��� ���, ���� �� ����� ������ 
\ � ������ ��������� ������ ���������� 0 0 ������ ������ � �� ������ 
\ �������� ���� ����� �� ����32. 
: iNextWord ( --> asc # ) 
            NextWord 

            DUP IF EXIT ELSE 2DROP THEN 

            REFILL IF RECURSE   \ ����� ����� ���� �� ������ NextWord 
                    ELSE 0 0 
                   THEN ; 

\ ��� ����� ����� ��� � ��� 
: IS POSTPONE TO ; IMMEDIATE 

\ --------------------------------------------------------------------------- 

\ ��� ����� ����� ������������ ������ � ��������� ������� 
VOCABULARY tests 
           ALSO tests DEFINITIONS 

\ ������������ ���� ���� ��������� ������ ��������� ����� ������������ 
USER-VECT is-delimiter 
USER-VECT action 

\ �������� ���� 
: process ( --> ) 
          BEGIN iNextWord DUP WHILE 
                2DUP is-delimiter WHILE 
               action 
           REPEAT 2DROP EXIT 
          THEN CR ." test section not finished" CR ABORT ; 

\ ����� ������� ������ ����������, �� ��� �������, ����� ������������ 
\ ������������� � ��� ������, ���� � ������� ������� ������� ����� testing 
: ?testing ( --> flag ) 
      S" testing" GET-CURRENT SEARCH-WORDLIST 
      IF DROP TRUE 
       ELSE FALSE 
      THEN ; 

\ --------------------------------------------------------------------------- 

\ ���, ������� ���������� �������� ������ 
: test-delimiter  ( --> asc # ) S" ;test" ; 

\ ��� �������, ��� ������ ��� ������ � �������� ������������ ����� SFIND 
: is-test-delimiter ( asc # --> false|nfalse ) test-delimiter COMPARE ; 

\ � ��� ������ ������������ 8) 
: work-delimiter    ( --> asc # ) S" ;work" ; 
: is-work-delimiter ( asc # --> false|nfalse ) work-delimiter COMPARE ; 

\ --------------------------------------------------------------------------- 

        PREVIOUS DEFINITIONS 
                 ALSO tests 

\ �� ����� ������������ ���� ����� ����� �������������� ���������������� 
\ ��� ������������. 
\ ����� ������������ ������ �����������! 
: test: ?testing IF    ['] EVAL-WORD IS action 
                  ELSE ['] 2DROP IS action 
                 THEN 
        ['] is-test-delimiter IS is-delimiter 
        process ; IMMEDIATE 

\ ���� ������������ �������� �� ������� ������, �� ������ �� �����-�� 
\ �������� ��������� ������ ������ ������������ 
test-delimiter S: CR ." testing delimiters unpaired!" ABORT ; IMMEDIATE 

\ �������� �������� �������� ������������, �� ���� �� ����� ������������ 
\ ������ ������ ����������� �� �����! �� � ������ ����� �����. 
: work: ?testing IF    ['] 2DROP IS action 
                  ELSE ['] EVAL-WORD IS action 
                 THEN 
        ['] is-work-delimiter IS is-delimiter 
        process ; IMMEDIATE 

work-delimiter S: CR ." working delimiters unpaired!" ABORT ; IMMEDIATE 

        PREVIOUS 

\EOF                     ��� ���� ��� ���� 

        � ��������� � ������ ����������� ��������� ��� ��� �������������� 
 �������� �� �����������������. ����� ������� ����� ������������� ��������� 
 ����������������� ���� ���������, �������� � ����������� ����, �� � ������ 
 ����. �������������� �������� �������� ������, ������� ����� ���������� 
 ��� ���� � .\devel\~??? � ������������� �� ����������. ������ �� ���� ����� 
 ������� 8). � ���� �� ������ ������ ����� ������������ ��� �������������� 
 ��������� ������ ����, ��������� ����������. 
 �� � ����� ������ ���������� ����� �����. 

        ����� � ������� ����� ����������� ������������, � ��� �� ��������� 
 ���������� state �� ������ �� ����������������� ��������. �� ���� ����� 
 ��������� ���� t�st: ;t�st � ������ �����������, � ����� ������������ 
 �������� ��� ������ � ������ �������������. �������� ��� t�st: ;t�st �� 
 ����������������� ��� ��� � ������� �� ����32 � ���� ��� �������� immediatest, 
 �� ���� t�st w�rk ����� ������������ � ���� ���������� ���� � �����.