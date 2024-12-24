\ $Id$
( ���������� �������.
  Windows-��������� �����.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  ������� - �������� 1999
)
\ 94 MEMORY


0 CONSTANT FORTH-START
.forth >VIRT ' FORTH-START >BODY !

0x80000 VALUE IMAGE-SIZE

VARIABLE THREAD-HEAP \ ��� ������������� � windows-�������, �������� ������� �������� �� ����

USER THREAD-MEMORY   \ ������ �������� ������

VARIABLE USER-OFFS \ �������� � ������� ������ ������, 
                   \ ��� ��������� ����� ����������

VARIABLE calloc-adr

: errno ( -- n )
  (()) __errno_location @
;

: ?ERR ( -1 -- -1 err | x -- x 0 )
  DUP -1 = IF errno ELSE 0 THEN
;

: USER-ALLOT ( n -- )
  USER-OFFS +!

\ ��������� � USER-CREATE ~day 
\  USER-OFFS @ +   \ � ������ ����������
\  CELL 1- +  [ CELL NEGATE ] LITERAL AND \ ����� �����������
\  USER-OFFS !
;
: USER-HERE ( -- n )
  USER-OFFS @
;

VARIABLE EXTRA-MEM
0x4000 ' EXTRA-MEM EXECUTE !

: ALLOCATE-THREAD-MEMORY ( -- )
  USER-OFFS @ EXTRA-MEM @ CELL+ + 1 2 calloc-adr @ 
  C-CALL DUP
  IF
     DUP CELL+ TlsIndex!
     THREAD-MEMORY !
     R> R@ TlsIndex@ CELL- ! >R
  ELSE
     -300 THROW
  THEN
;

: FREE-THREAD-MEMORY ( -- )
\ ���������� ��� �������� ������ ��� ��������
  (( THREAD-MEMORY @ )) free DROP
;


: (FIX-MEMTAG) ( addr -- addr ) 2R@ DROP OVER CELL- ! ;

: FIX-MEMTAG ( addr-allocated -- ) (FIX-MEMTAG) DROP ;

: ADD-SIZE ( u1 u2 -- u3 0 | u1 ior )
  2DUP 1+ NEGATE U< IF + 0 EXIT THEN DROP -24 \ "invalid numeric argument"
;

: ALLOCATE ( u -- a-addr ior ) \ 94 MEMORY
\ ������������ u ���� ������������ ������������ ������. ��������� ������������ 
\ ������ �� ���������� ���� ���������. �������������� ���������� ����������� 
\ ������� ������ ������������.
\ ���� ������������� �������, a-addr - ����������� ����� ������ �������������� 
\ ������� � ior ����.
\ ���� �������� �� ������, a-addr �� ������������ ���������� ����� � ior - 
\ ��������� �� ���������� ��� �����-������.

\ SPF: ALLOCATE �������� ���� ������ ������ ����� �������� ������
\ ��� "��������� �����" (��������, �������� ������ ���������� �������)
\ �� ��������� ����������� ������� ���� ���������, ��������� ALLOCATE

  \ ����� ���������� ������, ���� ���������� ��������� ������ ���� ������������
  CELL ADD-SIZE DUP IF EXIT THEN DROP ( u2 )

  1 SWAP 2 calloc-adr @ C-CALL
  DUP IF CELL+ (FIX-MEMTAG) 0 EXIT THEN -300
;

: FREE ( a-addr -- ior ) \ 94 MEMORY
\ ������� ����������� ������� ������������ ������, ������������ a-addr, ������� 
\ ��� ����������� �������������. a-addr ������ ������������ ������� 
\ ������������ ������, ������� ����� ���� �������� �� ALLOCATE ��� RESIZE.
\ ��������� ������������ ������ �� ���������� ������ ���������.
\ ���� �������� �������, ior ����. ���� �������� �� ������, ior - ��������� �� 
\ ���������� ��� �����-������.
  DUP 0= IF DROP -12 EXIT THEN \ -12 "argument type mismatch"
  CELL- 1 <( )) free DROP 0
;

: RESIZE ( a-addr1 u -- a-addr2 ior ) \ 94 MEMORY
\ �������� ������������� ������������ ������������ ������, ������������� � 
\ ������ a-addr1, ����� ��������������� �� ALLOCATE ��� RESIZE, �� u ����.
\ u ����� ���� ������ ��� ������, ��� ������� ������ �������.
\ ��������� ������������ ������ �� ���������� ������ ���������.
\ ���� �������� �������, a-addr2 - ����������� ����� ������ u ���� 
\ �������������� ������ � ior ����. a-addr2 �����, �� �� ������, ���� ��� �� 
\ �����, ��� � a-addr1. ���� ��� �����������, ��������, ������������ � ������� 
\ a-addr1, ���������� � a-addr2 � ���������� ������������ �� �������� ���� 
\ ���� ��������. ���� ��� ���������, ��������, ������������ � �������, 
\ ����������� �� ������������ �� u ��� ��������������� �������. ���� a-addr2 �� 
\ ��� ��, ��� � a-addr1, ������� ������ �� a-addr1 ������������ ������� 
\ �������� �������� FREE.
\ ���� �������� �� ������, a-addr2 ����� a-addr1, ������� ������ a-addr1 �� 
\ ����������, � ior - ��������� �� ���������� ��� �����-������.
  DUP 0= IF -12 EXIT THEN \ -12 "argument type mismatch"
  CELL+ SWAP CELL- SWAP 2 realloc-adr @ C-CALL
  DUP IF CELL+ 0 ELSE -300 THEN
;


PAGESIZE CONSTANT MEMORY-PAGESIZE
  \ NB: The "PAGESIZE" word is available only during building,
  \ and it isn't availabe in the target system.

: ALLOCATE-RWX ( +n -- a-addr 0 | x ior )
\ Allocate a memory region that can be read, modified, and executed
  \ add page size (to have at least one page), and one additional cell for MEMTAG
  MEMORY-PAGESIZE 1- CELL+ ADD-SIZE DUP IF EXIT THEN DROP ( n2 )
  DUP 0< IF -24 EXIT THEN \ "invalid numeric argument"
  \ Assertion: pagesize is a power of two, two's complement representation of signed integers
  MEMORY-PAGESIZE NEGATE AND ( u3 ) \ align u2 down on the page size
  \ Allocate a range on a pagesize-aligned address, and of pagesize-aligned size
  \ https://man7.org/linux/man-pages/man3/posix_memalign.3.html
  >R (( MEMORY-PAGESIZE R@ )) aligned_alloc  ( 0|a-addr1 )
  \ DUP 0= ?ERR NIP ( 0|a-addr1 ior|0 )
  DUP 0= -300 AND ( 0|a-addr1 -300|0 )
  DUP IF NIP R> SWAP ( u3 ior ) EXIT THEN DROP ( a-addr1 )
  \ Set protection, allow code execution
  \ https://man7.org/linux/man-pages/man2/mprotect.2.html#EXAMPLES
  (( DUP  R>  0 PROT_READ OR PROT_WRITE OR PROT_EXEC OR  )) mprotect ?ERR NIP ( a-addr1 ior )
  DUP IF >R  FREE  R>  ( ior2 ior ) EXIT THEN DROP ( a-addr1 )
  CELL+ (FIX-MEMTAG) 0 ( a-addr 0 )
;

: FREE-RWX ( a-addr -- ior )
  \ Assertion: a-addr is aligned to MEMORY-PAGESIZE
  DUP 0= IF DROP -12 EXIT THEN \ -12 "argument type mismatch"
  DUP MEMORY-PAGESIZE NEGATE AND OVER <> IF DROP -60 EXIT THEN
  FREE
;

: RESIZE-RWX ( a-addr -- a-addr ior ) -21 ; \ -21 "unsupported operation"
