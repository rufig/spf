REQUIRE STRUCT: lib/ext/struct.f
REQUIRE CONST   ~micro/lib/const/const.f

260 CONSTANT NM

STRUCT: TPluginStartupInfo
 4 -- StructSize \ integer;
NM -- ModuleName \ array[0..NM-1] of Char
 4 -- ModuleNumber \ integer;
 4 -- RootKey \ PChar;

 4 -- Menu \ TFarApiMenu;
 4 -- Dialog \ TFarApiDialog;
 4 -- Message \ TFarApiMessage;
 4 -- GetMsg \ TFarApiGetMsg;
 4 -- Control \ TFarApiControl;
 4 -- SaveScreen \ TFarApiSaveScreen;
 4 -- RestoreScreen \ TFarApiRestoreScreen;
 4 -- GetDirList \ TFarApiGetDirList;
 4 -- GetPluginDirList \ TFarApiGetPluginDirList;
 4 -- FreeDirList \ TFarApiFreeDirList;
 4 -- Viewer \ TFarApiViewer;
 4 -- Editor \ TFarApiEditor;
 4 -- CmpName \ TFarApiCmpName;
 4 -- CharTable \ TFarApiCharTable;
 4 -- Text \ TFarApiText;
 4 -- EditorControl \ TFarApiEditorControl;
\  Указатель на структуру с адресами полезных функций из far.exe
 4 -- FSF \ PFarStandardFunctions;
\  Функция вывода помощи
 4 -- ShowHelp \ TFarApiShowHelp;
\  Функция, которая будет действовать и в редакторе, и в панелях, и...
 4 -- AdvControl \ TFarApiAdvControl;
\  Функции для обработчика диалога
 4 -- InputBox \ TFarApiInputBox;
 4 -- DialogEx \ TFarApiDialogEx;
 4 -- SendDlgMessage \ TFarApiSendDlgMessage;
 4 -- DefDlgProc \ TFarApiDefDlgProc;
 4 -- Reserved \ DWORD;
 4 -- ViewerControl \ TFarApiViewerControl;
;STRUCT

STRUCT: TPluginInfo 
 4 -- StructSize \ integer;
 4 -- Flags \ DWORD;
 4 -- DiskMenuStrings \ PPCharArray;
 4 -- DiskMenuNumbers \ PIntegerArray;
 4 -- DiskMenuStringsNumber \ integer;
 4 -- PluginMenuStrings \ PPCharArr;
 4 -- PluginMenuStringsNumber \ integer;
 4 -- PluginConfigStrings \ PPCharArr;
 4 -- PluginConfigStringsNumber \ integer;
 4 -- CommandPrefix \ PChar;
 4 -- Reserved \ DWORD;
;STRUCT

CONST for GetPluginInfo
 PF_PRELOAD        1
 PF_DISABLEPANELS  2
 PF_EDITOR         4
 PF_VIEWER         8
 PF_FULLCMDLINE    16
;

CONST  for Message()
  FDLG_WARNING             0x000001
  FDLG_SMALLDIALOG         0x000002
  FDLG_NODRAWSHADOW        0x000004
  FDLG_NODRAWPANEL         0x000008
  FMSG_WARNING             0x000001
  FMSG_ERRORTYPE           0x000002
  FMSG_KEEPBACKGROUND      0x000004
  FMSG_DOWN                0x000008
  FMSG_LEFTALIGN           0x000010
  FMSG_ALLINONE            0x000020
  FMSG_MB_OK               0x010000
  FMSG_MB_OKCANCEL         0x020000
  FMSG_MB_ABORTRETRYIGNORE 0x030000
  FMSG_MB_YESNO            0x040000
  FMSG_MB_YESNOCANCEL      0x050000
  FMSG_MB_RETRYCANCEL      0x060000
;
