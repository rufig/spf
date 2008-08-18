REQUIRE Control ~nn/lib/win/control.f
\ REQUIRE TIME&DATE lib/ext/facil.f

CLASS: DateTimePicker <SUPER Control
    
0x1005 CONSTANT DTM_SETFORMAT

VM: Type S" SysDateTimePick32" ;
M: GetTime ( -- y-m wd-d h-m s-ms)
    0 0 0 0 SP@ 0 DTM_GETSYSTEMTIME SendMessage DROP ;
M: SetTime ( y-m wd-d h-m s-ms --)
    SP@ GDT_VALID DTM_SETSYSTEMTIME SendMessage DROP
    2DROP 2DROP ;
M: SetFormat DROP 0 DTM_SETFORMAT SendMessage DROP ;
;CLASS

CLASS: DatePicker <SUPER DateTimePicker
M: Get ( -- year month day week-day)
    GetTime 2SWAP 2DROP
    DUP LOWORD SWAP HIWORD
    ROT DUP HIWORD SWAP LOWORD DUP 0= IF DROP 7 THEN
;
M: Set ( y m d wd -- )
    SWAP 16 LSHIFT OR ROT ROT
    16 LSHIFT OR 0 0 2SWAP SetTime
;
;CLASS

CLASS: TimePicker <SUPER DateTimePicker
VM: Style DTS_TIMEFORMAT ;

M: Get ( -- hh mm ss)
    GetTime  2DROP
    DUP LOWORD SWAP HIWORD
    ROT LOWORD
;
M: Set ( hh mm ss -- )
   ROT ROT 16 LSHIFT OR
   65542 67536 SetTime
;

;CLASS