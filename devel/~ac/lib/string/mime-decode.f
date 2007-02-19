( rfc2231:

  charset := <registered character set name>
  language := <registered language tag [RFC-1766]>
  The ABNF given in RFC 2047 for encoded-words is:
  encoded-word := "=?" charset "?" encoding "?" encoded-text "?="
  This specification changes this ABNF to:
  encoded-word := "=?" charset ["*" language] "?" encoded-text "?="
  encoded-text = 1*<Any printable ASCII character other than "?" or SPACE>
                  ; but see "Use of encoded-words in message
                  ; headers", section 5


  rfc2045: base64, quotted printable
)

REQUIRE {             ~ac/lib/locals.f
REQUIRE "             ~ac/lib/str2.f
REQUIRE base64        ~ac/lib/string/conv.f
REQUIRE COMPARE-U     ~ac/lib/string/compare-u.f
REQUIRE SPLIT-        ~pinka/samples/2005/lib/split.f 

VOCABULARY CHARSET-DECODERS 
GET-CURRENT ALSO CHARSET-DECODERS DEFINITIONS
: windows-1251 ;
: koi8-r KOI>WIN ;
: Koi8-r KOI>WIN ;
: KOI8-R KOI>WIN ;
GET-CURRENT
PREVIOUS SWAP SET-CURRENT CONSTANT CHARSET-DECODERS-WL

: dequotep ( addr u -- addr2 u2 ) { \ s c }
  "" -> s
  BASE @ >R HEX
  2DUP + >R DROP
  BEGIN
    DUP R@ <
  WHILE
    DUP C@ DUP [CHAR] = = 
        IF DROP 1+ DUP 2+ SWAP 2 0 0 2SWAP >NUMBER 2DROP D>S
           ?DUP IF -> c ^ c 1 s STR+ THEN
        ELSE -> c 
             c [CHAR] _ = IF BL -> c THEN
             ^ c 1 s STR+ 1+
        THEN
  REPEAT DROP R> DROP
  R> BASE ! s STR@
;
USER uMimeValueDecodeCnt
VECT vDefaultMimeCharset \ кодировка входящей строки по умолчанию,
                         \ если она не указана в самой строке =?...?

: DefaultMimeCharset1 S" koi8-r" ; ' DefaultMimeCharset1 TO vDefaultMimeCharset

: MimeValueDecode1 ( encoding-a encoding-u text-a text-u flag -- addr u )
\ flag=true, если text закодирован base64
  IF debase64 ELSE dequotep THEN
  2SWAP CHARSET-DECODERS-WL SEARCH-WORDLIST IF EXECUTE THEN
  uMimeValueDecodeCnt 1+!
;
: MimeValueDecode { addr u \ ta tu s b -- addr2 u2 }
  "" -> s
  uMimeValueDecodeCnt 0!
  BEGIN
    addr u S" =?" SEARCH
  WHILE
    -> tu -> ta
    addr ta OVER - s STR+                                  \ некодированный текст
    ta 2+ tu 2- S" ?" SEARCH 0= IF s STR+ s STR@ EXIT THEN \ ошибка encoder'а
    -> tu ta 2+ SWAP DUP -> ta OVER - \ encoding
    tu 5 < IF 2DROP ta tu s STR+ s STR@ EXIT THEN                \ ошибка encoder'а
    ta 3 S" ?B?" COMPARE-U 0= -> b
    ta 3 + tu 3 - S" ?=" SEARCH 0= IF s STR+ 2DROP s STR@ EXIT THEN
    2- -> u DUP 2+ -> addr
    ta 3 + SWAP OVER - \ text
    b MimeValueDecode1 s STR+
  REPEAT                                   \ остаток текста не кодирован
  s STR+ s STR@
  uMimeValueDecodeCnt @ 0=
  IF \ MimeValueDecode1 не запускался, т.е. в строке не была указана кодировка
     \ поэтому декодируем из указанной по умолчанию
     vDefaultMimeCharset CHARSET-DECODERS-WL SEARCH-WORDLIST IF EXECUTE THEN
  THEN
;
: StripLwsp1_old { \ s }
  "" -> s
  BEGIN
    13 PARSE DUP
  WHILE
    s STR+
    SOURCE DROP >IN @ + 1+ C@ IsDelimiter IF 2 >IN +! THEN
  REPEAT 2DROP
  s STR@
;
: StripLwsp_old ( addr u -- addr2 u2 )
\ убрать из текста заголовка символы CRLFLWSP
\ т.е. переводы строк с последующими пробельными
\ символами, означающие перенос длинной строки
  ['] StripLwsp1_old EVALUATE-WITH
;

: -LEADING ( addr u -- addr1 u1 ) \ ~pig
\ пропускает пробелы и прочие разделители в начале строки
\
  BEGIN
    DUP DUP					\ пока строка не кончилась
    IF DROP OVER C@ IsDelimiter THEN		\ и пока она начинается с разделителя
  WHILE
    SKIP1					\ пропустить его
  REPEAT
;

\ ~pig: 15.02.2007
\ 1. Два варианта переделки слова StripLwsp
\ - не прерывает разбор по {CRLF}{CRLF}
\ - из строк продолжения удаляет не один разделитель, а все ведущие, сколько их там есть (некоторые почтовые клиенты, кодируя заголовки, лепят не символ табуляции, а серию пробелов, в результате получается криво)
\ - разделители строк (если текст в рещультате получается многострочный) тоже {CRLF}, а не одинокие переводы строки (возвраты каретки съедало слово PARSE)

: StripLwsp1 ( "text" -- addr u )
  "" >R						\ начальная пустышка
  BEGIN
    EndOfChunk 0=				\ разбор до конца буфера
  WHILE
    13 PARSE					\ выделить до конца строки
    R@ STR+					\ записать в буфер
    SOURCE DROP >IN @ + 1- C@ 13 =		\ был ли возврат каретки?
    IF
      10 SKIP					\ да - пропустить перевод строки
      OnDelimiter				\ следующая строка начинается с разделителя?
      GetChar SWAP 13 <> AND AND		\ но не с возврата каретки (не пустая)
      IF
        SkipDelimiters				\ пропустить все ведущие разделители следующей строки
      ELSE
        CRLF R@ STR+				\ это началась новая строка - добавить разделитель
      THEN
    THEN
  REPEAT
  R> STR@					\ собранная строка
;


\ ~pig: 15.02.2007
\ альтернативный вариант собственно StripLwsp
\ использует слова SPLIT- и -LEADING

: StripLwsp ( addr u -- addr1 u1 )
  "" >R						\ начальная пустышка
  BEGIN
    DUP						\ в строке что-нибудь есть?
    IF
      CRLF SPLIT- -ROT				\ выделить очередную строку
      R@ STR+					\ записать в буфер
      IF
        OVER C@ DUP IsDelimiter SWAP LT C@ <> AND OVER 0<> AND	\ следующая строка начинается с разделителя?
        IF
          -LEADING				\ да - убрать ведущие разделители
        ELSE
          CRLF R@ STR+				\ это началась новая строка - добавить разделитель
        THEN
        FALSE					\ пойти на следующий круг
      ELSE
        TRUE					\ больше строк нет, завершить
      THEN
    ELSE
      2DROP TRUE				\ с пустой строкой делать нечего
    THEN
  UNTIL
  R> STR@					\ собранная строка
;


(
" Subject: =?windows-1251?B?UmU6IFtlc2Vydl0gze7i++kg8ffl8iBFLTE5NDEg7vIgMjguMDEuMg==?=
	=?windows-1251?B?MDAz?=
Subject: =?koi8-r?B?W0V0eXBlXSDJzsbP0s3Bw8nRIM8g0MXSxdLZ18Ug09fR2skgMTUg0c7XwdLR?=
Subject: =?Windows-1251?B?0SDN7uL77CDD7uTu7CEg1e7y/CDxIO7v4Ofk4O3o5ewsIO3uIOLx5SDm?=
	=?Windows-1251?B?5SAlKQ==?=
From: =?koi8-r?Q?=EF=CC=D8=C7=C1=20=F0=C1=D7=CC=CF=D7=C1?=
Subject: =?koi8-r?Q?RE:_FIG_Taiwan_+_Russian+_clf_=C4=CF_=CB=D5=DE=C9?=
Subject: =?windows-1251?Q?=EF=EE_=EF=EE=E2=EE=E4=F3_Eserv?=
" STR@ StripLwsp MimeValueDecode ANSI>OEM TYPE

" =?koi8-r?Q?=EF=D4=CD=C5=CE=C5=CE=CF________=E9=FA=F7=E5=FD=E5=EE?=
 =?koi8-r?Q?=E9=E5=2E_=E9=EE=F4=E5=F2=EE=E5=F4_=FA=E1=EB=E1=FA_20638935?=
 =?koi8-r?Q?_=E9=EE=F7=EF=EA=F3_40620100_=E7=EF=F4=EF=F7_=EB_=F7=F9=E4=E1?=
 =?koi8-r?Q?=FE=E5__=C4=C1=D4=C1_=CD=CF=C4=C9=C6=C9=CB=C1=C3=C9=C9=3A_1?=
     =?koi8-r?Q?7=2E12=2E2003_=28=29?=
" STR@ StripLwsp MimeValueDecode ANSI>OEM TYPE

CR S" ьФП ФЕНБ Ч ЛПДЙТПЧЛЕ koi8-r ВЕЪ mime-ЛПДЙТПЧБОЙС" MimeValueDecode ANSI>OEM TYPE CR

)
