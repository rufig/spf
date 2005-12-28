: r>0s>0ab<mn  \ к точке - стабилизация
  2e FTO a 1e FTO b  
  3e FTO m 3e FTO n  
 0.2e FTO r 1e FTO s 
;

: r<0s<0ab=mn  \ к нулю
  1e FTO a 1e FTO b  
  1e FTO m 1e FTO n  
-0.2e FTO r -0.2e FTO s 
;

: r<0s<0ab<mn  \ к нулю
  1e FTO a 1e FTO b  
  4e FTO m 2e FTO n  
-0.2e FTO r -0.2e FTO s 
;

: r<0s<0ab>mn   \ Самый интересный случай - седло
 \ то ли к нулю - затухание гонки вооружений
 \ то ли к бесконечности - эскадация
  4e FTO a 2e FTO b  
  1e FTO m 1e FTO n  
-2e FTO r -0.2e FTO s 
;

\ Одна страна агрессивная другая нет.
: r<0s>0ab<mn  \ Затраты фиксируются на уровне для поддержания status quo
  1e FTO a 1e FTO b  
  2e FTO m 1e FTO n  
  -0.3e FTO r 0.2e FTO s 
;

: r<0s>0ab=mn  \ Безразличное состояние
  2e FTO a 1e FTO b  
  2e FTO m 1e FTO n  
  -0.4e FTO r 0.2e FTO s 
;
