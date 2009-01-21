\ программное усыпление машины

REQUIRE SetPrivilege ~ac/lib/win/access/nt_privelege.f 

WINAPI: IsPwrSuspendAllowed PowrProf.dll
WINAPI: SetSystemPowerState Kernel32.dll

: GetShutdownPrivilege ( -- )
  TRUE S" SeShutdownPrivilege" GetProcessToken THROW SetPrivilege THROW
;
: AcpiSuspend ( -- ior )

  \ если не выставить права, то SetSystemPowerState выдаст 1314
  ['] GetShutdownPrivilege CATCH ?DUP IF EXIT THEN  \ при неправильном имени Se - аппаратный exception внутри LookupPrivilegeValueA !!!

  IsPwrSuspendAllowed 1 =
  IF 0 1 SetSystemPowerState ERR ELSE 5 THEN \ возврат из функции происходит при выходе из сна
;
\ AcpiSuspend .
