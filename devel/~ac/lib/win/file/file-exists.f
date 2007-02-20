\ [Устаревший] вариант FileExists.

REQUIRE FIND-FILES-R      ~ac/lib/win/file/findfile-r.f 

: FileExists ( addr u -- flag )
  R/O OPEN-FILE-SHARED ?DUP
  IF NIP DUP 2 =
        OVER 3 = OR
        OVER 206 = OR 
        SWAP 123 = OR
        0=
  ELSE CLOSE-FILE THROW TRUE
  THEN
;
\ WINAPI: GetFileAttributesA KERNEL32.DLL

: IsDirectory ( addr u -- flag )
  DROP GetFileAttributesA DUP FILE_ATTRIBUTE_DIRECTORY AND
  0<> SWAP -1 <> AND
;
