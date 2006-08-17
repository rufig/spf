REQUIRE ->" ~micro/autopush/interface.f

MODULE: ConnectWindow
  : hwnd ( -- hwnd | 0 )
    desktop ->" Установлена связь с 8-180"
  ;
  : IsConnect ( -- f )
    hwnd 0<>
  ;
  : Disconnect ( -- )
    hwnd ->" Завер&шить связь" push
  ;
;MODULE