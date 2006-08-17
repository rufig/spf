REQUIRE ACCEPTHistory ~micro/lib/key/acceptgo.f

WINAPI: ReadConsoleOutputCharacterA KERNEL32.DLL

: MouseCoord
  MMouseY 16 LSHIFT MMouseX +
;

CREATE ConStr 80 ALLOT

: .H BASE @ SWAP HEX . BASE ! ;

: ReadConStr
  >R 0 SP@ R> 16 LSHIFT \ 0 adr coord
  80 ConStr H-STDOUT ReadConsoleOutputCharacterA DROP DROP
  ConStr
;

: GetChar ( addr n -- c )
  + C@
;

: GetPointedWordStr ( addr x -- addr1 u1 )
  2DUP GetChar BL = IF
    DROP 0
  ELSE
    BEGIN
      DUP
    WHILE \ Do it, if X!=0 ...
      2DUP 1- GetChar BL <>
    WHILE \ and prev. char !=BL
      1-
    REPEAT
    THEN \ addr x
    SWAP OVER \ x addr x
    BEGIN
      DUP 80 <>
    WHILE \ Do it, if X!=80 ...
      2DUP GetChar BL <>
    WHILE \ and curr. char !=BL
      1+
    REPEAT
    THEN \ xb addr xe+1
    ROT ROT OVER + \ xe+1 xb addr+xb
    ROT ROT -
  THEN
;

: GetPointedWord
  MMouseY W@ \ Ycoord
  ReadConStr \ addr
  MMouseX W@ GetPointedWordStr \ addr u
;

: EmulType ( sx sy addr u len x addrW uW -- sx sy addr u len1 x1 )
  0 ?DO
    DUP >R
    C@
    ACCEPTInsChar
    R> 1+
  LOOP
  DROP
;

: LikeMask ( n mask -- f )
  SWAP OVER AND =
;

: ACCEPTMOUSE ( sx sy addr u len x u -- sx sy addr u len x enter )
  DUP KEYFLAG_MOUSE_LBUTTON KEYFLAG_MOUSE_EVENT OR LikeMask IF
    DROP
    GetPointedWord
    EmulType
    BL ACCEPTInsChar
    -1
  ELSE
    DUP KEYFLAG_MOUSE_RBUTTON KEYFLAG_MOUSE_EVENT OR LikeMask IF
      DROP
      GetPointedWord
      EmulType
      BL ACCEPTInsChar
      0
    ELSE
      DROP
      0
    THEN
  THEN
;

' ACCEPTMOUSE TO ACCEPTUnknownEvent

.( Правая кнопка мыши вводит слово в строку,) CR
.( а левая делает ещё и ENTER.) CR