WINAPI: gdImageCreate@8         BGD.DLL
WINAPI: gdImageDestroy@4        BGD.DLL
WINAPI: gdImageColorAllocate@16 BGD.DLL
WINAPI: gdImageLine@24          BGD.DLL
WINAPI: gdImagePng@8            BGD.DLL
WINAPI: fopen                   msvcrt.dll
WINAPI: gdFontGetSmall@0        BGD.DLL
WINAPI: gdImageString@24        BGD.DLL

VARIABLE im
VARIABLE black
VARIABLE white
100 100 gdImageCreate@8 DUP . im !
0 0 0 im @ gdImageColorAllocate@16 DUP . black !
255 255 255 im @ gdImageColorAllocate@16 DUP . white !
white @ 99 99 0 0 im @ gdImageLine@24 DROP
white @ S" test_рус" DROP 50 50 gdFontGetSmall@0 im @ gdImageString@24 DROP
S" wb" DROP S" test2.png" DROP fopen NIP NIP DUP . im @ gdImagePng@8 DROP
