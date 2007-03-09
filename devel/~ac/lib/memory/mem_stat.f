\ MEM% - сколько процентов физической пам€ти зан€то

WINAPI: GlobalMemoryStatus KERNEL32.DLL

: MEM% ( -- n )
  PAD GlobalMemoryStatus DROP PAD CELL+ @
;