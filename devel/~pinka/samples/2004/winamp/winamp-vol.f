\ 22.Mar.2004 Mon 02:06, ruv
\ plugin for nncron

0x0400 CONSTANT WM_USER
WM_USER CONSTANT WM_WA_IPC

122 CONSTANT IPC_SETVOLUME 

\ also see [http://download.nullsoft.com/winamp/client/wa502_sdk.zip]/winamp/wa_ipc.h 

: winamp-vol! ( n -- )
  >R
  WIN-EXIST: "Winamp v*" IF

  IPC_SETVOLUME R@ WM_WA_IPC WIN-HWND SendMessageA DROP

  THEN
  
  RDROP
;

0 VALUE WA-HWND

: wait-wa ( -- )
  50 0 DO
    WIN-EXIST: "Winamp v*"
    IF UNLOOP EXIT THEN
    100 PAUSE
  LOOP
;
: get-wa ( -- f )
    wait-wa
    WIN-EXIST: "Winamp v*"
    DUP
    IF WIN-HWND ELSE 0 THENTO WA-HWND
;
: wa-vol! ( n -- )
  WA-HWND 0= IF DROP EXIT THEN
  >R
  IPC_SETVOLUME R> WM_WA_IPC WA-HWND SendMessageA DROP
;

500 VALUE  wa-ms  \ 1-200 -  100 sec

: winap-vol-up! ( n -- )
\ увеличить плавно громкость от 0 до n, n=0-255
  get-wa 0= IF DROP EXIT THEN
  0 ?DO
    I wa-vol!
    wa-ms PAUSE
  LOOP
;
