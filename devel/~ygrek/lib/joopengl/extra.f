REQUIRE STRUCT: lib/ext/struct.f

WINAPI: GetModuleHandleA     KERNEL32.DLL
WINAPI: AdjustWindowRectEx   USER32.DLL
WINAPI: ChoosePixelFormat    GDI32.DLL
WINAPI: SetPixelFormat       GDI32.DLL
WINAPI: CreateRectRgn        GDI32.DLL
WINAPI: WaitForSingleObject KERNEL32.DLL

4 CONSTANT LONG
2 CONSTANT INT
0 CONSTANT NULL

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
