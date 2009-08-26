REQUIRE {            ~ac/lib/locals.f
REQUIRE STR@         ~ac/lib/str5.f
REQUIRE [IF]          lib/include/tools.f

REQUIRE ForEachWTSession ~ac/lib/win/exceptions/wt.f

WINAPI: MessageBoxA USER32.DLL
         6 CONSTANT IDYES
0x00000004 CONSTANT MB_YESNO
0x00000030 CONSTANT MB_ICONEXCLAMATION
0x00000040 CONSTANT MB_ICONASTERISK
0x00200000 CONSTANT MB_SERVICE_NOTIFICATION


WINAPI: FormatMessageA KERNEL32.DLL

HEX

00000100 CONSTANT FORMAT_MESSAGE_ALLOCATE_BUFFER
00001000 CONSTANT FORMAT_MESSAGE_FROM_SYSTEM

00 CONSTANT LANG_NEUTRAL
01 CONSTANT SUBLANG_DEFAULT
DECIMAL

: MAKELANGID ( p s -- langid )
  10 LSHIFT OR
;
\       ((((WORD  )(s)) << 10) | (WORD  )(p))
USER EMBUF
VARIABLE DenyGuiMessages
: /dgm TRUE DenyGuiMessages ! ;

: ErrorMessage ( errcode -- addr u )
  >R
  0 0 EMBUF
  LANG_NEUTRAL SUBLANG_DEFAULT MAKELANGID
  R> 0
  FORMAT_MESSAGE_ALLOCATE_BUFFER  FORMAT_MESSAGE_FROM_SYSTEM OR
  FormatMessageA
  ?DUP IF EMBUF @ SWAP ( 2-) ELSE HERE 0 THEN
;

[UNDEFINED] PROG-NAME [IF] : PROG-NAME S" SP-Forth" ; [THEN]

VARIABLE MAIN-WINDOW \ запишите сюда хэндл главного окна, если сообщения должны быть подчиненными

: MsgBox
  MAIN-WINDOW @ MessageBoxA
;
: Message { s -- }
  DenyGuiMessages @ IF s STR@ TYPE CR EXIT THEN
  MB_ICONEXCLAMATION PROG-NAME DROP
  s STR@ DROP
  MsgBox DROP
;
: AsteriskMessage { s -- }
  DenyGuiMessages @ IF s STR@ TYPE CR EXIT THEN
  MB_ICONASTERISK PROG-NAME DROP
  s STR@ DROP
  MsgBox DROP
;
: ServiceMessage { s -- }
  DenyGuiMessages @ IF s STR@ TYPE CR EXIT THEN
  MB_ICONEXCLAMATION MB_SERVICE_NOTIFICATION OR PROG-NAME DROP
  s STR@ DROP
  MsgBox DROP
;
: MessageY/N { s -- flag }
  DenyGuiMessages @ IF s STR@ TYPE ."  - No" CR FALSE EXIT THEN
  MB_YESNO PROG-NAME DROP
  s STR@ DROP 
  MsgBox IDYES =
;
: ServiceMessageY/N { s -- flag }
  DenyGuiMessages @ IF s STR@ TYPE ."  - No" CR FALSE EXIT THEN
  MB_YESNO MB_SERVICE_NOTIFICATION OR PROG-NAME DROP
  s STR@ DROP 
  MsgBox IDYES =
;

WINAPI: WTSSendMessageA       WTSAPI32.DLL
0x00000020 CONSTANT MB_ICONQUESTION

: (MsgBoxWT) { a u sid state par \ style s out -- flag }
  u 0= IF TRUE EXIT THEN
  state 0 <> IF TRUE EXIT THEN
  ( s style ) 2DUP -> style -> s
  TRUE ^ out 0 style
  s STR@ SWAP
  PROG-NAME SWAP
  sid 0 WTSSendMessageA 0=
  IF a u TYPE ." :wt_msg_err=" GetLastError . CR s STR@ TYPE CR THEN
  out par @ OR par !
  TRUE
;
: MsgBoxWT { s style \ out -- out }
\ вывести сообщение на экраны всех активных сессий Terminal Services и на консоль (если консоль активна)
  DenyGuiMessages @ IF s STR@ TYPE CR ( EXIT) THEN
  s style ^ out ['] (MsgBoxWT) ForEachWTSession
  2DROP out
;
: MessageWT ( s -- )
  MB_ICONEXCLAMATION MsgBoxWT DROP
;
: ServiceMessageWT ( s -- )
  MB_ICONEXCLAMATION MB_SERVICE_NOTIFICATION OR MsgBoxWT DROP
;
: MessageY/NWT ( s -- flag )
  MB_YESNO MB_ICONQUESTION OR MsgBoxWT IDYES =
;
: ServiceMessageY/NWT ( s -- flag )
  MB_YESNO MB_ICONQUESTION OR MB_SERVICE_NOTIFICATION OR MsgBoxWT IDYES =
;
\ " Да?" ServiceMessageY/NWT .
