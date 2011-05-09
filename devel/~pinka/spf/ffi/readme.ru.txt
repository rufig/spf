FFI
  -- вызов "чужих" функций. В частности, функций OS API.

  Что надо "знать" форт-системе о чужой функции для организации вызова,
  в независимости от распространенных форматов вызова (calling convention)?

  Конкретный формат вызова, точку входа -- это понятно. И этого даже хватало 
  для Win32. В других случаях было необходимо число входных параметров.

  Похоже, для x64 будут нужны и типы выходных параметров?

  В частности, для Linux используется "System V Application Binary Interface" [6], 
  в соответствии с которым целочисленные аргументы передаются через одни регистры,
  а дробные (float) через другие регистры.

  Если все параметры целочисленны, то возможно некоторое упрощение.



See also: 

  [1] http://groups.google.com/group/comp.lang.forth/msg/cf4fb81872064a8a
        -- links to the papers by Anton Ertl 

  [2] http://sp-forth-dev-rus.670142.n2.nabble.com/FFI-td673128.html
        -- discussion about FFI in SP-Forth/4

  [3] http://comments.gmane.org/gmane.comp.lang.forth.spf/2013
        -- same as [2]

  [4] http://en.wikipedia.org/wiki/X86_calling_conventions#x86-64_Calling_Conventions
        -- x86-64 Calling Conventions (Microsoft x64, System V AMD64 ABI)

  [5] http://msdn.microsoft.com/en-us/library/ms235286%28v=vs.80%29.aspx
        -- Overview of x64 Calling Conventions  

  [6] http://x86-64.org/documentation/abi.pdf
      System V Application Binary Interface AMD64 Architecture Processor Supplement

  [7] http://stackoverflow.com/questions/3268979/arm-calling-conventions-on-wince-and-linux
        -- ARM calling conventions

