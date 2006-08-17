S" monthtable.f" INCLUDED

MODULE: html

  0 VALUE file

  : >file ( -- f )
    H-STDOUT
    file TO H-STDOUT
  ;

  : |file ( f -- )
    TO H-STDOUT
  ;

  : out:
    >IN @
      NextWord SFIND 0= ABORT" Not found"
      SWAP
    >IN !
    CREATE ,
    DOES>
      @
      >file >R
        EXECUTE
      R> |file
  ;

  out: EMIT
  out: SPACE
  out: SPACES
  out: TYPE
  out: .
  out: CR

  : ."
    POSTPONE >file
    POSTPONE ."
    POSTPONE |file
  ; IMMEDIATE

  : .'
    ?COMP
    POSTPONE >file
    [CHAR] ' PARSE POSTPONE SLITERAL POSTPONE TYPE
    POSTPONE |file
  ; IMMEDIATE

  : .Word
    CREATE
    LAST @ ,
    DOES>
    @ COUNT TYPE
  ;

  : tag:
    .Word
  ;

  : tags:
    BEGIN
      >IN @ >R
      NextWord
      R> >IN !
      NIP
    WHILE
      tag:
    REPEAT
  ;

  tags: <html> </html> <head> </head> <title> </title> <body> </body>
  tags: <tr> </tr> <td> </td>
  tags: </table> </font> </p>

  : Begin ( year -- )
    DUP TO Year
    <html> CR
    <head> CR
    <title> ." Календарь на " DUP . ." год" </title> CR
    .' <meta name="GENERATOR" content="SPF 3.75">' CR
    </head> CR
    .' <body bgcolor="#FFFFFF">' CR
    .' <p align="center"><font size="5">Календарь на ' . ." год</font>" CR
  ;

  : End
    </body> CR
    </html> CR
  ;

  : MainTableBegin
    .' <table border="1" width="100%" cellspacing="0" cellpadding="0">' CR
  ;

  : MainTableEnd
    </table> CR
  ;

  CREATE DOWNames C" пнвтсрчтптсбвс" ",
  : DOWName ( n -- addr u )
    2 * DOWNames 1+ + 2
  ;

  : DOWTable
    .' <table border="0" width="100%" cellspacing="0" cellpadding="0">' CR
    7 0 DO
      <tr> .' <td width="100%"'
      I 4 > IF
        .'  bgcolor="#E0E0E0"'
      THEN
      .' ><p align="center">'
        I DOWName TYPE
      </p> </td> </tr> CR
    LOOP
    </table> CR
  ;

  : MonthRow ( w mt -- )
    6 0 DO
      .' <td width="16%" align="right">'
      ( 1 . )

      2DUP
      I ROT ROT {{ MonthTable arr[] }} C@ ?DUP IF . ELSE ." &nbsp;" THEN

      </td> CR
    LOOP
    2DROP
  ;

  : ShowMonthTable ( month -- )
    1+ {{ MonthTable create DUP fill }}
    .' <table border="0" width="100%" cellspacing="0" cellpadding="0">' CR
    8 1 DO
      I 5 > IF
        .' <tr bgcolor="#E0E0E0">'
      ELSE
        <tr>
      THEN
      CR
      I OVER MonthRow
      </tr> CR
    LOOP
    </table> CR
    {{ MonthTable destroy }}
  ;

  : MainRow ( month -- )
    <tr> CR
      DUP 4 + SWAP DO
        .' <td width="5%"><p align="center">&nbsp;' </p> CR
        DOWTable
        </td> CR
        .' <td width="20%"><p align="center">' I 1+ MonthName TYPE </p> CR
        I ShowMonthTable
        </td> CR
      LOOP
    </tr> CR
  ;
;MODULE

: MakeHTML ( year file -- )
  {{ html
    TO file
    Begin
    MainTableBegin
    12 0 DO
      I MainRow
    4 +LOOP
    MainTableEnd
    End
  }} ;

\ 2002 H-STDOUT MakeHTML
\EOF
S" calendar.html" DELETE-FILE DROP
2003
S" calendar.html" R/W CREATE-FILE-SHARED THROW TUCK
MakeHTML
CLOSE-FILE THROW