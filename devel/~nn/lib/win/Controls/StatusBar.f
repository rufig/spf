REQUIRE Control ~nn/lib/win/control.f
WM_USER 1+ CONSTANT SB_SETTEXT
CLASS: StatusBar <SUPER Control
VM: Type S" msctls_statusbar32" ;
M: SetParts ( a # )  SB_SETPARTS SendMessage  DROP ;
M: SetText ( a u # ) NIP SB_SETTEXT SendMessage DROP ;
;CLASS