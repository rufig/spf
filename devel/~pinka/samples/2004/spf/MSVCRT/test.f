\ 19.Jan.2004 Mon 20:38

REQUIRE GetTimes  ~pinka\lib\Tools\profiler.f
profile off

\ tested word from  ~ac\lib\win\file\stream.f 

profile on
: read(WinAPI) ( a u -- )
  R/O OPEN-FILE THROW >R
  BEGIN
    PAD 1000 R@ READ-LINE THROW
  WHILE
    \ PAD SWAP TYPE CR
    DROP
  REPEAT DROP
  R> CLOSE-FILE THROW
;
profile off

MODULE: T1

~ac\lib\win\file\stream.f 


EXPORT

profile on

: read(MSVCRT) ( a u -- )
  R/O OPEN-FILE THROW >R
  BEGIN
    PAD 1000 R@ READ-LINE THROW
  WHILE
    \ PAD SWAP TYPE CR
    DROP
  REPEAT DROP
  R> CLOSE-FILE THROW
;

profile off

;MODULE

MODULE: T2

~af\lib\stream_io.f 

EXPORT

ALSO FStream
profile on
: read(FStream) ( a u -- )
  R/O OPEN-FILE THROW >R
  BEGIN
    PAD 1000 R@ READ-LINE THROW
  WHILE
    \ PAD SWAP TYPE CR
    DROP
  REPEAT DROP
  R> CLOSE-FILE THROW
;
profile off
PREVIOUS

;MODULE

: testfile  S" lib\asm\486asm.f" FIND-FULLNAME ;

\ чтобы OS сделала кэширование файла:
testfile read(WinAPI)
testfile read(MSVCRT)
testfile read(FStream)

ResetProfiles

: TEST
  10 0 DO
    testfile read(WinAPI)
    testfile read(MSVCRT)
    testfile read(FStream)
  LOOP
  .AllStatistic
;
TEST BYE
