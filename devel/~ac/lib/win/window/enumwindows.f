WINAPI: EnumWindows              USER32.DLL
WINAPI: EnumChildWindows         USER32.DLL
WINAPI: GetWindowTextA           USER32.DLL
WINAPI: GetForegroundWindow      USER32.DLL
WINAPI: GetWindowModuleFileNameA USER32.DLL \ NT4SP3, Win98
WINAPI: IsWindowVisible          USER32.DLL

: (EnumWindow1) ( xt hwnd -- flag )
\ flag=true - continue enumeration
\ flag=false - stop enumeration
  SWAP EXECUTE
;
\ ' (EnumWindow1) WNDPROC: EnumWindow1
' (EnumWindow1) 8 CALLBACK: EnumWindow1

: ForEachWindow ( xt -- ior )
  ['] EnumWindow1 EnumWindows ERR
;

: (EnumChildWindow1) ( xt hwnd -- flag )
\ flag=true - continue enumeration
\ flag=false - stop enumeration
  SWAP EXECUTE
;
' (EnumChildWindow1) 8 CALLBACK: EnumChildWindow1

: ForEachChildWindow ( xt hwnd -- ior )
  ['] EnumChildWindow1 SWAP EnumChildWindows ERR
;

\EOF

: PWND
  DUP .
  GetForegroundWindow OVER = IF ." FOREGROUND: " THEN
  DUP IsWindowVisible IF ." VISIBLE: " THEN
  DUP 512 PAD ROT GetWindowTextA PAD SWAP ?DUP IF TYPE ELSE DROP THEN
  DUP 512 PAD ROT GetWindowModuleFileNameA PAD SWAP ?DUP 
  IF ."  (" TYPE ." )" ELSE DROP THEN
  DROP CR
  TRUE
;
: TEST
  ['] PWND ForEachWindow DROP
;
