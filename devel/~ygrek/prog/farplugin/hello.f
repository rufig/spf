REQUIRE (dllinit) ~ygrek/lib/far/plugindll.f
REQUIRE NEWDIALOG ~ygrek/lib/far/control.f

1234 CONSTANT SOMETHING

' STARTLOG TO FARPLUGIN-INIT

( 
 Функция GetMsg возвращает строку сообщения из языкового файла.
 А это надстройка над Info.GetMsg для сокращения кода :-)

: GetMsg ( MsgId -- pchar ) FARAPI. ModuleNumber @ FARAPI. GetMsg @ API-CALL ;

:NONAME DUP 1+ SWAP CREATE , DOES> @ GetMsg ; ENUM MESSAGES=

0 
 MESSAGES= MTitle MMessage1 MMessage2 MMessage3 MMessage4 MButton ;
DROP

( 
Функция SetStartupInfo вызывается один раз, перед всеми
другими функциями. Она передается плагину информацию,
необходимую для дальнейшей работы.
)

:NONAME ( psi -- void )
  FARAPI. /SIZE CMOVE
  SOMETHING
; 1 CELLS CALLBACK: SetStartupInfo

( 
Функция GetPluginInfo вызывается для получения основной
  [general] информации о плагине
)

VARIABLE MyPluginMenuStrings \ array[0..0] of PChar;
VARIABLE MyPluginConfigStrings

:NONAME { pi \ -- void }  
   TEMPAUS TPluginInfo pi

   pi. /SIZE NIP  pi. StructSize !

   W: PF_VIEWER pi. Flags !

   MTitle MyPluginMenuStrings !
   MyPluginMenuStrings pi. PluginMenuStrings !

   1 pi. PluginMenuStringsNumber !

   MTitle MyPluginConfigStrings !
   MyPluginConfigStrings pi. PluginConfigStrings !

   1 pi. PluginConfigStringsNumber !

  SOMETHING \ Возвращаем что-нибудь
; 1 CELLS CALLBACK: GetPluginInfo

0 VALUE .output
0 VALUE .input

: MakeGrid ( -- grid )

   0 TO Items
   10 Items. get ALLOCATE THROW TO Items
   10 Items. buf ERASE
   
   GRID
    GRID
     " SPF:" label |
     " 2 2 + . " edit  -xspan  20 1 this ctlresize  this TO .input  |
     ===
     "" label  this TO .output |
     -boxed
    GRID; |
    ===
    "" label |
    ===
    " OK" button -xspan -center |
   GRID;

;

0 VALUE zz

: ToLabel ( a u -- )
   >ASCIIZ
   zz SWAP ZAPPEND
   zz .output -text! ;

MESSAGES: MyDlgProc

M: dn_key { \ buf -- }
    param1 .input -id@ <> IF FALSE EXIT THEN
    param2 13 <> IF FALSE EXIT THEN

    0 zz !
    zz .output -text!

    .input -text# ALLOCATE THROW TO buf
    buf .input -text@ 
    buf .input -text#
    ['] ToLabel TO TYPE
    EVALUATE
\    ['] ToLabel2 TO TYPE
\    S" OK" EVALUATE
    ['] TYPE1 TO TYPE
    DEPTH 0 ?DO DROP LOOP \ DROP all extra
    buf FREE THROW
  
    TRUE RETURN
    TRUE
M;

MESSAGES;

:NONAME ( Item OpenFrom -- Handle )
  ( 2DUP ." from = " .H ." item = " .H CR )

   2DROP 

   NEWDIALOG

    MakeGrid  winmain -grid!
    MyDlgProc winmain -dlgproc!

    1024 ALLOCATE THROW TO zz

   RUNDIALOG

    zz FREE THROW

\   5 Items. buf DUMP

   Items FREE THROW
   0 TO Items

  INVALID_HANDLE_VALUE ; 2 CELLS CALLBACK: OpenPlugin

(
  Вызывается при вызове из меню настроек плагинов
) 
:NONAME ( number -- flag )
  DROP

  TRUE
; 1 CELLS CALLBACK: Configure

