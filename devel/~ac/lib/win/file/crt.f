\ std-хэндлы для fwrite-функций (исп. для openssl applink)

WINAPI: _fdopen         MSVCRT.DLL
WINAPI: _open_osfhandle MSVCRT.DLL

: CRT_STREAM ( modea modeu h -- stream )
  0 SWAP _open_osfhandle NIP NIP
  NIP _fdopen NIP NIP
;
: CRT_WSTREAM ( h -- stream )
  S" w" ROT CRT_STREAM
;
: h-stderr H-STDERR CRT_WSTREAM ;
: h-stdout H-STDOUT CRT_WSTREAM ;
