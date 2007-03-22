REQUIRE STR@          ~ac/lib/str5.f
REQUIRE COMPARE-U     ~ac/lib/string/compare-u.f

VECT vParseMime
USER MimePart           \ временный указатель на текущую mime-часть
USER CurrentHeader      \ временный указатель на текущее поле заголовка
USER NestingLevel       \ текущий уровень вложенности
USER uBodySectionHeader \ модификатор. ≈сли TRUE, то GetMimePart отдаст заголовок
USER Rfc822MessageSize

0
CELL -- mhNextHeader
CELL -- mhNameAddr
CELL -- mhNameLen
CELL -- mhValueAddr
CELL -- mhValueLen
CONSTANT /MimeHeader

0
CELL -- mpNextPart
CELL -- mpHeaderList
CELL -- mpPartAddr
CELL -- mpPartLen
CELL -- mpHeaderAddr
CELL -- mpHeaderLen
CELL -- mpBodyAddr
CELL -- mpBodyLen
CELL -- mpBoundaryAddr
CELL -- mpBoundaryLen
CELL -- mpCharsetAddr
CELL -- mpCharsetLen
CELL -- mpLevel
CELL -- mpIndex
CELL -- mpIsMultipart
CELL -- mpIsMessage
CELL -- mpTypeAddr
CELL -- mpTypeLen
CELL -- mpSubTypeAddr
CELL -- mpSubTypeLen
CELL -- mpParts
CELL -- mpChilds#
CONSTANT /MimePart

: EnumMimeHeaders { mp xt -- }
  mp mpHeaderList @
  BEGIN
    DUP
  WHILE
    DUP xt EXECUTE
    mhNextHeader @
  REPEAT DROP
;
: FindMimeHeader { addr u mp -- addr2 u2 }
  mp mpHeaderList @
  BEGIN
    DUP
  WHILE
    DUP mhNameAddr @
    OVER mhNameLen @ addr u COMPARE-U 0=
    IF DUP mhValueAddr @ SWAP mhValueLen @ EXIT THEN
    mhNextHeader @
  REPEAT DROP
  \ S" "
  0 0 ( =NIL, а не "" )
;

: ParseHeaderLineNew
  /MimeHeader ALLOCATE THROW DUP CurrentHeader @ mhNextHeader !
  CurrentHeader !
  TIB CurrentHeader @ mhNameAddr !
  [CHAR] : PARSE CurrentHeader @ mhNameLen ! DROP
  SkipDelimiters
  TIB >IN @ + CurrentHeader @ mhValueAddr !
  1 PARSE CurrentHeader @ mhValueLen ! DROP
;
: ParseHeaderLineCont
  SOURCE NIP LTL @ + CurrentHeader @ mhValueLen +!
;
: ParseHeaderLine  ( -- ) \ на входе в TIB строка заголовка
  TIB C@ IsDelimiter
  IF ParseHeaderLineCont ELSE ParseHeaderLineNew THEN
;
WORDLIST CONSTANT CP-PARAMS
GET-CURRENT CP-PARAMS SET-CURRENT
: charset MimePart @ mpCharsetLen ! MimePart @ mpCharsetAddr ! ;
: boundary MimePart @ mpBoundaryLen ! MimePart @ mpBoundaryAddr ! ;
: Charset CP-PARAMS::charset ;
: Boundary CP-PARAMS::boundary ;
: CHARSET CP-PARAMS::charset ;
: BOUNDARY CP-PARAMS::boundary ;
SET-CURRENT

: EvalParams ( valuea valueu namea nameu -- )
  CP-PARAMS SEARCH-WORDLIST IF EXECUTE ELSE 2DROP THEN
;
: SetContentType { addr u \ a -- }
  addr u S" /" SEARCH
  IF OVER -> a 1- MimePart @ mpSubTypeLen ! 1+ MimePart @ mpSubTypeAddr !
     addr a OVER -
  THEN
  2DUP S" multipart" COMPARE-U 0= MimePart @ mpIsMultipart !
  S" Content-Disposition" MimePart @ FindMimeHeader ?DUP IF S" attachment" SEARCH NIP NIP 0= ELSE DROP TRUE THEN
  IF
    2DUP S" message"   COMPARE-U 0= MimePart @ mpIsMessage !
  THEN
  MimePart @ mpTypeLen ! MimePart @ mpTypeAddr !

  MimePart @ mpSubTypeAddr @ MimePart @ mpSubTypeLen @
  S" rfc822" COMPARE-U IF MimePart @ mpIsMessage 0! THEN
;
: ParseParamsWith { xtp -- }
  [CHAR] = PARSE -TRAILING
  SkipDelimiters
  PeekChar [CHAR] " = IF >IN 1+! [CHAR] " ELSE 1 THEN PARSE
  2SWAP xtp EXECUTE
;
USER uPhParamNum

: (ParseHeaderWith) { xt xtp -- }
  SkipDelimiters [CHAR] ; PARSE -TRAILING
  xt EXECUTE
  uPhParamNum 0!
  BEGIN
    SkipDelimiters [CHAR] ; PARSE -TRAILING DUP
  WHILE
    uPhParamNum 1+!
    xtp ROT ROT ['] ParseParamsWith EVALUATE-WITH
  REPEAT 2DROP
;
: ParseHeaderWith { addr u xt xtp mp -- }
  addr u mp FindMimeHeader
  xt xtp 2SWAP ['] (ParseHeaderWith) EVALUATE-WITH
;
: ParseContentType
  S" Content-Type" ['] SetContentType ['] EvalParams MimePart @
  ParseHeaderWith
  MimePart @ mpTypeLen @ 0=
  IF S" text/plain" SetContentType THEN
;
: ParseHeader
  /MimePart ALLOCATE THROW 
  DUP MimePart !
  mpHeaderList CurrentHeader ! \ псевдозаголовок, указатель на список
  NestingLevel @ MimePart @ mpLevel !
  1 MimePart @ mpIndex ! \ перезапишетс€ при выходе, если была рекурси€
  SOURCE MimePart @ mpPartLen ! MimePart @ mpPartAddr !

  TIB MimePart @ mpHeaderAddr !
  BEGIN
    13 PARSE DUP
    TIB >IN @ + C@ 10 = IF >IN 1+! THEN
  WHILE
    ['] ParseHeaderLine EVALUATE-WITH
  REPEAT 2DROP
  >IN @ MimePart @ mpHeaderLen !
  ParseContentType
;
: PartBoundary ( -- addr flag )
  SOURCE SWAP >IN @ + SWAP >IN @ - 0 MAX
  MimePart @ mpBoundaryLen @ 0= IF DROP FALSE EXIT THEN
  2DUP
  MimePart @  mpBoundaryAddr @ MimePart @ mpBoundaryLen @ " {s}{CRLF}" STR@ SEARCH
  IF 2SWAP 2DROP TRUE 
  ELSE 2DROP MimePart @  mpBoundaryAddr @ MimePart @ mpBoundaryLen @ " {s}--" STR@ SEARCH THEN
  IF
    DROP DUP 4 - SWAP
    MimePart @ mpBoundaryLen @ + TIB - >IN !
    TIB >IN @ + 2 S" --" COMPARE 0<> IF 2 >IN +! TRUE EXIT THEN
    4 >IN +! TRUE
  ELSE DROP FALSE THEN
;
: ParseMimeX { addr u i \ mp ch -- mp }
  MimePart @ -> mp
  CurrentHeader @ -> ch
  CurrentHeader 0! MimePart 0!
  NestingLevel 1+!
  addr u ['] vParseMime EVALUATE-WITH \ рекурси€
  i OVER mpIndex !
  NestingLevel @ 1- NestingLevel !
  ch CurrentHeader !
  mp MimePart !
;
: ParseMessagePart { \ mp ch r -- }
  SOURCE >IN @ - 0 MAX  SWAP >IN @ + SWAP 1 ParseMimeX -> r
  MimePart @ -> mp
  CurrentHeader @ -> ch
  CurrentHeader 0! MimePart 0!
  NestingLevel 1+!
  vParseMime
  1 OVER mpIndex !
  NestingLevel @ 1- NestingLevel !
  ch CurrentHeader !
  mp MimePart !
  MimePart @ mpParts !
;
: ParseMultipartBody { \ i pp -- }
  PartBoundary NIP 0= IF EXIT THEN
  BEGIN
    TIB >IN @ +
    PartBoundary
  WHILE
    i 1+ -> i
    OVER -
    i ParseMimeX
    i MimePart @ mpChilds# !
    DUP i 1 = IF MimePart @ mpParts ! 
              ELSE pp mpNextPart ! THEN
    -> pp
  REPEAT 2DROP
;
: ParsePlainBody
;
: Lines# ( addr u -- n )
  0 >R
  BEGIN
    CRLF SEARCH
  WHILE
    R> 1+ >R
    2- SWAP 2+ SWAP
  REPEAT 2DROP R>
;
: GetMimePart { addr u mp \ n -- addr2 u2 }
  mp mpIsMultipart @ IF addr u " 1.{s}" STR@ -> u -> addr THEN
  BEGIN
    mp 0= IF S" " EXIT THEN
    u 0 >
  WHILE
    0 0 addr u >NUMBER -> u -> addr D>S -> n
    BEGIN
      mp 0= IF S" " EXIT THEN
      mp mpIndex @ n <>
    WHILE
      mp mpNextPart @ -> mp
    REPEAT
    u 0 > IF addr 1+ -> addr 
             u 1- -> u
             mp mpParts @ -> mp
          THEN
  REPEAT
  uBodySectionHeader @
  IF mp mpHeaderAddr @ mp mpHeaderLen @
  ELSE mp mpBodyAddr @ mp mpBodyLen @ THEN
;
: ParseBody
  TIB >IN @ + MimePart @ mpBodyAddr ! 
  #TIB @ >IN @ - 0 MAX MimePart @ mpBodyLen !
  MimePart @ mpIsMultipart @
  IF ParseMultipartBody 
  ELSE MimePart @ mpIsMessage @
       IF ParseMessagePart
       ELSE ParsePlainBody THEN
  THEN
;
: ParseMime ( -- mp ) \ на входе в TIB сообщение
  ParseHeader
  ParseBody
  MimePart @
;
' ParseMime TO vParseMime

: ParseMessageText ( addr u -- mp )

  2DUP + 5 - 5 " {CRLF}.{CRLF}" DUP >R STR@ COMPARE 0= R> STRFREE
  IF 3 - THEN DUP Rfc822MessageSize !
  ['] ParseMime EVALUATE-WITH
;

: ParseMessageFile { addr u -- mp }
  addr u FILE 

  2DUP 4096 MIN S" rom:" SEARCH NIP NIP 0=
  IF 2DROP LastFileFree \ DROP FREE THROW _LASTFILE 0!
    addr u
  " From: message_parser
To: you
Subject: {s} - not a valid message file

not a valid message file
" STR@
  THEN

  ParseMessageText
;
