REQUIRE STRUCT: lib/ext/struct.f

WINAPI: GetModuleHandleA    KERNEL32.DLL
WINAPI: AdjustWindowRectEx  USER32.DLL
WINAPI: ChoosePixelFormat   GDI32.DLL
WINAPI: SetPixelFormat      GDI32.DLL

\ from ~day\joop\win\wfunc.f

WINAPI: PaintDesktop     USER32.DLL
WINAPI: SetFocus         USER32.DLL
WINAPI: ShowCursor       USER32.DLL
WINAPI: ScrollWindowEx   USER32.DLL
WINAPI: IsMenu           USER32.DLL
WINAPI: DestroyMenu      USER32.DLL
WINAPI: GetDesktopWindow USER32.DLL
WINAPI: GetWindowDC      USER32.DLL
WINAPI: GetSysColor      USER32.DLL
WINAPI: ScreenToClient   USER32.DLL
WINAPI: GetCursorPos      USER32.DLL
WINAPI: ClientToScreen   USER32.DLL
WINAPI: SendMessageA      USER32.DLL
WINAPI: ChildWindowFromPoint USER32.DLL
WINAPI: ShowOwnedPopups   USER32.DLL
WINAPI: BringWindowToTop  USER32.DLL
WINAPI: GetLastActivePopup USER32.DLL
WINAPI: IsWindowEnabled  USER32.DLL
WINAPI: WaitMessage      USER32.DLL
WINAPI: PeekMessageA     USER32.DLL
WINAPI: GetActiveWindow  USER32.DLL
WINAPI: GetTopWindow     USER32.DLL
WINAPI: SetActiveWindow  USER32.DLL
WINAPI: GetForegroundWindow USER32.DLL
WINAPI: SetForegroundWindow USER32.DLL
WINAPI: EnableWindow      USER32.DLL
WINAPI: EnumThreadWindows USER32.DLL
WINAPI: SetParent        USER32.DLL
WINAPI: GetParent        USER32.DLL
WINAPI: GetWindowTextA   USER32.DLL
WINAPI: RegisterClassExA USER32.DLL
WINAPI: RegisterClassA USER32.DLL
WINAPI: CreateMenu       USER32.DLL
WINAPI: CreatePopupMenu       USER32.DLL
WINAPI: TrackPopupMenu  USER32.DLL
WINAPI: SetMenu          USER32.DLL
WINAPI: GetMenu          USER32.DLL
WINAPI: AppendMenuA      USER32.DLL
WINAPI: DrawMenuBar      USER32.DLL
WINAPI: MessageBoxA      USER32.DLL
WINAPI: GetWindowLongA   USER32.DLL
WINAPI: GetWindow        USER32.DLL
WINAPI: SetWindowLongA   USER32.DLL
WINAPI: MoveWindow       USER32.DLL
WINAPI: DestroyWindow    USER32.DLL
WINAPI: CreateWindowExA  USER32.DLL
WINAPI: SetWindowTextA   USER32.DLL
WINAPI: UpdateWindow     USER32.DLL
WINAPI: BeginPaint       USER32.DLL
WINAPI: EndPaint         USER32.DLL
WINAPI: GetClassNameA    USER32.DLL
WINAPI: DefWindowProcA   USER32.DLL
WINAPI: DefDlgProcA   USER32.DLL
WINAPI: LoadIconA        USER32.DLL
WINAPI: LoadCursorA      USER32.DLL
WINAPI: DrawIcon         USER32.DLL
WINAPI: IsWindow         USER32.DLL
WINAPI: ShowWindow       USER32.DLL
WINAPI: GetMessageA      USER32.DLL
WINAPI: DispatchMessageA USER32.DLL
WINAPI: TranslateMessage USER32.DLL
WINAPI: GetClientRect    USER32.DLL
WINAPI: InvalidateRect   USER32.DLL
WINAPI: DrawTextA        USER32.DLL
WINAPI: PostQuitMessage  USER32.DLL
WINAPI: SetTimer         USER32.DLL
WINAPI: KillTimer        USER32.DLL
WINAPI: GetDC            USER32.DLL
WINAPI: ReleaseDC        USER32.DLL
WINAPI: LoadMenuIndirectW USER32.DLL
WINAPI: GetDialogBaseUnits USER32.DLL
WINAPI: UnregisterClassA    USER32.DLL
WINAPI: DialogBoxIndirectParamA USER32.DLL
WINAPI: EndDialog               USER32.DLL
WINAPI: GetDlgItemTextA         USER32.DLL
WINAPI: SetDlgItemTextA         USER32.DLL
WINAPI: GetDlgItem      USER32.DLL
WINAPI: SetCursor       USER32.DLL
WINAPI: SetScrollRange  USER32.DLL
WINAPI: SetScrollPos    USER32.DLL
WINAPI: SetScrollInfo   USER32.DLL
WINAPI: GetScrollPos    USER32.DLL
WINAPI: FillRect        USER32.DLL
WINAPI: GetWindowRect   USER32.DLL

WINAPI: SetPixel                     GDI32.DLL
WINAPI: GetPixel                     GDI32.DLL
WINAPI: ExtFloodFill                 GDI32.DLL
WINAPI: BitBlt                       GDI32.DLL
WINAPI: PlgBlt                       GDI32.DLL
WINAPI: PatBlt                       GDI32.DLL
WINAPI: CreateCompatibleBitmap       GDI32.DLL
WINAPI: CreateDCA                    GDI32.DLL
WINAPI: CreatePalette                GDI32.DLL
WINAPI: CreatePen                    GDI32.DLL
WINAPI: CreateSolidBrush             GDI32.DLL
WINAPI: RealizePalette               GDI32.DLL
WINAPI: SelectPalette                GDI32.DLL
WINAPI: SetBkMode                    GDI32.DLL
WINAPI: SetBkColor                   GDI32.DLL
WINAPI: SetPaletteEntries            GDI32.DLL
WINAPI: SetTextColor                 GDI32.DLL
WINAPI: TextOutA                     GDI32.DLL
WINAPI: UpdateColors                 GDI32.DLL
WINAPI: SetMapMode        GDI32.DLL
WINAPI: SetWindowExtEx    GDI32.DLL
WINAPI: SetViewportExtEx  GDI32.DLL
WINAPI: SetViewportOrgEx  GDI32.DLL
WINAPI: SelectObject      GDI32.DLL
WINAPI: GetStockObject    GDI32.DLL
WINAPI: Ellipse           GDI32.DLL
WINAPI: Polyline          GDI32.DLL
WINAPI: CreateFontA       GDI32.DLL
WINAPI: DeleteObject     GDI32.DLL
WINAPI: StretchBlt       GDI32.DLL
WINAPI: DeleteDC         GDI32.DLL
WINAPI: MoveToEx         GDI32.DLL
WINAPI: LineTo           GDI32.DLL


\ strings
WINAPI: SetPriorityClass KERNEL32.DLL
\ WINAPI: MultiByteToWideChar KERNEL32.DLL
\ WINAPI: WideCharToMultiByte KERNEL32.DLL
WINAPI: GetCurrentProcess KERNEL32.DLL
WINAPI: GetCurrentThreadId  KERNEL32.DLL

WINAPI: InitCommonControlsEx COMCTL32.DLL

\ Windows structures

4 CONSTANT LONG
2 CONSTANT INT
0 CONSTANT NULL

STRUCT: POINT
  LONG -- x
  LONG -- y
;STRUCT

STRUCT: MSG
   LONG -- hwnd
   LONG -- msg
   LONG -- wParam
   LONG -- lParam
   LONG -- time
   POINT::/SIZE -- pt
;STRUCT

STRUCT: WNDCLASS
   LONG -- style
   LONG -- lpfnWndProc
   LONG -- cbClsExtra
   LONG -- cbWndExtra
   LONG -- hInstance
   LONG -- hIcon
   LONG -- hCursor
   LONG -- hbrBackground
   LONG -- lpszMenuName
   LONG -- lpszClassName
;STRUCT

STRUCT: RECT
   LONG -- left
   LONG -- top
   LONG -- right
   LONG -- bottom
;STRUCT

STRUCT: PIXELFORMATDESCRIPTOR 
  2 --  nSize 
  2 --  nVersion
  4 --  dwFlags
  1 --  iPixelType 
  1 --  cColorBits 
  1 --  cRedBits 
  1 --  cRedShift 
  1 --  cGreenBits  
  1 --  cGreenShift  
  1 --  cBlueBits  
  1 --  cBlueShift  
  1 --  cAlphaBits  
  1 --  cAlphaShift  
  1 --  cAccumBits  
  1 --  cAccumRedBits  
  1 --  cAccumGreenBits  
  1 --  cAccumBlueBits  
  1 --  cAccumAlphaBits  
  1 --  cDepthBits  
  1 --  cStencilBits  
  1 --  cAuxBuffers  
  1 --  iLayerType  
  1 --  bReserved  
  4 --  dwLayerMask  
  4 --  dwVisibleMask  
  4 --  dwDamageMask  
;STRUCT

STRUCT: PAINTSTRUCT  
  LONG -- hdc; 
   INT -- fErase; 
  RECT::/SIZE -- rcPaint; 
   INT -- fRestore; 
   INT -- fIncUpdate; 
    32 -- rgbReserved[32]; 
;STRUCT