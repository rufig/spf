\ Небольшие тонкости и дополнения к WinLib

REQUIRE treeview ~yz/lib/wincc.f
WINAPI: SetScrollInfo user32
WINAPI: CreateFontW GDI32.DLL


: tool-unclosable-window ( parent -- win/0)
  (* ws_caption ws_sizebox *) W: ws_ex_toolwindow
  create-window-with-styles
  DUP IF W: color_3dface syscolor OVER -bgcolor! THEN ;

: win-pos { tab \ [ 4 CELLS ] rect -- x y }
  rect tab -hwnd@ GetWindowRect DROP
  rect @
  rect 1 CELLS@ ;

\ сквозной статичный элемент, не перехватывающий фокуса
: through-control control static (* ss_left ss_sunken ss_ownerdraw *) create-control
transparent OVER -bgcolor! ;

\ установить размер страницы для скроллбара
: set-page-size { page-size ctl \ [ 7 CELLS ] scrollinfo -- } 
7 CELLS scrollinfo !
W: SIF_PAGE scrollinfo CELL+ !
page-size scrollinfo 4 CELLS + !
TRUE scrollinfo W: sb_ctl ctl -hwnd@ SetScrollInfo DROP ;

\ очистить дерево
: tv-del-all-items ( ctl --) W: TVI_ROOT SWAP tv-del ;


\ имя шрифта в уникоде
: create-font-uni ( zname size -- ) pt>devunits
  >R (* default_pitch ff_dontcare *) W: default_quality
  W: clip_default_precis W: out_default_precis W: ansi_charset
  font-attr @ 8 AND  font-attr @ 4 AND  font-attr @ 2 AND 
  font-attr @ 1 AND IF 700 ELSE 400 THEN
  0 0 0 R> CreateFontW
  font-attr 0! ;