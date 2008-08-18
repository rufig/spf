REQUIRE Control ~nn/lib/win/control.f

CLASS: UpDownControl <SUPER Control
WINAPI: CreateUpDownControl comctl32.dll

CONSTR: init ;

M: Create
	CreateUpDownControl
;

;CLASS