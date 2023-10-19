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
    LATEST-NAME NAME>CSTRING ,
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
  tags: <br> <center> </center>
  tags: <h1> <h2> </h1> </h2>
  tags: <ul> </ul> </a>

;MODULE

0 VALUE Year
CREATE gpdirA 10 ALLOT
0 VALUE gpdirU
TRUE VALUE 1stGP

: CreateFilename ( addr u -- addr1 u1 )
	<#
		S" .mp3" HOLDS
		HOLDS
		[CHAR] \ HOLD
		gpdirA gpdirU HOLDS
		[CHAR] \ HOLD
		Year S>D #S 2DROP
	0. #> ;
: GetFileSize ( addr u -- n )
	R/O OPEN-FILE-SHARED IF DROP -1 EXIT THEN
	DUP FILE-SIZE THROW IF
		DROP -1
	ELSE
		1024 /
	THEN
	SWAP CLOSE-FILE THROW ;

ALSO html

MODULE: Script

: Y ( y -- )
	TO Year
	<center> <h1>
	Year . ." год"
	</h1> </center> <br> CR
	TRUE TO 1stGP ;
: GP ( "name" "dir" -- )
	1stGP IF
		FALSE TO 1stGP
	ELSE
		CR </ul> CR
	THEN
	NextWord
	<h2> ." ГП " TYPE ." ." </h2> CR
	<ul>
	NextWord
	DUP TO gpdirU
	gpdirA SWAP MOVE ;
: + ( "filename" "desc" -- )
	NextWord
	CR .' 	<li><a href="'
	CreateFilename
	2DUP TYPE
	GetFileSize >R
	.' ">'
	0 PARSE TYPE
	BEGIN
		REFILL 0= IF FALSE
		ELSE
			>IN @ >R
				NextWord SFIND IF
					DROP FALSE
				ELSE
					2DROP TRUE
				THEN
			R> >IN !
		THEN
	WHILE
		BL EMIT
		0 PARSE TYPE
	REPEAT
	</a> ."  (" R> . ." K)" <br> ;

;MODULE

: top
	<html> CR
	<head> CR
	.' <meta http-equiv="Content-Type" content="text/html; '
	.' charset=windows-1251">' CR
	</head> CR
	.' <bgsound src="intro.wav"></bgsound>' CR
	.' <title>Перлы от Попова</title>' CR
	<body> CR ;
: bottom
	CR
	<br> CR
	<center> .' <a href="..\..\index.htm">Обратно</a>' </center> CR
	</body>
	</html> ;
: Make
	top
	GET-ORDER
	ONLY Script
	S" sounds.cfg" INCLUDED
	SET-ORDER
	bottom ;

:NONAME
	S" sounds.htm" R/W CREATE-FILE-SHARED THROW TO file
	Make
	file CLOSE-FILE THROW
	BYE
; MAINX !
FALSE TO ?GUI
S" 1.exe" SAVE
BYE