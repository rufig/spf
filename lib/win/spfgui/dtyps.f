WINAPI: CreateEventA        KERNEL32.DLL
WINAPI: SetEvent            KERNEL32.DLL
WINAPI: ResetEvent          KERNEL32.DLL
WINAPI: WaitForSingleObject KERNEL32.DLL
WINAPI: SetTimer         USER32.DLL
WINAPI: SendMessageA     USER32.DLL
WINAPI: SetTextColor     GDI32.DLL
WINAPI: SetBkColor       GDI32.DLL
WINAPI: GetKeyState      USER32.DLL
WINAPI: RegisterWindowMessageA USER32.DLL
WINAPI: RegisterClassExA USER32.DLL
WINAPI: CreateWindowExA  USER32.DLL
WINAPI: CreateWindowExW  USER32.DLL
WINAPI: GetClassInfoExA  USER32.DLL
WINAPI: UnregisterClassA  USER32.DLL

WINAPI: SetWindowTextA   USER32.DLL
WINAPI: UpdateWindow     USER32.DLL
WINAPI: BeginPaint       USER32.DLL
WINAPI: EndPaint         USER32.DLL
WINAPI: GetClassNameA    USER32.DLL
WINAPI: DefWindowProcA   USER32.DLL
WINAPI: LoadIconA        USER32.DLL
WINAPI: LoadCursorA      USER32.DLL
WINAPI: DrawIcon         USER32.DLL
WINAPI: ShowWindow       USER32.DLL
WINAPI: GetMessageA      USER32.DLL
WINAPI: DispatchMessageA USER32.DLL
WINAPI: TranslateMessage USER32.DLL
WINAPI: GetClientRect    USER32.DLL
WINAPI: InvalidateRect   USER32.DLL
WINAPI: DrawTextA        USER32.DLL
WINAPI: PostQuitMessage  USER32.DLL
WINAPI: GetDC            USER32.DLL
WINAPI: ReleaseDC        USER32.DLL
WINAPI: MessageBoxA      USER32.DLL
WINAPI: GetFocus         USER32.DLL
WINAPI: SetCaretPos      USER32.DLL
WINAPI: CreateCaret      USER32.DLL
WINAPI: ShowCaret        USER32.DLL
WINAPI: HideCaret        USER32.DLL
WINAPI: DestroyCaret     USER32.DLL

\ grafics
WINAPI: SelectObject      GDI32.DLL
WINAPI: TextOutA          GDI32.DLL
WINAPI: GetStockObject    GDI32.DLL
WINAPI: GetTextMetricsA   GDI32.DLL

WINAPI: ScrollWindow     USER32.DLL
WINAPI: MoveWindow       USER32.DLL
WINAPI: GetSystemMetrics USER32.DLL

\ paint structure
0
4 -- PS.hdc
4 -- PS.fErase
4 -- PS.rcPaint
4 -- PS.fRestore
4 -- PS.fIncUpdate
4 -- PS.rgbReserved
\ 31 +
48 +
CONSTANT /PS


\  WNDCLASS
0
4 -- окна.размер_структ
4 -- окна.стиль
4 -- окна.процедура
4 -- окна.класс+
4 -- окна.окно+
4 -- окна.экземпл€р
4 -- окна.икон
4 -- окна.курсор
4 -- окна.фон
4 -- окна.меню
4 -- окна.им€
4 -- окна.икон+
CONSTANT /winclass

0
 4 -- tmHeight
 4 -- tmAscent
 4 -- tmDescent
 4 -- tmInternalLeading
 4 -- tmExternalLeading
 4 -- tmAveCharWidth
 4 -- tmMaxCharWidth
 4 -- tmWeight
 4 -- tmOverhang
 4 -- tmDigitizedAspectX
 4 -- tmDigitizedAspectY
 1 -- tmFirstChar
 1 -- tmLastChar
 1 -- tmDefaultChar
 1 -- tmBreakChar
 1 -- tmItalic
 1 -- tmUnderlined
 1 -- tmStruckOut
 1 -- tmPitchAndFamily
 1 -- tmCharSet
CONSTANT /TEXTMETRIC
0
4 -- MSG.hwnd
4 -- MSG.message
4 -- MSG.wParam
4 -- MSG.lParam
4 -- MSG.time
4 -- MSG.pt
4 -- MSG.ex
CONSTANT /MSG

0
CELL -- par.hwnd
CELL -- par.cxClient
CELL -- par.cyClient
CELL -- par.cyChar
CELL -- par.bKill
CELL -- par.tid
CONSTANT /PARAMS
