REQUIRE FOR-FILES ~nn/lib/for-files3.f
REQUIRE ON ~nn/lib/onoff.f
\ REQUIRE { ~nn/lib/locals.f
\ REQUIRE ZPLACE ~nn/lib/az.f
WINAPI: RemoveDirectoryA KERNEL32.DLL
WINAPI: SetFileAttributesA KERNEL32.DLL
USER DEL-LEVEL
USER DEL-ROOT

: (DEL-TREE) ( a u -- ior )
\      ." DEL TREE : " 2DUP TYPE CR
    DEL-LEVEL 1+!
     2DUP S" \*.*" S+ OVER >R
\    2DUP TYPE CR
    ~RECURSIVE
    FOR-FILES
\        ." found: " FOUND-FULLPATH TYPE CR
        IS-DIR?
        IF
            FOUND-FULLPATH RECURSE DROP
        ELSE
\            ." Delete file: " FOUND-FULLPATH TYPE SPACE
            FOUND-FULLPATH DELETE-FILE ( DUP . CR) 5 =
            IF
                0 FOUND-FULLPATH DROP SetFileAttributesA DROP
                FOUND-FULLPATH DELETE-FILE DROP
            THEN
        THEN
    ;FOR-FILES
    R> FREE DROP
    DROP
    DEL-LEVEL @ 1 = DEL-ROOT @ 0= AND 0=
    IF 
\          ." Remove DIR: " DUP ASCIIZ> TYPE CR    
        DUP RemoveDirectoryA ERR DUP
        5 = 
        IF 
           DROP 0 OVER 
\             DUP ASCIIZ> TYPE CR
           SetFileAttributesA  DROP
\             DUP ASCIIZ> TYPE CR 
           RemoveDirectoryA
\             ." second time" DUP . 
           ERR 
\             DUP . CR
        ELSE NIP THEN
    ELSE 
        DROP GetLastError DUP ERROR_NO_MORE_FILES = IF DROP 0 THEN
    THEN
    -1 DEL-LEVEL +!
;

: DEL-TREE ( a u -- ior )
    FF-RECURSIVE? @ >R
    0 SetLastError DROP
\    FF-FILESONLY? OFF
    DEL-ROOT ON DEL-LEVEL OFF   (DEL-TREE)
    R> FF-RECURSIVE? !
; 

: EMPTY-TREE
    FF-RECURSIVE? @ >R
    0 SetLastError DROP
    DEL-ROOT OFF DEL-LEVEL OFF  (DEL-TREE)
    R> FF-RECURSIVE? !

;

\ S" e:\tmp\cron" DEL-TREE