\ SERVER_UDP.F  (C) 2000-2002 A.Cherezov

1500 VALUE PACK_SIZE

: ServerUdp { ss \ mem port ip size -- ior }
\ Серверный поток:
\ и выполнять обработку клиентских пакетов.
\ ss - серверный сокет, уже настроенный bind.
  SP@ S0 !
  ss TO vServerSocket
  ss TO vClientSocket \ это для лога
  PACK_SIZE ALLOCATE THROW -> mem
  NextThread
  BEGIN
    S0 @ SP!
    mem PACK_SIZE vServerSocket ReadFrom -> port -> ip -> size
    size
  WHILE
    GetTime
    S" OnUdpRecv" ['] EvalRules CATCH  IF 2DROP THEN
  REPEAT DROP
  vServerSocket CloseSocket DROP
;
' ServerUdp TASK: ServerUdpThread
