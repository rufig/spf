\ 03.Apr.2002 Wed 15:24  ruv
\ ����������� ���������� �� ��������� �������
\ � ������� ������� ����
\       lib/include/tools.f
\       ASM-TEMP-WL
\       CODE
\ ����� �������� ���� ORDER: ONLY FORTH DEFINITIONS
\ ( �.�. ORDER ����� ����, ���� �� �������� �� ��� ������ )

REQUIRE [UNDEFINED] lib/include/tools.f

\ ���� ��� ����������, ������������ � ���������� �������
[UNDEFINED] ASSEMBLER [IF]

\ ���� spf-asm-tmp ���������� � ������ ���
[UNDEFINED] ASM-TEMP-WL [IF]

ONLY FORTH DEFINITIONS

0 VALUE ASM-TEMP-WL

..: AT-PROCESS-STARTING ( -- )
  0 TO ASM-TEMP-WL
;..

: CODE ( "name" -- )
  ASM-TEMP-WL 0= ABORT" You must include spf-asm-tmp.f before."
  S" CODE" ASM-TEMP-WL SEARCH-WORDLIST IF EXECUTE ELSE -321 THROW THEN
;
[THEN]

\ ���� ��������� ��� �� ��������
ASM-TEMP-WL 0= [IF]
\ ========================================
\ ������ ������ � FORTH ���� �� �����!

TEMP-WORDLIST TO ASM-TEMP-WL
ALSO ASM-TEMP-WL CONTEXT ! DEFINITIONS

FORTH-WORDLIST ASM-TEMP-WL CHAIN-WORDLIST \ ��������� ������ ����


WARNING @  WARNING 0!

OPT?
FALSE TO OPT?

: VOCABULARY ( -- ) \ name
  TEMP-WORDLIST
  CREATE
    ( wid ) LATEST-NAME NAME>CSTRING OVER VOC-NAME!  ,
  DOES> @   CONTEXT !
;

TO OPT?

: O_FORTH FORTH ;
: FORTH ASM-TEMP-WL CONTEXT ! ;
: ONLY  ONLY FORTH ;

WARNING !
        
ONLY S" lib/ext/spf-asm.f" INCLUDED
ONLY O_FORTH DEFINITIONS
[THEN]
[THEN]
