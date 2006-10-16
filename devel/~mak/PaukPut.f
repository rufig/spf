\ Запись файла на ФПаук-сервер на 400 часов
REQUIRE [IF] ~MAK\CompIF1.f

: SOURCE-ID SOURCE-ID  STREAM-FILE ;
REQUIRE  FILE ~ac\lib\str3.f 

REQUIRE fputs ~ac\lib\win\winsock\psocket.f 
REQUIRE OpenDialog ~day\joop\win\filedialogs.f


C" DUP>R" FIND NIP 0=
[IF] : DUP>R 0x50 C, ; IMMEDIATE
[THEN]

 \ Sample

FILTER: fTest

  NAME" all files" EXT" *.*"
  NAME" rar files" EXT" *.rar"

;FILTER


OpenDialog :new VALUE tt

: title1
     S" Put on FPauk"
;

 fTest tt :setFilter
title1 tt :setTitle

: PATH\FN>FN ( ADDR U -- ADDR1 U1 )
    OVER + DUP>R
    BEGIN 1- 2DUP = OVER 1- C@ [CHAR] \ = OR
    UNTIL NIP R> OVER - CR ." FN="  2DUP TYPE
;


CREATE PATH\FILENAME  2 CELLS ALLOT
VARIABLE FILESIZE

: P_FILE_PUT ( host port addr u -- )
    
  2DUP R/O OPEN-FILE THROW >R
  R@  FILE-SIZE  THROW DROP ." FS=" DUP U. FILESIZE !
  R> CLOSE-FILE  THROW
  PATH\FILENAME 2!
  SocketsStartup THROW 
  fsockopen DUP>R \ fsock ClientSocket !

" PUTF> {PATH\FILENAME 2@ 
PATH\FN>FN}{CRLF}{FILESIZE 4 }{PATH\FILENAME 2@ FILE}"

  CR ."  Wait for '$' symbol occurrence"
  STR@  R@ fsock WriteSocket THROW
  PAD
  BEGIN DUP 1 R@ fsock ReadSocket DROP 1 <> OVER C@ DUP EMIT [CHAR] $ = OR
  UNTIL DROP
  R> fclose DROP CR
;


: P_F_P ( host port -- )

 tt :execute DROP
 tt :fileName DUP

 IF   P_FILE_PUT
 ELSE DROP 2DROP
 THEN ;

" maksimov435.rtc.neva.ru" 3333  P_F_P
\EOF
 Если ваш номер 44 то URL будет:
 http://maksimov435.rtc.neva.ru/0044/<имя файла>
