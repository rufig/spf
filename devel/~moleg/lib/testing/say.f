\ 15-01-2007 ~mOleg
\ отладка кода с помощью анализа отчетов.
\ Пример очень простой реализации.

        0 VALUE standoff \ кол-во отступов от начала экрана
        6 VALUE maxdepth \ максимальное кол-во отображаемых
                         \ эелементов на стеке данных

\ сделать отступ, увеличить значение отступа для следующего имени
: indent> ( --> )
          standoff SPACES TYPE
          standoff 1+ TO standoff ;

\ вернуть значение для отступа назад на одну позицию
: <indent ( --> ) standoff 1- 0 MAX TO standoff ;

\ отобразить содержимое стека данных
\ более maxdepth элементов смысла не имеет
: ~stack SPACE DEPTH maxdepth MIN 0 MAX ." -->  " .SN ;

\ выдать сообщение при входе в слово
: ~about ( asc # --> ) CR indent> ~stack ;

\ сообщение при выходе из слова
: backlv ( --> ) ."  »" <indent ;

\ компилирует диагностический код в начало двоеточного определения
: say ( --> )
      LATEST COUNT
      [COMPILE] 2LITERAL
      POSTPONE ~about ;

\ экстренный выход из определения
: EXIT ( --> ) POSTPONE backlv [COMPILE] EXIT ; IMMEDIATE

\ безымянное определение
: :NONAME ( --> ' )
          :NONAME S" NONAME" [COMPILE] 2LITERAL
          POSTPONE ~about ;

\ дополняем стандартное ';'
: ; ( --> ) POSTPONE backlv [COMPILE] ;  ; IMMEDIATE

\ дополняем стандартное ':'
: : ( --> ) : say ;

\ дальше все происходящее сохраняем в spf.log
STARTLOG

\ какой сюда бы поудачнее пример?
\ samples\bench\bubble.f  MAIN

\ EOF простой пример использования

: simple  ;
: first   ." first" EXIT ." other" ;

: second  IF simple ELSE first THEN ;
: thrid   0 second 1 second ;
:NONAME ." noname sample" ; ->VECT X
: fourth  3 0 DO thrid LOOP ;
: fifth   X 9 7 DO fourth LOOP ;

fifth

