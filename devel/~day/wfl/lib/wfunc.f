REQUIRE ADD-CONST-VOC ~day\wincons\wc.f
\ DAY FEB-2000

0 CONSTANT WFUNC

\ user
WINAPI: PaintDesktop     USER32.DLL
WINAPI: CallWindowProcA  USER32.DLL
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
WINAPI: PostMessageA      USER32.DLL
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
WINAPI: IsDialogMessage USER32.DLL

\ grafics
WINAPI: CreateDCA                    GDI32.DLL
WINAPI: CreatePalette                GDI32.DLL
WINAPI: CreatePen                    GDI32.DLL
WINAPI: CreateCompatibleDC           GDI32.DLL
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

WINAPI: SetCapture       USER32.DLL
WINAPI: ReleaseCapture       USER32.DLL

\ strings
WINAPI: SetPriorityClass KERNEL32.DLL
WINAPI: MultiByteToWideChar KERNEL32.DLL
WINAPI: WideCharToMultiByte KERNEL32.DLL
WINAPI: GetCurrentProcess KERNEL32.DLL
WINAPI: GetCurrentThreadId  KERNEL32.DLL

WINAPI: SetLastError    KERNEL32.DLL

WINAPI: InitCommonControlsEx COMCTL32.DLL

\ from byka
: rgb           ( red green blue -- colorref )
   2               \ flag             ( for palette rgb value )
   256 * +         \ flag*256 + blue
   256 * +         \ flag*256 + blue*256 + green
   256 * +        \ flag*256 + blue*256 + green*256 + red
;

0
CELL -- rect.left
CELL -- rect.top
CELL -- rect.right
CELL -- rect.bottom
CONSTANT /RECT

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

: GetDesktopCoord ( -- x y)
\ ѕолучить размер десктопа
    4 RALLOT DUP
    GetDesktopWindow
    GetClientRect DROP
    DUP rect.right @
    SWAP rect.bottom @
    4 RFREE
;

: @RECT ( addr -- bottom right top left )
    >R
    R@ 3 CELLS + @
    R@ 2 CELLS + @
    R@ CELL+ @
    R> @
;

\ ѕосле этого выполнить 4 RFREE
: RECT-RP! ( b r t l -- addr)
  R> 
  4 PICK >R
  3 PICK >R
  2 PICK >R
  1 PICK >R
  RP@ SWAP >R

  >R 2DROP 2DROP R>
;

: OR! ( u addr)
    DUP @ ROT OR
    SWAP !
;

IMAGE-BASE CONSTANT HINST \ handle of application

WINAPI: FormatMessageA KERNEL32.DLL
VARIABLE lpFormatMessage

: FormatMessage ( i -- addr u )
   >R
   0 
   512
   lpFormatMessage
   0  \ langId
   R> \ messageId
   0  \ lpSource
   FORMAT_MESSAGE_ALLOCATE_BUFFER
   FORMAT_MESSAGE_FROM_SYSTEM OR
   FormatMessageA DROP
   lpFormatMessage @ ASCIIZ>
;

: WIN-THROW ( n )
   0= INVERT GetLastError 0= INVERT AND 
   IF HYPE::MetaClass ^ returnStack.
      GetLastError FormatMessage 
      ER-U ! ER-A ! -2 THROW
   THEN
;

: -WIN-THROW
   0= WIN-THROW
;

: FormatWordFromWinMessage ( c u -- addr u )
    BASE @ >R HEX
    0 <# # # # #  # # # # ROT HOLD #>
    R> BASE !
;

WM_USER 0x1C00 + CONSTANT OCM_BASE

: CreateMsgProcessor
    PARSE-NAME EVALUATE FormatWordFromWinMessage SHEADER ] HIDE
;

: W: [CHAR] W CreateMsgProcessor ; \ windows message
: C: [CHAR] C CreateMsgProcessor ; \ WM_COMMAND
: N: [CHAR] N CreateMsgProcessor ; \ WM_NOTIFY
: M: [CHAR] M CreateMsgProcessor ; \ Menu items
: A: [CHAR] A CreateMsgProcessor ; \ Accelerator
: X: [CHAR] X CreateMsgProcessor ; \ Fast comment this method

\ Reflected message
: R: [CHAR] W PARSE-NAME EVALUATE OCM_BASE + 
     FormatWordFromWinMessage SHEADER ] HIDE ;

: HIWORD
   16 RSHIFT
;

: LOWORD
   0xFFFF AND
;

USER CC_INIT \ однократна€ инициализаци€ CommonControls
CREATE   CC_INITS 8 , BASE @ HEX 3FFF , BASE !

: InitCommonControls
  CC_INIT @ IF EXIT THEN
  CC_INITS InitCommonControlsEx DROP
  S" RICHED32.DLL" DROP LoadLibraryA DROP
  S" RICHED20.DLL" DROP LoadLibraryA DROP
  TRUE CC_INIT !
;
