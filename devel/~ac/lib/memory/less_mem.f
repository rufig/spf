\ idea of Svyatoslav Ushakov

REQUIRE WinNT?            ~ac/lib/win/winver.f
REQUIRE GetCurrentProcess ~ac/lib/win/process/pipes.f

WINAPI: SetProcessWorkingSetSize KERNEL32.DLL

: ReduceMem
  WinNT?
  IF -1 -1 GetCurrentProcess SetProcessWorkingSetSize DROP THEN
;
