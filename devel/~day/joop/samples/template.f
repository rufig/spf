\ «аготовка дл€ простого Windows приложени€.
\ “о есть практически любое ваше gui приложение должно
\ начинатьс€ с этой заготовки

REQUIRE FrameWindow ~day\joop\win\framewindow.f
REQUIRE Button ~day\joop\win\control.f
REQUIRE Font ~day\joop\win\font.f
\ REQUIRE OpenDialog ~day\joop\win\filedialogs.f
REQUIRE MENUITEM ~day\joop\win\menu.f


CLASS: AppWindow <SUPER FrameWindow

        \ «десь можно описать кнопочки, типа Button OBJ MyButton
        
: :createPopup ( -- hMenu)
   0 \ ¬место 0 вставьте текст-описание всплывающего меню 
;
        
: :createMenu
   0 \ аналогично, но дл€ меню приложени€
;

: :init
   own :init
   \ «десь действи€ перед созданием окна ф-ей CreateWindowEx
;

: :create
  \ «десь действи€ перед созданием окна ф-ей CreateWindowEx
  own :create
  \ «десь создание и инициализаци€ кнопочек etc
;

;CLASS


: RUN { \ w }
   AppWindow :new -> w
   0 w :create
   S" «десь ваш caption" w :setText
   100 50 200 160 w :move
   w :show
   w :run 
   w :free
   BYE
;

HERE IMAGE-BASE - 10000 + TO IMAGE-SIZE \ ¬место 10000 свое значение
' RUN MAINX !
TRUE TO ?GUI
S" yourapp.exe" SAVE BYE
