REQUIRE ParseMime              ~ac/lib/lin/mime/mime.f 
REQUIRE StripLwsp              ~ac/lib/string/mime-decode.f 
\ REQUIRE UNICODE>UTF8           ~ac/lib/win/com/com.f
REQUIRE iso-8859-5>UNICODE     ~ac/lib/lin/iconv/iconv.f 
WARNING @ WARNING 0! S" ~ac/lib/win/utf8.f" INCLUDED WARNING ! \ в Windows более все€дный декодер UTF8, чем в ICONV !
REQUIRE replace-str            ~pinka/samples/2005/lib/replace-str.f 

\ ================================= subject decoding ==================

GET-CURRENT ALSO CHARSET-DECODERS DEFINITIONS
: UTF-8 UTF8> ;
: Utf-8 UTF8> ;
: utf-8 UTF8> ; \ UTF8>UNICODE " {s}" STR@ UNICODE> ;
: iso-8859-5 iso-8859-5>UNICODE " {s}" STR@ UNICODE> ;
PREVIOUS SET-CURRENT

REQUIRE { lib/ext/locals.f

: ">BL ( addr u -- )
  0 ?DO DUP C@ DUP [CHAR] " = SWAP [CHAR] ' = OR 
  IF BL OVER C! THEN 1+ LOOP DROP
;
: ,>BL ( addr u -- )
  0 ?DO DUP C@ [CHAR] , =
  IF BL OVER C! THEN 1+ LOOP DROP
;
\ ====== ¬ычленение имени и Email из From разных форматов ==

: SOURCE/
  SOURCE SWAP >IN @ + SWAP >IN @ - 0 MAX
;
: ?DupEmail ( addr1 u1 addr2 u2 -- addr1 u1 addr2 u2 )
\  2SWAP DUP IF 2SWAP EXIT THEN 2DROP 2DUP
;
: (Strip<) ( -- addr u )
  BL SKIP PeekChar [CHAR] < = IF >IN 1+! THEN
  [CHAR] > PARSE
;

WARNING @ WARNING 0!
: Strip< ( addr u -- addr2 u2 ) \ см. также версию в conv.f
  DUP IF ['] (Strip<) EVALUATE-WITH THEN
;
WARNING !

: FromNameEmail1 ( addr1 u1 addr2 u2 -- addr1 u1 addr2 u2 )
  -TRAILING 2SWAP -TRAILING Strip< ?DupEmail
;
: FromNameEmail2 ( -- addr1 u1 addr2 u2 )
  TIB >IN @ -TRAILING SOURCE/ -TRAILING ?DupEmail
;
: (FromNameEmail) ( -- addr1 u1 addr2 u2 )
  SOURCE ">BL BL SKIP
  SOURCE/ S" <" SEARCH
  IF DUP SOURCE/ ROT - FromNameEmail1 EXIT THEN 2DROP
  SOURCE/ S" (" SEARCH
  IF DUP SOURCE/ ROT - FromNameEmail1 EXIT THEN 2DROP
  BEGIN
    >IN @
    NextWord DUP
  WHILE
    S" @" SEARCH NIP NIP
    IF >IN ! FromNameEmail2 EXIT THEN
    DROP
  REPEAT 2DROP DROP
  >IN 0! BL SKIP SOURCE/ -TRAILING S" unknown@email"
;
: FromNameEmail ( addr u -- addr1 u1 addr2 u2 )
  ['] (FromNameEmail) EVALUATE-WITH
  2DUP S" @" SEARCH NIP NIP 0= >R
  2SWAP 2DUP S" @" SEARCH NIP NIP R> AND
  IF EXIT ELSE 2SWAP THEN
;
\ ==========================================================
: (Strip")
\  [CHAR] " PARSE 2DROP [CHAR] " PARSE
  SOURCE ">BL BL SKIP 1 PARSE -TRAILING
;
: (Strip')
\  [CHAR] ' PARSE 2DROP [CHAR] ' PARSE
  SOURCE ">BL BL SKIP 1 PARSE -TRAILING
;
CREATE _Quo CHAR " C,
: Strip"
  2DUP _Quo 1 SEARCH NIP NIP
  IF ['] (Strip") EVALUATE-WITH EXIT THEN
  2DUP S" '" SEARCH NIP NIP
  IF ['] (Strip') EVALUATE-WITH EXIT THEN
;
: (Strip2<)
  [CHAR] < PARSE 2DROP [CHAR] > PARSE
;
: Strip2<
  2DUP S" <" SEARCH NIP NIP
  IF ['] (Strip2<) EVALUATE-WITH THEN
  Strip"
;
: ParseRcpt1 { xt i -- }

  SOURCE FromNameEmail i xt EXECUTE EXIT

\ ------------
  BEGIN
    >IN @ >R
    NextWord DUP
  WHILE
    2DUP S" @" SEARCH NIP NIP
    IF SOURCE DROP R> Strip"
       2SWAP Strip2< i xt EXECUTE EXIT
    ELSE 2DROP RDROP THEN
  REPEAT 2DROP RDROP
;
: ParseRcpt2 { xt i -- i }
  BEGIN
    [CHAR] , PARSE DUP
  WHILE
    i 1+ -> i
    xt i 2SWAP
    ['] ParseRcpt1 EVALUATE-WITH
  REPEAT 2DROP i
;
: ParseRcptXt ( addr u xt -- n )
  0 2SWAP
  ['] ParseRcpt2 EVALUATE-WITH
;


: Is8Bit ( addr u -- flag )
  2DUP S" =?" SEARCH NIP NIP IF 2DROP FALSE EXIT THEN \ уже закодировано
  0 ?DO DUP I + C@ 127 > IF DROP TRUE UNLOOP EXIT THEN LOOP
  DROP FALSE
;
USER uStripCRLFtemp
: (StripCRLF)
  BEGIN
    13 PARSE DUP
  WHILE
    uStripCRLFtemp @ STR+
    >IN 1+! >IN 1+! \ пропустить LF и TAB
\    S"  " uStripCRLFtemp @ STR+
  REPEAT 2DROP
;
: StripCRLF ( addr u -- addr u )
  2DUP CRLF SEARCH NIP NIP 0= IF EXIT THEN
  "" uStripCRLFtemp !
  ['] (StripCRLF) EVALUATE-WITH
  uStripCRLFtemp @ STR@
;
: AddDefEncoding ( addr u ) { mp -- addr u }
\  StripCRLF
  StripLwsp
  2DUP Is8Bit 0= IF EXIT THEN
  S" Content-Type" mp FindMimeHeader 2DUP
  S" indows-1251" SEARCH NIP NIP
  IF 2DROP base64 OVER >R " =?windows-1251?B?{s}?=" STR@ R> FREE DROP
  ELSE
     S" -8" SEARCH NIP NIP
     IF base64 OVER >R " =?UTF-8?B?{s}?=" STR@ R> FREE DROP
     ELSE ( addr u ) \ если в заголовке кодировка не указана, попробуем найти еЄ в первой mime-части
        S" 1" mp GetMimePartMp S" Content-Type" ROT FindMimeHeader  2DUP
        S" indows-1251" SEARCH NIP NIP
        IF 2DROP base64 OVER >R " =?windows-1251?B?{s}?=" STR@ R> FREE DROP
        ELSE
           S" -8" SEARCH NIP NIP
           IF base64 OVER >R " =?UTF-8?B?{s}?=" STR@ R> FREE DROP THEN
        THEN
     THEN
  THEN
;
: Add1251Encoding { a u \ s buf -- a2 u2 }
  \ входна€ строка в Windows-1251, закодировать в ней кириллицу дл€ почтовых заголовков
  u 0= IF a u EXIT THEN
  a u Is8Bit 0= IF a u EXIT THEN
  "" -> s "" -> buf
  u 0 DO
    a I + DUP C@ 127 >
    IF 1 buf STR+
    ELSE
      buf STRLEN
      IF buf STR@ base64 " =?windows-1251?B?{s}?=" s S+ buf STRFREE "" -> buf THEN
      1 s STR+
    THEN
  LOOP
  buf STRLEN
  IF buf STR@ base64 " =?windows-1251?B?{s}?=" s S+ buf STRFREE THEN
  s STR@
;
: GetSubject { mp -- addr u }
  S" Subject" mp FindMimeHeader mp AddDefEncoding
;
: GetFromLine { mp -- addr u }
  S" From" mp FindMimeHeader mp AddDefEncoding
;
: GetToLine { mp -- addr u }
  S" To" mp FindMimeHeader mp AddDefEncoding
;
: GetCcLine { mp -- addr u }
  S" Cc" mp FindMimeHeader mp AddDefEncoding
;
\ ================================= /subject decoding ==================

\ ================================= message decoding ================
: GetFrom { mp -- addr1 u1 addr2 u2 }
  S" From" mp FindMimeHeader DUP 0=
  IF 2DROP S" Reply-To" mp FindMimeHeader THEN
  mp AddDefEncoding
  MimeValueDecode ( ** add bregexp) FromNameEmail
;
CREATE CRLF.CRLF 13 C, 10 C, CHAR . C, 13 C, 10 C,

: StripTrailingEmptyLines { addr u -- addr u }
  addr u + 5 - 5 CRLF.CRLF 5 COMPARE 0= IF u 3 - -> u THEN
  BEGIN
    u 4 > IF addr u + 4 - 4 CRLF.CRLF 5 COMPARE 0=
          ELSE FALSE THEN
  WHILE
    u 2 - -> u
  REPEAT
  addr u
;
: StripLeadingEmptyLines { addr u -- addr u }
  BEGIN
    u 4 > IF addr 2 CRLF COMPARE 0=
          ELSE FALSE THEN
  WHILE
    addr 2 + -> addr
    u 2 - -> u
  REPEAT
  addr u
;
: _>BL ( addr u -- )
  0 ?DO DUP I + C@ 154 = ( OVER I + 1+ C@ 13 = AND) IF BL OVER I + C! THEN LOOP DROP
;
: CRCR>BLCR ( addr u -- )
\ исправление 1—-ного форматировани€ xml-файлов
  0 ?DO DUP I + W@ 0x0D0D = IF 0x0D20 OVER I + W! THEN LOOP DROP
;
: CR>BR
  StripLeadingEmptyLines
  StripTrailingEmptyLines
\  DUP
\  IF
\    S" s/(<)/&lt;/g" BregexpReplace DROP
\    " {s}" STR@ BregexpFree
\    S" s/\n/<br>/g" BregexpReplace DROP
\    " {s}" STR@ BregexpFree
\  THEN
;
: <<escape ( a1 u1 -- a2 u2 )
  2DUP S" <" SEARCH NIP NIP IF >STR DUP " <" " &lt;" replace-str- STR@ THEN
;
CREATE dbCRLFCRLF 13 C, 10 C, 13 C, 10 C,

: debase64_3 ( addr u -- addr1 u1 ) { \ i }
\ верси€, игнорирующа€ пробельные символы внутри исходной строки
\ и игнорирующа€ баг энкодера google
\ и игнорирующа€ невозможные в base64 символы (баг OE6 или MDaemon)

\ отрезаем левые приписки после base64-блока, которые иногда добавл€ютс€ форвардерами почты
  2DUP dbCRLFCRLF 4 SEARCH IF NIP - ELSE 2DROP THEN

  DUP 0= IF 2DROP 4 ALLOCATE THROW abase ! abase @ 0 EXIT THEN
  0 SWAP DUP 4 / 3 * CELL+ ALLOCATE THROW abase ! lbase 0! nbase 0!
  0 ?DO
    OVER I + C@ 32 >
    IF
      OVER I + C@ DUP [CHAR] = =
      IF DROP 0 nbase 1+! TRUE ELSE -AL64 THEN
      IF
        3 i 4 MOD - 0 ?DO 64 * LOOP +
        i 4 MOD 3 = IF abase @ lbase @ + DUP >R !
        R@ C@ R@ 2 CHARS + C@ R@ C! R> 2 CHARS + C!
        3 lbase +! 0 THEN
        i 1+ -> i
      ELSE DROP THEN
    THEN
  LOOP
  NIP ?DUP
  IF \ баг энкодера google - не добавлены == в конце
    8 RSHIFT DUP abase @ lbase @ + DUP >R 1+ C!
    8 RSHIFT R> C!
    2 lbase +!
  THEN
  abase @ lbase @ nbase @ - 0 MAX
;
' debase64_3 TO debase64

USER _LASTMSGHTML
USER uMessageBaseUrl \ устанавливаетс€ вызывающим кодом, если нужно переместить ссылки
USER uMessageMID

: MessagePartName { mp -- a u }
  mp mpNameLen  @ ?DUP IF mp mpNameAddr  @ SWAP StripLwsp MimeValueDecode EXIT THEN
  mp mpFnameLen @ ?DUP IF mp mpFnameAddr @ SWAP StripLwsp MimeValueDecode EXIT THEN
  mp mpCidLen   @ ?DUP IF mp mpCidAddr   @ SWAP EXIT THEN
  S" "
;
: GetMimePartByNameMp { na nu mp -- mp }
  BEGIN
    mp
  WHILE
    mp MessagePartName na nu COMPARE 0=
    IF mp EXIT THEN
    mp mpParts @ ?DUP
    IF na nu ROT RECURSE ?DUP IF EXIT THEN THEN
    mp mpNextPart @ -> mp
  REPEAT
  mp
;
: GetMimePartByName { na nu mp -- addr u }
  na nu mp GetMimePartByNameMp
  ?DUP
  IF -> mp
    uBodySectionHeader @
    IF mp mpHeaderAddr @ mp mpHeaderLen @
    ELSE mp mpBodyAddr @ mp mpBodyLen @ THEN
  ELSE S" " THEN
;
: __IsUtf8 ( addr u -- flag )
  \ ’ак, но как-то надо читать нечитабельные письма...

  0 ?DO DUP I + C@ DUP 0x80 0xC0 WITHIN
        OVER 0xA8 <> AND OVER 0xB8 <> AND \ ®Є
        OVER 0xAB <> AND OVER 0xBB <> AND \ <<>>
        OVER 0x93 <> AND OVER 0x94 <> AND \ ""
        OVER 0x96 <> AND OVER 0x97 <> AND \ --
        OVER 0xB3 <> AND OVER 0xBA <> AND \ .ua
        SWAP 0xA0 <> AND
        IF DROP TRUE UNLOOP EXIT THEN
    LOOP
  DROP FALSE
;
: GetMimePartByNameDecoded { na nu mp -- addr u }
  na nu mp GetMimePartByNameMp
  ?DUP
  IF -> mp
    uBodySectionHeader @
    IF mp mpHeaderAddr @ mp mpHeaderLen @
    ELSE mp mpBodyAddr @ mp mpBodyLen @
       S" Content-Transfer-Encoding" mp FindMimeHeader S" quoted-printable"
       COMPARE-U 0= IF dequotep_ns THEN
       S" Content-Transfer-Encoding" mp FindMimeHeader S" base64"
       COMPARE-U 0= IF debase64 THEN
       mp mpCharsetAddr @ mp mpCharsetLen @ ?DUP
           IF CHARSET-DECODERS-WL SEARCH-WORDLIST IF EXECUTE THEN
           ELSE DROP
\              2DUP __IsUtf8 IF UTF8> THEN
           THEN
    THEN
  ELSE S" " THEN
;
USER uMpAltCnt
USER uSkipAttach
USER uAllowMpAlt
VARIABLE vCalendarRenderer

: MessageHtml { mp s \ tf_dq tf_db tf_pl istext -- addr u }

\ ¬нимание! ѕри не-windows-1251 кодировках сообщение перекодируетс€ на
\ месте (но кодировка в заголовке не мен€етс€), поэтому дважды дл€ одного mp
\ вызывать MessageHtml нельз€, надо использовать LastMsgHtml (см. ниже).

\  mp GetFrom DUP IF 2DUP S" unknown@email" COMPARE
\                    IF 2SWAP " <h4>{s} [{s}]</h4>" s S+ ELSE 2DROP 2DROP THEN
\                 ELSE 2DROP 2DROP THEN
\  mp GetSubject ?DUP IF MimeValueDecode " <h4>{s}</h4>" s S+ ELSE DROP THEN
\  S" Date" mp FindMimeHeader ?DUP IF  MimeValueDecode " <h4>{s}</h4>" s S+ ELSE DROP THEN
  " <table class='message' border='1'>" s S+
  BEGIN
    " <tr><td>" s S+
    mp mpIsMultipart @ mp mpIsMessage OR mp mpParts @ AND
    IF mp mpSubTypeAddr @ mp mpSubTypeLen @ S" alternative" COMPARE-U 0= IF uMpAltCnt 1+! THEN
       mp mpParts @ s RECURSE 2DROP
       uMpAltCnt 0!
    ELSE mp mpTypeAddr @ mp mpTypeLen @ 
         2DUP
         S" text" COMPARE-U 0= ROT ROT
         S" message" COMPARE-U 0=
         OR DUP -> istext
         mp mpCdispLen @ 0= AND
         mp mpCdispAddr @ mp mpCdispLen @ S" inline" SEARCH NIP NIP istext AND OR
         IF
           mp mpBodyAddr @ mp mpBodyLen @

           0 -> tf_dq 0 -> tf_db
           S" Content-Transfer-Encoding" mp FindMimeHeader S" quoted-printable"
           COMPARE-U 0= IF dequotep_ns OVER -> tf_dq THEN
           S" Content-Transfer-Encoding" mp FindMimeHeader S" base64"
           COMPARE-U 0= IF debase64 OVER -> tf_db THEN
\           2DUP _>BL ( отключено: портит unicode-букву " " )
           mp mpCharsetAddr @ mp mpCharsetLen @ ?DUP
           IF CHARSET-DECODERS-WL SEARCH-WORDLIST IF EXECUTE THEN
           ELSE DROP
              2DUP __IsUtf8 IF UTF8> THEN
           THEN

           0 -> tf_pl

           mp mpSubTypeAddr @ mp mpSubTypeLen @ S" plain" COMPARE-U 0=
           IF uMpAltCnt @ uAllowMpAlt @ 0= AND
              IF 2DROP S" <!-- text/plain alternative was here -->"
              ELSE
                <<escape CR>BR mp MessagePartName
                " <pre class='plain' title='{s}'>{s}</pre>" DUP -> tf_pl STR@
              THEN
           THEN

           mp mpSubTypeAddr @ mp mpSubTypeLen @ S" rfc822" COMPARE-U 0=
           IF <<escape CR>BR mp MessagePartName
              " <pre class='plain' title='{s}'>{s}</pre>" DUP -> tf_pl STR@
           THEN


           mp mpSubTypeAddr @ mp mpSubTypeLen @ S" calendar" COMPARE-U 0=
           IF vCalendarRenderer @
              IF mp MessagePartName vCalendarRenderer @ EXECUTE
              ELSE
                <<escape CR>BR mp MessagePartName
                " <pre class='plain' title='{s}'>{s}</pre>"
              THEN
              DUP -> tf_pl STR@
           THEN

           mp mpSubTypeAddr @ mp mpSubTypeLen @ S" xml" COMPARE-U 0=
           IF 2DUP CRCR>BLCR <<escape mp MessagePartName
              " <pre class='plain' title='{s}'>{s}</pre>" DUP -> tf_pl STR@

              mp MessagePartName 2DUP
              uMessageBaseUrl @ ?DUP IF STR@ ELSE S" " THEN
              mp mpCidAddr @ mp mpCidLen @ DUP 0= IF 2DROP mp MessagePartName THEN
              " <img src='/e4a/icons/attach.png' width='16' height='16'/>
<a id='cid:{s}' href='{s}{s}' class='inline_att'>{s}</a><br/>{s}" STR@

           THEN
           s STR+
           ( tf_dq ?DUP IF FREE DROP THEN) tf_db ?DUP IF FREE DROP THEN
           \ dequotep возвращает бывш.str5-строку, а не ALLOCATEd-буфер, поэтому тут нельз€ делать FREE!
           tf_pl ?DUP IF STRFREE THEN
         ELSE uSkipAttach @ 0=
            IF
              mp mpCdispAddr @ mp mpCdispLen @ S" attachment" COMPARE-U 0=
              IF
                " <img src='/e4a/icons/attach.png' width='16' height='16'/> " s S+
                mp mpSubTypeAddr @ mp mpSubTypeLen @
                mp mpTypeAddr @ mp mpTypeLen @
                " <img src='/e4a/icons/{s}_{s}.png' width='16' height='16'/> " s S+
              THEN
              mp MessagePartName 2DUP
              uMessageBaseUrl @ ?DUP IF STR@ ELSE S" " THEN
              mp mpCidAddr @ mp mpCidLen @ DUP 0= IF 2DROP mp MessagePartName THEN
              " <a id='cid:{s}' href='{s}{s}' class='inline_att'>{s}</a>" s S+
            THEN
         THEN
    THEN
    mp mpNextPart @ DUP -> mp 0=
    " </td></tr>{CRLF}" s S+
  UNTIL
  " </table>{CRLF}" s S+
  s DUP _LASTMSGHTML ! STR@
;
: MessageHtml2 { mp s \ tf_dq tf_db tf_pl istext -- addr u }

\ ¬нимание! ѕри не-windows-1251 кодировках сообщение перекодируетс€ на
\ месте (но кодировка в заголовке не мен€етс€), поэтому дважды дл€ одного mp
\ вызывать MessageHtml нельз€, надо использовать LastMsgHtml (см. ниже).

\  mp GetFrom DUP IF 2DUP S" unknown@email" COMPARE
\                    IF 2SWAP " <span class='msg_from_name'>{s}</span><span class='msg_from_email'>{s}</span>" s S+ ELSE 2DROP 2DROP THEN
\                 ELSE 2DROP 2DROP THEN
\  mp GetSubject ?DUP IF MimeValueDecode " <h4>{s}</h4>" s S+ ELSE DROP THEN
\  S" Date" mp FindMimeHeader ?DUP IF  MimeValueDecode " <span class='msg_date'>{s}</span>{CRLF}" s S+ ELSE DROP THEN
\  " <table border='1'>" s S+
  BEGIN
\    " <tr><td>" s S+
    mp mpIsMultipart @ mp mpIsMessage OR mp mpParts @ AND
    IF mp mpParts @ s RECURSE 2DROP
    ELSE mp mpTypeAddr @ mp mpTypeLen @
         2DUP
         S" text" COMPARE-U 0= ROT ROT
         S" message" COMPARE-U 0=
         OR DUP -> istext
         mp mpCdispLen @ 0= AND
         mp mpCdispAddr @ mp mpCdispLen @ S" inline" SEARCH NIP NIP istext AND OR
         IF
           mp mpBodyAddr @ mp mpBodyLen @

           0 -> tf_dq 0 -> tf_db
           S" Content-Transfer-Encoding" mp FindMimeHeader S" quoted-printable"
           COMPARE-U 0= IF dequotep_ns OVER -> tf_dq THEN
           S" Content-Transfer-Encoding" mp FindMimeHeader S" base64"
           COMPARE-U 0= IF debase64 OVER -> tf_db THEN
\           2DUP _>BL ( отключено: портит unicode-букву " " )
           mp mpCharsetAddr @ mp mpCharsetLen @ ?DUP
           IF CHARSET-DECODERS-WL SEARCH-WORDLIST IF EXECUTE THEN
           ELSE DROP
              2DUP __IsUtf8 IF UTF8> THEN
           THEN

           0 -> tf_pl
\           mp mpSubTypeAddr @ mp mpSubTypeLen @ S" rfc822" COMPARE-U 0=
\           IF CR>BR " <pre class='plain'>{s}</pre>" DUP -> tf_pl STR@ THEN
           s STR+
           ( tf_dq ?DUP IF FREE DROP THEN) tf_db ?DUP IF FREE DROP THEN
           \ dequotep возвращает бывш.str5-строку, а не ALLOCATEd-буфер, поэтому тут нельз€ делать FREE!
           tf_pl ?DUP IF STRFREE THEN
         ELSE mp mpTypeAddr @ mp mpTypeLen @ s STR+ THEN
    THEN
    mp mpNextPart @ DUP -> mp 0=
\    " </td></tr>" s S+
  UNTIL
\  " </table>" s S+
  s DUP _LASTMSGHTML ! STR@
;

: LastMsgHtml
  _LASTMSGHTML @ ?DUP IF STR@ ELSE S" " THEN
;
: LastMsgHtmlFree
  _LASTMSGHTML @ ?DUP IF STRFREE _LASTMSGHTML 0! THEN
;

: SaveMsgAtt1 ( da du na nu mp1 -- )
  DROP WFILE
;
: ForEachAtt { mp xt \ tf_dq tf_db -- }
\ ¬ыполнить xt ( da du na nu mp1 -- ) дл€ всех вложений сообщени€ mp

  BEGIN
    mp mpIsMultipart @ mp mpIsMessage OR mp mpParts @ AND
    IF mp mpParts @ xt RECURSE
    ELSE 
       mp mpCdispAddr @ mp mpCdispLen @ S" attachment" COMPARE-U 0=
       mp mpTypeAddr @ mp mpTypeLen @ S" text" COMPARE-U OR
       \ если Content-Disposition="attachment" или Content-Type не текст
       \ то обрабатываем как вложение - выполн€ем дл€ него xt
       IF
         mp mpBodyAddr @ mp mpBodyLen @

         0 -> tf_dq 0 -> tf_db
         S" Content-Transfer-Encoding" mp FindMimeHeader S" quoted-printable"
         COMPARE-U 0= IF dequotep_ns OVER -> tf_dq THEN
         S" Content-Transfer-Encoding" mp FindMimeHeader S" base64"
         COMPARE-U 0= IF debase64 OVER -> tf_db THEN
         mp mpCharsetAddr @ mp mpCharsetLen @ ?DUP
           IF CHARSET-DECODERS-WL SEARCH-WORDLIST IF EXECUTE THEN
           ELSE DROP
\              2DUP __IsUtf8 IF UTF8> THEN
           THEN

         ( da du ) mp MessagePartName mp  xt EXECUTE

         ( tf_dq ?DUP IF FREE DROP THEN) tf_db ?DUP IF FREE DROP THEN
         \ dequotep возвращает бывш.str5-строку, а не ALLOCATEd-буфер, поэтому тут нельз€ делать FREE!
       THEN
    THEN
    mp mpNextPart @ DUP -> mp 0=
  UNTIL
;

\ ================================= message decoding ================
\EOF

REQUIRE STR@             ~ac/lib/str2.f

: TTCR ( namea nameu emaila emailu i -- )
  .
  TYPE CR
  TYPE CR
;
"  'Andrey Cherezov'  <ac@eserv.ru> , 
{''}Eserv Support{''} support@eserv.ru " STR@ ' TTCR ParseRcptXt .
