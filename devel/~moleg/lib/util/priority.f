\ 16-11-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ установка текущего приоритета процесса

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f

?DEFINED SetPriorityClass   WINAPI: SetPriorityClass  KERNEL32.DLL
?DEFINED GetCurrentProcess  WINAPI: GetCurrentProcess KERNEL32.DLL

        0x0020 CONSTANT normal
        0x0040 CONSTANT idle
        0x0080 CONSTANT high
        0x0100 CONSTANT realtime
        0x4000 CONSTANT normal--
        0x8000 CONSTANT normal++

\ установить собственный приоритет
\ возвращает FALSE
: own ( prc --> flag )
      GetCurrentProcess
      SetPriorityClass
      IF TRUE ELSE FALSE THEN ;

?DEFINED test{ \EOF

test{ idle own 0= THROW \ установить приоритет текущего процесса в idle
       
  S" passed" TYPE 
}test
