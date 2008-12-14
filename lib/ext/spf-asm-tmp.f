\ 03.Apr.2002 Wed 15:24  ruv
\ Подключение ассемблера во временный словарь
\ В текущий словарь идут
\       lib/include/tools.f
\       ASM-TEMP-WL
\       CODE
\ После загрузки асма ORDER: ONLY FORTH DEFINITIONS
\ ( т.е. ORDER будет сбит, если до загрузки он был другой )

REQUIRE [UNDEFINED] lib/include/tools.f

\ Если нет ассемблера, загруженного в постоянный словарь
[UNDEFINED] ASSEMBLER [IF]

\ Если spf-asm-tmp инклюдится в первый раз
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

\ Если ассемблер еще не загружен
ASM-TEMP-WL 0= [IF]
\ ========================================
\ больше ничего в FORTH идти не будет!

TEMP-WORDLIST TO ASM-TEMP-WL
ALSO ASM-TEMP-WL CONTEXT ! DEFINITIONS

FORTH-WORDLIST @  ASM-TEMP-WL ! \ подключаю список слов


WARNING @  WARNING 0!

OPT?
FALSE TO OPT?

: VOCABULARY ( -- ) \ name
  TEMP-WORDLIST
  CREATE
    LATEST OVER CELL+ ( VOC-NAME ) !  ,
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
