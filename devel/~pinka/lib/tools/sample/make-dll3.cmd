@rem zzz2.exe exe2dll.test.f S" zzz2.bin" SAVE BYE >z2
@rem zzz.exe exe2dll.test.f exe2dll.f S" zzz2.bin" S" zzz.dll" SAVE-DLL BYE >z

spf-2.exe %1.f S" %1-2.bin" SAVE BYE
spf-1.exe %1.f exe2dll3.f S" %1-2.bin" S" %1.dll" SAVE-DLL BYE >%1.log

