\ Отладочные дамперы / примеры листателей.

REQUIRE MapiLogon ~ac/lib/win/mapi/exmapi.f 

: MapiListAtt { row \ att num -- }
  ." att:"
  row PR_ATTACH_NUM MapiRowProp@ IF DUP . -> num DROP THEN
  row PR_ATTACH_LONG_FILENAME MapiRowStr@ 
  IF TYPE SPACE 
  ELSE
    row PR_ATTACH_FILENAME MapiRowStr@ 
    IF 2DUP TYPE SPACE 
       " att\-----{s}-----" STR@ 2DUP TYPE CR num MapiSaveAtt
    THEN
  THEN
  row PR_ATTACH_SIZE MapiRowProp@ IF . DROP THEN CR
;
: MapiListRcpt { rcpt -- }
  ." rcpt=" rcpt PR_EMAIL_ADDRESS  MapiRowStr@ IF TYPE SPACE THEN CR
;

: MapiListMessage { row \ msg -- }
CR CR ." ==========================" row PR_MESSAGE_CLASS MapiRowStr@ IF TYPE THEN CR
  row ( PR_SUBJECT) PR_NORMALIZED_SUBJECT MapiRowStr@ IF ANSI>OEM TYPE CR THEN
  row PR_BODY MapiRowStr@ IF ." ((" ANSI>OEM TYPE ." ))" CR THEN
  row PR_ENTRYID MapiRowProp@ 
  IF MapiOpenItem 5 =
     IF -> msg

        msg ['] MapiListRcpt MapiEnumRcpt

        msg PR_BODY MapiProp@ ( ANSI>OEM) TYPE CR
        msg PR_HTML_BODY  MapiProp@ ." html=" . . CR \ ( ANSI>OEM) TYPE CR
        msg PR_TRANSPORT_MESSAGE_HEADERS MapiProp@ ." headers=" TYPE CR
\        msg MapiRtfBody@ ." rtf=" TYPE CR
        msg uMapiMessage ! \ нужен для сохранения аттача
        msg ['] MapiListAtt MapiEnumAtt
     THEN
  THEN
;
: MapiListFolder { row -- }
  row PR_DISPLAY_NAME  MapiRowStr@ IF SPACE ANSI>OEM TYPE CR THEN
;
USER lpEntryID
USER cbEntryID

: DumpRow ( addr nprop -- )
  0 ?DO
    DUP I 16 * +
      DUP @ DUP 0xFFFF AND PT_STRING8 = 
          IF U. CELL+ CELL+ @ ASCIIZ> ANSI>OEM TYPE CR
          ELSE 
             DUP 0xFFFF AND 0xA = \ не печатаем свойства, чье значение "ошибка"
             IF 2DROP
             ELSE
               DUP PR_ENTRYID =
               IF U. DUP CELL+ CELL+ @ cbEntryID ! CELL+ CELL+ CELL+ @ lpEntryID !
               ELSE U. CELL+ CELL+ @ U. THEN CR
             THEN
          THEN 
  LOOP DROP CR ." ==============="
;
: DumpRow1 ( row -- )
  DUP CELL+ @
  SWAP CELL+ CELL+ @ SWAP
  DumpRow
;
: DumpRowSet ( rs -- )
  ['] DumpRow1 MapiForEach
;
