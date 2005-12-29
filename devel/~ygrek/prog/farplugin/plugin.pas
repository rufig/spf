(********************************************************
* PLUGIN.PAS
* Plugin API for FAR Manager 1.70
* $Revision$
*
* Copyright (c) 1996-2000 Eugene Roshal
* Copyrigth (c) 2000-2001 [ FAR group ]
* Translated by Vasily V. Moshninov
* VP comments and fixes by Dmitry Suhodoev
*********************************************************)



{$IFDEF VIRTUALPASCAL}

  {$DEFINE VP}
  {&Delphi+,AlignData+,AlignRec+,StdCall+,H+,Z+,Use32+}

{$ELSE}

  {$ALIGN OFF}
  {$MINENUMSIZE 4}

  {$WRITEABLECONST ON}

  {$IFNDEF VER80}           { Delphi 1.0     }
   {$IFNDEF VER90}          { Delphi 2.0     }
    {$IFNDEF VER93}         { C++Builder 1.0 }
      {$IFNDEF VER100}
        {$IFNDEF VER110}
          {$DEFINE USE_DELPHI4}   { Delphi 4.0 or higher }
        {$ENDIF}
      {$ENDIF}
    {$ENDIF}
   {$ENDIF}
  {$ENDIF}

{$ENDIF}

unit plugin;

interface
uses windows;

function MakeFarVersion(major: DWORD; minor: DWORD; build: DWORD): DWORD; {$IFNDEF VP} register; {$ENDIF}

const

// See initialization section
  FARMANAGERVERSION : DWORD = 0;

  NM = 260;

{$IFDEF VP}
  MaxInt = MaxLongint;
{$ENDIF}

  MAXSIZE_SHORTCUTDATA = 8192;

type

  size_t = DWORD;

  TPCharArr = packed array[0..Pred(MaxInt div sizeof(PChar))] of PChar;
  PPCharArr = ^TPCharArr;

  TIntArr = packed array[0..Pred(MaxInt div sizeof(integer))] of integer;
  PIntArr = ^TIntArr;

  TWin32FindDataEx = packed record
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    dwReserved0: DWORD;
    dwReserved1: DWORD;
    cFileName: packed array[0..Pred(MAX_PATH)] of AnsiChar;
    cAlternateFileName: packed array[0..13] of AnsiChar;
  end; { TWin32FindDataEx record }

 TPluginPanelItem = packed record
   FindData: TWin32FindDataEx;
   PackSizeHigh: DWORD;
   PackSize: DWORD;
   Flags: DWORD;
   NumberOfLinks: DWORD;
   Description: PChar;
   Owner: PChar;
   CustomColumnData: PPCharArr;
   CustomColumnNumber: integer;
   UserData: DWORD;
   CRC32: DWORD;
   Reserved: packed array[0..1] of DWORD;
  end; { TPluginPanelItem record }
  PPluginPanelItem = ^TPluginPanelItem;
  TPluginPanelItemArr = packed array[0..Pred(MaxInt div sizeof(TPluginPanelItem))] of TPluginPanelItem;
  PPluginPanelItemArr = ^TPluginPanelItemArr;

const
// PluginPanelItem flags
  PPIF_PROCESSDESCR = $80000000;
  PPIF_SELECTED     = $40000000;
  PPIF_USERDATA     = $20000000;

// FarMenu flags
  FMENU_SHOWAMPERSAND        = $0001;
  FMENU_WRAPMODE             = $0002;
  FMENU_AUTOHIGHLIGHT        = $0004;
  FMENU_REVERSEAUTOHIGHLIGHT = $0008;
  FMENU_USEEXT               = $0020;

  MIF_SELECTED               = $00010000;
  MIF_CHECKED                = $00020000;
  MIF_SEPARATOR              = $00040000;
  MIF_DISABLE                = $00080000;
  MIF_USETEXTPTR             = $80000000;

type

  TFarMenuItem = packed record
    Text: packed array[0..127] of char;
    Selected: BOOL;
    Checked: BOOL;
    Separator: BOOL;
  end; { TFarMenuItem record }
  PFarMenuItem = ^TFarMenuItem;
  TFarMenuItemArr = packed array[0..Pred(MaxInt div sizeof(TFarMenuItem))] of TFarMenuItem;
  PFarMenuItemArr = ^TFarMenuItemArr;

  TFarMenuItemEx = packed record
    Flags: DWORD;
    Text: record case integer of
      0: (Text: array[0..127] of char);
      1: (TextPtr: PChar);
    end;
    AccelKey: DWORD;
    Reserved: DWORD;
    UserData: DWORD;
  end;
  PFarMenuItemEx = ^TFarMenuItemEx;


  TFarListItemData = packed record
    Index: integer;
    DataSize: integer;
    Data: pointer;
    Reserved: DWORD;
  end;
  PFarListItemData = ^TFarListItemData;
  TFarListItemDataArr = packed array[0..Pred(MaxInt div sizeof(TFarListItemData))] of TFarListItemData;
  PFarListItemDataArr = ^TFarListItemDataArr;

  TFarListTitles = packed record
    TitleLen: integer;
    Title: PChar;
    BottomLen: integer;
    Bottom: PChar;
  end;
  PFarListTitles = ^TFarListTitles;

  TFarDialogItemData = packed record
    PtrLength: integer;
    PtrData: PChar;
  end;
  PFarDialogItemData = ^TFarDialogItemData;
  TFarDialogItemDataArr = packed array[0..Pred(MaxInt div sizeof(TFarDialogItemData))] of TFarDialogItemData;
  PFarDialogItemDataArr = ^TFarDialogItemDataArr;

  TFarApiMenu = function(
    PluginNumber: integer;
    X, Y: integer;
    MaxHeight: integer;
    Flags: DWORD;
    const Title: PChar;
    const Bottom: PChar;
    const HelpTopic: PChar;
    const BreakKeys: PIntArr;
    BreakCode: PInteger;
    const Items: PFarMenuItemArr;
    ItemsNumber: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

// функция - обработчика окна
  TFarApiWndProc = function(
    hDlg: THandle;
    Msg: integer;
    Param1: integer;
    Param2: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

// обмен сообщениями с обработчиком диалога
  TFarApiSendDlgMessage = function(
    hDlg: THandle;
    Msg: integer;
    Param1: integer;
    Param2: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarApiDefDlgProc = function(
    hDlg: THandle;
    Msg: integer;
    Param1: integer;
    Param2: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

const
// ListItem flags
  LIF_SELECTED       = $00010000;
  LIF_CHECKED        = $00020000;
  LIF_SEPARATOR      = $00040000;
  LIF_DISABLE        = $00080000;
  LIF_DELETEUSERDATA = $80000000;

  BSTATE_UNCHECKED = 0;
  BSTATE_CHECKED   = 1;
  BSTATE_3STATE    = 2;
  BSTATE_TOGGLE    = 3;

  FLINK_HARDLINK         = $00000001;
  FLINK_SYMLINK          = $00000002;
  FLINK_VOLMOUNT         = $00000003;
  FLINK_SHOWERRMSG       = $00010000;
  FLINK_DONOTUPDATEPANEL = $00020000;

  LIFIND_EXACTMATCH= $00000001;

type

  TFarPtr = packed record
    PtrFlags: DWORD;
    PtrLength: integer;
    PtrData: PChar;
    PtrTail: array[0..0] of char;
  end; { TFarDialogPtr record }

//   Список Items для DI_COMBOBOX & DI_LISTBOX
  TFarListItem = packed record
    Flags: DWORD;
    Text: packed array[0..127] of char;
    Reserved: packed array[0..2] of DWORD;
  end; { TFarListItem record }
  PFarListItem = ^TFarListItem;
  TFarListItemArr = packed array[0..Pred(MaxInt div sizeof(TFarListItem))] of TFarListItem;
  PFarListItemArr = ^TFarListItemArr;

// Список для передачи диалогу
  TFarList = packed record
    ItemsNumber: integer;
    Items: PFarListItemArr;
  end; { TFarList record }
  PFarList = ^TFarList;

  TFarListUpdate = packed record
    Index: integer;
    Item: TFarListItem;
  end;

  TFarListInsert = packed record
    Index: integer;
    Item: TFarListItem;
  end;

  TFarListPos = packed record
    SelectPos: integer;
    TopPos: integer;
  end;
  PFarListPos = ^TFarListPos;

  TFarListFind = packed record
    StartIndex: integer;
    Pattern: PChar;
    Flags: DWORD;
    Reserved: DWORD;
  end;
  PFarListFind = ^TFarListFind;

  TFarListDelete = packed record
    StartIndex: integer;
    Count: integer;
  end;
  PFarListDelete = ^TFarListDelete;

  TFarListGetItem = packed record
    ItemIndex: integer;
    Item: TFarListItem;
  end;
  PFarListGetItem = ^TFarListGetItem;

const

  LINFO_SHOWNOBOX             = $00000400;
  LINFO_AUTOHIGHLIGHT         = $00000800;
  LINFO_REVERSEHIGHLIGHT      = $00001000;
  LINFO_WRAPMODE              = $00008000;
  LINFO_SHOWAMPERSAND         = $00010000;

type

  TFarListInfo = packed record
    Flags: DWORD;
    ItemsNumber: integer;
    SelectPos: integer;
    TopPos: integer;
    MaxHeight: integer;
    MaxLength: integer;
    Reserved: array[0..5] of DWORD;
  end;
  PFarListInfo = ^TFarListInfo;

type

  TFarListColors = packed record
    Flags: DWORD;
    Reserved: DWORD;
    ColorCount: integer;
    Colors: PChar;
  end;
  PFarListColors = ^TFarListColors;

  TFarDialogItem = packed record
    ItemType: integer;
    X1: integer;
    Y1: integer;
    X2: integer;
    Y2: integer;
    Focus: integer;
//    Selected: integer;
    Param: record case integer of
      0: (Selected: BOOL);
      1: (History: PChar);
      2: (Mask: PChar);
      3: (ListItems: PFarList);
      4: (ListPos: integer);
      5: (VBuf: PCharInfo);
    end;
    Flags: DWORD;
    DefaultButton: BOOL;
    Data: record case integer of
      0: (Data: packed array[0..511] of char);
      1: (Ptr: TFarPtr)
    end;
  end; { TFarDialogItem record }
  PFarDialogItem = ^TFarDialogItem;
  TFarDialogItemArr = packed array[0..Pred(MaxInt div sizeof(TFarDialogItem))] of TFarDialogItem;
  PFarDialogItemArr = ^TFarDialogItemArr;

  TFarApiDialog = function(
    PluginNumber: integer;
    X1, Y1: integer;
    X2, Y2: integer;
    const HelpTopic: PChar;
    Items: PFarDialogItemArr;
    ItemsNumber: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

//   Дополнительный параметр Param, который будет передан
//   в обработчик диалога в WM_INITDIALOG
  TFarApiDialogEx = function(
    PluginNumber: integer;
    X1, Y1: integer;
    X2, Y2: integer;
    const HelpTopic: PChar;
    Items: PFarDialogItemArr;
    ItemsNumber: integer;
    Reserved: DWORD;
    Flags: DWORD;
    DlgProc: TFarApiWndProc;
    Param: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

const
  FDLG_WARNING             = $00000001;
  FDLG_SMALLDIALOG         = $00000002;
  FDLG_NODRAWSHADOW        = $00000004;
  FDLG_NODRAWPANEL         = $00000008;

// FarMessage constants
  FMSG_WARNING             = $00000001;
  FMSG_ERRORTYPE           = $00000002;
  FMSG_KEEPBACKGROUND      = $00000004;
  FMSG_DOWN                = $00000008;
  FMSG_LEFTALIGN           = $00000010;

  FMSG_ALLINONE            = $00000020;


  FMSG_MB_OK               = $00010000;
  FMSG_MB_OKCANCEL         = $00020000;
  FMSG_MB_ABORTRETRYIGNORE = $00030000;
  FMSG_MB_YESNO            = $00040000;
  FMSG_MB_YESNOCANCEL      = $00050000;
  FMSG_MB_RETRYCANCEL      = $00060000;

type

  TFarApiMessage = function(
    PluginNumber: integer;
    Flags: DWORD;
    const HelpTopic: PChar;
    const Items: PPCharArr;
    ItemsNumber: integer;
    ButtonsNumber: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarApiGetMsg = function(
    PluginNumber: integer;
    MsgId: integer): PChar; {$IFNDEF VP} stdcall; {$ENDIF}

const
  DI_TEXT        = 00;
  DI_VTEXT       = 01;
  DI_SINGLEBOX   = 02;
  DI_DOUBLEBOX   = 03;
  DI_EDIT        = 04;
  DI_PSWEDIT     = 05;
  DI_FIXEDIT     = 06;
  DI_BUTTON      = 07;
  DI_CHECKBOX    = 08;
  DI_RADIOBUTTON = 09;
  DI_COMBOBOX    = 10;
  DI_LISTBOX     = 11;
  DI_USERCONTROL = 255;

const
// FarDialogItem flags
  DIF_COLORMASK       = $000000ff;
  DIF_SETCOLOR        = $00000100;
  DIF_BOXCOLOR        = $00000200;
  DIF_GROUP           = $00000400;
  DIF_LEFTTEXT        = $00000800;
  DIF_MOVESELECT      = $00001000;
  DIF_SHOWAMPERSAND   = $00002000;
  DIF_CENTERGROUP     = $00004000;
  DIF_NOBRACKETS      = $00008000;
  DIF_MANUALADDHISTORY= $00008000;
  DIF_SEPARATOR       = $00010000;
  DIF_VAREDIT         = $00010000;
  DIF_SEPARATOR2      = $00020000;
  DIF_EDITOR          = $00020000;
  DIF_LISTNOAMPERSAND = $00020000;
  DIF_LISTNOBOX       = $00040000;
  DIF_HISTORY         = $00040000;
  DIF_BTNNOCLOSE      = $00040000;
  DIF_CENTERTEXT      = $00040000;
  DIF_EDITEXPAND      = $00080000;
  DIF_DROPDOWNLIST    = $00100000;
  DIF_USELASTHISTORY  = $00200000;
  DIF_MASKEDIT        = $00400000;
  DIF_SELECTONENTRY   = $00800000;
  DIF_3STATE          = $00800000;
  DIF_LISTWRAPMODE    = $01000000;
  DIF_LISTAUTOHIGHLIGHT=$02000000;
  DIF_HIDDEN          = $10000000;
  DIF_READONLY        = $20000000;
  DIF_NOFOCUS         = $40000000;
  DIF_DISABLE         = $80000000;

const
  DM_FIRST             = 00;
  DM_CLOSE             = DM_FIRST + 01;
  DM_ENABLE            = DM_FIRST + 02;
  DM_ENABLEREDRAW      = DM_FIRST + 03;
  DM_GETDLGDATA        = DM_FIRST + 04;
  DM_GETDLGITEM        = DM_FIRST + 05;
  DM_GETDLGRECT        = DM_FIRST + 06;
  DM_GETTEXT           = DM_FIRST + 07;
  DM_GETTEXTLENGTH     = DM_FIRST + 08;
  DM_KEY               = DM_FIRST + 09;
  DM_MOVEDIALOG        = DM_FIRST + 10;
  DM_SETDLGDATA        = DM_FIRST + 11;
  DM_SETDLGITEM        = DM_FIRST + 12;
  DM_SETFOCUS          = DM_FIRST + 13;
  DM_REDRAW            = DM_FIRST + 14;
  DM_SETREDRAW         = DM_REDRAW;
  DM_SETTEXT           = DM_FIRST + 15;
  DM_SETMAXTEXTLENGTH  = DM_FIRST + 16;
  DM_SETTEXTLENGTH     = DM_SETMAXTEXTLENGTH;
  DM_SHOWDIALOG        = DM_FIRST + 17;
  DM_GETFOCUS          = DM_FIRST + 18;
  DM_GETCURSORPOS      = DM_FIRST + 19;
  DM_SETCURSORPOS      = DM_FIRST + 20;
  DM_GETTEXTPTR        = DM_FIRST + 21;
  DM_SETTEXTPTR        = DM_FIRST + 22;
  DM_SHOWITEM          = DM_FIRST + 23;
  DM_ADDHISTORY        = DM_FIRST + 24;

  DM_GETCHECK          = DM_FIRST + 25;
  DM_SETCHECK          = DM_FIRST + 26;
  DM_SET3STATE         = DM_FIRST + 27;

  DM_LISTSORT          = DM_FIRST + 28;
  DM_LISTGETITEM       = DM_FIRST + 29;
  DM_LISTGETCURPOS     = DM_FIRST + 30;
  DM_LISTSETCURPOS     = DM_FIRST + 31;
  DM_LISTDELETE        = DM_FIRST + 32;
  DM_LISTADD           = DM_FIRST + 33;
  DM_LISTADDSTR        = DM_FIRST + 34;
  DM_LISTUPDATE        = DM_FIRST + 35;
  DM_LISTINSERT        = DM_FIRST + 36;
  DM_LISTFINDSTRING    = DM_FIRST + 37;
  DM_LISTINFO          = DM_FIRST + 38;
  DM_LISTGETDATA       = DM_FIRST + 39;
  DM_LISTSETDATA       = DM_FIRST + 40;
  DM_LISTSETTITLES     = DM_FIRST + 41;
  DM_LISTGETTITLES     = DM_FIRST + 42;

  DM_RESIZEDIALOG      = DM_FIRST + 43;
  DM_SETITEMPOSITION   = DM_FIRST + 44;

  DM_GETDROPDOWNOPENED = DM_FIRST + 45;
  DM_SETDROPDOWNOPENED = DM_FIRST + 46;

  DM_SETHISTORY        = DM_FIRST + 47;

  DM_GETITEMPOSITION   = DM_FIRST + 48;
  DM_SETMOUSEEVENTNOTIFY=DM_FIRST + 49;

  DM_EDITUNCHANGEDFLAG = DM_FIRST + 50;

  DM_GETITEMDATA       = DM_FIRST + 51;
  DM_SETITEMDATA       = DM_FIRST + 52;

  DM_LISTSET           = DM_FIRST + 53;
  DM_LISTSETMOUSEREACTION=DM_FIRST+ 54;

  DM_GETCURSORSIZE     = DM_FIRST + 55;
  DM_SETCURSORSIZE     = DM_FIRST + 56;
  DM_LISTGETDATASIZE   = DM_FIRST + 57;

  DN_FIRST             = $1000;
  DN_BTNCLICK          = DN_FIRST + 01;
  DN_CTLCOLORDIALOG    = DN_FIRST + 02;
  DN_CTLCOLORDLGITEM   = DN_FIRST + 03;
  DN_CTLCOLORDLGLIST   = DN_FIRST + 04;
  DN_DRAWDIALOG        = DN_FIRST + 05;
  DN_DRAWDLGITEM       = DN_FIRST + 06;
  DN_EDITCHANGE        = DN_FIRST + 07;
  DN_ENTERIDLE         = DN_FIRST + 08;
  DN_GOTFOCUS          = DN_FIRST + 09;
  DN_HELP              = DN_FIRST + 10;
  DN_HOTKEY            = DN_FIRST + 11;
  DN_INITDIALOG        = DN_FIRST + 12;
  DN_KILLFOCUS         = DN_FIRST + 13;
  DN_LISTCHANGE        = DN_FIRST + 14;
  DN_MOUSECLICK        = DN_FIRST + 15;
  DN_DRAGGED           = DN_FIRST + 16;
  DN_RESIZECONSOLE     = DN_FIRST + 17;
  DN_MOUSEEVENT        = DN_FIRST + 18;

  DN_CLOSE             = DM_CLOSE;
  DN_KEY               = DM_KEY;

  DM_USER              = $4000;


const
// FarControl commands
  FCTL_CLOSEPLUGIN         = 00;
  FCTL_GETPANELINFO        = 01;
  FCTL_GETANOTHERPANELINFO = 02;
  FCTL_UPDATEPANEL         = 03;
  FCTL_UPDATEANOTHERPANEL  = 04;
  FCTL_REDRAWPANEL         = 05;
  FCTL_REDRAWANOTHERPANEL  = 06;
  FCTL_SETANOTHERPANELDIR  = 07;
  FCTL_GETCMDLINE          = 08;
  FCTL_SETCMDLINE          = 09;
  FCTL_SETSELECTION        = 10;
  FCTL_SETANOTHERSELECTION = 11;
  FCTL_SETVIEWMODE         = 12;
  FCTL_SETANOTHERVIEWMODE  = 13;
  FCTL_INSERTCMDLINE       = 14;
  FCTL_SETUSERSCREEN       = 15;
  FCTL_SETPANELDIR         = 16;
  FCTL_SETCMDLINEPOS       = 17;
  FCTL_GETCMDLINEPOS       = 18;
  FCTL_SETSORTMODE         = 19;
  FCTL_SETANOTHERSORTMODE  = 20;
  FCTL_SETSORTORDER        = 21;
  FCTL_SETANOTHERSORTORDER = 22;
  FCTL_GETCMDLINESELECTEDTEXT = 23;
  FCTL_SETCMDLINESELECTION = 24;
  FCTL_GETCMDLINESELECTION = 25;
  FCTL_GETPANELSHORTINFO   = 26;
  FCTL_GETANOTHERPANELSHORTINFO = 27;
  FCTL_CHECKPANELSEXIST    = 28;

  KSFLAGS_DISABLEOUTPUT    = $00000001;

type

  TCmdLineSelect = packed record
    SelStart: integer;
    SelEnd: integer;
  end;
  PCmdLineSelect = ^TCmdLineSelect;

  TKeySequence = packed record
    Flags: DWORD;
    Count: integer;
    Sequence: PDWORD;
  end;

const

  FCLR_REDRAW   = $00000001;

type

  TFarSetColors = packed record
    Flags: DWORD;
    StartIndex: integer;
    ColorItem: integer;
    Colors: PChar;
  end;
  PFarSetColors = ^TFarSetColors;

const
// FarAdvancedControl commands
  ACTL_GETFARVERSION    = 00;
  ACTL_CONSOLEMODE      = 01; // Переключить/получить текущий режим (окно/экран)
  ACTL_GETSYSWORDDIV    = 02; // получить строку с символами разделителями слов
  ACTL_WAITKEY          = 03; // ожидать клавишу
  ACTL_GETCOLOR         = 04; // получить определенный цвет
  ACTL_GETARRAYCOLOR    = 05; // получить весь массив цветов
  ACTL_EJECTMEDIA       = 06;
  ACTL_KEYMACRO         = 07;
  ACTL_POSTSEQUENCEKEY  = 08;
  ACTL_GETWINDOWINFO    = 09;
  ACTL_GETWINDOWCOUNT   = 10;
  ACTL_SETCURRENTWINDOW = 11;
  ACTL_COMMIT           = 12;
  ACTL_GETFARHWND       = 13;
  ACTL_GETSYSTEMSETTINGS= 14;
  ACTL_GETPANELSETTINGS = 15;
  ACTL_GETINTERFACESETTINGS= 16;
  ACTL_GETCONFIRMATIONS = 17;
  ACTL_GETDESCSETTINGS  = 18;
  ACTL_SETARRAYCOLOR    = 19;

// ACTL_GETSYSTEMSETTINGS
  FSS_CLEARROATTRIBUTE          = $00000001;
  FSS_DELETETORECYCLEBIN        = $00000002;
  FSS_USESYSTEMCOPYROUTINE      = $00000004;
  FSS_COPYFILESOPENEDFORWRITING = $00000008;
  FSS_CREATEFOLDERSINUPPERCASE  = $00000010;
  FSS_SAVECOMMANDSHISTORY       = $00000020;
  FSS_SAVEFOLDERSHISTORY        = $00000040;
  FSS_SAVEVIEWANDEDITHISTORY    = $00000080;
  FSS_USEWINDOWSREGISTEREDTYPES = $00000100;
  FSS_AUTOSAVESETUP             = $00000200;

// ACTL_GETPANELSETTINGS
  FPS_SHOWHIDDENANDSYSTEMFILES    = $00000001;
  FPS_HIGHLIGHTFILES              = $00000002;
  FPS_AUTOCHANGEFOLDER            = $00000004;
  FPS_SELECTFOLDERS               = $00000008;
  FPS_ALLOWREVERSESORTMODES       = $00000010;
  FPS_SHOWCOLUMNTITLES            = $00000020;
  FPS_SHOWSTATUSLINE              = $00000040;
  FPS_SHOWFILESTOTALINFORMATION   = $00000080;
  FPS_SHOWFREESIZE                = $00000100;
  FPS_SHOWSCROLLBAR               = $00000200;
  FPS_SHOWBACKGROUNDSCREENSNUMBER = $00000400;
  FPS_SHOWSORTMODELETTER          = $00000800;

// ACTL_GETINTERFACESETTINGS
  FIS_CLOCKINPANELS                  = $00000001;
  FIS_CLOCKINVIEWERANDEDITOR         = $00000002;
  FIS_MOUSE                          = $00000004;
  FIS_SHOWKEYBAR                     = $00000008;
  FIS_ALWAYSSHOWMENUBAR              = $00000010;
  FIS_HISTORYINDIALOGEDITCONTROLS    = $00000020;
  FIS_PERSISTENTBLOCKSINEDITCONTROLS = $00000040;
  FIS_USERIGHTALTASALTGR             = $00000080;
  FIS_SHOWTOTALCOPYPROGRESSINDICATOR = $00000100;
  FIS_SHOWCOPYINGTIMEINFO            = $00000200;
  FIS_AUTOCOMPLETEININPUTLINES       = $00000400;
  FIS_USECTRLPGUPTOCHANGEDRIVE       = $00000800;

// ACTL_GETCONFIRMATIONS
  FCS_COPYOVERWRITE          = $00000001;
  FCS_MOVEOVERWRITE          = $00000002;
  FCS_DRAGANDDROP            = $00000004;
  FCS_DELETE                 = $00000008;
  FCS_DELETENONEMPTYFOLDERS  = $00000010;
  FCS_INTERRUPTOPERATION     = $00000020;
  FCS_DISCONNECTNETWORKDRIVE = $00000040;
  FCS_RELOADEDITEDFILE       = $00000080;
  FCS_CLEARHISTORYLIST       = $00000100;
  FCS_EXIT                   = $00000200;

//  ACTL_GETDESCSETTINGS
  FDS_UPDATEALWAYS           = $00000001;
  FDS_UPDATEIFDISPLAYED      = $00000002;
  FDS_SETHIDDEN              = $00000004;
  FDS_UPDATEREADONLY         = $00000008;

// константы для ACTL_*WINDOW*
  WTYPE_PANELS          = 1;
  WTYPE_VIEWER          = 2;
  WTYPE_EDITOR          = 3;
  WTYPE_DIALOG          = 4;
  WTYPE_VMENU           = 5;
  WTYPE_HELP            = 6;

// константы для ACTL_CONSOLEMODE
  FAR_CONSOLE_GET_MODE       = -2;
  FAR_CONSOLE_TRIGGER        = -1;
  FAR_CONSOLE_SET_WINDOWED   = 00;
  FAR_CONSOLE_SET_FULLSCREEN = 01;
  FAR_CONSOLE_WINDOWED       = 00;
  FAR_CONSOLE_FULLSCREEN     = 01;

// константы для ACTL_EJECTMEDIA
  EJECT_NO_MESSAGE = $00000001;
  EJECT_LOAD_MEDIA = $00000002;

type

  TACtlEjectMedia = packed record
    Letter: DWORD;
    Flags: DWORD;
  end;
  PACtlEjectMedia = ^TACtlEjectMedia;

  TACtlKeyMacro = packed record
    Command: integer;
    Reserved: array[0..2] of DWORD;
  end;
  PACtlKeyMacro = ^TACtlKeyMacro;

  TWindowInfo = packed record
    Pos: integer;
    WndType: integer;
    Modified: BOOL;
    Current: BOOL;
    TypeName: packed array[0..63] of char;
    Name: packed array[0..Pred(NM)] of char;
  end;
  PWindowInfo = ^TWindowInfo;

const

  MCMD_LOADALL = 00;
  MCMD_SAVEALL = 01;

// Panel types
  PTYPE_FILEPANEL    = 00;
  PTYPE_TREEPANEL    = 01;
  PTYPE_QVIEWPANEL   = 02;
  PTYPE_INFOPANEL    = 03;

// Panel flags
  PFLAGS_SHOWHIDDEN           = $00000001;
  PFLAGS_HIGHLIGHT            = $00000002;
  PFLAGS_REVERSESORTORDER     = $00000004;
  PFLAGS_USESORTGROUPS        = $00000008;
  PFLAGS_SELECTEDFIRST        = $00000010;
  PFLAGS_REALNAMES            = $00000020;

type

  TPanelInfo = packed record
    PanelType: integer;
    Plugin: integer;
    PanelRect: TRect;
    PanelItems: PPluginPanelItemArr;
    ItemsNumber: integer;
    SelectedItems: PPluginPanelItemArr;
    SelectedItemsNumber: integer;
    CurrentItem: integer;
    TopPanelItem: integer;
    Visible: BOOL;
    Focus: BOOL;
    ViewMode: integer;
    ColumnTypes: packed array[0..79] of char;
    ColumnWidths: packed array[0..79] of char;
    CurDir: packed array[0..Pred(NM)] of char;
    ShortNames: integer;
    SortMode: integer;
    Flags: DWORD;
    Reserved: DWORD;
  end; { TPanelInfo record }
  PPanelInfo = ^TPanelInfo;

  TPanelRedrawInfo = packed record
    CurrentItem: integer;
    TopPanelItem: integer;
  end; { TPanelRedrawInfo record }
  PPanelRedrawInfo = ^TPanelRedrawInfo;

type

  TFarApiControl = function(
    hPlugin: THandle;
    Command: integer;
    Param: pointer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarApiSaveScreen = function(
    X1, Y1: integer;
    X2, Y2: integer): THandle; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarApiRestoreScreen = procedure(
    hScreen: THandle); {$IFNDEF VP} stdcall; {$ENDIF}

  TFarApiGetDirList = function(
    const Dir: PChar;
    var PanelItems: PPluginPanelItemArr;
    var ItemsNumber: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarApiGetPluginDirList = function(
    PluginNumber: integer;
    hPlugin: THandle;
    const Dir: PChar;
    var PanelItems: PPluginPanelItemArr;
    var ItemsNumber: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarApiFreeDirList = procedure(
    const PanelItems: PPluginPanelItemArr); {$IFNDEF VP} stdcall; {$ENDIF}

const
// Viewer flags
  VF_NONMODAL        = $00000001;
  VF_DELETEONCLOSE   = $00000002;
  VF_ENABLE_F6       = $00000004;
  VF_DISABLEHISTORY  = $00000008;
  VF_IMMEDIATERETURN = $00000100;
  VF_DELETEONLYFILEONCLOSE = $00000200;

// Editor flags
  EF_NONMODAL        = $00000001;
  EF_CREATENEW       = $00000002;
  EF_ENABLE_F6       = $00000004;
  EF_DISABLEHISTORY  = $00000008;
  EF_DELETEONCLOSE   = $00000010;
  EF_IMMEDIATERETURN = $00000100;
  EF_DELETEONLYFILEONCLOSE = $00000200;

// enum EDITOR_EXITCODE
  EEC_OPEN_ERROR          = 0;
  EEC_MODIFIED            = 1;
  EEC_NOT_MODIFIED        = 2;
  EEC_LOADING_INTERRUPTED = 3;

type

  TFarApiViewer = function(
    const FileName: PChar;
    const Title: PChar;
    X1, Y1: integer;
    X2, Y2: integer;
    Flags: DWORD): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarApiEditor = function(
    const FileName: PChar;
    const Title: PChar;
    X1, Y1: integer;
    X2, Y2: integer;
    Flags: DWORD;
    StartLine: integer;
    StartChar: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarApiCmpName = function(
    const Pattern: PChar;
    const FileName: PChar;
    SkipPath: BOOL): integer; {$IFNDEF VP} stdcall; {$ENDIF}

const

  FCT_DETECT = $40000000;

type

  TCharTableSet = packed record
    DecodeTable: packed array[0..255] of char;
    EncodeTable: packed array[0..255] of char;
    UpperTable: packed array[0..255] of char;
    LowerTable: packed array[0..255] of char;
    TableName: packed array[0..127] of char;
  end; { TCharTableSet record }
  PCharTableSet = ^TCharTableSet;

type

  TFarApiCharTable = function(
    Command: integer;
    Buffer: PChar;
    BufferSize: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarApiText = procedure(
    X, Y: integer;
    Color: integer;
    const Str: PChar); {$IFNDEF VP} stdcall; {$ENDIF}

  TFarApiEditorControl = function(
    Command: integer;
    Param: pointer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

const
//  Флаги FHELP_* для функции ShowHelp
  FHELP_NOSHOWERROR= $80000000;
  FHELP_SELFHELP   = $00000000;
  FHELP_FARHELP    = $00000001;
  FHELP_CUSTOMFILE = $00000002;
  FHELP_CUSTOMPATH = $00000004;
  FHELP_USECONTENTS =$40000000;

type

// Функция вывода помощи
  TFarApiShowHelp = function(
    const ModuleName: PChar;
    const HelpTopic: PChar;
    Flags: DWORD): BOOL; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarApiAdvControl = function(
    ModuleNumber: integer;
    Command: integer;
    Param: pointer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

const


  EE_READ   = 00;
  EE_SAVE   = 01;
  EE_REDRAW = 02;
  EE_CLOSE  = 03;

  _EEREDRAW_ALL    : DWORD = 0;
  _EEREDRAW_CHANGE : DWORD = 1;
  _EEREDRAW_LINE   : DWORD = 2;

  EEREDRAW_ALL    : pointer = @_EEREDRAW_ALL;
  EEREDRAW_CHANGE : pointer = @_EEREDRAW_CHANGE;
  EEREDRAW_LINE   : pointer = @_EEREDRAW_LINE;

const

// EditorControl commands
  ECTL_GETSTRING    = 00;
  ECTL_SETSTRING    = 01;
  ECTL_INSERTSTRING = 02;
  ECTL_DELETESTRING = 03;
  ECTL_DELETECHAR   = 04;
  ECTL_INSERTTEXT   = 05;
  ECTL_GETINFO      = 06;
  ECTL_SETPOSITION  = 07;
  ECTL_SELECT       = 08;
  ECTL_REDRAW       = 09;
  ECTL_EDITORTOOEM  = 10;
  ECTL_OEMTOEDITOR  = 11;
  ECTL_TABTOREAL    = 12;
  ECTL_REALTOTAB    = 13;
  ECTL_EXPANDTABS   = 14;
  ECTL_SETTITLE     = 15;
  ECTL_READINPUT    = 16;
  ECTL_PROCESSINPUT = 17;
  ECTL_ADDCOLOR     = 18;
  ECTL_GETCOLOR     = 19;
  ECTL_SAVEFILE     = 20;
  ECTL_QUIT         = 21;
  ECTL_SETKEYBAR    = 22;
  ECTL_PROCESSKEY   = 23;
  ECTL_SETPARAM     = 24;
  ECTL_GETBOOKMARKS = 25;
  ECTL_TURNOFFMARKINGBLOCK = 26;
  ECTL_DELETEBLOCK  = 27;

// EditorSetParameter types
  ESPT_TABSIZE         = 00;
  ESPT_EXPANDTABS      = 01;
  ESPT_AUTOINDENT      = 02;
  ESPT_CURSORBEYONDEOL = 03;
  ESPT_CHARCODEBASE    = 04;
  ESPT_CHARTABLE       = 05;
  ESPT_SAVEFILEPOSITION= 06;
  ESPT_LOCKMODE        = 07;


type

  TEditorSetParameter = packed record
    ParamType: integer;
    Param: record case integer of
      0: (iParam: integer);
      1: (cParam: PChar);
      2: (Reserved1: DWORD);
    end;
    Flags: DWORD;
    Reserved2: DWORD;
  end;
  PEditorSetParameter = ^TEditorSetParameter;

  TEditorGetString = packed record
    StringNumber: integer;
    StringText: PChar;
    StringEOL: PChar;
    StringLength: integer;
    SelStart: integer;
    SelEnd: integer;
  end; { TEditorGetString record }
  PEditorGetString = ^TEditorGetString;

  TEditorSetString = packed record
    StringNumber: integer;
    StringText: PChar;
    StringEOL: PChar;
    StringLength: integer;
  end; { TEditorSetString record }
  PEditorSetString = ^TEditorSetString;


const

  EOPT_EXPANDTABS       = 01;
  EOPT_PERSISTENTBLOCKS = 02;
  EOPT_DELREMOVESBLOCKS = 04;
  EOPT_AUTOINDENT       = 08;
  EOPT_SAVEFILEPOSITION = 16;
  EOPT_AUTODETECTTABLE  = 32;
  EOPT_CURSORBEYONDEOL  = 64;

const

  BTYPE_NONE   = 00;
  BTYPE_STREAM = 01;
  BTYPE_COLUMN = 02;

  ECSTATE_MODIFIED = 01;
  ECSTATE_SAVED    = 02;
  ECSTATE_LOCKED   = 04;

type

  TEditorInfo = packed record
    EditorID: integer;
    FileName: PChar;
    WindowSizeX: integer;
    WindowSizeY: integer;
    TotalLines: integer;
    CurLine: integer;
    CurPos: integer;
    CurTabPos: integer;
    TopScreenLine: integer;
    LeftPos: integer;
    Overtype: integer;
    BlockType: integer;
    BlockStartLine: integer;
    AnsiMode: BOOL;
    TableNum: integer;
    Options: DWORD;
    TabSize: integer;
    BookmarkCount: integer;
    CurState: DWORD;
    Reserved: packed array[0..5] of DWORD;
  end; { TEditorInfo record }
  PEditorInfo = ^TEditorInfo;

  TEditorBookmarks = packed record
    Line: PIntArr;
    Cursor: PIntArr;
    ScreenLine: PIntArr;
    LeftPos: PIntArr;
    Reserved: packed array[0..3] of DWORD;
  end;
  PEditorBookmarks = ^TEditorBookmarks;

  TEditorSetPosition = packed record
    CurLine: integer;
    CurPos: integer;
    CurTabPos: integer;
    TopScreenLine: integer;
    LeftPos: integer;
    Overtype: integer;
  end; { TEditorSetPosition record }
  PEditorSetPosition = ^TEditorSetPosition;

  TEditorSelect = packed record
    BlockType: integer;
    BlockStartLine: integer;
    BlockStartPos: integer;
    BlockWidth: integer;
    BlockHeight: integer;
  end; { TEditorSelect record }
  PEditorSelect = ^TEditorSelect;

  TEditorConvertText = packed record
    Text: PChar;
    TextLength: integer;
  end; { TEditorConvertText record }
  PEditorConvertText = ^TEditorConvertText;

  TEditorConvertPos = packed record
    StringNumber: integer;
    SrcPos: integer;
    DestPos: integer;
  end; { TEditorConvertPos }
  PEditorConvertPos = ^TEditorConvertPos;

  TEditorColor = packed record
    StringNumber: integer;
    ColorItem: integer;
    StartPos: integer;
    EndPos: integer;
    Color: integer;
  end; { TEditorColor record }
  PEditorColor = ^TEditorColor;

  TEditorSaveFile = packed record
    FileName: packed array[0..Pred(NM)] of char;
    FileEOL: PChar;
  end; { TEditorSaveFile record }
  PEditorSaveFile = ^TEditorSaveFile;

type

  TFarStdMkLink = function(
    const Src: PChar;
    const Dest: PChar;
    Flags: DWORD): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdConvertNameToReal = function(
    const Src: PChar;
    Dest: PChar;
    DestSize: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdGetReparsePointInfo = function(
    const Src: PChar;
    Dest: PChar;
    DestSize: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

//  Убирает ВСЕ начальные и заключительные кавычки
  TFarStdUnquote = procedure(
    Str: PChar); {$IFNDEF VP} stdcall; {$ENDIF}

//  Расширение строки с учетом переменных окружения
  TFarStdExpandEnvironmentStr = function(
    Src: PChar;
    Dst: PChar;
    Size: DWORD): DWORD; {$IFNDEF VP} stdcall; {$ENDIF}

const
// Флаги для InputBox
  FIB_ENABLEEMPTY      = $00000001;
  FIB_PASSWORD         = $00000002;
  FIB_EXPANDENV        = $00000004;
// если не нужно пред значение - ставим этот флаг
  FIB_NOUSELASTHISTORY = $00000008;
//  Если нужно - показываем кнопки <Ok> & <Cancel>
  FIB_BUTTONS          = $00000010;
  FIB_NOAMPERSAND      = $00000020;

type
// Функция ввода строки
  TFarApiInputBox = function(
    const Title: PChar;
    const SubTitle: PChar;
    const HistoryName: PChar;
    const SrcText: PChar;
    DstText: PChar;
    DstLength: integer;
    const HelpTopic: PChar;
    Flags: DWORD): integer; {$IFNDEF VP} stdcall; {$ENDIF}

// typedef int   (WINAPIV *FARSTDSPRINTF)(char *buffer,const char *format,...);
// typedef int   (WINAPIV *FARSTDSSCANF)(const char *s, const char *format,...);

{&Cdecl+}
  TFarStdQSortFunc = function(
    Param1: pointer;
    Param2: pointer): integer; {$IFNDEF VP} cdecl; {$ENDIF}

{&StdCall+}
  TFarStdQSort = procedure(
    Base: pointer;
    NElem: size_t;
    Width: size_t;
    fcmp: TFarStdQSortFunc); {$IFNDEF VP} stdcall; {$ENDIF}

{&Cdecl+}
  TFarStdQSortExFunc = function(
    Param1: pointer;
    Param2: pointer;
    UserParam: pointer): integer; {$IFNDEF VP} cdecl; {$ENDIF}

{&StdCall+}
  TFarStdQSortEx = procedure(
    Base: pointer;
    NElem: size_t;
    Width: size_t;
    fcmp: TFarStdQSortExFunc;
    UserParam: pointer); {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdBSearch = procedure(
    Key: pointer;
    Base: pointer;
    NElem: size_t;
    Width: size_t;
    fcmp: TFarStdQSortFunc); {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdGetFileOwner = function(
    Computer: PChar;
    Name: PChar;
    Owner: PChar): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdGetNumberOfLinks = function(
    Name: PChar): integer; {$IFNDEF VP} stdcall; {$ENDIF}

type

  TFarStdatoi = function(
    S: PChar): integer; {$IFNDEF VP} stdcall; {$ENDIF}

{$IFDEF USE_DELPHI4}
  TFarStdAToI64 = function(
    S: PChar): int64; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdIToA64 = function(
    Value: int64;
    Str: PChar;
    Radix: integer): PChar; {$IFNDEF VP} stdcall; {$ENDIF}
{$ELSE}
  INPUT_RECORD = record
    EventType: system.Word;
    Reserved: system.Word;
    Event: record case Integer of
      0: (KeyEvent: TKeyEventRecord);
      1: (MouseEvent: TMouseEventRecord);
      2: (WindowBufferSizeEvent: TWindowBufferSizeRecord);
      3: (MenuEvent: TMenuEventRecord);
      4: (FocusEvent: TFocusEventRecord);
    end;
  end;
  TInputRecord = INPUT_RECORD;
{$ENDIF}

  TFarStdIToA = function(
    Value: integer;
    Str: PChar;
    Radix: integer): PChar; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdLTrim = function(
    Str: PChar): PChar; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdRTrim = function(
    Str: PChar): PChar; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdTrim = function(
    Str: PChar): PChar; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdTruncStr = function(
    Str: PChar;
    MaxLength: integer): PChar; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdTruncPathStr = function(
    Str: PChar;
    MaxLength: integer): PChar; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdQuoteSpaceOnly = function(
    Str: PChar): PChar; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdPointToName = function(
    const Path: PChar): PChar; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdGetPathRoot = procedure(
    const Path: PChar;
    Root: PChar); {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdAddEndSlash = function(
    Path: PChar): BOOL; {$IFNDEF VP} stdcall; {$ENDIF}

//   Дополнительные функции
  TFarStdCopyToClipboard = function(
    const Data: PChar): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdPasteFromClipboard = function: PChar; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdKeyToKeyName = function(
    Key: integer;
    KeyName: PChar;
    Size: integer): BOOL; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdKeyNameToKey = function(
    const Name: PChar): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdLocalIsLower = function(
    Ch: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdLocalIsUpper = function(
    Ch: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdLocalIsAlpha = function(
    Ch: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdLocalIsAlphaNum = function(
    Ch: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdLocalUpper = function(
    LowerChar: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdLocalLower = function(
    UpperChar: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdLocalUpperBuf = procedure(
    Buf: PChar;
    Length: integer); {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdLocalLowerBuf = procedure(
    Buf: PChar;
    Length: integer); {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdLocalStrUpr = procedure(
    s1: PChar); {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdLocalStrLwr= procedure(
    s1: PChar); {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdLocalStrICmp = function(
    s1: PChar;
    s2: PChar): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdLocalStrNICmp = function(
    s1: PChar;
    s2: PChar;
    n: integer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdInputRecordToKey = function(
    const R: PInputRecord): integer; {$IFNDEF VP} stdcall; {$ENDIF}

const
  PN_CMPNAME      = $000000;
  PN_CMPNAMELIST  = $001000;
  PN_GENERATENAME = $002000;
  PN_SKIPPATH     = $100000;

type

  TFarStdProcessName = function(
    Param1: PChar;
    Param2: PChar;
    Flags: DWORD): integer; {$IFNDEF VP} stdcall; {$ENDIF}

const

  XLAT_SWITCHKEYBLAYOUT = $00000001; // переключить раскладку клавиатуры
                                     // после преобразования XLAT
  XLAT_SWITCHKEYBBEEP   = $00000002;

type

  TFarStdXLAT = function(
    Line: PChar;
    StartPos: integer;
    EndPos: integer;
    const TableSet: PCharTableSet;
    Flags: DWORD): PChar; {$IFNDEF VP} stdcall; {$ENDIF}


  TFRSFunction = function(
    var FindData: TWin32FindDataEx;
    const FullName: PChar;
    Param: pointer): integer; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarRecursiveSearch = procedure(
    const InitDir: PChar;
    const Mask: PChar;
    Func: TFRSFunction;
    Flags: DWORD;
    Param: pointer); {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdMkTemp = function(
    Dest: PChar;
    Prefix: PChar): PChar; {$IFNDEF VP} stdcall; {$ENDIF}

  TFarStdDeleteBuffer = procedure(
    Buffer: PChar); {$IFNDEF VP} stdcall; {$ENDIF}

const
  FRS_SETUPDIR = $0001;
  FRS_RECUR    = $0002;

type

  TFarStandardFunctions = packed record
    StructSize: integer;

    atoi: TFarStdAToI;
{$IFDEF USE_DELPHI4}
    atoi64: TFarStdAToI64;
{$ELSE}
    atoi64: pointer;
{$ENDIF}

    itoa: TFarStdIToA;
{$IFDEF USE_DELPHI4}
    itoa64: TFarStdIToA64;
{$ELSE}
    itoa64: pointer;
{$ENDIF}

    sprintf: pointer;
    sscanf:  pointer;

    qsort: TFarStdQSort;
    bsearch: TFarStdBSearch;
    qsortex: TFarStdQSortEx;

    Reserved: packed array[0..8] of DWORD;

    LIsLower:    TFarStdLocalIsLower;
    LIsUpper:    TFarStdLocalIsUpper;
    LIsAlpha:    TFarStdLocalIsAlpha;
    LIsAlphanum: TFarStdLocalIsAlphaNum;
    LUpper:      TFarStdLocalUpper;
    LLower:      TFarStdLocalLower;
    LUpperBuf:   TFarStdLocalUpperBuf;
    LLowerBuf:   TFarStdLocalLowerBuf;
    LStrUpr:     TFarStdLocalStrUpr;
    LStrLwr:     TFarStdLocalStrLwr;
    LStrICmp:    TFarStdLocalStrICmp;
    LStrNICmp:   TFarStdLocalStrNICmp;

    Unquote: TFarStdUnquote;
    ExpandEnvironmentStr: TFarStdExpandEnvironmentStr;
    LTrim: TFarStdLTrim;
    RTrim: TFarStdRTrim;
    Trim: TFarStdTrim;
    TruncStr: TFarStdTruncStr;
    TruncPathStr: TFarStdTruncPathStr;
    QuoteSpaceOnly: TFarStdQuoteSpaceOnly;
    PointToName: TFarStdPointToName;
    GetPathRoot: TFarStdGetPathRoot;
    AddEndSlash: TFarStdAddEndSlash;
    CopyToClipboard: TFarStdCopyToClipboard;
    PasteFromClipboard: TFarStdPasteFromClipboard;
    FarKeyToName: TFarStdKeyToKeyName;
    FarNameToKey: TFarStdKeyNameToKey;
    FarInputRecordToKey: TFarStdInputRecordToKey;
    XLAT: TFarStdXLAT;
    GetFileOwner: TFarStdGetFileOwner;
    GetNumberOfLinks: TFarStdGetNumberOfLinks;
    FarRecurseSearch: TFarRecursiveSearch;
    MkTemp: TFarStdMkTemp;
    DeleteBuffer: TFarStdDeleteBuffer;
    ProcessName: TFarStdProcessName;
    MkLink: TFarStdMkLink;
    ConvertNameToReal: TFarStdConvertNameToReal;
    GetReparsePointInfo: TFarStdGetReparsePointInfo;
  end; { TFarStandardFunctions record }
  PFarStandardFunctions = ^TFarStandardFunctions;

type

  TPluginStartupInfo = packed record
    StructSize: integer;
    ModuleName: packed array[0..Pred(NM)] of char;
    ModuleNumber: integer;
    RootKey: PChar;
    Menu: TFarApiMenu;
    Dialog: TFarApiDialog;
    Message: TFarApiMessage;
    GetMsg: TFarApiGetMsg;
    Control: TFarApiControl;
    SaveScreen: TFarApiSaveScreen;
    RestoreScreen: TFarApiRestoreScreen;
    GetDirList: TFarApiGetDirList;
    GetPluginDirList: TFarApiGetPluginDirList;
    FreeDirList: TFarApiFreeDirList;
    Viewer: TFarApiViewer;
    Editor: TFarApiEditor;
    CmpName: TFarApiCmpName;
    CharTable: TFarApiCharTable;
    Text: TFarApiText;
    EditorControl: TFarApiEditorControl;
//  Указатель на структуру с адресами полезных функций из far.exe
    FSF: PFarStandardFunctions;
//  Функция вывода помощи
    ShowHelp: TFarApiShowHelp;
//  Функция, которая будет действовать и в редакторе, и в панелях, и...
    AdvControl: TFarApiAdvControl;
//  Функции для обработчика диалога
    InputBox: TFarApiInputBox;
    DialogEx: TFarApiDialogEx;
    SendDlgMessage: TFarApiSendDlgMessage;
    DefDlgProc: TFarApiDefDlgProc;
    Reserved: array[0..1] of DWORD;
  end; { TPluginStartupInfo record }
  PPluginStartupInfo = ^TPluginStartupInfo;

const

  PF_PRELOAD        = $0001;
  PF_DISABLEPANELS  = $0002;
  PF_EDITOR         = $0004;
  PF_VIEWER         = $0008;
// флаг для передачи плагину всей строки вместе с префиксом
  PF_FULLCMDLINE    = $0010;

type

  TPluginInfo = packed record
    StructSize: integer;
    Flags: DWORD;
    DiskMenuStrings: PPCharArr;
    DiskMenuNumbers: PIntArr;
    DiskMenuStringsNumber: integer;
    PluginMenuStrings: PPCharArr;
    PluginMenuStringsNumber: integer;
    PluginConfigStrings: PPCharArr;
    PluginConfigStringsNumber: integer;
    CommandPrefix: PChar;
    Reserved: DWORD;
  end; {TPluginInfo record }
  PPluginInfo = ^TPluginInfo;

  TInfoPanelLine = packed record
    Text: packed array[0..79] of char;
    Data: packed array[0..79] of char;
    Separator: integer;
  end; { TInfoPanelLine record }
  PInfoPanelLine = ^TInfoPanelLine;
  TInfoPanelLineArr = packed array[0..Pred(MaxInt div sizeof(TInfoPanelLine))] of TInfoPanelLine;
  PInfoPanelLineArr = ^TInfoPanelLineArr;

  TPanelMode = packed record
    ColumnTypes: PChar;
    ColumnWidths: PChar;
    ColumnTitles: PPCharArr;
    FullScreen: BOOL;
    DetailedStatus: BOOL;
    AlignExtensions: BOOL;
    CaseConversion: BOOL;
    StatusColumnTypes: PChar;
    StatusColumnWidths: PChar;
    Reserved: packed array[0..1] of DWORD;
  end; { TPanelMode record }
  PPanelMode = ^TPanelMode;
  TPanelModeArr = packed array[0..Pred(MaxInt div sizeof(TPanelMode))] of TPanelMode;
  PPanelModeArr = ^TPanelModeArr;

const

  OPIF_USEFILTER               = $0001;
  OPIF_USESORTGROUPS           = $0002;
  OPIF_USEHIGHLIGHTING         = $0004;
  OPIF_ADDDOTS                 = $0008;
  OPIF_RAWSELECTION            = $0010;
  OPIF_REALNAMES               = $0020;
  OPIF_SHOWNAMESONLY           = $0040;
  OPIF_SHOWRIGHTALIGNNAMES     = $0080;
  OPIF_SHOWPRESERVECASE        = $0100;
  OPIF_FINDFOLDERS             = $0200;
  OPIF_COMPAREFATTIME          = $0400;
  OPIF_EXTERNALGET             = $0800;
  OPIF_EXTERNALPUT             = $1000;
  OPIF_EXTERNALDELETE          = $2000;
  OPIF_EXTERNALMKDIR           = $4000;
  OPIF_USEATTRHIGHLIGHTING     = $8000;

const

  SM_DEFAULT        = 00;
  SM_UNSORTED       = 01;
  SM_NAME           = 02;
  SM_EXT            = 03;
  SM_MTIME          = 04;
  SM_CTIME          = 05;
  SM_ATIME          = 06;
  SM_SIZE           = 07;
  SM_DESCR          = 08;
  SM_OWNER          = 09;
  SM_COMPRESSEDSIZE = 10;
  SM_NUMLINKS       = 11;


type

  TKeyBarTitles = packed record
    Titles: packed array[0..11] of PChar;
    CtrlTitles: packed array[0..11] of PChar;
    AltTitles: packed array[0..11] of PChar;
    ShiftTitles: packed array[0..11] of PChar;
// Дополнения
    CtrlShiftTitles: packed array[0..11] of PChar;
    AltShiftTitles: packed array[0..11] of PChar;
    CtrlAltTitles: packed array[0..11] of PChar;
  end; { TKeyBarTitles record }
  PKeyBarTitles = ^TKeyBarTitles;

  TOpenPluginInfo = packed record
    StructSize: integer;
    Flags: DWORD;
    HostFile: PChar;
    CurDir: PChar;
    Format: PChar;
    PanelTitle: PChar;
    InfoLines: PInfoPanelLineArr;
    InfoLinesNumber: integer;
    DescrFiles: PPCharArr;
    DescrFilesNumber: integer;
    PanelModesArray: PPanelModeArr;
    PanelModesNumber: integer;
    StartPanelMode: integer;
    StartSortMode: integer;
    StartSortOrder: integer;
    KeyBar: PKeyBarTitles;
    ShortcutData: PChar;
//     + добавка, для того, чтобы различить FAR <= 1.65 и > 1.65
    Reserved: DWORD;
  end; { TOpenPluginInfo record }
  POpenPluginInfo = ^TOpenPluginInfo;

const

  OPEN_DISKMENU    = 00;
  OPEN_PLUGINSMENU = 01;
  OPEN_FINDLIST    = 02;
  OPEN_SHORTCUT    = 03;
  OPEN_COMMANDLINE = 04;
  OPEN_EDITOR      = 05;
  OPEN_VIEWER      = 06;

const

  PKF_CONTROL = 01;
  PKF_ALT     = 02;
  PKF_SHIFT   = 04;

const

  FE_CHANGEVIEWMODE = 00;
  FE_REDRAW         = 01;
  FE_IDLE           = 02;
  FE_CLOSE          = 03;
  FE_BREAK          = 04;
  FE_COMMAND        = 05;

const

  OPM_SILENT    = $0001;
  OPM_FIND      = $0002;
  OPM_VIEW      = $0004;
  OPM_EDIT      = $0008;
  OPM_TOPLEVEL  = $0010;
  OPM_DESCR     = $0020;
  OPM_QUICKVIEW = $0040;

function Dlg_GetDlgData(Info: TPluginStartupInfo; hDlg: THandle): integer;
function Dlg_SetDlgData(Info: TPluginStartupInfo; hDlg: THandle; Data: pointer): integer;

function DlgItem_GetFocus(Info: TPluginStartupInfo; hDlg: THandle): integer;
function DlgItem_SetFocus(Info: TPluginStartupInfo; hDlg: THandle; ID: integer): integer;

function DlgItem_Enable(Info: TPluginStartupInfo; hDlg: THandle; ID: integer): integer;
function DlgItem_Disable(Info: TPluginStartupInfo; hDlg: THandle; ID: integer): integer;
function DlgItem_IsEnable(Info: TPluginStartupInfo; hDlg: THandle; ID: integer): integer;

function DlgItem_SetText(Info: TPluginStartupInfo; hDlg: THandle; ID: integer; Str: PChar): integer;

function DlgItem_GetCheck(Info: TPluginStartupInfo; hDlg: THandle; ID: integer): integer;
function DlgItem_SetCheck(Info: TPluginStartupInfo; hDlg: THandle; ID: integer; State: integer): integer;

function DlgEdit_AddHistory(Info: TPluginStartupInfo; hDlg: THandle; ID: integer; Str: PChar): integer;

function DlgList_AddString(Info: TPluginStartupInfo; hDlg: THandle; ID: integer; Str: PChar): integer;
function DlgList_GetCurPos(Info: TPluginStartupInfo; hDlg: THandle; ID: integer): integer;
function DlgList_SetCurPos(Info: TPluginStartupInfo; hDlg: THandle; ID: integer; NewPos: integer): integer;
function DlgList_ClearList(Info: TPluginStartupInfo; hDlg: THandle; ID: integer): integer;
function DlgList_DeleteItem(Info: TPluginStartupInfo; hDlg: THandle; ID: integer; Index: integer): integer;
function DlgList_SortUp(Info: TPluginStartupInfo; hDlg: THandle; ID: integer): integer;
function DlgList_SortDown(Info: TPluginStartupInfo; hDlg: THandle; ID: integer): integer;
function DlgList_GetItemData(Info: TPluginStartupInfo; hDlg: THandle; ID: integer; Index: integer): integer;
function DlgList_SetItemStr(Info: TPluginStartupInfo; hDlg: THandle; ID: integer; Index: integer; Str: PChar): integer;

implementation

function Dlg_GetDlgData;
begin
  result:= Info.SendDlgMessage(hDlg, DM_GETDLGDATA, 0, 0);
end;

function Dlg_SetDlgData;
begin
  result:= Info.SendDlgMessage(hDlg, DM_SETDLGDATA, 0, integer(Data));
end;

function DlgItem_GetFocus;
begin
  result:= Info.SendDlgMessage(hDlg, DM_GETFOCUS, 0, 0);
end;

function DlgItem_SetFocus;
begin
  result:= Info.SendDlgMessage(hDlg, DM_SETFOCUS, ID, 0);
end;

function DlgItem_Enable;
begin
  result:= Info.SendDlgMessage(hDlg, DM_ENABLE, ID, 1);
end;

function DlgItem_Disable;
begin
  result:= Info.SendDlgMessage(hDlg, DM_ENABLE, ID, 0);
end;

function DlgItem_IsEnable;
begin
  result:= Info.SendDlgMessage(hDlg, DM_ENABLE, ID, -1);
end;

function DlgItem_SetText;
begin
  result:= Info.SendDlgMessage(hDlg, DM_SETTEXTPTR, ID, integer(Str));
end;

function DlgItem_GetCheck;
begin
  result:= Info.SendDlgMessage(hDlg, DM_GETCHECK, ID, 0);
end;

function DlgItem_SetCheck;
begin
  result:= Info.SendDlgMessage(hDlg, DM_SETCHECK, ID, State);
end;

function DlgEdit_AddHistory;
begin
  result:= Info.SendDlgMessage(hDlg, DM_ADDHISTORY, ID, integer(Str));
end;

function DlgList_AddString;
begin
  result:= Info.SendDlgMessage(hDlg, DM_LISTADDSTR, ID, integer(Str));
end;

function DlgList_GetCurPos;
begin
  result:= Info.SendDlgMessage(hDlg, DM_LISTGETCURPOS, ID, 0);
end;

function DlgList_SetCurPos;
begin
  result:= Info.SendDlgMessage(hDlg, DM_LISTSETCURPOS, ID, NewPos);
end;

function DlgList_ClearList;
begin
  result:= Info.SendDlgMessage(hDlg, DM_LISTDELETE, ID, 0);
end;

function DlgList_DeleteItem;
var
  FLDItem: TFarListDelete;
begin
  FLDItem.StartIndex:= Index;
  FLDItem.Count:= 1;
  result:= Info.SendDlgMessage(hDlg, DM_LISTDELETE, ID, integer(@FLDItem));
end;

function DlgList_SortUp;
begin
  result:= Info.SendDlgMessage(hDlg, DM_LISTSORT, ID, 0);
end;

function DlgList_SortDown;
begin
  result:= Info.SendDlgMessage(hDlg, DM_LISTSORT, ID, 1);
end;

function DlgList_GetItemData(Info: TPluginStartupInfo; hDlg: THandle; ID: integer; Index: integer): integer;
begin
  result:= Info.SendDlgMessage(hDlg, DM_LISTGETDATA, ID, Index);
end;

function DlgList_SetItemStr(Info: TPluginStartupInfo; hDlg: THandle; ID: integer; Index: integer; Str: PChar): integer;
var
  FLID: TFarListItemData;
begin
  FillChar(FLID, sizeof(FLID), 0);
  FLID.Index:= Index;
  FLID.Data:= Str;
  result:= Info.SendDlgMessage(hDlg, DM_LISTSETDATA, ID, integer(@FLID));
end;

function MakeFarVersion(major: DWORD; minor: DWORD; build: DWORD): DWORD;
{$IFNDEF VP}
register; assembler;
asm
  SHL EAX,$08
  SHL ECX,$10
  OR  EAX,EDX
  OR  EAX,ECX
end;
{$ELSE}
begin
  result:= (major shl 8) or (minor) or (build shl 16);
end;
{$ENDIF}

initialization
  FARMANAGERVERSION:= MakeFarVersion(1,70,1634);

end.
