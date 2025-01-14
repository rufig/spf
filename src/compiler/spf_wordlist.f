\ $Id$

( �������� �������� ������ � �������� WORDLIST.
  ��-����������� �����������.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  �������������� �� 16-���������� � 32-��������� ��� - 1995-96��
  ������� - �������� 1999, ���� 2000
)

USER WARNING

USER VOC-FOUND  \ �������, � ������� ������� ����� ��� SFIND ��� WordByAddr
\ ����� VOC-FOUND @ � ������ ������������� ����������
\ (�.�. ������ ���� �������, � ������� ����� ����� "@").
\ ����� ����� ������������ ������ � ���������� ����.


VARIABLE _VOC-LIST \ ������ ��������

VECT VOC-LIST \ ����� ��� �����������

' _VOC-LIST ' VOC-LIST TC-VECT!  \ ��������� �������� (����� ����. xt)


USER LAST     \ ��������� �� ���� ����� ���������
              \ ���������������� ��������� ������
              \ � ������� �� LATEST, ������� ����
              \ ����� ���������� ����� � CURRENT

1 CONSTANT &IMMEDIATE \ ��������� ��� ��������� ������ IMMEDIATE
2 CONSTANT &VOC

WORDLIST VALUE FORTH-WORDLIST  ( -- wid ) \ 94 SEARCH
\ ���������� wid - ������������� ������ ����, ����������� ��� ����������� 
\ �����, �������������� �����������. ���� ������ ���� ���������� ������ 
\ ���������� � ����� ���������� ������� ������.


: >BODY ( xt -- a-addr ) \ 94
\ a-addr - ����� ���� ������, ��������������� xt.
\ �������������� �������� ���������, ���� xt �� �� �����,
\ ������������� ����� CREATE.
(  1+ @ ���� � ������ 2.5 )
  5 +
;

: +SWORD ( addr u wid -> ) \ ���������� ��������� ������ � ������,
         \ �������� ������� addr u, � ������, ��������� wid.
         \ ��������� ������ ���� ����� � ����� �
         \ ���������� ������ �� ALLOT.
  HERE LAST !
  HERE 2SWAP S", SWAP DUP @ , !
;

: +WORD ( A1, A2 -> ) \ ���������� ��������� ������ � ������,
         \ �������� ������� �� ��������� A1, � ������, ���������
         \ ���������� A2. ��������� ������ ���� ����� � ����� �
         \ ���������� ������ �� ALLOT. � �������� ����� ��
         \ ������ A2 ���������� ����� ���� ����� ������, �
         \ ������� ���������� ����� � ���� ������.
         \ ������: C" SP-FORTH" ORDER-TOP +WORD
  SWAP COUNT ROT +SWORD
;

100000 VALUE WL_SIZE  \ ������ ������, ���������� ��� ���������� �������

LOAD-BUILD-NUMBER 1+ 
DUP SPF-KERNEL-VERSION 1000 * + VALUE VERSION  \ ������ � ����� ����� SPF � ���� 4XXYYY
    SAVE-BUILD-NUMBER

CREATE BUILD-DATE
NOWADAYS ,"

: AT-WORDLIST-CREATING ( wid -- wid ) ... ;

: WORDLIST ( -- wid ) \ 94 SEARCH
\ ������� ����� ������ ������ ����, ��������� ��� ������������� wid.
\ ����� ������ ���� ����� ���� ��������� �� �������������� �������������� 
\ ������� ���� ��� ����� ����������� �������������� � ������������ ������.
\ ������� ������ ��������� �������� ��� ������� 8 ����� ������� ���� � 
\ ���������� � ��������� � �������.
  ALIGN
  HERE VOC-LIST @ , VOC-LIST !
  HERE 0 , \ ����� ����� ��������� �� ��� ���������� ����� ������
       0 , \ ����� ����� ��������� �� ��� ������ ��� ����������
  GET-CURRENT
         , \ wid �������-������
       0 , \ ����� ������� = wid �������, ������������� �������� �������
       0 , \ reserved, ��� ����������

  AT-WORDLIST-CREATING ( wid -- wid )
;
\ ��� ��������� �������� �������������� ����������:
\       0 , \ ����� �������� ���������� ������� (����� ��������)
\       0 , \ ������ ����, ������� ������������� ��������� �������
\       0 , \ DP ���������� ������� (������� ������)


: TEMP-WORDLIST ( -- wid )
\ ������� ��������� ������� (� ����������� ������)

  WL_SIZE ALLOCATE-RWX THROW DUP >R WL_SIZE ERASE
  -1      R@ ! \ �� ������������ � VOC-LIST, ������ ������� ����������� �������
  R@      R@ 6 CELLS + !
  VERSION R@ 7 CELLS + !
  R@ 9 CELLS + DUP CELL- !
  R> CELL+
;
: FREE-WORDLIST ( wid -- )
  CELL- FREE-RWX THROW
;

: WID-HEAD@ ( wid -- nt|0 ) @ ;
: WID-HEAD! ( nt|0 wid -- ) ! ;

: VOC-NAME! ( c-addr wid --   )  CELL+ ! ;
: VOC-NAME@ ( wid -- c-addr|0 )  CELL+ @ ;  \ c-addr is an address of a counted string
: CLASS! ( cls wid -- ) CELL+ CELL+ CELL+ ! ;
: CLASS@ ( wid -- cls ) CELL+ CELL+ CELL+ @ ;
: PAR!   ( Pwid wid -- ) CELL+ CELL+ ! ;
: PAR@   ( wid -- Pwid ) CELL+ CELL+ @ ;
: WID-EXTRA ( wid -- addr )  4 CELLS + ; \ ��������� ��� ���������� ������ 
\ ������ ���������� �������������� ��� �����, ����� �������� ������ ���� ��������.


\ -5 -- cfa
\ -1 -- flags
\  0 -- NFA
\  1 -- name
\  n -- LFA

CODE NAME> ( nt -- xt ) \ CFA
     MOV EAX, -5 [EAX]
     RET
END-CODE

CODE NAME>C ( nt -- a-addr.xt ) \ 'CFA
     LEA EAX, -5 [EAX]
     RET
END-CODE

CODE NAME>F ( nt -- a-addr.flags ) \ FFA
     LEA EAX, -1 [EAX]
     RET
END-CODE

CODE NAME>L ( nt -- a-addr.link ) \ LFA
     MOVZX EBX, BYTE [EAX]
     LEA EAX, [EBX] [EAX]
     LEA EAX, 1 [EAX]
     RET
END-CODE

CODE CDR ( nt1|0 -- nt2|0 ) \ this word is no longer used and left for only backward compatibility
     OR EAX, EAX
     JZ SHORT @@1
      MOVZX EBX, BYTE [EAX]
      MOV EAX, 1 [EBX] [EAX]
@@1: RET
END-CODE

CODE NAME>NEXT-NAME ( nt1 -- nt2|0 )
    MOVZX EBX, BYTE [EAX]
    MOV EAX, 1 [EBX] [EAX]
    RET
END-CODE

: NAME>CSTRING ( nt -- c-addr )
  \ In this implementation, nt is NFA, which is an address of a counted string in the header.
  \ NB: a call to this word will be eliminated by the optimizer.
;

: NAME>STRING ( nt -- sd.name ) \ "name-to-string" TOOLS-EXT Forth-2012
  NAME>CSTRING COUNT
;

: IS-NAME-HIDDEN ( nt -- 0 | x.true\0 )
  NAME>CSTRING CHAR+ C@ 12 =  \ see "SMUDGE"
;
: IS-IMMEDIATE ( nt -- 0 | x.true\0 )
  NAME>F C@ &IMMEDIATE AND
;
: IS-VOC ( nt -- 0 | x.true\0 )
  NAME>F C@ &VOC AND
;

: ID. ( nt -- )
  NAME>STRING TYPE
;

\ ��� �������� �������������:
: ?IMMEDIATE ( nt -- 0 | x.true\0 ) IS-IMMEDIATE ;
: ?VOC ( nt -- 0 | x.true\0 ) IS-VOC ;


\ ==============================================
\ ������ � ���������� ������������� �����
\ � ������� ���������, � ��� �����������

: LATEST ( -- nt|0 )
 \ ���� ������� ������� �����������, � ������ ���� ����������
 \ �� ��������� ����� ��������� ����� �����������,
 \ �� ������� ����� ����� nt ��� �������� �����������,
 \ ��� ���� ��������� ���� ����� ������ ����� (��������, ���� �����)
 \ ����� ���� ����������� �����������.
 \ �����, ���� ������ ���� ���������� �� ����, �� �������
 \ ����� ����� nt ��� �����������, ������� ���� ��������
 \ � ���� ������ ���������.
 \ ����� ������� 0.
  GET-CURRENT  WID-HEAD@
;

: LATEST-NAME-IN ( wid -- nt|0 )
  \ ����� ������������� ������ ���� wid. 
  \ ���� ���� ������ ���� �� ����, �� ������� ����� ����� nt ��� �����������,
  \ ������� ���� �������� � ���� ������ ���������.
  \ ����� ������� 0.
  WID-HEAD@  BEGIN DUP WHILE DUP IS-NAME-HIDDEN WHILE NAME>NEXT-NAME REPEAT THEN
;
: LATEST-NAME ( -- nt )
  \ ���� ������ ���� ���������� �� ����, �� ������� ����� ����� nt
  \ ��� �����������, ������� ���� �������� � ���� ������ ���������.
  \ ����� ������������ ���������� � ����� -80.
  GET-CURRENT LATEST-NAME-IN DUP IF EXIT THEN -80 THROW
;
: LATEST-NAME-XT ( -- xt ) \ NB: it never return 0
  \ ���� ������ ���� ���������� �� ����, �� ������� ����� ���������� xt
  \ ��� �����������, ������� ���� �������� � ���� ������ ���������.
  \ ����� ������������ ���������� � ����� -80.
  LATEST-NAME NAME>
;


: IMMEDIATE ( -- ) \ 94
\ ������� ��������� ����������� ������ ������������ ����������.
\ �������������� �������� ���������, ���� ��������� �����������
\ �� ����� �����, ��� ������ ���� ���������� ��� �������
\ � ������� ������ �������� ����� ����������� (��. Forth-2012 16.3.3).
  WARNING @ IF \ on any non zero warnings level
    LATEST-NAME LAST @ <> IF
      S" \ Warning: LAST does not point to LATEST-NAME when executing IMMEDIATE" TYPE CR
    THEN
  THEN
  LATEST-NAME NAME>F DUP C@ &IMMEDIATE OR SWAP C!
;

: VOC ( -- )
\ �������� ��������� ������������ ����� ��������� "�������".
  LATEST-NAME NAME>F DUP C@ &VOC OR SWAP C!
;

\ ==============================================
\ ��������� ������� ����

: CHAIN-WORDLIST ( wid.tail wid-empty -- ) \ wid-empty => wid
\ ���� wid-empty �� ����, �� ������������ ���������� -12, �����
\ �������� � wid-empty ��� �����, ������� �������� � wid.tail, �������� �������.
  DUP WID-HEAD@ 0= IF >R LATEST-NAME-IN R> WID-HEAD! EXIT THEN
  -12 THROW \ "argument type mismatch" (assuming wid-empty is a refinement subtype of wid)
  \ NB: ���� wid-empty �� ����, �� ��� ����� ���� ������ ����������� � ������ � ����,
  \ � ����� ��� �������� ������������ (� ������ ����������) ������ ����������� � wid.tail ������,
  \ � ��� �����������.
;

\ ==============================================
\ �������������� - ������� �������� � ����

: IS-CLASS-FORTH ( wid -- flag )
  CLASS@ DUP 0= SWAP FORTH-WORDLIST = OR
;
: ENUM-VOCS ( xt -- )
\ xt ( wid -- )
  >R VOC-LIST @ BEGIN DUP WHILE
    DUP CELL+ ( a wid ) R@ ROT @ >R
    EXECUTE R>
  REPEAT DROP RDROP
;
: (ENUM-VOCS-FORTH) ( xt wid -- xt )
  DUP IS-CLASS-FORTH IF SWAP DUP >R EXECUTE R> EXIT THEN DROP
;
: ENUM-VOCS-FORTH ( xt -- )
\ ������� ������ ������� ����-�������� (� ������� CLASS ����� 0 ��� FORTH-WORDLIST )
\ xt ( wid -- )
  ['] (ENUM-VOCS-FORTH) ENUM-VOCS  DROP
;
: FOR-WORDLIST  ( wid xt -- ) \ xt ( nfa -- )
  SWAP LATEST-NAME-IN  BEGIN  DUP WHILE ( xt NFA ) 2DUP 2>R SWAP EXECUTE 2R> NAME>NEXT-NAME REPEAT  2DROP
;

\ ==============================================
\ ������� - ����� ����� �� ������ � ��� ����

: (NEAREST1) ( addr 0|nfa1 nfa2 -- addr 0|nfa1|nfa2 )
  DUP 0= IF DROP EXIT THEN >R
  \ ���������� xt (������ ������ ����, cfa @)
  2DUP  DUP IF  NAME> THEN 1-
  SWAP  R@ NAME> 1- ( a1 addr a2 ) WITHIN IF DROP R> EXIT THEN RDROP
  \ 1- �.�. WITHIN ������� �����
;
: (NEAREST2) ( addr nfa1 wid -- addr nfa2 )
  2DUP >R >R
  ['] (NEAREST1) FOR-WORDLIST
  DUP R> = IF RDROP EXIT THEN
  R> VOC-FOUND !
;
: (NEAREST3) ( addr nfa1 -- addr nfa2 )
  ['] (NEAREST2) ENUM-VOCS-FORTH
;

VECT (NEAREST-NFA) ( addr nfa1 -- addr nfa2 )

' (NEAREST3) ' (NEAREST-NFA) TC-VECT!

: (WordByAddrSilent) ( addr -- c-addr u )
  VOC-FOUND 0!
  0 (NEAREST-NFA) DUP 0= IF NIP DUP ( 0 0 ) EXIT THEN
  TUCK NAME> - ABS 4096 U< IF COUNT EXIT THEN
  \ ���������� ������� ��������� �� xt, � �� �� nfa
  \ ( -- ����� ��������� � ������ �������)
  0 ( caddr 0 )
;
: WordByAddrSilent ( addr -- c-addr u )
  ['] (WordByAddrSilent) CATCH  ?DUP IF ."  EXC:" . 0 ( x 0 ) THEN
  255 UMIN
;

: (WordByAddr) ( addr -- c-addr u )
  (WordByAddrSilent) DUP IF EXIT THEN
  DROP 0= IF S" <?not in the image>" EXIT THEN
  S" <?not found>"
;
: WordByAddr ( addr -- c-addr u )
  ['] (WordByAddr) CATCH  ?DUP IF ."  EXC:" . DROP S" <?WordByAddr exception>" EXIT THEN
  255 UMIN
;

\ ��� �������� �������������:
: NEAR_NFA ( addr -- nfa|0 addr )
  0 (NEAREST-NFA) SWAP
;
