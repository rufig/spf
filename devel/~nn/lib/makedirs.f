REQUIRE S>ZALLOC ~nn/lib/az.f
REQUIRE { lib/ext/locals.f
REQUIRE SetFileSA ~nn/lib/sec/file.f
REQUIRE ALLOCATE9x ~nn/lib/alloc95.f
WINAPI: CreateDirectoryA KERNEL32.DLL

USER MAKE-DIR-SA

: ERROR_PATH_NOT_FOUND? ( ior -- ?)
    ERROR_PATH_NOT_FOUND = ;

: MAKE-DIR ( a u -- ior)
\    2DUP TYPE CR
    MAX_PATH ALLOCATE9x THROW >R
    R@ ZPLACE
\    MAKE-DIR-SA @
    0
    R@ CreateDirectoryA ERR \ DUP .
    DUP IF DUP ERROR_ALREADY_EXISTS = IF DROP 0 THEN THEN
    DUP 0= MAKE-DIR-SA @ 0<> AND IF R@ ASCIIZ> MAKE-DIR-SA @ SetFileSA DROP THEN
    R> FREE9x THROW
;

: CreateDirSA ( sa a u -- ior) ROT MAKE-DIR-SA ! MAKE-DIR ;

: DROP-RIGHT-DIR ( a u -- a u1 true | -- false)
    OVER +
    BEGIN  1- 2DUP <  WHILE
      DUP C@ [CHAR] \ =
      IF
        OVER -
\        ." -->" 2DUP TYPE CR
        TRUE EXIT
      THEN
    REPEAT
    2DROP FALSE
;

: MAKE-DIRS { a u -- ior }
    u 2 = IF a 1+ C@ [CHAR] : = IF 0 EXIT THEN THEN
    u 3 = IF a 1+ 2 S" :\" COMPARE 0= IF 0 EXIT THEN THEN
    a u MAKE-DIR ?DUP 0= IF 0 EXIT THEN
    DUP ERROR_PATH_NOT_FOUND?
    IF DROP
       a u DROP-RIGHT-DIR
       IF
          RECURSE DUP 0=
          IF DROP  a u MAKE-DIR THEN
       ELSE
         ERROR_BAD_PATHNAME
       THEN
    THEN
;

(
MAKE-DIR-SA 0!
S" c:\tmp3\t1\t2\t3\t4\t5\t6" MAKE-DIRS THROW
)