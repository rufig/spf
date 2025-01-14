( ���������� �������� ������� ��������.
  ��-����������� �����������.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  �������������� �� 16-���������� � 32-��������� ��� - 1995-96��
  ������� - �������� 1999
)

USER S0   \ ����� ��� ����� ������
USER R0   \ ����� ��� ����� ���������
USER STATE ( -- a-addr ) \ 94
     \ a-addr - ����� ������, ���������� ������ "��������� ����������".
     \ STATE "������" � ������ ����������, ����� "����".
     \ �������� STATE ������ ��������� ����������� �����:
     \ : ; [ ] ABORT QUIT :NONAME
USER BLK

VECT OK
VECT <MAIN>
VECT ?LITERAL
VECT ?SLITERAL

: DEPTH ( -- +n ) \ 94
\ +n - ����� ��������� �����, ����������� �� ����� ������ �����
\ ��� ��� ���� ���� �������� +n.
  SP@ S0 @ - NEGATE  1 CELLS /
\ �������� ����� ���� �������������, ������� '>CELLS' ������ '/' ������  
;
: ?STACK ( -> ) \ ������ ������ "���������� �����", ���� �� ����� ��� ����
  SP@ S0 @ SWAP U< IF S0 @ SP! -4 THROW THEN
;

: ?COMP ( -> )
  STATE @ 0= IF -312 THROW THEN ( ������ ��� ������ ���������� )
;

: WORD ( char "<chars>ccc<char>" -- c-addr ) \ 94
\ ���������� ������� �����������. ������� �������, ������������
\ ������������ char.
\ �������������� �������� ���������, ���� ����� ����������� ������
\ ������ ������������ ����� ������ �� ���������.
\ c-addr - ����� ���������� �������, ���������� ����������� �����
\ � ���� ������ �� ���������.
\ ���� ����������� ������� ����� ��� �������� ������ �����������,
\ �������������� ������ ����� ������� �����.
\ � ����� ������ ���������� ������, �� ���������� � ����� ������.
\ ��������� ����� �������� ������� � ������.
  DUP BL = IF DROP PARSE-NAME ELSE DUP SKIP PARSE THEN 255 UMIN
  DUP SYSTEM-PAD C! SYSTEM-PAD CHAR+ SWAP CMOVE
  0 SYSTEM-PAD COUNT CHARS + C!
  SYSTEM-PAD
;

: ' ( "<spaces>name" -- xt ) \ 94
\ ���������� ������� �������. �������� name, ������������ ��������. ����� name 
\ � ������� xt, ���������� ����� ��� name. �������������� �������� ���������, 
\ ���� name �� �������.
\ �� ����� �������������  ' name EXECUTE  �����������  name.
  PARSE-NAME
  NON-OPT-WL PUSH-ORDER  SFIND  DROP-ORDER
  \ NB: taking NON-OPT-WL into account violates the standard #todo
  0= IF -321 THROW THEN
;

: CHAR ( "<spaces>name" -- char ) \ 94
\ ���������� ������� �����������. �������� ���, ������������ ���������.
\ �������� ��� ��� ������� ������� �� ����.
  PARSE-NAME DROP C@
;

: BYE ( -- ) \ 94 TOOLS EXT
\ ������� ���������� ������������ �������, ���� ��� ����.
  0 
  HALT
;

: EVAL-WORD ( a u -- )
\ ���������������� ( �������������) ����� � ������  a u
    SFIND ?DUP    IF
    STATE @ =  IF 
    COMPILE,   ELSE 
    EXECUTE    THEN
                  ELSE
    -2003 THROW THEN
;

: NOTFOUND ( a u -- )
\ ��������� � ������ � �������� � ����  vocname1::wordname
\ ��� vocname1::vocname2::wordname � �.�.
\ ��� vocname1:: wordname
\ ����� wordname ������������� � ���������������� ��������� (!)

  2DUP 2>R ['] ?SLITERAL CATCH ?DUP IF NIP NIP 2R>
  2DUP S" ::" SEARCH 0= IF 2DROP 2DROP THROW  THEN \ ������ ���� :: ?
  2DROP ROT DROP
  GET-ORDER  N>R
                         BEGIN ( a u )
    2DUP S" ::" SEARCH   WHILE ( a1 u1 a3 u3 )
    2 -2 D+ ( ������� ����������� :: )  2>R
    R@ - 2 - SFIND              IF
    SP@ >R
    ALSO EXECUTE SP@ R> - 0=
    IF SET-ORDER-TOP THEN
                                ELSE  ( a1 u' )
    RDROP RDROP
    NR>  SET-ORDER
    -2011 THROW                 THEN
    2R>                  REPEAT
  NIP 0= IF 2DROP PARSE-NAME THEN
  ['] EVAL-WORD CATCH
  NR> SET-ORDER THROW
 ELSE RDROP RDROP THEN
;

: INTERPRET_ ( -> ) \ ���������������� ������� �����
  BEGIN
    PARSE-NAME DUP
  WHILE
    SFIND ?DUP
    IF
         STATE @ =
         IF COMPILE, ELSE EXECUTE THEN
    ELSE
         S" NOTFOUND" SFIND 
         IF EXECUTE
         ELSE 2DROP ?SLITERAL THEN
    THEN
    ?STACK
  REPEAT 2DROP
;

VARIABLE   &INTERPRET

' INTERPRET_ ' &INTERPRET TC-ADDR!

: INTERPRET &INTERPRET @ EXECUTE ;


: #(SIGNED) ( d1 -- d2 )
  [CHAR] ) HOLD DUP >R DABS #S R> SIGN [CHAR] ( HOLD
;

: .SN ( n --)
\ ����������� n ������� ��������� �����
   >R BEGIN
         R@
      WHILE
        SP@ R@ 1- CELLS + @ DUP 0< 
        IF DUP U>D (D.) TYPE <# S>D #(SIGNED) #> TYPE SPACE
        ELSE . THEN
        R> 1- >R
      REPEAT RDROP
;

: OK1
  STATE @ 0=
  IF
    DEPTH 6 U< IF
                 DEPTH IF ."  Ok ( " DEPTH .SN  ." )" CR
                       ELSE ."  Ok" CR
                       THEN
               ELSE ."  Ok ( [" DEPTH S>D (D.) TYPE ." ].. "
                    5 .SN ." )" CR
               THEN
  THEN
;

: [   \ 94 CORE
\ �������������: ��������� ������������.
\ ����������: ��������� ��������� ����������, ������ ����.
\ ����������: ( -- )
\ ���������� ��������� �������������. [ ����� ������������ ����������.
  STATE 0!
; IMMEDIATE


: ] ( -- ) \ 94 CORE
\ ���������� ��������� ����������.
  TRUE STATE !
;

: MAIN1 ( -- )
  BEGIN
    REFILL
  WHILE
    INTERPRET OK
  REPEAT BYE
;

: QUIT ( -- ) ( R: i*x ) \ CORE 94
\ �������� ���� ���������, �������� ���� � SOURCE-ID.
\ ���������� ����������� ������� ����� � ��������� �������������.
\ �� �������� ���������. ��������� ���������:
\ - ������� ������ �� �������� ������ �� ������� �����, �������� >IN
\   � ���������������.
\ - ������� ��������� �� ���������� ��������� �����������, ����
\   ������� ��������� � ��������� �������������, ��� �������� ���������,
\   � ��� ������������� ��������.
  BEGIN
    CONSOLE-HANDLES
    0 TO SOURCE-ID
    0 TO SOURCE-ID-XT
    ATIB 0 SOURCE! \ �� ������, ���� QUIT ������� �� EVALUATE
    \ SOURCE! ������������� ��� �� #TIB � >IN 
    \ � �����, ��� ���������� ������ ��� ��������� ��� ��������� � ����� ��������� �� �����
    [COMPILE] [
    ['] MAIN1 CATCH         DUP SOURCE NIP 2>R
    ['] ERROR CATCH DROP    2R> 0= IF HALT THEN DROP
    \ ������ ������� ����� ����� ������� � ���, ��� ���������� ���������
    \ ��� ��������� REFILL (� �� INTERPRET). ����� �������� ������������ �����,
    \ � ���� �������� �������� ���������� �������� � ����� ����������.
    \ testcase: H-STDIN CLOSE-FILE . CR
 (  R0 @ RP! \ ���� �� ����������, �.�. ��� �� ��� ������ CATCH :)
    S0 @ SP! \ ����    ����������, �.�. OPTIONS ����� �������� �������� :(
  AGAIN
;

: SAVE-SOURCE ( -- i*x i )
  SOURCE-ID-XT  SOURCE-ID   >IN @   SOURCE   CURSTR @   6
;

: RESTORE-SOURCE ( i*x i  -- )
  6 <> IF ABORT THEN
  CURSTR !    SOURCE!  >IN !  TO SOURCE-ID   TO SOURCE-ID-XT
;

: EVALUATE-WITH ( ( i*x c-addr u xt -- j*x )
\ ������ c-addr u ������� �������, ��������� � ��������������� xt.
  SAVE-SOURCE N>R 
  >R  SOURCE!  -1 TO SOURCE-ID
  R> ( ['] INTERPRET) CATCH
  NR> RESTORE-SOURCE
  THROW
;

: EVALUATE ( i*x c-addr u -- j*x ) \ 94
\ ��������� ������� ������������ �������� ������.
\ ���������� -1 � SOURCE-ID. ������ ������, �������� c-addr u,
\ ������� ������� � ������� �������, ������������� >IN � 0
\ � ��������������. ����� ������ ��������� �� ����� - ���������������
\ ������������ ����������� �������� ������.
\ ������ ��������� ����� ������������ ������������ �� EVALUATE �������.
  ['] INTERPRET EVALUATE-WITH
;


VECT PROCESS-ERR ( ior -- ior ) \ ���������� ������ ���������� (�����).

: PROCESS-ERR1 ( ior -- ior )  \ ��� �������� �� ior=0 ���� �����.
  DUP IF SEEN-ERR? IF DUP SAVE-ERR THEN THEN
;
' PROCESS-ERR1 ' PROCESS-ERR TC-VECT!

: RECEIVE-WITH-XT  ( i*x source source-xt xt -- j*x ior )
\ ��������� ������������ �������� ������
\ ���������� ������� ����� �� source, ����� ��� ������ ������ � source-xt
\ ��������� xt
\ ������������ ������������ �������� ������
  SAVE-SOURCE N>R
  C/L 2+ ALLOCATE THROW DUP >R  0 SOURCE!  CURSTR 0!
  SWAP TO SOURCE-ID-XT
  SWAP TO SOURCE-ID
  CATCH  DUP IF PROCESS-ERR ( err -- err ) THEN
  R> FREE THROW
  NR> RESTORE-SOURCE
;

: RECEIVE-WITH  ( i*x source xt -- j*x ior )
\ ��������� ������������ �������� ������
\ ���������� ������� ����� �� source, ��������� xt
\ ������������ ������������ �������� ������
  0 SWAP RECEIVE-WITH-XT
;

: HEAP-COPY ( addr u -- addr1 )
\ ����������� ������ � ��� � ������� � ����� � ����
  DUP 0< IF 8 THROW THEN
  DUP CHAR+ ALLOCATE THROW DUP >R
  SWAP DUP >R CHARS MOVE
  0 R> R@ + C! R>
;

VECT FIND-FULLNAME \ ����� ��������� ���� � ������� ��� � ������ �����

: FIND-FULLNAME1 ( a1 u1 -- a u )
  2DUP FILE-EXISTS IF EXIT THEN
  2DUP +LibraryDirName  2DUP FILE-EXISTS IF 2SWAP 2DROP EXIT THEN 2DROP
  2DUP +ModuleDirName   2DUP FILE-EXISTS IF 2SWAP 2DROP EXIT THEN 2DROP
  2 ( ERROR_FILE_NOT_FOUND ) THROW
;
' FIND-FULLNAME1 ' FIND-FULLNAME TC-VECT!


: SkipBomUtf8 ( -- )
  \ ���� �� �������� ����� ������� ���� UTF-8 BOM, �� ���������� ���,
  \ ������� >IN �� 3 �����; ����� ������ �� ��������.
  SOURCE  OVER >IN @ + >R  +  R> ( addr9 addr1 )
  TUCK 3 ( CHARS ) + U< IF DROP EXIT THEN
  ( addr1 )
  DUP C@ 0xEF = IF 1+ ( CHAR+ )
  DUP C@ 0xBB = IF 1+ ( CHAR+ )
  DUP C@ 0xBF = IF
    3 ( CHARS ) >IN +!
  THEN THEN THEN DROP
  \ CHARS �� ������������, �.�. � UTF-8 ������ ������� 8 ��� = address unit
;

: TranslateFlow ( -- )
  REFILL 0= IF EXIT THEN SkipBomUtf8 INTERPRET
  BEGIN REFILL WHILE INTERPRET REPEAT
;

: INCLUDE-FILE ( i*x fileid -- j*x ) \ 94 FILE
\ ������ fileid �� �����. ��������� ������� ������������ �������� ������,
\ ������� ������� �������� SOURCE-ID. �������� fileid � SOURCE-ID.
\ ������� ����, �������� fileid, ������� �������. �������� 0 � BLK.
\ ������ ��������� ����� ������������ ������� �� ����������� �����.
\ ��������� �� ����� �����: �������� ������ �� �����, ��������� �������
\ ����� ���������� ���� ������, ���������� >IN � ���� � ����������������.
\ ������������� ������ ���������� � �������, � ������� ������ �����������
\ ���������� ������ �����.
\ ����� ��������� ����� �����, ������� ���� � ������������ ������������
\ �������� ������ � �� ����������� ���������.
\ �������������� �������� ���������, ���� fileid �������, ���� ���������
\ �������������� �������� �����-������ �� ���� ������ fileid, ���
\ ��������� �������������� �������� ��� �������� �����. ����� �����
\ ����� �������������� ��������, ������ (������ ��� ������) �����
\ ���������������� ������ ������� �� ����������.
  BLK 0!
  DUP >R  
  ['] TranslateFlow RECEIVE-WITH
  R> CLOSE-FILE THROW
  THROW
;

: INCLUDE-PROBE ( addr u -- ... 0 | ior )
  R/O OPEN-FILE-SHARED ?DUP
  IF NIP EXIT THEN
  INCLUDE-FILE 0
;

VECT (INCLUDED)

: (INCLUDED1) ( i*x a u -- j*x )
  R/O OPEN-FILE-SHARED THROW
  INCLUDE-FILE
;
' (INCLUDED1) ' (INCLUDED) TC-VECT!

USER INCLUDE-DEPTH

: INCLUDED_STD ( i*x c-addr u -- j*x )
  CURFILE @ >R
  2DUP HEAP-COPY CURFILE !
  
  INCLUDE-DEPTH 1+!
  INCLUDE-DEPTH @ 64 > IF -27 THROW THEN
  ['] (INCLUDED) CATCH
  INCLUDE-DEPTH @ 1- 0 MAX 
  INCLUDE-DEPTH !
  
  CURFILE @ FREE THROW
  R> CURFILE !
  THROW
;

: INCLUDED ( i*x c-addr u -- j*x ) \ 94 FILE
\ ������ c-addr u �� �����. ��������� ������� ������������ �������� ������,
\ ������� ������� �������� SOURCE-ID. ������� ����, �������� c-addr u,
\ �������� ���������� fileid � SOURCE-ID � ������� ��� ������� �������.
\ �������� 0 � BLK.
\ ������ ��������� ����� ������������ ������� �� ����������� �����.
\ ��������� �� ����� �����: �������� ������ �� �����, ��������� �������
\ ����� ���������� ���� ������, ���������� >IN � ���� � ����������������.
\ ������������� ������ ���������� � �������, � ������� ������ �����������
\ ���������� ������ �����.
\ ����� ��������� ����� �����, ������� ���� � ������������ ������������
\ �������� ������ � �� ����������� ���������.
\ �������������� �������� ���������, ���� fileid �������, ���� ���������
\ �������������� �������� �����-������ �� ���� ������ fileid, ���
\ ��������� �������������� �������� ��� �������� �����. ����� �����
\ ����� �������������� ��������, ������ (������ ��� ������) �����
\ ���������������� ������ ������� �� ����������.
  FIND-FULLNAME INCLUDED_STD
;
: REQUIRED ( waddr wu laddr lu -- )
  2SWAP SFIND
  IF DROP 2DROP
  ELSE 2DROP INCLUDED THEN
;
: REQUIRE ( "word" "libpath" -- )
  PARSE-NAME PARSE-NAME 2DUP + 0 SWAP C!
  REQUIRED
;
: INCLUDED-EXISTING ( i*x  a u -- j*x true | i*x  a u  false )
  2DUP FILE-EXISTS IF INCLUDED TRUE ELSE FALSE THEN
;
