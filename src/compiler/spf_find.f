( ����� ���� � �������� � ���������� �������� ������.
  ��-����������� �����������.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  �������������� �� 16-���������� � 32-��������� ��� - 1995-96��
  ������� - �������� 1999

  Mar.2012 - ����������� � ����������� � search-order: GET-ORDER � SFIND
  �������� �������� ��� ������ ��������� ������; ��������� ����������
  ��� ���������� � ������������. ~pinka
)

VECT FIND

VECT SEARCH-WORDLIST ( c-addr u wid -- 0 | xt 1 | xt -1 ) \ 94 SEARCH
\ ����� �����������, �������� ������� c-addr u � ������ ����, ���������������� 
\ wid. ���� ����������� �� �������, ������� ����.
\ ���� ����������� �������, ������� ���������� ����� xt � ������� (1), ���� 
\ ����������� ������������ ����������, ����� ����� ������� (-1).


1 [IF] \ optimized and refactored version

S" src/compiler/spf_find_cdr.f" INCLUDED

[ELSE]

\ �������������� by day (29.10.2000)
\ �������������� by mak July 26th, 2001 - 15:45

CODE CDR-BY-NAME ( c-addr u nfa1|0 -- c-addr u nfa1|nfa2|0 )
\ ����, ��� � CDR (��. � spf_wordlist.f), �� ����� ����� ������ �������� �������� � �������� ���.
\ ��� ���������� �� SEARCH-WORDLIST, by ~ygrek Nov.2006
      PUSH EDI

      MOV EDX, [EBP]                \ ����� (�������)
      MOV ESI, EAX                  \ ���� � ������
      MOV EDI, 4 [EBP]              \ ������� �����

      CMP EDX, # 4    \ ��� ������ 0,1,2,3 ����� �� ������� ������ --
      JNB SHORT @@4    \ ��������� ����� (�� ����� ������� �������)
      MOV EBX, # 0xFF
      JMP @@1

@@4:  \ ���������� ���� ��� ���������
      A;  0xBB C, -1 W, 0 W, \    MOV EBX, # FFFF
      CMP EDX, # 3
      JB  SHORT @@8
      A;  0xBB C,  -1 DUP W, W, \   MOV  EBX, # FFFFFFFF
@@8:   MOV EAX, [EDI] \ -- � ���� ����� ����� ��������� AV, ���� c-addr � ���� ���������� ������
      SHL EAX, # 8
      OR  EDX, EAX
      AND EDX, EBX
      MOV AL, # 0
      A;  0x25 C, 0xFF C, 0 C, 0 W, \       AND EAX, # FF
      JMP @@1
@@3:
      A;  0x25 C, 0xFF C, 0 C, 0 W, \       AND EAX, # FF
      MOV ESI, 1 [ESI] [EAX]
@@1:   OR ESI, ESI
      JZ SHORT @@2                   \ ����� ������
      MOV EAX, [ESI]
      AND EAX, EBX
      CMP EAX, EDX
      JNZ SHORT @@3              \ ����� �� ����� - ���� ������
\ ��������� ��� ������
      INC ESI
      CLD
      XOR ECX, ECX
      MOV CL, DL
      PUSH ESI
      PUSH EDI                  \ ��������� ����� ������ �������� �����
      REPZ CMPS BYTE
      POP EDI
      JZ SHORT @@5
      POP EAX                   \ �������� esi �� ���������� � ������ �������
      MOV ESI, [ESI] [ECX]
      JMP SHORT @@1
@@2:
      XOR EAX, EAX
      JMP SHORT @@7                  \ ����� � "�� �������"

@@5:  
      POP ESI
      DEC ESI               \   ������������� �� ������ ������ � NFA
      MOV EAX, ESI
@@7:
      POP EDI
      RET
END-CODE

[THEN]

\ ����-����������:
\ : CDR-BY-NAME ( a u nfa1|0 -- a u nfa2|0 )
\  BEGIN  ( a u NFA | a u 0 )
\    DUP
\  WHILE  ( a u NFA )
\    >R 2DUP R@ COUNT COMPARE R> SWAP
\  WHILE
\    CDR  ( a u NFA2 )
\  REPEAT THEN 
\ ;

: SEARCH-WORDLIST-NFA ( c-addr u wid -- 0 | nfa -1 )
  LATEST-NAME-IN CDR-BY-NAME NIP NIP ?DUP 0<>
;

: SEARCH-WORDLIST1
   SEARCH-WORDLIST-NFA 0= IF 0 EXIT THEN
   DUP NAME>
   SWAP ?IMMEDIATE IF 1 EXIT THEN -1
;

' SEARCH-WORDLIST1 ' SEARCH-WORDLIST TC-VECT!


USER-CREATE S-O 16 CELLS TC-USER-ALLOT \ ������� ������
USER-CREATE S-O| \ ������� ������� ������� S-O
USER-VALUE CONTEXT    \ CONTEXT @ ���� wid1
\ CONTEXT ��������� ���� ��������� ������� ����� ���������
\ (������ ���� ������ � ������� ���������� �������)

: SFIND ( addr u -- addr u 0 | xt 1 | xt -1 ) \ 94 SEARCH
\ ��������� ��������� CORE FIND ���������:
\ ������ ����������� � ������, �������� ������� addr u.
\ ���� ����������� �� ������� ����� ��������� ���� ������� � ������� ������,
\ ���������� addr u � ����. ���� ����������� �������, ���������� xt.
\ ���� ����������� ������������ ����������, ������� ����� ������� (1);
\ ����� ����� ������� ����� ������� (-1). ��� ������ ������, ��������,
\ ������������ FIND �� ����� ����������, ����� ���������� �� ��������,
\ ������������ �� � ������ ����������.
  CONTEXT
  BEGIN
    DUP S-O U> WHILE >R 2DUP R@ @ SEARCH-WORDLIST DUP 0= WHILE DROP R> CELL-
  REPEAT
    R> VOC-FOUND !
    2SWAP 2DROP EXIT
  THEN
  DROP VOC-FOUND 0! 0
;

: FIND1 ( c-addr -- c-addr 0 | xt 1 | xt -1 ) \ 94 SEARCH
\ ��������� ��������� CORE FIND ���������:
\ ������ ����������� � ������, �������� ������� �� ��������� c-addr.
\ ���� ����������� �� ������� ����� ��������� ���� ������� � ������� ������,
\ ���������� c-addr � ����. ���� ����������� �������, ���������� xt.
\ ���� ����������� ������������ ����������, ������� ����� ������� (1);
\ ����� ����� ������� ����� ������� (-1). ��� ������ ������, ��������,
\ ������������ FIND �� ����� ����������, ����� ���������� �� ��������,
\ ������������ �� � ������ ����������.
  DUP >R COUNT SFIND
  DUP 0= IF NIP NIP R> SWAP ELSE RDROP THEN
;

: DEFINITIONS ( -- ) \ 94 SEARCH
\ ������� ������� ���������� ��� �� ������ ����, ��� � ������ ������ � ������� 
\ ������. ����� ����������� ����������� ����� ���������� � ������ ����������.
\ ����������� ��������� ������� ������ �� ������ �� ������ ����������.
  CONTEXT @ SET-CURRENT
;

: GET-ORDER ( -- widn ... wid1 n ) \ 94 SEARCH
\ ���������� ���������� ������� ���� � ������� ������ - n � �������������� 
\ widn ... wid1, ���������������� ��� ������ ����. wid1 - �������������� ������ 
\ ����, ������� ��������������� ������, � widn - ������ ����, ��������������� 
\ ���������. ������� ������ �� ����������.
  S-O BEGIN DUP CONTEXT U< WHILE CELL+ DUP @ SWAP REPEAT
  S-O - >CELLS
;

: SET-ORDER ( widn ... wid1 n -- ) \ 94 SEARCH
\ ���������� ������� ������ �� ������, ���������������� widn ... wid1.
\ ����� ������ ���� wid1 ����� ��������������� ������, � ������ ���� widn
\ - ���������. ���� n ���� - �������� ������� ������. ���� ����� �������,
\ ���������� ������� ������ �� ��������� �� ���������� ����������� ������
\ ������.
\ ����������� ������ ������ ������ �������� ����� FORTH-WORDLIST � SET-ORDER.
\ ������� ������ ��������� �������� n ��� ������� 8.
  DUP -1 = IF DROP  FORTH-WORDLIST 1  THEN \ see " ONLY " below
  DUP CELLS S-O + DUP S-O| U< IF ( n*x n sp )
    DUP TO CONTEXT SWAP
    0 ?DO TUCK ! CELL- LOOP DROP EXIT
  THEN -49 THROW
;

: ALSO! ( wid -- )
  CONTEXT CELL+ DUP S-O| U< IF DUP TO CONTEXT ! EXIT THEN
  -49 THROW
;
: ALSO ( -- ) \ 94 SEARCH EXT
\ ������������� ������� ������, ��������� �� widn, ...wid2, wid1 (��� wid1 
\ ��������������� ������) � widn,... wid2, wid1, wid1. �������������� �������� 
\ ���������, ���� � ������� ������ ������� ����� �������.
  CONTEXT @ ALSO!
;
: PREVIOUS ( -- ) \ 94 SEARCH EXT
\ ������������� ������� ������, ��������� �� widn, ...wid2, wid1 (��� wid1 
\ ��������������� ������) � widn,... wid2. �������������� �������� ���������,
\ ���� ������� ������ ��� ���� ����� ����������� PREVIOUS.
  CONTEXT DUP S-O U> IF CELL- TO CONTEXT EXIT THEN
  -50 THROW
;

: FORTH ( -- ) \ 94 SEARCH EXT
\ ������������� ������� ������, ��������� �� widn, ...wid2, wid1 (��� wid1 
\ ��������������� ������) � widn,... wid2, widFORTH-WORDLIST.
  FORTH-WORDLIST CONTEXT !
;

: ONLY ( -- ) \ 94 SEARCH EXT
\ ���������� ������ ������ �� ��������� �� ���������� ����������� ������ ������.
\ ����������� ������ ������ ������ �������� ����� FORTH-WORDLIST � SET-ORDER.
\ NB: `-1 SET-ORDER` shall perfrom `ONLY`
  S-O TO CONTEXT
  FORTH-WORDLIST ALSO!
;


: VOC-NAME. ( wid -- ) \ ���������� ��� ������ ����, ���� �� ��������
  DUP FORTH-WORDLIST = IF DROP ." FORTH" EXIT THEN
  DUP VOC-NAME@ DUP IF NIP COUNT TYPE ELSE DROP ." <NONAME>:" U. THEN
;

: ORDER ( -- ) \ 94 SEARCH EXT
\ �������� ������ � ������� ������, �� ������� ���������������� ������ �� 
\ ����������. ����� �������� ������ ����, ���� ���������� ����� �����������.
\ ������ ����������� ������� �� ����������.
\ ORDER ����� ���� ���������� � �������������� ���� ���������� ��������������
\ �����. ������������� �� ����� ��������� ������������ �������, 
\ ���������������� #>.
  GET-ORDER ." Context: "
  0 ?DO ( DUP .) VOC-NAME. SPACE LOOP CR
  ." Current: " GET-CURRENT VOC-NAME. CR
;
