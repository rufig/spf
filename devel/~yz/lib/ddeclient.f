\ Клиент DDE
\ Ю.Жиловец, http://www.forth.org.ru/~yz

REQUIRE " ~yz/lib/common.f
REQUIRE { ~ac/lib/locals.f

MODULE: DDEClient

WINAPI: DdeInitializeA         USER32.DLL
WINAPI: DdeUninitialize        USER32.DLL
WINAPI: DdeConnect             USER32.DLL
WINAPI: DdeDisconnect          USER32.DLL
WINAPI: DdeClientTransaction   USER32.DLL
WINAPI: DdeCreateStringHandleA USER32.DLL
WINAPI: DdeFreeStringHandle    USER32.DLL
WINAPI: DdeQueryStringA        USER32.DLL
WINAPI: DdeGetData             USER32.DLL
WINAPI: DdeFreeDataHandle      USER32.DLL
WINAPI: DdeGetLastError        USER32.DLL

USER-VALUE ddeid

:NONAME
\ 8 PARAMS ." ddecallback=" s.
 2DROP 2DROP 2DROP 2DROP
 0
; WNDPROC: ddecallback

: z>hsz ( z -- hsz)
  1004 ( cp_winansi) SWAP ddeid DdeCreateStringHandleA ; 

: free-string ( hsz -- )
  ddeid DdeFreeStringHandle DROP ;

EXPORT

: dde-init ( -- 0 ok/ <>0 error)
  0 0x3C0010 ( appclass_clientonly|cbf_skip_allnotifications)
  ['] ddecallback
  0 >R RP@ DdeInitializeA R> TO ddeid
;

: dde-destroy ( -- )
  ddeid DdeUninitialize DROP
;

: dde-connect
  ( zService zTopic -- hconv 0 |сервер найден| / 0 0 |сервер не найден| / errorcode |ошибка|)
  { service topic -- }
  topic z>hsz TO topic
  service z>hsz TO service
  0 topic service ddeid DdeConnect
  topic free-string
  service free-string
  ?DUP IF 0 EXIT THEN
  ( вернем код ошибки)
  ddeid DdeGetLastError
  DUP 0= IF 0 THEN
;

: dde-disconnect ( hconv -- 0 / error)
  DdeDisconnect
  IF 0 ELSE ddeid DdeGetLastError THEN
;

: dde-execute ( z hconv -- 0 / errorcode )
  { command hconv -- }
  0 10000 0x4050 ( xtyp_execute) 0 0 hconv command ZLEN command
  DdeClientTransaction
  IF 0 ELSE ddeid DdeGetLastError THEN
;

: dde-poke { zdata topic hconv -- 0/errcode }
  topic z>hsz TO topic
  0 10000 0x4090 ( xtyp_poke) 1 ( cf_text) topic hconv
  zdata ASCIIZ> SWAP DdeClientTransaction
  topic free-string
  IF 0 ELSE ddeid DdeGetLastError THEN
;

: dde-request ( z hconv -- z 0 / 0 0 сервер ничего не вернул / errorcode)
\ возвращаемую строку после использования надо освободить
\ Случай 0 0, похоже, наблюдается только на 95/98, когда у сервера
\ тайм-аут. NT возвращает правильный код ошибки 0x4002
  { request hconv \ hdata -- }
  0 10000 0x20B0 ( xtyp_request) 1 ( cf_text) request z>hsz DUP TO request
  hconv 0 0
  DdeClientTransaction
  request free-string
  ?DUP 0= IF ddeid DdeGetLastError DUP 0= IF 0 THEN EXIT THEN
  TO hdata
  0 0 0 hdata DdeGetData ( длина данных)
  DUP GETMEM ( # to) DUP >R 0 ROT ROT hdata DdeGetData DROP
  R> 0
  hdata DdeFreeDataHandle DROP
;

;MODULE
