\ std-хэндлы для fwrite-функций (исп. для openssl applink)

WINAPI: _fdopen         MSVCRT.DLL
WINAPI: _open_osfhandle MSVCRT.DLL

: h-stderr
  H-STDERR
  0 SWAP _open_osfhandle NIP NIP S" w" DROP SWAP _fdopen NIP NIP
;
: h-stdout
  H-STDOUT
  0 SWAP _open_osfhandle NIP NIP S" w" DROP SWAP _fdopen NIP NIP
;
