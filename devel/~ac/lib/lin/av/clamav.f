REQUIRE SO  ~ac/lib/ns/so-xt.f
REQUIRE {   lib/ext/locals.f

\ db options
0x2    CONSTANT CL_DB_PHISHING	    
0x8    CONSTANT CL_DB_PHISHING_URLS 
0x10   CONSTANT CL_DB_PUA	    
0x20   CONSTANT CL_DB_CVDNOTMP	      \ obsolete
0x40   CONSTANT CL_DB_OFFICIAL	      \ internal
0x80   CONSTANT CL_DB_PUA_MODE	    
0x100  CONSTANT CL_DB_PUA_INCLUDE   
0x200  CONSTANT CL_DB_PUA_EXCLUDE   
0x400  CONSTANT CL_DB_COMPILED	      \ internal
0x800  CONSTANT CL_DB_DIRECTORY	      \ internal
0x1000 CONSTANT CL_DB_OFFICIAL_ONLY 
0x2000 CONSTANT CL_DB_BYTECODE      
0x4000 CONSTANT CL_DB_SIGNED	    

CL_DB_PHISHING CL_DB_PHISHING_URLS OR CL_DB_BYTECODE OR CONSTANT CL_DB_STDOPT

ALSO SO NEW: libclamav.dll
ALSO SO NEW: libclamav.so


: TEST { \ eng sig scanned virname -- }
  0 1 cl_init THROW
  0 cl_debug .
  0 cl_engine_new -> eng
  ( CL_DB_STDOPT DROP)
  0x7FFF ^ sig eng S" C:\ProgramData\.clamwin\db" DROP 4 cl_load THROW
  ." sigs=" sig . CR
  eng 1 cl_engine_compile THROW
  0 eng ^ scanned ^ virname S" I:\dl\eicar.com" DROP 5 cl_scanfile IF virname ASCIIZ> TYPE CR THEN
  eng 1 cl_engine_free THROW

  \ 0 cl_retdbdir ASCIIZ> TYPE CR
;
TEST .( OK)
