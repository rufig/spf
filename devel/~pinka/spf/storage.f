\ 23.Dec.2006 Sat 16:08, ruvim@forth.org.ru
\ $Id$
( ��������� ����������� �������� ��� SPF4.
    
    ������� ��������� �������, ������� ��������� ����� TEMP-WORDLIST,
    ����� ��������� ����������: � ��� ������ ��������� ��������� ������� 
    ������� ����� WORDLIST ��� ����������� �� ���� �����. ���� ��
    ��������� ������� ����� ������ ������� �������, �� ��������� 
    ��������� ��������:
      - ���������� ����� ������� ������ � ����� ������� ���������;
        - ��� ������������ ���������� ��������� �����;
        - ��� ������������ ���������� ������� ��������� ������
          � ������� ���������;
      - ����� ������������ ���������� ������� ������ �������� VOC-LIST
        ����� �����������.
    ��������� ����������� ��������, ����������� �� ������� ����, 
    ������� ��� ��������.

  ������������ ���� ��������� ��������� �� ���������� [storage-core.f]
  � ����� ��������� ����������:
    - ������� ������ ���� ��� ����������,
    - ������ ���� �� ���������, ��� ����� ��������� ��������,
    - ������ �������� [������� ����, VOC-LIST], �� ���� �������� � ���������.

  ������� ��������� ������� ������ ���������, �����
  SET-CURRENT ������������� ������� � ���������,
  � ������� ������������� �������.

  � �������� ������� ������� ��������� � ������� ������� �� �����������!
  ����� ���, ��� ���-�� �����������, ��������� � ����� ������
  ������ ���������� ������� [�� ����, �������] ��������� ��� �������.
  ��������������� ��������� ������ ���� '��������' �� ������ �������,
  �� ����, ��� �� ������ ���� ������� � �����-���� ������ ������.

  ������ ������������� ����� �������� ����:
    TEMP-WORDLIST -- ������� ��������� ��������� � � ��� �������,
    FREE-WORDLIST -- ������������� ���������, � ������� ���������� �������.
    ORDER ������ ������� ��������� ������!
    SAVE -- �������� AT-SAVING-BEFORE � AT-SAVING-AFTER
    SET-CURRENT � DEFINITIONS -- ��������� ����� ��������� ��� ������ DP.

    �����: ������ ����������� �������, ���� �� ������������; �.�. 
    ������ FREE-WORDLIST, ����� ���� ������� � CURRENT ��� CONTEXT,
    ���� ����� � ��� ��������.

  ������ ���������� ����� UNUSED, ����������� ������� ���������, ������� 
  ��� ������������� lib/include/core-ext.f ��� ������ ���� �� storage.f,
  �.�. � ��� UNUSED ���� ������������.
  � ��������� ��, storage.f ������ ���� ��������� �� ����� ������ ������.

  ���������:
    ��������� �� �������� CURRENT ���� ��������� ��� ���������, ��� ������.


  C��������� � quick-swl3.f, ������� ������� ���������� ����� ������� ������.
)

REQUIRE Included ~pinka/lib/ext/requ.f
REQUIRE REPLACE-WORD lib/ext/patch.f
REQUIRE NDROP    ~pinka/lib/ext/common.f

WARNING @  WARNING 0!

' DP
USER DP ( -- addr ) \ ����������, ���������� HERE �������� ������

DUP EXECUTE @ DP !  ' DP SWAP REPLACE-WORD
\ �������� ������ DP, ����� �� �������������� ��� ������������� �����

USER STORAGE \ ������� ���������. 
              \ ��� ����� ���������� ������ ����� �������������.

S" storage-core.f" Included

\ ���������� ����������� ���������:

..: AT-FORMATING ( -- )
  ( ALIGN) HERE STORAGE-EXTRA !
  HERE 0 ,  \ 0, current wid
  0 ,       \ 1, extra
  HERE 0 ,  \ 2, default wid
  0 ,       \ 3, voc-list
  0 ,       \ 4, isBusy -- for debug
  WORDLIST DUP ROT ! \ to default
  SWAP !             \ to current
;..

..: AT-DISMOUNTING ( -- )
  STORAGE-EXTRA @  CURRENT @ OVER !  4 CELLS + 0!  CURRENT 0!
;..

..: AT-MOUNTING ( -- )
  STORAGE-EXTRA @  DUP
  4 CELLS +  DUP  @ IF -2012 THROW THEN -1 SWAP !
  @ CURRENT !
;..

: DEFAULT-WORDLIST ( -- wid )
  STORAGE-EXTRA @  CELL+ CELL+ @
;

VOC-LIST @
( old-voc-list@ )

CREATE _VOC-LIST-EMPTY 0 ,
\ ���� ���-�� ������� ���������� ������� ��� ����������� ���������.

: VOC-LIST2 ( -- addr )
  STORAGE-ID IF STORAGE-EXTRA @ 3 CELLS + EXIT THEN _VOC-LIST-EMPTY
;
' VOC-LIST2 TO VOC-LIST

: STORAGE-EXTRA ( -- a ) \ ��������� ������
  STORAGE-EXTRA @ CELL+
;

( old-voc-list@ )
ALIGN HERE IMAGE-SIZE HERE IMAGE-BASE - - ( addr u ) \ see  lib/include/core-ext.f
FORMAT
  DUP MOUNT \ (!!!)
  FORTH-WORDLIST SET-CURRENT
CONSTANT FORTH-STORAGE  \ ������� ��������� ����-�������

( old-voc-list@ ) VOC-LIST !  \ ������ �������� �������� ���������

..: AT-PROCESS-STARTING  FORTH-STORAGE MOUNT ;..

: AT-SAVING-BEFORE ... ; 
: AT-SAVING-AFTER ... ;

: CODESPACE-CONTENT ( -- addr u )
  STORAGE-ID FORTH-STORAGE <> IF CODESPACE-CONTENT EXIT THEN
  IMAGE-BASE DP @ OVER -
;
: FLUSH-STORAGE ( -- )
  STORAGE-ID FORTH-STORAGE = IF IMAGE-BASE IMAGE-SIZE +  STORAGE-ID 3 CELLS + ! THEN
  FLUSH-STORAGE
;
: SAVE ( addr u -- )
  STORAGE-ID FORTH-STORAGE <> ABORT" Current storage is not FORTH-STORAGE"
  AT-SAVING-BEFORE
  FLUSH-STORAGE STORAGE-EXTRA 3 CELLS + DUP >R 0! \ ��������� ���� � ������ "��������"
  SAVE
  -1 R> !
  AT-SAVING-AFTER
;
\ �.�. ���� �������� ������� ��������� ����� �����������; ��� ������ ���� �������.


\ ==================================================
\ ����� ��� SET-CURRENT ������� ����������� � ���������, � ������� ���������� �������,
\ ���������� ����� ������� ���� ���� ���������.

Require WidExtraSupport  wid-extra.f  \ ������ WID-STORAGEA

MODULE: WidExtraSupport

: MAKE-EXTR-STORAGE ( wid -- )
  STORAGE-ID SWAP WID-STORAGEA !
;
..: AT-WORDLIST-CREATING  DUP MAKE-EXTR-STORAGE ;..

EXPORT

: WL-STORAGE ( wid -- h-storage )
  WID-STORAGEA @
;

' MAKE-EXTR-STORAGE ENUM-VOCS-FORTH  \ ���������� STORAGE-ID ��� ������������ ��������

;MODULE


\ �������������� ��� �����, ���������� �� SET-CURRENT
\ (�.�. ����������� ����� �����������, � ��������� ������ ���������� ����� ������������)

: SET-CURRENT ( wid -- )
  DUP IF DUP WL-STORAGE MOUNT  CURRENT ! EXIT THEN
  CURRENT ! DISMOUNT DROP
;

..: AT-THREAD-STARTING STORAGE-ID 0= IF CURRENT 0! THEN ;..
\ �� ��������� ������ ������ ������ � ������� �������� ������� ������� ���������

: DEFINITIONS ( -- ) \ 94 SEARCH
  CONTEXT @ SET-CURRENT
;

: MODULE: ( "name" -- old-current )
  >IN @ 
  ['] ' CATCH
  IF >IN ! VOCABULARY LATEST-NAME-XT ELSE NIP THEN
  GET-CURRENT SWAP ALSO EXECUTE DEFINITIONS
;
: ;MODULE ( old-current -- )
  SET-CURRENT PREVIOUS
;


: ORDER ( -- ) \ 94 SEARCH EXT
  GET-ORDER ." Context>: "
  DUP >R BEGIN DUP WHILE DUP PICK VOC-NAME. SPACE 1- REPEAT DROP R> NDROP CR
  ." Current: " GET-CURRENT DUP IF VOC-NAME. ELSE DROP ." <not mounted>" THEN CR
;

\ =====
\ ��������� ��������� � �������

: AT-STORAGE-DELETING ( -- ) ... ;

: NEW-STORAGE ( size -- h )
  DUP ALLOCATE-RWX THROW (FIX-MEMTAG) SWAP
  2DUP ERASE FORMAT
;
: DEL-STORAGE ( h -- )
  PUSH-MOUNT AT-STORAGE-DELETING POP-MOUNT FREE-RWX THROW
;

: TEMP-WORDLIST ( -- wid )
\ ������� ��������� ��������� � ������� ���� (����)
\ � � ��� �������
  WL_SIZE NEW-STORAGE (FIX-MEMTAG) PUSH-MOUNT
  DEFAULT-WORDLIST  POP-MOUNT DROP
;
: FREE-WORDLIST ( wid -- )
  WL-STORAGE DEL-STORAGE
;
: IS-TEMP-WORDLIST ( wid -- flag )
  WL-STORAGE FORTH-STORAGE <>
;
: IS-TEMP-WL ( -- flag )
  GET-CURRENT IS-TEMP-WORDLIST
;

WARNING !

Include storage-enum.f
