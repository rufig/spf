\ 16.Oct.2007
\ $Id$

( Позволяет менять CURRENT в процессе определения слова;
но только для обычных словарей.
  -- см. Bug#1808325, https://sourceforge.net/tracker/index.php?func=detail&aid=1808325&group_id=17919&atid=117919

Несовместимо с locals.f и тому подобным кодом, когда в процессе
определения слова создаются другие слова в другом временном словаре.

Для большей совместимости подключайте данный модуль в отдельный словарь.
)

WARNING @  WARNING 0!

: SMUDGE ( -- )
\  LAST-NON IF EXIT THEN
  LAST @ IF
    C-SMUDGE C@
    LAST @ 1+ C@ C-SMUDGE C!
    LAST @ 1+ C!
  THEN
;
: HIDE
  12 C-SMUDGE C! SMUDGE
;
: : ( C: "<spaces>name" -- colon-sys ) \ 94
  HEADER ] HIDE
;
: ; ( -- )
  RET, [COMPILE] [ SMUDGE
  ClearJpBuff
  0 TO LAST-NON
; IMMEDIATE

WARNING !
