REQUIRE (WINAPI:) ~nn/lib/winapi.f
REQUIRE LH-INCLUDED  ~nn/lib/lh.f
S" ~nn/lib/usedll.f" LH-INCLUDED
S" ~nn/lib/wincon.f" INCLUDED
UseDLL USER32.DLL
UseDLL KERNEL32.DLL
UseDLL GDI32.DLL
