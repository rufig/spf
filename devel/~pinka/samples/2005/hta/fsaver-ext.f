REQUIRE {         lib\ext\locals.f
REQUIRE NEXT-PARAM ~day\common\clparam.f
REQUIRE SetPriorityClass ~day\joop\win\wfunc.f
REQUIRE ShowMessage ~day\joop\win\window.f 
REQUIRE Wait ~pinka\lib\multi\synchr.f

WINAPI: ShellExecuteA   shell32.dll
WINAPI: ShellExecuteExA shell32.dll

: ShellRun { addr u -- }
  SW_SHOW \ nShowCmd
  0 \ lpDirectory
  0 \ lpParameters
  addr \ lpFile
  S" open" DROP \ lpOperation
  0 \ HWND
  ShellExecuteA ( hinst )
  DROP
;

: DWORD 4 ;
: DW!   ! ;

0 \ struct _SHELLEXECUTEINFO {
DWORD -- cbSize
CELL  -- fMask
CELL  -- hwnd
CELL  -- lpVerb \ LPCTSTR
CELL  -- lpFile \ LPCTSTR
CELL  -- lpParameters \ LPCTSTR
CELL  -- lpDirectory \ LPCTSTR 
CELL  -- nShow
CELL  -- hInstApp
CELL  -- lpIDList \ LPVOID
CELL  -- lpClass \ LPCTSTR
CELL  -- hkeyClass \ HKEY
DWORD -- dwHotKey \ DWORD
CELL  -- DUMMYUNIONNAME ( 
    union {
        HANDLE hIcon;
        HANDLE hMonitor;
    } DUMMYUNIONNAME;    )
CELL  --  hProcess \ HANDLE
\ } SHELLEXECUTEINFO, *LPSHELLEXECUTEINFO;
CONSTANT /SHELLEXECUTEINFO

\ windows constant value
\ search: http://www.google.ru/search?q=SW_SHOW+5+SEE_MASK_NOCLOSEPROCESS
\ found: http://thevbzone.com/cFile.cls
\        SEE_MASK_NOCLOSEPROCESS = &H40 :)

0x40 CONSTANT SEE_MASK_NOCLOSEPROCESS

: ShellRunWait ( addr u -- )
  /SHELLEXECUTEINFO ALLOCATE THROW { addr u i }
  i /SHELLEXECUTEINFO ERASE
  /SHELLEXECUTEINFO i cbSize DW!
  addr i lpFile !
  S" open" DROP i lpVerb !
  SW_SHOW i nShow !
  SEE_MASK_NOCLOSEPROCESS i fMask !

  i ShellExecuteExA  
  \ ERR THROW
  0= IF EXIT THEN
  i hProcess @  -1 Wait DROP
  i hProcess @ CloseHandle ERR THROW
  i FREE THROW
;

: RUN { \ w }  \ word skeleton from ~day\joop\samples\fsaver.f  :)
   IDLE_PRIORITY_CLASS GetCurrentProcess
   SetPriorityClass DROP
   NEXT-PARAM 2DROP
   NEXT-PARAM  DROP 1+ C@ DUP [CHAR] p = IF BYE THEN
   [CHAR] c =
   IF
      S" There aren't any options" ShowMessage
   ELSE
      \ FALSE ShowCursor DROP
      \ S" fsaver.ini" INCLUDED
      S" fsaver-flash.hta" ShellRunWait
      \ TRUE ShowCursor DROP
   THEN
   BYE
;

\ EOF

HERE IMAGE-BASE - 10000 + TO IMAGE-SIZE
' RUN MAINX !
TRUE TO ?GUI
S" fsaver-hta.scr" SAVE BYE
