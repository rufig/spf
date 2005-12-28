DIS-OPT

REQUIRE {       ~ac\lib\locals.f

' NOOP ' MAINX EXECUTE !

: (INIT1)
  0 TO H-STDLOG
  0 TO H-STDIN
  CONSOLE-HANDLES
  ['] CGI-OPTIONS ERR-EXIT
  ['] AT-PROCESS-STARTING ERR-EXIT
  MAINX @ ?DUP IF ERR-EXIT THEN
;

: (INIT2)
  (INIT1)
  SPF-INIT?  IF
    ['] SPF-INI ERR-EXIT
  THEN OPTIONS
  CGI? @ 0= POST? @ OR IF ['] <MAIN> ERR-EXIT THEN
  BYE
;

: (dllinit) ( reserved reason hinstance -- retcode )
  OVER 0 = IF  ( ." DLL_PROCESS_DETACH " )       ELSE
  OVER 1 = IF (INIT1) ( ." DLL_PROCESS_ATTACH ") ELSE
  OVER 2 = IF ( ." DLL_THREAD_ATTACH ")  ELSE
  OVER 3 = IF ( ." DLL_THREAD_DETACH ")  ELSE
\  OVER  .
  THEN THEN THEN THEN \ CR
  2DROP DROP
  1  \ 0 to fail
;

' (dllinit) 3 CELLS CALLBACK: DllMain

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

REQUIRE CONST ~micro/lib/const/const.f
REQUIRE TPSI  plugin.f
REQUIRE .S    lib/include/tools.f

0x00001000 CONSTANT MB_SYSTEMMODAL
WINAPI: MessageBoxA USER32.DLL

1234 CONSTANT SOMETHING

HERE TPSI::/SIZE ALLOT VALUE FARAPI
TPSI::/SIZE FARAPI TPSI::StructSize ! 

CONST
 MTitle     0
 MMessage1  1
 MMessage2  2
 MMessage3  3
 MMessage4  4
 MButton    5
;

: .H ( x -- )
 BASE @ SWAP HEX ." 0x0" . BASE ! 
;

: PrintPluginInfo ( psi -- )
  >R
   CR 
   ." -------------------------------------------------"
   CR
   ." PSI : " R@ .H CR
   R@ TPSI::StructSize DUP .H ." StructSize " @ .H CR
   R@ TPSI::ModuleNumber DUP .H ." ModuleNumber " @ .H CR
   R@ TPSI::GetMsg DUP .H ." GetMsg " @ .H CR
   R@ TPSI::Message DUP .H ." Message " @ .H CR
   R@ TPSI::ShowHelp DUP .H ." ShowHelp " @ .H CR
   R@ TPSI::DefDlgProc DUP .H ." DefDlgProc " @ .H CR
   ." -------------------------------------------------"
   CR
  RDROP
;

VARIABLE String
 HERE S" Hello world plugin in Forth" S,  0 ,
 String !

( 
 Функция GetMsg возвращает строку сообщения из языкового файла.
 А это надстройка над Info.GetMsg для сокращения кода :-)

: GetMsg ( MsgId -- pchar )
\  ." GetMsg "
  FARAPI TPSI::ModuleNumber @ FARAPI TPSI::GetMsg @ API-CALL
;

( 
Функция SetStartupInfo вызывается один раз, перед всеми
другими функциями. Она передается плагину информацию,
необходимую для дальнейшей работы.
)

:NONAME ( psi -- )
\  ." SetStartupInfo "
  FARAPI TPSI::/SIZE CMOVE
\  FARAPI PrintPluginInfo
  SOMETHING
; 1 CELLS CALLBACK: SetStartupInfo

( 
Функция GetPluginInfo вызывается для получения основной
  [general] информации о плагине
)

VARIABLE PluginMenuStrings \ array[0..0] of PChar;

: ShowMessage ( addr u -- )
   DROP >R MB_SYSTEMMODAL S" hi" DROP R>  0 MessageBoxA DROP
;

:NONAME ( PluginInfo)
  >R
   TPI::/SIZE R@ TPI::StructSize !
   PF_VIEWER R@ TPI::Flags !
   MTitle GetMsg PluginMenuStrings !
   PluginMenuStrings R@ TPI::PluginMenuStrings !
   1 R@ TPI::PluginMenuStringsNumber !
  RDROP
  SOMETHING \ Возвращаем что-нибудь
; 1 CELLS CALLBACK: GetPluginInfo

CREATE Msg 6 CELLS ALLOT

( 
  Функция OpenPlugin вызывается при создании новой копии плагина.
)
:NONAME ( Item OpenFrom -- Handle )
\  S" OpenPlugin" ShowMessage
\  ." OpenPlugin : "
\  ." from = " .H ." item = " .H CR

     MTitle GetMsg Msg 0 CELLS + !
  MMessage1 GetMsg Msg 1 CELLS + !
  MMessage2 GetMsg Msg 2 CELLS + !
  MMessage3 GetMsg Msg 3 CELLS + !
  MMessage4 GetMsg Msg 4 CELLS + !
    MButton GetMsg Msg 5 CELLS + !
   
  1 \ ButtonsNumber
  6 \ ItemsNumber
  Msg \ Items
  0 \ HelpTopic
  FMSG_WARNING FMSG_ERRORTYPE OR FMSG_LEFTALIGN OR \ Flags
  FARAPI TPSI::ModuleNumber @ \ PluginNumber
  FARAPI TPSI::Message @ API-CALL
  DROP

\  ." result " .H
  
  INVALID_HANDLE_VALUE 
; 2 CELLS CALLBACK: OpenPlugin

( 
exports
  SetStartupInfo,
  GetPluginInfo,
  OpenPlugin;
)
