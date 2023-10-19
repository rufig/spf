\ 03.Feb.2007 ruv
\ $Id$
( �������� ��������������:

    -- ������ ������ /� ������� ������/
    HERE ALLOT , C, S, 
    SXZ, SCZ,
    CARBON

    -- ������ ���� /� ������� ���� � � ������� ������ ��� �������������/
    EXEC, LIT, 2LIT, SLIT,
    CONCEIVE GERM BIRTH IT

    -- ������������ ����, ������������ ������� ����������
    BFW, ZBFW, RFW MBW BBW, ZBBW, BFW2, ZBFW2,
    \ abbr. from -- Branch, ZeroBranch, ForWard, BackWard, Mark, Resolve.
    \ ����������� ���������� ���� ����������� ����.

    -- �������� ������������� �������� ���� � ������ � ����������� �� ����������.


 'S,' -- ���������� ������ ��������� ��� ���� ������ /������� � �������� ������/ � ������ ������.
 'SLIT,' -- ����� �� �������������, �� ��������� ������, � ���� ����������� [c-addr u] ��� ����������;
          �������� ������� x0 � ����� ����� ������ ��� ��������, ���� ��� ������ /����� API ����-������� ������� Z-������/.
 'EXEC,' -- ����������� ���������� ���������, �������������� ������� xt.
 'EXIT,' -- ����������� ����� �� �����.

  GERM [ -- xt ] ���� ����� ������������ ����.
  ���� CONCEIVE [ -- ]  BIRTH [ -- xt ] ��������� � ��������������� ���������� GERM
    � ������� ��������������� �� ������������ ����� CS.
  IT   [ -- xt ] ���� ����� ��������� �����, ��������� �������������.


  C���� '&' [ c-addr u -- xt ]  -- ����������� ������� ' [tick]
  /������, ��� � ������������� ����� ����� ���������/.
)


REQUIRE lexicon.basics-aligned ~pinka/lib/ext/basics.f
REQUIRE Require   ~pinka/lib/ext/requ.f

: SXZ, ( a u -- ) DUP  , S, 0 C, ;
: SCZ, ( a u -- ) DUP C, S, 0 C, ;

: CARBON ( a1 u -- a2 u )
  HERE OVER 2SWAP S,
;

\ ��������� ����� � SPF4 ����� ����������� ��������� 
\ ��� ������������ �� ���������� (����������), -- ��� �������� inlines.
Require ADVICE-COMPILER inlines.f \ ��� ������ ����� SPF4 �����������

\ ����� ADVICE-COMPILER ( xt-compiler xt -- ) ��������� ��������
\ ����������� ��������� ���������� �� xt
\ � ����� GET-COMPILER? ( xt -- xt-compiler true | xt false ) 
\ ���� ��� ���������, ���� ��� �������.
\ ����� "EXEC," (�������� ����������) ���������� ����������� ����������,
\ ���� �� ����� ��� ������� xt.

\ ������������� ������ � ��������� xt-compiler.
\ ���� �������, ��� ��� ����� �������� �� xt � ����� ���� ( -- )



Require >CS control-stack.f \ ����������� ����

Require PUSH-DEVELOP native-context.f \ �������� ������ � ���������� ����-����


\ ---
\ �������� ��������������, � ������ CODEGEN-WL
WORDLIST DUP CONSTANT CODEGEN-WL  LATEST-NAME NAME>CSTRING SWAP VOC-NAME! \ ������ �� ��� �������, SPF4 (!)

CODEGEN-WL PUSH-DEVELOP

Include codegen.f

DROP-DEVELOP \ see:  CODEGEN-WL NLIST
\ ---


Require NAMING- native-wordlist.f \ ������� ������ ����-����

' CODEGEN-WL `CODEGEN NAMING- \ alias
CODEGEN ALSO! ' IT `IT NAMING- PREVIOUS \ export
