\ DLOPEN, DLSYM для SPF/Win32

: DLOPEN ( addr u -- h )
  DROP LoadLibraryA
;
: DLSYM ( addr u h -- api-xt )
  NIP GetProcAddress
;