( addr_exe u_exe addr_fres u_fres -- )
\ ��������� ������� ���� ������� � exe � ��������� �� fres �����;
\ ���� ������� �� �����, �� u_fres = 0.
\ ����������� tsave - ���� �������� �� ��������� ������� � ��
\ �������� � ������� ���������.
\ ��� ���� ������� �� ������ resources.f �. ������� (~yz\lib\resources.f )
\ � ���� SaveWithRes (~af)

DECIMAL

GET-CURRENT
TEMP-WORDLIST DUP PUSH-ORDER DEFINITIONS ( wid.compilation.old wid.new.tmp )

0x080 CONSTANT START-PE-HEADER
0x400 CONSTANT SIZE-HEADER
0x2000 CONSTANT BASEOFCODE
0 VALUE END-CODE-SEG
0 VALUE END-RES-SEG
TRUE VALUE ?Res
0 VALUE START-RES-TABLE

: relocate ( adr xt -- ) 
\ ��������� �� ���� ��������� �������� adr ����� xt
  >R
  DUP 12 + W@ ( ����������� ������) OVER 14 + W@ ( ������������� ������) +
  SWAP 16 + SWAP
  BEGIN ( adr #) DUP WHILE
    OVER CELL+ @ 0x7FFFFFFF AND END-CODE-SEG + R@ EXECUTE
  SWAP 2 CELLS + ( ����� ������) SWAP 1-
  REPEAT 2DROP
  RDROP
;

: relocate3 ( leaf --) IMAGE-SIZE BASEOFCODE + SWAP +! ;
: relocate2 ( dir -- ) ['] relocate3 relocate ;
: relocate1 ( dir -- ) ['] relocate2 relocate ;

: ADD-RES ( addr u -- )
  DUP IF
    R/O OPEN-FILE THROW >R
    END-CODE-SEG R@ FILE-SIZE 2DROP R@ READ-FILE THROW ALLOT
    END-CODE-SEG ['] relocate1 relocate \ �������� �� ���� ������� ��������
     \ IMAGE-SIZE BASEOFCODE +
    R> CLOSE-FILE DROP
  ELSE
    2DROP
  THEN
;

: SAVE ( offset c-addr u -- )
  ( ���������� ������������ ����-������� � EXE-����� ������� PE - Win32 )
  R/W CREATE-FILE THROW >R
  ModuleName R/O OPEN-FILE-SHARED THROW >R
  HERE SIZE-HEADER R@ READ-FILE THROW SIZE-HEADER < THROW
  R> CLOSE-FILE THROW

  \ ���� �������� ��� (u_coff = 0), �� END-CODE-SEG = END-RES-SEG
  END-CODE-SEG END-RES-SEG = IF FALSE ELSE TRUE THEN TO ?Res

  ?Res IF 3 ELSE 2 THEN HERE START-PE-HEADER 0x06  + + W! ( Num of Objects)
  ?GUI IF 2 ELSE 3 THEN HERE START-PE-HEADER 0x5C  + + W!
  BASEOFCODE            HERE START-PE-HEADER 0x28  + +  ! ( EntryPointRVA )
  IMAGE-BASE            HERE START-PE-HEADER 0x34  + +  ! ( ImageBase )
  IMAGE-SIZE BASEOFCODE + END-RES-SEG END-CODE-SEG - 0xFFF + 0x1000 / 0x1000 * +
                        HERE START-PE-HEADER 0x50  + +  ! ( ImageSize )
  ?Res IF IMAGE-SIZE BASEOFCODE + ELSE 0 THEN
                        HERE START-PE-HEADER 0x88  + + !
  ?Res IF END-RES-SEG END-CODE-SEG - ELSE 0 THEN
                        HERE START-PE-HEADER 0x8C  + + !

  IMAGE-SIZE            HERE START-PE-HEADER 0x128 + + ! ( VirtualSize code)
  END-CODE-SEG IMAGE-BEGIN -
                        HERE START-PE-HEADER 0x130 + + ! ( PhisicalSize code)
                        HERE START-PE-HEADER 0x1C + + 0! ( SizeOfCode)

  HERE 0x1C8 + TO START-RES-TABLE
  START-RES-TABLE 0x38 ERASE
  ?Res IF
    \ see: https://docs.microsoft.com/en-us/windows/desktop/debug/pe-format#section-table-section-headers
    S" .rsrc"             START-RES-TABLE SWAP CMOVE
    END-RES-SEG END-CODE-SEG - 0xFFF + 0x1000 / 0x1000 *
                          START-RES-TABLE 0x08 + !
    IMAGE-SIZE BASEOFCODE + 0xFFF + 0x1000 TUCK / *
                          START-RES-TABLE 0x0C + ! ( VirtualAddress  )
    END-RES-SEG END-CODE-SEG -
                          START-RES-TABLE 0x10 + !
    END-CODE-SEG IMAGE-BEGIN - SIZE-HEADER +
                          START-RES-TABLE 0x14 + !
                          START-RES-TABLE 0x18 + 0xC ERASE
    0x40 0x40000000 OR    START-RES-TABLE 0x24 + !
  THEN

  HERE SIZE-HEADER R@ WRITE-FILE THROW ( ��������� � ������� ������� )
  IMAGE-BEGIN HERE OVER -
  ROT ALLOT
  R@ WRITE-FILE THROW
  R> CLOSE-FILE THROW
;


( wid.compilation.old wid.new.tmp )
SWAP SET-CURRENT ( wid.new.tmp )

HERE
ALIGN-BYTES @ 512 ALIGN-BYTES ! ALIGN ALIGN-BYTES !
HERE TO END-CODE-SEG

2SWAP ADD-RES

ALIGN-BYTES @ 512 ALIGN-BYTES ! ALIGN ALIGN-BYTES !
HERE TO END-RES-SEG

HERE -

2SWAP SAVE
PREVIOUS
( wid.new.tmp )
FREE-WORDLIST
