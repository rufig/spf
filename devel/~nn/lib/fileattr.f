\ REQUIRE FIND-FIRST-FILE ~nn/lib/find.f
WINAPI: FindFirstFileA kernel32.dll
WINAPI: FindClose kernel32.dll
\ Return flag and fill buf with file attributes (see find.f)
: FILE-ATTRIBUTES ( buf a u -- ?)
    DROP FindFirstFileA DUP INVALID_HANDLE_VALUE <>
    IF FindClose DROP TRUE ELSE DROP FALSE THEN
;

