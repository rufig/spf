\ REQUIRE EVAL-SUBST ~nn/lib/subst.f
\ REQUIRE FOR-FILES ~nn/lib/for-files.f
REQUIRE MAKE-DIRS ~nn/lib/makedirs.f
REQUIRE DEL-TREE ~nn/lib/deltree.f
REQUIRE ONLYNAME ~nn/lib/filename.f
REQUIRE >EOF ~nn/lib/eof.f
REQUIRE TempFile ~nn/lib/tempfile.f

USER-CREATE CUR-FILE-NAME 2 CELLS USER-ALLOT
VECT FILE-ERR
: (FILE-ERR) ( a u -- )
\    ." FILE ERROR # " GetLastError . ." (" CUR-FILE-NAME 2@ TYPE ." ): " TYPE CR
    2DROP
;

' (FILE-ERR) TO FILE-ERR

: MAKE-FILE ( a u mode -- handle ior)
    >R
    2DUP R@ CREATE-FILE-SHARED DUP
    ERROR_PATH_NOT_FOUND =
    IF 2DROP
       2DUP DROP-RIGHT-DIR
       IF
           MAKE-DIR-SA 0!  MAKE-DIRS ?DUP 0=
           IF R@ CREATE-FILE-SHARED
           ELSE ( a u ior -- ) NIP NIP 0 SWAP THEN
       ELSE 2DROP 0 ERROR_BAD_PATHNAME THEN
    ELSE
        2SWAP 2DROP
    THEN
    RDROP
;

: OPEN/CREATE-FILE ( a u mode -- handle ior)
    >R
    2DUP R@ OPEN-FILE-SHARED
    IF DROP
       R@ MAKE-FILE
    ELSE
        >R 2DROP R> 0
    THEN
    RDROP
;

: DIR-CREATE ( a u -- )
    2DUP CUR-FILE-NAME 2!
    MAKE-DIR-SA 0!
    MAKE-DIRS IF S" DIR-CREATE" FILE-ERR THEN
;

: DIR-DELETE ( a u -- )
    2DUP CUR-FILE-NAME 2!
    DEL-TREE IF S" DIR-DELETE" FILE-ERR THEN
;

: FWRITE ( a u a-filename u-filename -- )
    2DUP CUR-FILE-NAME 2!
    W/O MAKE-FILE IF DROP 2DROP S" WRITE" FILE-ERR EXIT THEN
    >R
    R@ WRITE-FILE DROP
    R> CLOSE-FILE DROP
;

\ : F2EOF ( h -- )
\    >R R@ FILE-SIZE 0=
\    IF R@ REPOSITION-FILE DROP
\    ELSE 2DROP THEN
\    R> DROP
\ ;

: FAPPEND ( a u a-filename u-filename -- )
    2DUP CUR-FILE-NAME 2! R/W OPEN/CREATE-FILE
    IF DROP 2DROP S" APPEND" FILE-ERR EXIT THEN
    >R
    R@ >EOF
    R@ WRITE-FILE DROP
    R> CLOSE-FILE DROP
;

: FREAD ( a u a-filename u-filename -- a u1 )
    2DUP CUR-FILE-NAME 2!
    R/O OPEN-FILE-SHARED
    IF DROP DROP 0 S" READ" FILE-ERR EXIT THEN
    >R
    OVER SWAP R@ READ-FILE  IF DROP 0 THEN
    R> CLOSE-FILE DROP
;

WINAPI: CopyFileA KERNEL32.DLL

: del-on-exit R> ( ." Delete=" DUP . CR) FREE DROP ;
: ?dst-is-dir ( a1 u1 a2 u2 -- a1 u1 a3 u3 )
    OVER GetFileAttributesA DUP -1 <>
    IF
        FILE_ATTRIBUTE_DIRECTORY AND 0<>
        IF
            2OVER ONLYNAME      \ ." only name=" 2DUP TYPE CR
            DUP 2OVER DROP + CELL+ ALLOCATE THROW >R
            2SWAP R@ ZPLACE S" \" R@ +ZPLACE R@ +ZPLACE
            R> ASCIIZ>           \ ." result=" 2DUP TYPE CR
                                 \ ." to delete=" OVER . CR
            OVER R> SWAP >R ['] del-on-exit >R >R
        ELSE
           OVER FILE_ATTRIBUTE_NORMAL SWAP SetFileAttributesA DROP
        THEN
    ELSE DROP THEN
;

: FCOPY ( from-a1 u1 to-a2 u2 -- )
    2OVER CUR-FILE-NAME 2!
    ?dst-is-dir
    0 SetLastError DROP
    DROP NIP 0 SWAP ROT CopyFileA ERR
    IF S" COPY" FILE-ERR THEN ;

: FMOVE ( from-a1 u1 to-a2 u2 -- )
    2OVER CUR-FILE-NAME 2!
    ?dst-is-dir
    0 SetLastError DROP
\    2DUP TYPE CR 2OVER TYPE CR
    DROP NIP SWAP MoveFileA ERR
    IF S" MOVE" FILE-ERR THEN ;

: FRENAME ( from-a1 u1 to-a2 u2 -- )   FMOVE ;

\ : FDELETE ( a u -- )
\     2DUP CUR-FILE-NAME 2!
\    DELETE-FILE
\    IF S" DELETE" FILE-ERR THEN ;

: DELETE-R/O-FILE ( a u -- ior )
    OVER FILE_ATTRIBUTE_NORMAL SWAP SetFileAttributesA DROP
    DELETE-FILE
;

: FDELETE ( a u -- )
   FILESONLY
   FOR-FILES
        FOUND-FULLPATH DELETE-R/O-FILE DROP
   ;FOR-FILES
;

\ : FDEL/TRUNC ( a u -- )
\     2DUP DELETE-FILE
\     IF W/O OPEN-FILE-SHARED THROW
\
\     ELSE 2DROP THEN
\ ;

: FCREATE ( a u -- )
    2DUP CUR-FILE-NAME 2!
    R/W MAKE-FILE
    IF DROP S" CREATE" FILE-ERR
    ELSE CLOSE-FILE DROP THEN
;

USER PURGE-DATE
USER PURGE-DAYS
USER PURGE-WITHDIRS
: WITHDIRS PURGE-WITHDIRS ON RECURSIVE ;
: FIT-TO-PURGE?
\    DBG( ." fit-to-purge start" CR )
    CUR-DATE ( DUP .) PURGE-DATE @ EXECUTE ( DUP .) DATE- ( DUP . CR) PURGE-DAYS @ >
\    DBG( ." fit-to-purge stop=" DUP . CR )
;
: (PURGE-OLD) ( a u days xt -- )
    PURGE-DATE ! PURGE-DAYS !
    FOR-FILES
\       DBG( ." ---> " FOUND-FULLPATH TYPE CR )
       IS-DIR?
       IF
          PURGE-WITHDIRS @
          IF
            FIT-TO-PURGE?
            IF
                FOUND-FULLPATH DEL-TREE DROP
            THEN
          THEN
       ELSE
           FIT-TO-PURGE?
           IF
\                FOUND-FULLPATH 2DUP 10 + DUMP CR
                FOUND-FULLPATH DELETE-R/O-FILE DROP
           THEN
       THEN
    ;FOR-FILES
    PURGE-WITHDIRS OFF
;

: PURGE-OLD  ( a u days --)  ['] CREATION-DATE (PURGE-OLD) ;
: PURGE-OLDW ( a u days --)  ['] WRITE-DATE (PURGE-OLD) ;
: PURGE-OLDA ( a u days --)  ['] ACCESS-DATE (PURGE-OLD) ;

0 [IF]
: FILE-OP ( addr u xt -- ... )
    FF-SAVE-STACK FF-SAVE
    >R
    DROP FIND-FIRST-FILE DUP IF NIP THEN
    R> EXECUTE
    FF-REST
    FF-REST-STACK
;
[ELSE]
: FILE-OP ( addr u xt -- ... )
    __FFB >R __FFH >R
    >R
    DROP FIND-FIRST-FILE DUP IF NIP THEN
    R> EXECUTE
    FIND-CLOSE
    R> TO __FFH
    R> TO __FFB
;
[THEN]

: SIZE-OP
    IF __FFB nFileSizeLow @ __FFB nFileSizeHigh @
    ELSE 0 0 THEN ;

: CDATE-OP IF CREATION-DATE ELSE 0 THEN ;
: ADATE-OP IF ACCESS-DATE ELSE 0 THEN ;
: WDATE-OP IF WRITE-DATE ELSE 0 THEN ;

: CTIME-OP IF FF-CREATION-TIME ELSE 0. THEN ;
: ATIME-OP IF FF-ACCESS-TIME ELSE 0. THEN ;
: WTIME-OP IF FF-WRITE-TIME ELSE 0. THEN ;


: FSIZE  ['] SIZE-OP FILE-OP ;
: FCDATE ['] CDATE-OP FILE-OP ;
: FADATE ['] ADATE-OP FILE-OP ;
: FWDATE ['] WDATE-OP FILE-OP ;

: FCTIME ['] CTIME-OP FILE-OP ;
: FATIME ['] ATIME-OP FILE-OP ;
: FWTIME ['] WTIME-OP FILE-OP ;

0 [IF]
: FCROP { a u maxsize size \ fh1 fh2 fsize bufsize buf -- }
    maxsize 0 > size 0 > AND 0= IF EXIT THEN
    a u R/O OPEN-FILE-SHARED IF DROP EXIT THEN TO fh1
    fh1 FILE-SIZE THROW DROP TO fsize
    fsize maxsize >
    IF
        1024 ALLOCATE THROW TO buf
        BEGIN  buf 1020 fh1 READ-LINE THROW NIP
            IF fsize fh1 FILE-POSITION THROW DROP - size < ELSE TRUE THEN
        UNTIL
        fh1 FILE-POSITION THROW DROP 1024 MIN TO bufsize
        a u R/W OPEN-FILE-SHARED ?DUP
        IF NIP fh1 CLOSE-FILE DROP buf FREE DROP THROW THEN TO fh2
        0 0 fh2 REPOSITION-FILE THROW
        BEGIN
            buf bufsize fh1 READ-FILE THROW ?DUP
        WHILE
            buf SWAP fh2 WRITE-FILE THROW
        REPEAT
        fh2 FILE-POSITION THROW fh2 RESIZE-FILE THROW
        fh2 CLOSE-FILE DROP
    THEN
    fh1 CLOSE-FILE DROP
;
[THEN]

: crop-temp-name ( a u -- a1 u1 )
    ONLYDIR ?DUP
    IF
        DUP >R TempFile DUP R> + 2 + TEMP-ALLOC >R
        2SWAP R@ ZPLACE
        S" \" R@ +ZPLACE
        R@ +ZPLACE
        R> ASCIIZ>
    ELSE
        DROP
        TempFile
    THEN

;

: D>Kb 1024 UM/MOD NIP ;

: FCROPkb { a u maxsizeKb sizeKb \ fh1 fh2 fsizeKb bufsize buf temp-name -- }
    maxsizeKb 0 > sizeKb 0 > AND 0= IF EXIT THEN
    a u R/O OPEN-FILE-SHARED IF DROP EXIT THEN TO fh1
    fh1 FILE-SIZE THROW D>Kb TO fsizeKb
    fsizeKb maxsizeKb >
    IF
        1020 TO bufsize
        bufsize CELL+ ALLOCATE THROW TO buf
        fsizeKb sizeKb - 1- 0 MAX 1024 UM* fh1 REPOSITION-FILE THROW
        BEGIN  buf bufsize fh1 READ-LINE THROW NIP
            IF fsizeKb fh1 FILE-POSITION THROW D>Kb - sizeKb < ELSE TRUE THEN
        UNTIL
        \ fh1 FILE-POSITION THROW ." <" D. ." > "
        \ fh1 FILE-POSITION THROW DROP 1024 MIN TO bufsize

        \ a u R/W OPEN-FILE-SHARED ?DUP
        a u crop-temp-name OVER TO temp-name R/W CREATE-FILE-SHARED ?DUP
        IF NIP fh1 CLOSE-FILE DROP buf FREE DROP THROW THEN TO fh2
        \ 0 0 fh2 REPOSITION-FILE THROW

        BEGIN
            buf bufsize fh1 READ-FILE THROW ?DUP
        WHILE
            buf SWAP fh2 WRITE-FILE THROW
        REPEAT
        \ fh2 FILE-POSITION THROW fh2 RESIZE-FILE THROW
        fh2 CLOSE-FILE DROP
        \ 0 0 fh1 RESIZE-FILE THROW
        fh1 CLOSE-FILE DROP
        \ теперь старый файл удаляем
        a u DELETE-R/O-FILE IF a u crop-temp-name DROP a MoveFileA DROP THEN
        a temp-name MoveFileA DROP
    ELSE
        fh1 CLOSE-FILE DROP
    THEN
;

\ : FCROPkb ( a u maxsize size --)  1024 * SWAP 1024 * SWAP FCROP ;

USER-CREATE <DIR-SIZE> 2 CELLS ALLOT
: DIR-SIZE ( a u -- d)
    0 0 <DIR-SIZE> 2!
    S" \*.*" S+ OVER >R
    FOR-FILES
        IS-DIR? 0= SIZE-OP <DIR-SIZE> 2@ D+ <DIR-SIZE> 2!
    ;FOR-FILES
    R> FREE DROP
    <DIR-SIZE> 2@
;

: DIR-EMPTY?
    TRUE <DIR-SIZE> !
    S" \*.*" S+ OVER >R
    ~RECURSIVE
    FOR-FILES
        FALSE <DIR-SIZE> !
    ;FOR-FILES
    R> FREE DROP
    <DIR-SIZE> @
;

: ?FCR ( h -- )
    >R
    R@ FILE-SIZE THROW
    2DUP OR
    IF -2. D+ R@ REPOSITION-FILE THROW
       0 SP@ 2 R@ READ-FILE THROW DROP
               \  DUP HEX . DECIMAL CR
       LT W@   \  DUP HEX . DECIMAL CR
       <> IF S" " R@ WRITE-LINE THROW THEN
    ELSE
      2DROP
    THEN
    RDROP
;

: fexist? { a u -- a1 u1 ? }
    a u EXIST?
    IF a u TRUE
    ELSE
        a u +ModuleDirName 2DUP EXIST?
    THEN
;

(
: test
    S" test.txt" R/W OPEN-FILE-SHARED THROW >R
    R@ ?FCR
    R> CLOSE-FILE THROW
;
1 2 3 4 5
test
.S
)


\EOF

\ test for FCROPkb
: testfile S" e:\tmp\testfile.tmp" ;
: test
    0
    BEGIN
        DUP S>D <# S" 111111111111111122222222222222222222233333333333333333333333333" HOLDS
                   BL HOLD # # # # # #> testfile FAPPEND
        LT LTL @ testfile FAPPEND
        testfile FSIZE D.
        testfile FSIZE
        testfile 4 2 FCROPkb
        testfile FSIZE DNEGATE D+ OR IF EXIT THEN
        100 PAUSE
        1+
    AGAIN
;
test