\ user
WINAPI: RegisterClassA       USER32.DLL
WINAPI: CreateWindowExA      USER32.DLL
WINAPI: UpdateWindow         USER32.DLL
WINAPI: DefWindowProcA       USER32.DLL
WINAPI: LoadIconA            USER32.DLL
WINAPI: LoadCursorA          USER32.DLL
WINAPI: PostQuitMessage      USER32.DLL
WINAPI: GetDC                USER32.DLL
WINAPI: ReleaseDC            USER32.DLL
WINAPI: MoveWindow           USER32.DLL
WINAPI: SetFocus             USER32.DLL
WINAPI: ShowWindow           USER32.DLL
WINAPI: SetWindowLongA       USER32.DLL
WINAPI: GetMessageA          USER32.DLL
WINAPI: PeekMessageA         USER32.DLL
WINAPI: DispatchMessageA     USER32.DLL
WINAPI: TranslateMessage     USER32.DLL
WINAPI: SendMessageA         USER32.DLL
WINAPI: CallWindowProcA      USER32.DLL
WINAPI: CreateMenu           USER32.DLL
WINAPI: CreatePopupMenu      USER32.DLL
WINAPI: AppendMenuA          USER32.DLL
WINAPI: GetKeyState          USER32.DLL
WINAPI: LockWindowUpdate     USER32.DLL

WINAPI: GetOpenFileNameA     COMDLG32.DLL

\ graphics
WINAPI: DeleteObject         GDI32.DLL
WINAPI: GetStockObject       GDI32.DLL
WINAPI: CreateFontIndirectA  GDI32.DLL

\ kernel
WINAPI: ResetEvent           KERNEL32.DLL
WINAPI: SetStdHandle         KERNEL32.DLL

DECIMAL
IMAGE-BASE CONSTANT HINST  \ Instance текущего приложения


211 CONSTANT cmdBYE
212 CONSTANT cmdOPEN
221 CONSTANT cmdCUT
222 CONSTANT cmdCOPY
223 CONSTANT cmdPASTE
231 CONSTANT cmdHELP


0
4 -- .style
4 -- .lpfnWndProc
4 -- .cbClsExtra
4 -- .cbWndExtra
4 -- .hInstance
4 -- .hIcon
4 -- .hCursor
4 -- .hbrBackground
4 -- .lpszMenuName
4 -- .lpszClassName
CONSTANT /WNDCLASS

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

0
  4 --  lfHeight
  4 --  lfWidth
  4 --  lfEscapement
  4 --  lfOrientation
  4 --  lfWeight
  1 --  lfItalic
  1 --  lfUnderline
  1 --  lfStrikeOut
  1 --  lfCharSet
  1 --  lfOutPrecision
  1 --  lfClipPrecision
  1 --  lfQuality
  1 --  lfPitchAndFamily
 48 --  lfFaceName
CONSTANT  /LOGFONT

0
  4 --  .lStructSize
  4 --  .hwndOwner
  4 --  .hInstance1
  4 --  .lpstrFilter
  4 --  .lpstrCustomFilter
  4 --  .nMaxCustFilter
  4 --  .nFilterIndex
  4 --  .lpstrFile
  4 --  .nMaxFile
  4 --  .lpstrFileTitle
  4 --  .nMaxFileTitle
  4 --  .lpstrInitialDir
  4 --  .lpstrTitle
  4 --  .Flags
  2 --  .nFileOffset
  2 --  .nFileExtension
  4 --  .lpstrDefExt
  4 --  .lCustData
  4 --  .lpfnHook
  4 --  .lpTemplateName
CONSTANT  /OPENFILENAME
