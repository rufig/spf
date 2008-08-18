REQUIRE { lib/ext/locals.f
REQUIRE (WINAPI:) ~nn/lib/winapi.f
REQUIRE LH-INCLUDED  ~nn/lib/lh.f
S" ~nn/lib/usedll.f" LH-INCLUDED
REQUIRE (WIN-SHOW-CONST) ~nn/lib/wincon.f
UseDLL USER32.DLL
UseDLL KERNEL32.DLL
UseDLL GDI32.DLL
0 CONSTANT nn-adapter
