\ 04.Jul.2001 Wed 03:43

REQUIRE [UNDEFINED]  lib\include\tools.f

[UNDEFINED] ?WINAPI:  [IF]
: ?WINAPI: ( -- ) \
  >IN @
  POSTPONE [UNDEFINED]
  IF   >IN ! WINAPI: 
  ELSE DROP NextWord 2DROP 
  THEN
;                     [THEN]

?WINAPI: GetMessageA USER32.DLL (
    UINT  wMsgFilterMax     // last message
    UINT  wMsgFilterMin     // first message
    HWND  hWnd              // handle of window
    LPMSG  lpMsg            // address of structure with message
    -- BOOL  )

?WINAPI: PeekMessageA USER32.DLL (
    UINT  wRemoveMsg    // removal flags
    UINT  uMsgFilterMax    // last message
    UINT  uMsgFilterMin    // first message
    HWND  hWnd         // handle of window
    LPMSG  lpMsg       // address of structure for message
  -- BOOL )

?WINAPI: WaitMessage  USER32.DLL ( -- BOOL )

?WINAPI: PostThreadMessageA USER32.DLL (
    LPARAM  lParam  // second message parameter
    WPARAM  wParam  // first message parameter
    UINT  uMsg      // message to post
    DWORD  dwThreadId  // thread identifier
    -- BOOL )

?WINAPI: PostMessageA  USER32.DLL


[UNDEFINED] GetCurrentThreadId [IF]
WINAPI: GetCurrentThreadId KERNEL32.DLL (
  -- DWORD )                   [THEN]

[UNDEFINED] WM_QUIT [IF]
0x0012 CONSTANT WM_QUIT [THEN]

[UNDEFINED] WM_USER [IF]
0x0400 CONSTANT WM_USER [THEN]

