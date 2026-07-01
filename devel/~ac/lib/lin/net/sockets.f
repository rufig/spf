\ ~ac/lib/lin/net/sockets.f -- POSIX (Linux + macOS) сокеты дл€ spf64 через виртуальный словарь SO,
\ dlopen-аналог ~ac/lib/win/winsock/SOCKETS.F.  API как у SOCKETS.F:
\   CreateSocket BindSocket ListenSocket AcceptSocket ConnectSocket ReuseAddrSocket CloseSocket
\   WriteSocket ReadSocket ConnectHost   (+ FdRead / FdWrite = read()/write() дл€ файлов и сокетов).
\ ќт архитектуры не зависит; Linux и macOS различаютс€ лишь первыми двум€ байтами sockaddr_in (BSD
\ sin_len), числами SOL_SOCKET / SO_REUSEADDR, раскладкой struct addrinfo и именем errno-функции -- по [DEFINED] DLFN:.
DECIMAL
[DEFINED] DLFN: [IF]   528 [ELSE]   2 [THEN] CONSTANT AF-INIT       \ mac sin_len|AF_INET=0x0210 ; Linux 0x0002
[DEFINED] DLFN: [IF] 65535 [ELSE]   1 [THEN] CONSTANT SOL-SOCKET    \ mac SOL_SOCKET=0xffff ; Linux 1
[DEFINED] DLFN: [IF]     4 [ELSE]   2 [THEN] CONSTANT SO-REUSEADDR  \ mac SO_REUSEADDR=4 ; Linux 2
[DEFINED] DLFN: [IF]    32 [ELSE]  24 [THEN] CONSTANT AI-ADDR-OFF   \ addrinfo.ai_addr: mac +32, Linux +24
40 CONSTANT AI-NEXT-OFF                                             \ addrinfo.ai_next (последнее поле, +40 на обеих ќ—)
2 CONSTANT AF_INET
USER-CREATE sock_addr 16 USER-ALLOT          \ sockaddr_in на поток (реентерабельно)
USER-CREATE hostz    256 USER-ALLOT          \ буфер имени (0-терминированный) дл€ getaddrinfo, на поток
USER-CREATE gai-res    8 USER-ALLOT          \ результат getaddrinfo, свой на поток (освобождаетс€ freeaddrinfo)
CREATE sockopt-one 8 ALLOT   1 sockopt-one !  \ optval=1 (только чтение) дл€ setsockopt
CREATE gai-hints  48 ALLOT   gai-hints 48 0 FILL   AF_INET gai-hints 4 + !   1 gai-hints 8 + !  \ подсказка: AF_INET, SOCK_STREAM

\ ---- вызовы libc через виртуальный словарь SO (пор€док как в spf4: aN..a1 N им€) ----
NS-ON
[DEFINED] DLFN: [IF] ALSO SO NEW: libSystem.B.dylib [ELSE] ALSO SO NEW: libc.so.6 [THEN]
\ (errno) ( -- n ) : errno текущего потока (macOS __error / Linux __errno_location -- обе возвращают &errno)
[DEFINED] DLFN: [IF]   : (errno)   0 __error L@ ;
                [ELSE] : (errno)   0 __errno_location L@ ;
                [THEN]
: FdRead   ( a u fd -- n )    >R SWAP R>  3 read ;                  \ read(fd, a, u) -- ssize_t (64-бит)
: FdWrite  ( a u fd -- n )    >R SWAP R>  3 write ;                 \ write(fd, a, u)
: (mksock) ( -- fd )          6 1 AF_INET 3 socket ;               \ socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
: (connect) ( fd -- r )       16 sock_addr ROT 3 connect ;         \ connect(fd, &sock_addr, 16)
: (bind)   ( fd -- r )        16 sock_addr ROT 3 bind ;            \ bind(fd, &sock_addr, 16)
: (listen) ( fd -- r )        16 SWAP 2 listen ;                   \ listen(fd, 16)
: (accept) ( fd -- s2 )       0 0 ROT 3 accept ;                   \ accept(fd, NULL, NULL)
: (closefd) ( fd -- r )       1 close ;                            \ close(fd)
: (setreuse) ( fd -- r )      >R  4 sockopt-one SO-REUSEADDR SOL-SOCKET R> 5 setsockopt ;  \ setsockopt(...)
: (getai)  ( res hints service node -- ior )  4 getaddrinfo ;      \ getaddrinfo(node, service, hints, res)
: (freeai) ( res -- )         1 freeaddrinfo DROP ;                \ freeaddrinfo(res)
PREVIOUS                                                           \ вернуть пор€док поиска

\ ---- знаковое расширение + ior (C int в младших 32 битах; ior=errno, как оригинал -- WSAGetLastError) ----
: SX ( n -- n )   [ HEX ] FFFFFFFF AND  80000000 XOR  80000000 -  [ DECIMAL ] ;  \ знаковое расширение 32-битного int
: >ior ( r -- ior )   SX 0< IF (errno) ELSE 0 THEN ;              \ 0 = успех, иначе errno  (как "IF WSAGetLastError ELSE 0 THEN")

\ ---- sockaddr_in + API (как в SOCKETS.F) ----
: (sockaddr!) ( ip port -- )
   DUP 8 RSHIFT sock_addr 2 + C!  255 AND sock_addr 3 + C!         \ sin_port = htons(port): старший, младший
   sock_addr 4 + !                                                \ sin_addr = ip
   AF-INIT 255 AND sock_addr C!  AF-INIT 8 RSHIFT sock_addr 1 + C! \ sin_family (+ sin_len на BSD)
   0 sock_addr 8 + ! ;                                            \ sin_zero = 0
: CreateSocket ( -- socket ior )  (mksock) SX  DUP 0< IF (errno) ELSE 0 THEN ;
: ConnectSocket ( IP port socket -- ior )  >R (sockaddr!)  R> (connect) >ior ;
: BindSocket ( port socket -- ior )  >R  0 SWAP (sockaddr!)  R> (bind) >ior ;
: ListenSocket ( socket -- ior )  (listen) >ior ;
: AcceptSocket ( socket -- s2 ior )  (accept) SX  DUP 0< IF (errno) ELSE 0 THEN ;
: WriteSocket ( addr u s -- ior )  FdWrite  DUP 0< IF (errno) ELSE DROP 0 THEN ;      \ ssize_t -- знак уже верный
: ReadSocket ( addr u s -- rlen ior )  FdRead  DUP 0> IF 0 ELSE DUP 0= IF DROP 0 -1002 ELSE DROP 0 (errno) THEN THEN ;
: CloseSocket ( s -- ior )  (closefd) >ior ;
: ReuseAddrSocket ( socket -- ior )  (setreuse) >ior ;
\ ConnectHost ( addr u port -- sock ior )
\ ѕодключитьс€ к хосту addr u на порт port с автоматическим перебором всех IP-адресов хоста.
\ ≈сли коннект не удалс€, то ior -- код ошибки (на последнем адресе из списка) и sock=0.
\ ≈сли удалс€, то sock -- новый соединЄнный сокет, ior=0.
\ getaddrinfo реентерабелен: свой список адресов на вызов, освобождаетс€ freeaddrinfo.
: ConnectHost { a u port \ node s ior -- sock ior }
   u 255 MIN -> u
   a hostz u MOVE  0 hostz u + C!                                 \ 0-терминированна€ копи€ имени (на поток)
   gai-res gai-hints 0 hostz (getai)  ?DUP IF  0 SWAP EXIT  THEN  \ не разрешилось: sock=0, ior
   gai-res @ -> node   -1 -> ior                                  \ ior=-1, если список пуст
   BEGIN node WHILE                                               \ перебор всех адресов (ai_next)
      CreateSocket THROW -> s                                     \ свой сокет на попытку; ior от socket() -- THROW, не DROP
      node AI-ADDR-OFF + @  4 +  @   port s ConnectSocket -> ior  \ connect(node->ai_addr->sin_addr, port)
      ior 0= IF  gai-res @ (freeai)  s 0 EXIT  THEN               \ соединились: sock, ior=0
      s CloseSocket DROP                                          \ нет -- закрыть и к следующему адресу
      node AI-NEXT-OFF + @ -> node
   REPEAT
   gai-res @ (freeai)  0 ior ;                                    \ все неуспешны: sock=0, ior последнего
