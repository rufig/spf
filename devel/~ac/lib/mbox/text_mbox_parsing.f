( Разбор файлов-почтовых ящиков. А.Черезов 1998-2000 )

REQUIRE {          ~ac/lib/locals.f
REQUIRE COMPARE-U  ~ac/lib/string/compare-u.f
REQUIRE UPPERCASE  ~ac/lib/string/uppercase.f
REQUIRE TIB>BL     ~ac/lib/string/conv.f
REQUIRE inList     ~ac/lib/list/str_list.f
REQUIRE InVoc{     ~ac/lib/transl/vocab.f

InVoc{ TextMbox

USER InputFile
USER DotDelimited
USER IsTest
USER DOT-FOUND

CREATE ZS 0 , : ZEROSTRING ZS 1 ;

: COPYBUFC ( addr1 u1 -- addr2 )
  DUP CELL+ CHAR+ ALLOCATE THROW DUP >R CELL+ SWAP DUP >R MOVE
  R> R> SWAP 2DUP + CELL+ 0 SWAP C!
  OVER !
;
: isBinary ( addr u -- flag )
  0 ?DO DUP I + C@ DUP BL < SWAP 9 <> AND IF UNLOOP EXIT THEN LOOP
  DROP FALSE
;

: FEX ( c-addr -- ... )
  FIND IF EXECUTE THEN
;
: -d   \ если сообщения разделяются точкой, и обработка NewMessage[?] не нужна
  TRUE DotDelimited !
;
: -nd FALSE DotDelimited ! ;

: -t
  TRUE IsTest !
;
: isTest IsTest @ ;

: DefaultLineProcessing
  C" LineProcessor" FEX
;
\ -----------------------------
USER MODE
USER KEYWORD
USER KWL
USER LAST-FIELD
USER aMessageStartPos CELL USER-ALLOT

1 CONSTANT ModeKeyWord
2 CONSTANT ModeMessageEnd
3 CONSTANT ModeMessageBody

: WriteLastMessageNC ( h -- )
  { h \ p1 p2 size }
  InputFile @ FILE-POSITION THROW -> p1 -> p2
  aMessageStartPos 2@ InputFile @ REPOSITION-FILE THROW
  p2 p1 aMessageStartPos 2@ DNEGATE D+ D>S -> size
  10000 ALLOCATE THROW \ addr
  BEGIN
    DUP DUP 10000 size MIN
    InputFile @ READ-FILE THROW DUP \ addr addr size size
    size OVER - 0 MAX -> size
  WHILE
    h WRITE-FILE THROW
  REPEAT 2DROP
  FREE THROW
;
: WriteLastMessage ( h -- )
  DUP >R WriteLastMessageNC
  R> CLOSE-FILE THROW
;
: FindField ( addr u -- af true | false )
  { a u }
  KWL @
  BEGIN
    DUP
  WHILE
    DUP CELL+ @ COUNT a u COMPARE-U 0=
    IF CELL+ CELL+ TRUE EXIT THEN
    @
  REPEAT
;
: CreateField ( addr u -- af )
  { a u \ node name }
  3 CELLS ALLOCATE THROW -> node
  node 3 CELLS ERASE
  u CHAR+ ALLOCATE THROW -> name
  u name C! a name CHAR+ u MOVE
  name COUNT UPPERCASE
  name node CELL+ !
  KWL @ node !  node KWL !
  node CELL+ CELL+
;
: FreeField ( af -- )
  DUP @ ?DUP IF FREE THROW THEN
  0!
;
: FreeKWL ( -- )
  KWL @
  BEGIN
    DUP
  WHILE
    DUP CELL+ CELL+ FreeField
    DUP @ SWAP FREE THROW
  REPEAT KWL !
;
: PrintKWL ( -- )
  KWL @
  BEGIN
    DUP
  WHILE
    ." @"
    DUP CELL+ @ COUNT TYPE ." ="
    DUP CELL+ CELL+ @ XCOUNT TYPE CR
    @
  REPEAT DROP
;
: GetField ( af -- addr u )
  ?DUP IF @ ?DUP IF XCOUNT ELSE S" " THEN 
       ELSE S" " THEN
;
: GetFieldValue ( addr u -- addr2 u2 )
  FindField IF GetField ELSE S" " THEN
;
: EnumFieldsByValue ( addr u xt -- )
  { a u xt }
  KWL @
  BEGIN
    DUP
  WHILE
    DUP CELL+ CELL+ GetField a u COMPARE-U 0=
    IF DUP CELL+ @ COUNT xt EXECUTE THEN
    @
  REPEAT
;
: SetFieldData ( addr u af -- )
  { a u af \ mem }
\  1 PARSE -> u -> a
  af FreeField
  u CELL+ ALLOCATE THROW -> mem
  u mem ! a mem CELL+ u MOVE
  mem af !
;
: SetFieldValue ( af -- )
  1 PARSE ROT SetFieldData
;
: AddFieldData ( addr u af -- )
  { a u af \ mem oldmem oa ou }
  af @ -> oldmem
  oldmem 0= IF a u af SetFieldData EXIT THEN
  oldmem @ -> ou  oldmem CELL+ -> oa
  u ou + CELL+ DUP ALLOCATE THROW -> mem  1 CELLS - mem !
  oa mem CELL+ ou MOVE
  a mem CELL+ ou + u MOVE
  mem af !
  oldmem FREE THROW
;  
: AddFieldValue ( af -- )
  { af \ a u mem oldmem oa ou }
  af @ -> oldmem
  oldmem 0= IF af SetFieldValue EXIT THEN
  oldmem @ -> ou  oldmem CELL+ -> oa
  1 PARSE -> u -> a
  u ou + CELL+ CHAR+ DUP ALLOCATE THROW -> mem  1 CELLS - mem !
  oa mem CELL+ ou MOVE
  BL mem CELL+ ou + C!
  a mem CELL+ ou + CHAR+ u MOVE
  mem af !
  oldmem FREE THROW
;
: AddField ( addr u -- )
  255 MIN { a u }
  a u FindField
  IF DUP LAST-FIELD ! AddFieldValue
  ELSE a u CreateField DUP LAST-FIELD ! BL SKIP SetFieldValue THEN
;
: KeyWordContinued
  LAST-FIELD @ AddFieldValue
  isTest IF ." @KeyWordContinued: " SOURCE TYPE CR THEN
;
: LastKeywordEnd
  isTest IF ." @LastKeywordEnd." CR THEN
  KEYWORD 0!
;
: ProcessKeyWord ( addr u -- )
  AddField
  isTest IF ." @ProcessKeyWord: " SOURCE TYPE CR THEN
;
: HeaderEnd
  isTest IF ." @HeaderEnd." CR THEN
;
: MessageEnd
  MODE @ ModeMessageEnd = IF EXIT THEN \ [todo]
  isTest IF ." @MessageEnd." CR PrintKWL THEN
  FreeKWL
;
: NewMessage[?]
  isTest IF ." @NewMessage[?]." CR THEN
;
: NewMessage
  MessageEnd
  isTest IF ." @NewMessage." CR THEN
  InputFile @ FILE-POSITION THROW
  SOURCE NIP 2+ S>D DNEGATE D+ \ отняли размер текущей строки
  aMessageStartPos 2!
;
: TextEnd
  C" MessageEnd" FEX
  isTest IF ." @TextEnd." CR THEN
;
: BodySeparatorLine
  isTest IF ." @BodySeparatorLine." CR THEN
;
: OrphanLine
  isTest IF ." @OrphanLine: " SOURCE TYPE CR THEN
;
: MessageLine
  isTest IF ." @MessageLine: " SOURCE TYPE CR THEN
;
: JustLine
  MODE @ ModeMessageBody =
  IF C" MessageLine" FEX
  ELSE C" OrphanLine" FEX THEN
;
: ParseRcpt ( addr u list -- )
  { a u l \ t t# in }
\  SAVE-INPUT
  >IN @ -> in #TIB @ -> t# TIB -> t
  a u asTib
  SOURCE TIB,>BL

  BEGIN
    BL WORD COUNT DUP
  WHILE
    2DUP S" @" SEARCH NIP NIP
    IF Strip<
       2DUP l inList
       IF 2DROP
       ELSE COPYBUFC l AddNode THEN
    ELSE 2DROP THEN
  REPEAT 2DROP

\  RESTORE-INPUT DROP
  t t# asTib in >IN !
;
: ParseRcpt(For) ( addr u list -- )
  { a u l \ t t# in }
\  SAVE-INPUT
  >IN @ -> in #TIB @ -> t# TIB -> t
  a u asTib
  SOURCE TIB,>BL

  BEGIN
    BL WORD COUNT DUP
  WHILE
    S" for" COMPARE 0=
    IF 
       BL WORD COUNT
       2DUP S" @" SEARCH NIP NIP
       IF Strip<
          2DUP l inList
          IF 2DROP
          ELSE COPYBUFC l AddNode THEN
       ELSE 2DROP THEN
    THEN
  REPEAT 2DROP

\  RESTORE-INPUT DROP
  t t# asTib in >IN !
;
: DefaultLineProcessor

  SOURCE isBinary IF EXIT THEN
  SOURCE TIB>BL    ( все TABы преобразовали в SPACE)

  TIB C@ BL = MODE @ ModeKeyWord = AND
  IF C" KeyWordContinued" FEX EXIT THEN
  ( если строка начинается с пробела, а до этого мы обрабатывали
    строки, начинающиеся с ключевых слов, то это продолжение строки )

  SOURCE NIP 0= MODE @ ModeKeyWord = AND
  IF C" LastKeywordEnd" FEX
     C" HeaderEnd" FEX
     C" BodySeparatorLine" FEX
     ModeMessageBody MODE ! EXIT
  THEN
  ( если пустая строка после ключевой строки, то это конец заголовка )

  SOURCE NIP 0=
  IF JustLine EXIT THEN
  ( если просто пустая строка, [не после заголовка],
    то это или пустая строка в теле письма, либо "между письмами")

  TIB C@ BL = IF JustLine EXIT THEN
  ( ниже нас интересуют только строки, начинающиеся со слов,
    а это была строка с пробелом в начале, причем не продолжение keyword )

  SOURCE S" ." COMPARE 0= DUP IF TRUE DOT-FOUND ! THEN
  SOURCE ZEROSTRING SEARCH NIP NIP OR
  MODE @ ModeMessageEnd <> AND
  IF C" MessageEnd" FEX ModeMessageEnd MODE ! EXIT THEN
  ( гарантированный конец письма )

  BL PARSE 2DUP + 1- C@ [CHAR] : = >R
  2DUP S" Received" COMPARE 0= R> OR    ( addr u flag )
  MODE @ ModeMessageBody <> AND
  IF ( ключевая строка, т.е. с ":" после первого слова, или "магическая" )

     MODE @ ModeKeyWord =
     IF ( предыдущая ключевая на этом закончилась )
        C" LastKeywordEnd" FEX

     ELSE ( до этого ключевых не было, похоже на начало следующ. письма)
        MODE @ ModeMessageEnd =
        IF ( гарантированное начало следующего письма, т.к.
             перед этим была строка с точкой)
           C" NewMessage" FEX
        ELSE ( может быть начало письма, а может и ключевое слово
               внутри письма...
               ненормальная ситуация в случае файлов Eserv
             )
           DotDelimited @ 0= IF C" NewMessage[?]" FEX THEN
        THEN
        ModeKeyWord MODE !
     THEN
     ( addr u ) C" ProcessKeyWord" FEX
  ELSE 2DROP JustLine THEN
;
\ -----------------------------
: LineProcessor DefaultLineProcessor ;
: DefaultTextEnd C" TextEnd" FEX ;

: ProcessFile
  DOT-FOUND 0!
  BEGIN
    REFILL
  WHILE
    DefaultLineProcessing
  REPEAT
  DefaultTextEnd
;

\ ****************************** Interface ********************************

Public{

: TextMbox:DotFound? DOT-FOUND @ ;
: TextMbox:ReadIndexH ( file-handle -- )
  { h \ source }
  SOURCE-ID -> source
  h TO SOURCE-ID
  h InputFile !
  -d \ -t
  ModeMessageEnd MODE !
  ALSO TextMbox
  C" ProcessFile" FEX
  PREVIOUS
  source TO SOURCE-ID
;

: GetField      GetField      ;
: SetFieldData  SetFieldData  ;
: GetFieldValue GetFieldValue ;

}Public

\ ****************************** /Interface ********************************

}PrevVoc
