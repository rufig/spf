REQUIRE Window           ~ac/lib/win/window/window.f 
REQUIRE LOAD-ICON16      ~ac/lib/win/window/icons.f 
REQUIRE EnumWindows      ~ac/lib/win/window/enumwindows.f 
REQUIRE HH_DISPLAY_TOPIC ~ac/lib/win/html/htmlhelp.f 

WINAPI: SetClassLongA USER32.DLL
WINAPI: EnumChildWindows              USER32.DLL
WINAPI: GetWindowRect USER32.DLL
WINAPI: RealGetWindowClass USER32.DLL

: ForEachChildWindow ( xt h -- ior )
  ['] EnumWindow1 SWAP EnumChildWindows ERR
;
VARIABLE WI

: RECT.
  WI 1+!
  DUP @ . CELL+ DUP @ . ." - " CELL+ DUP @ . CELL+ @ .
;
: PWND1
  DUP .
  GetForegroundWindow OVER = IF ." FOREGROUND: " THEN
  DUP IsWindowVisible IF ." VISIBLE: " THEN
  DUP 512 PAD ROT GetWindowTextA PAD SWAP ?DUP IF TYPE ELSE DROP THEN
  DUP 512 PAD ROT GetWindowModuleFileNameA PAD SWAP ?DUP 
  IF ."  (" TYPE ." )" ELSE DROP THEN
  DUP 512 PAD ROT RealGetWindowClass PAD SWAP TYPE SPACE
  DUP PAD SWAP GetWindowRect DROP PAD RECT.
  WI @ 1 = IF DUP WindowHide GetLastError . THEN
  DROP CR
  TRUE
;
: ZZ ( h -- )
  ['] PWND SWAP ForEachChildWindow DROP
;

: TEST1
  || h ||

  S" RichEdit20A" SPF_STDEDIT 0 Window -> h
  500000 0 EM_EXLIMITTEXT h PostMessageA DROP

  400 200 h WindowPos
  150 250 h WindowSize
  h WindowShow
  h WindowMinimize
  h WindowRestore

  0 HH_DISPLAY_TOPIC
  S" htmlhelp.chm::/ch05.html" DROP h HtmlHelpA >R

   S" ESERV.ICO" LOAD-ICON16 -14 R>
   SetClassLongA DROP

\   0 HH_DISPLAY_TOPIC
\ S" http://www.enet.ru/" DROP h HtmlHelpA .

  h MessageLoop
  h WindowDelete
;
S" ESERV.ICO" LOAD-ICON16 -14 
0 HH_DISPLAY_TOPIC 
S" htmlhelp.chm::/ch05.html" DROP GetDesktopWindow HtmlHelpA DUP ZZ SetClassLongA DROP
