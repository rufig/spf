\ Окошки с сообщениями

WINAPI: MessageBoxA      USER32.DLL

: MsgBox ( zcaption z flags -- n) ROT ROT 0 MessageBoxA ;
: msgbox ( zcaption z -- ) 0x40 ( mb_Iconasterisk) MsgBox DROP ;
