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
  STARTLOG
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
REQUIRE TPluginStartupInfo  plugin.f
REQUIRE .S    lib/include/tools.f

1234 CONSTANT SOMETHING

0 VALUE DEBUG \ 1 for debugging output

ALSO TPluginStartupInfo
HERE /SIZE ALLOT VALUE FARAPI
/SIZE FARAPI StructSize !
PREVIOUS

CONST
 MTitle     0
 MMessage1  1
 MMessage2  2
 MMessage3  3
 MMessage4  4
 MButton    5
;

: .H ( x -- ) BASE @ SWAP HEX ." 0x0" . BASE ! ;

: PrintPluginInfo ( psi -- )
  >R
  [ ALSO TPluginStartupInfo ]
   CR ." -------------------------------------------------"
   CR ." PSI : " R@ .H
   CR R@ StructSize   DUP .H ." StructSize "   @ .H
   CR R@ ModuleNumber DUP .H ." ModuleNumber " @ .H
   CR R@ GetMsg       DUP .H ." GetMsg "       @ .H
   CR R@ Message      DUP .H ." Message "      @ .H
   CR R@ ShowHelp     DUP .H ." ShowHelp "     @ .H
   CR R@ DefDlgProc   DUP .H ." DefDlgProc "   @ .H
   CR ." -------------------------------------------------"
  [ PREVIOUS ]
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
  FARAPI TPluginStartupInfo::ModuleNumber @ FARAPI TPluginStartupInfo::GetMsg @ API-CALL
;

( 
Функция SetStartupInfo вызывается один раз, перед всеми
другими функциями. Она передается плагину информацию,
необходимую для дальнейшей работы.
)

:NONAME ( psi -- )
  STARTLOG
  DEBUG IF CR S" SetStartupInfo " THEN
  FARAPI TPluginStartupInfo::/SIZE CMOVE
\  FARAPI PrintPluginInfo
  SOMETHING
; 1 CELLS CALLBACK: SetStartupInfo

( 
Функция GetPluginInfo вызывается для получения основной
  [general] информации о плагине
)

VARIABLE MyPluginMenuStrings \ array[0..0] of PChar;

ALSO TPluginInfo

:NONAME ( PluginInfo)
  DEBUG IF CR ." GetPluginInfo" THEN
  >R
   /SIZE R@ StructSize !
   PF_VIEWER R@ Flags !
   MTitle GetMsg MyPluginMenuStrings !
   MyPluginMenuStrings R@ PluginMenuStrings !
   1 R@ PluginMenuStringsNumber !
  RDROP
  SOMETHING \ Возвращаем что-нибудь
; 1 CELLS CALLBACK: GetPluginInfo

PREVIOUS \ TPluginInfo

CREATE Msg 6 CELLS ALLOT

( 
  Функция OpenPlugin вызывается при создании новой копии плагина.
)
:NONAME ( Item OpenFrom -- Handle )
\  S" OpenPlugin" ShowMessage
  DEBUG IF
   ." OpenPlugin : "
   ." from = " .H ." item = " .H CR
  ELSE
   2DROP 
  THEN

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
  FARAPI TPluginStartupInfo::ModuleNumber @ \ PluginNumber
  FARAPI TPluginStartupInfo::Message @ API-CALL
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
