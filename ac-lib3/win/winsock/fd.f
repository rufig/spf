\ #define FD_ISSET(fd, set) __WSAFDIsSet((SOCKET)(fd), (fd_set FAR *)(set))

WINAPI: __WSAFDIsSet WSOCK32.DLL

: FD_ISSET ( socket set -- flag )
  SWAP __WSAFDIsSet
;
