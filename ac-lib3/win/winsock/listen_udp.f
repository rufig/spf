: ListenPortUdp ( port -- )
  { port \ s  -- }
  CreateUdpSocket THROW -> s
  port s BindSocket THROW
  s ServerUdpThread START
  port s ROT AddServer
;
: ListenInterfaceUdp ( port IP -- )
  { port ip \ s }
  CreateUdpSocket THROW -> s
  port ip s BindSocketInterface THROW
  s ServerUdpThread START
  port s ROT AddServer
;
: ListenUdp: { \ sp err }
  BEGIN
    REFILL
  WHILE
    SP@ -> sp
    ParseNum DUP 0= IF DROP EXIT THEN
    BL PARSE0 ?DUP
    IF GetHostIP DROP ['] ListenInterfaceUdp
    ELSE DROP ['] ListenPortUdp THEN

    CATCH ?DUP 
    IF -> err sp SP! SOURCE err DUP ErrorMessage ROT
       510 GetLogStr MessageY/N
       0= IF BYE THEN
    THEN
    uListeners 1+!
  REPEAT
;
